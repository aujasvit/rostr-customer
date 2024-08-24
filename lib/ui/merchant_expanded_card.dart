import 'package:flutter/material.dart';
import 'package:rostr_customer/models/merchant.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class MerchantExpandedCard extends StatelessWidget {
  Merchant merchant;
  MerchantExpandedCard({super.key, required this.merchant});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Scaffold(
            appBar: AppBar(
              title: Text(merchant.name,
                  style: const TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
            ),
            backgroundColor: Colors.white,
            body: Card(
              elevation: 0,
              margin: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: MediaQuery.of(context).size.width < 430
                    ? MediaQuery.of(context).size.width
                    : 430,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      // children: [
                      //   // Text("IP: ${merchant.IPAddress}",
                      //   //     style: const TextStyle(
                      //   //         fontWeight: FontWeight.bold)),
                      // ]),
                      const SizedBox(height: 8),
                      Text("Pricing: ${merchant.pricing}"),
                      const SizedBox(height: 8),
                      Text("Description: ${merchant.description}"),
                      const Spacer(flex: 1),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(
                              flex: 1,
                            ),
                            InkWell(
                              child: const Icon(Icons.call),
                              onTap: () {
                                launchDialer(
                                    'tel: ${merchant.contactDetails["phone"]}');
                              },
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                          ])
                    ],
                  ),
                ),
              ),
            )));
  }

  launchDialer(String phone) async {
    if (await canLaunchUrl(Uri.parse(phone))) {
      await launchUrl(Uri.parse(phone));
    } else {
      throw 'Could not launch $phone';
    }
  }
}
