import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nostr/nostr.dart';
import 'package:rostr_customer/main.dart';
import 'package:rostr_customer/models/relay.dart';
import 'package:rostr_customer/models/relay_pool.dart';
import 'package:rostr_customer/services/crud/relays_service.dart';
import 'package:rostr_customer/services/providers/relay_list_provider.dart';

final StateNotifierProvider<RelayPoolNotifier, RelayPool> relayPoolProvider =
    StateNotifierProvider<RelayPoolNotifier, RelayPool>((ref) {
  final relayPool = RelayPoolNotifier(relayListInit: ref.watch(initAllRelays));

  final streamController = ref.read(relayPoolProvider).controller;
  final stream = streamController.stream;
  stream.listen((message) {
    if (message.messageType == MessageType.event) {
      final event = message.message;

      if (event.kind == 10001) {
        final content = json.decode(event.content);
        final relayService = RelaysService();
        final newRelayList = RelayList();
        for (final relayString in content[relayListKey]) {
          final relay = Relay.fromJSON(json.decode(relayString));
          newRelayList.upsertRelay(relay);
          relayService.upsertRelay(relay: relay);
        }
        relayPool.updateRelayList(newRelayList);
      }
    }
  });

  return relayPool;
});

class RelayPoolNotifier extends StateNotifier<RelayPool> {
  RelayPoolNotifier({required RelayList relayListInit})
      : super(RelayPool(relayList: relayListInit));

  void updateRelayList(RelayList newRelayList) {
    final currentRelayList = state.relayList;
    for (final relay in newRelayList.relayList) {
      currentRelayList.upsertRelay(relay);
    }
    state.relayList = currentRelayList;
    state = state.copyWith();
  }
}
