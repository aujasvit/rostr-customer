import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rostr_customer/models/merchant.dart';
import 'package:rostr_customer/models/relay.dart';
import 'package:rostr_customer/services/crud/relays_service.dart';
import 'package:rostr_customer/services/location_services.dart';
import 'package:rostr_customer/services/providers/merchant_list_provider.dart';
import 'package:rostr_customer/services/providers/relay_pool_provider.dart';
import 'package:rostr_customer/ui/merchant_base_card.dart';
import 'package:rostr_customer/ui/merchant_list_page.dart';

final initAllRelays = Provider<RelayList>((ref) => throw UnimplementedError());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await handleLocationPermission();
  final relaysService = RelaysService();
  await relaysService.open();

  final relayList = await relaysService.getRelayList();

  runApp(ProviderScope(
    overrides: [initAllRelays.overrideWithValue(relayList)],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EagerInitialization(
      child: MaterialApp(
        title: "Rostr Customer",
        home: MerchantListPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final relayList = await relaysService.getRelayList();

    ref.watch(relayPoolProvider);
    ref.watch(merchantListProvider);
    return child;
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Merchant exampleMerchant = Merchant(
      pubkey: 'merchantPubkey',
      name: 'Example Merchant',
      description: 'This is an example merchant for demonstration purposes.',
      pricing: 'Affordable',
      contactDetails: {
        'email': 'merchant@example.com',
        'phone': 9876543210,
      },
      latitude: 40.7128,
      longitude: -74.0060,
    );
    return MerchantBaseCard(merchant: exampleMerchant);
  }
}
