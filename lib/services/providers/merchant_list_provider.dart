import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nostr/nostr.dart';
import 'package:rostr_customer/models/merchant.dart';
import 'package:rostr_customer/services/providers/relay_pool_provider.dart';

final merchantListProvider =
    StateNotifierProvider<MerchantListNotifier, MerchantList>(
  (ref) {
    final merchantList = MerchantListNotifier(ref: ref);
    return merchantList;
  },
);

class MerchantListNotifier extends StateNotifier<MerchantList> {
  final StateNotifierProviderRef ref;
  MerchantListNotifier({required this.ref}) : super(MerchantList()) {
    final streamController = ref.read(relayPoolProvider).controller;
    final stream = streamController.stream;
    stream.listen(
      (message) {
        if (message.messageType == MessageType.event) {
          final event = message.message;

          if (event.kind == 10001) {
            final content = json.decode(event.content);
            final newMerchantList = MerchantList();
            for (final merchantString in content[merchantListKey]) {
              final merchant = Merchant.fromJSON(json.decode(merchantString));
              newMerchantList.upsertMerchant(merchant);
            }

            updateMerchantList(newMerchantList);
          }
        }
      },
    );
  }

  void updateMerchantList(MerchantList newMerchants) {
    for (final merchant in newMerchants.merchantList) {
      state.upsertMerchant(merchant);
    }
    state = state.copyWith();
  }

  void clear() {
    state = MerchantList();
    state = state.copyWith();
  }
}

const String merchantListKey = 'merchantList';
