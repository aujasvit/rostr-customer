import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nostr/nostr.dart';
import 'package:rostr_customer/models/merchant.dart';
import 'package:rostr_customer/services/providers/merchant_list_provider.dart';
import 'package:rostr_customer/services/providers/relay_pool_provider.dart';
import 'package:rostr_customer/ui/merchant_base_card.dart';
import 'package:rostr_customer/ui/merchant_map_page.dart';

class MerchantListPage extends ConsumerWidget {
  const MerchantListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantList = ref.watch(merchantListProvider);
    // log(merchantList.merchantList.toString());
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Rostr',
            style: TextStyle(
              fontFamily: 'Brand-Bold',
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const MerchantMapPage();
                  }),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.map),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                // log(ref.read(merchantListProvider).merchantList.toString());
                final relayGroup = ref.read(relayPoolProvider);
                final merchantListFilter = Filter(kinds: <int>[10001]);
                ref.read(merchantListProvider.notifier).clear();
                relayGroup.connectAndSub(<Filter>[merchantListFilter]);
                // relayGroup.connect().then((value) {
                //   ref.read(merchantListProvider.notifier).clear();
                //   final merchantListFilter = Filter(kinds: <int>[11001]);
                //   relayGroup.sub(<Filter>[merchantListFilter]);
                // });
              },
            ),
          ],
        ),
        body: ListView(children: [
          for (Merchant m in merchantList.merchantList)
            MerchantBaseCard(merchant: m),
        ]),
      ),
    );
  }
}
