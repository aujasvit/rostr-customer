import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nostr/nostr.dart';
import 'package:rostr_customer/models/relay.dart';
import 'package:rostr_customer/services/relay_pool_provider.dart';

final StateNotifierProvider<RelayListNotifier, RelayList> relayListProvider =
    StateNotifierProvider<RelayListNotifier, RelayList>(
  (ref) {
    final relayList = RelayListNotifier();

    final streamController = ref.read(relayPoolProvider).controller;
    final stream = streamController.stream;
    stream.listen(
      (message) {
        if (message.messageType == MessageType.event) {
          final event = message.message;

          if (event.kind == 10001) {
            final content = json.decode(event.content);

            final newRelayList = RelayList();
            for (final relayString in content[relayListKey]) {
              final relay = Relay.fromJSON(json.decode(relayString));
              // TODO add method to geographically check relays
              newRelayList.upsertRelay(relay);
            }

            ref.read(relayPoolProvider.notifier).updateRelayList(newRelayList);
          }
        }
      },
    );
    return relayList;
  },
);

class RelayListNotifier extends StateNotifier<RelayList> {
  RelayListNotifier() : super(RelayList()) {
    // state.upsertRelay(Relay(
    //   url: "ws://192.168.52.55:8001",
    //   name: "name",
    //   latitude: 26.510321,
    //   longitude: 80.230881,
    // ));
  }

  void update(RelayList newRelays) {
    for (final relay in newRelays.relayList) {
      state.upsertRelay(relay);
    }
    state = state.copyWith();
  }
}

const String relayListKey = 'relayList';
