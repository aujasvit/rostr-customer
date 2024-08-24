import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nostr/nostr.dart';
import 'package:rostr_customer/models/relay.dart';
import 'package:rostr_customer/services/providers/relay_pool_provider.dart';

final StateNotifierProvider<RelayListNotifier, RelayList> relayListProvider =
    StateNotifierProvider<RelayListNotifier, RelayList>(
  (ref) {
    final relayList = RelayListNotifier();

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
