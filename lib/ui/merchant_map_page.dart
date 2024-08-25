import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:nostr/nostr.dart';
import 'package:rostr_customer/services/location_services.dart';
import 'package:rostr_customer/services/providers/merchant_list_provider.dart';
import 'package:rostr_customer/services/providers/relay_pool_provider.dart';
import 'package:rostr_customer/ui/merchant_expanded_card.dart';
import 'package:rostr_customer/ui/merchant_list_page.dart';

// ignore: must_be_immutable
class MerchantMap extends ConsumerWidget {
  Position currentPosition;
  late AnimatedMapController _mapController;

  MerchantMap({super.key, required this.currentPosition});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _mapController = AnimatedMapController(
        vsync: Scaffold.of(context),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController.mapController,
          options: MapOptions(
            initialCenter:
                LatLng(currentPosition.latitude, currentPosition.longitude),
            initialZoom: 12.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: LatLng(
                      currentPosition.latitude, currentPosition.longitude),
                  radius: 2500,
                  useRadiusInMeter: true,
                  color: Colors.red.withOpacity(0.3),
                  borderColor: Colors.red.withOpacity(0.7),
                  borderStrokeWidth: 2,
                )
              ],
            ),
            MarkerLayer(
              markers: [
                    Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(currentPosition.latitude,
                            currentPosition.longitude),
                        child: Icon(
                          size: 15,
                          Icons.circle_sharp,
                          color: Colors.red.withOpacity(1),
                        ))
                  ] +
                  List<Marker>.from(ref
                      .watch(merchantListProvider)
                      .merchantList
                      .map(
                        (merchant) => Marker(
                          width: 40.0,
                          height: 40.0,
                          point: LatLng(merchant.latitude, merchant.longitude),
                          child: IconButton(
                            icon: const Icon(Icons.location_on),
                            color: Colors.blue,
                            iconSize: 35.0,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (builder) {
                                  return MerchantExpandedCard(
                                      merchant: merchant);
                                },
                              );
                              _mapController.animateTo(
                                dest: LatLng(
                                    merchant.latitude, merchant.longitude),
                                rotation: 0,
                              );
                            },
                          ),
                        ),
                      )
                      .toList()),
            ),
          ],
        ),
        Align(
          heightFactor: 11.6,
          widthFactor: 5.9,
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: () {
              _mapController.animateTo(
                  dest: LatLng(
                    currentPosition.latitude,
                    currentPosition.longitude,
                  ),
                  zoom: 12.5,
                  rotation: 0.0);
            },
            child: const Icon(Icons.my_location),
          ),
        )
      ],
    );
  }
}

class MerchantMapPage extends ConsumerWidget {
  const MerchantMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    return const MerchantListPage();
                  }),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.list),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                // log(ref.read(merchantListProvider).merchantList.toString());
                final relayPool = ref.read(relayPoolProvider);
                final merchantListFilter = Filter(kinds: <int>[10001]);
                ref.read(merchantListProvider.notifier).clear();
                relayPool.connectAndSub(<Filter>[merchantListFilter]);
                // relayGroup.connect().then((value) {
                //   ref.read(merchantListProvider.notifier).clear();
                //   final merchantListFilter = Filter(kinds: <int>[11001]);
                //   relayGroup.sub(<Filter>[merchantListFilter]);
                // });
              },
            ),
          ],
        ),
        body: FutureBuilder<bool>(
          future: handleLocationPermission(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!) {
                return FutureBuilder(
                  future: Geolocator.getCurrentPosition(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return MerchantMap(
                          currentPosition: snapshot.data as Position);
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              } else {
                return const Center(
                  child: Text('Location permission denied',
                      style: TextStyle(
                        fontFamily: 'Brand-Regular',
                        fontSize: 22,
                      )),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
