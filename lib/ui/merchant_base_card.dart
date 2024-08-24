import 'package:flutter/material.dart';
import 'package:rostr_customer/models/merchant.dart';
import 'package:rostr_customer/ui/merchant_expanded_card.dart';

// ignore: must_be_immutable
class MerchantBaseCard extends StatelessWidget {
  Merchant merchant;
  MerchantBaseCard({super.key, required this.merchant});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        elevation: 0, // Add elevation for a Material-like shadow
        margin: const EdgeInsetsDirectional.symmetric(
            horizontal: 16.0, vertical: 8.0), // Add margin for some spacing
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Add rounded corners
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Match the border radius\
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05), // Custom shadow color
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes the shadow direction
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width < 430
              ? MediaQuery.of(context).size.width
              : 430,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text(
                    merchant.name,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 42, 42, 42),
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(flex: 1),
                  // Text("IP: ${merchant.IPAddress}",
                  //     style: const TextStyle(fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 8),
                Text("Pricing: ${merchant.pricing}"),
                const SizedBox(height: 8),
                // const Text("Contacts: unavailable",
                //     style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MerchantExpandedCard(merchant: merchant),
          ),
        );
      },
    );
  }
}
