class Merchant {
  final String pubkey;
  final String name;
  final String description;
  final String pricing;
  final Map<String, dynamic> contactDetails;
  final double latitude;
  final double longitude;

  Merchant({
    required this.pubkey,
    required this.name,
    required this.description,
    required this.pricing,
    required this.contactDetails,
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(covariant Merchant other) {
    return pubkey == other.pubkey;
  }

  @override
  int get hashCode => pubkey.hashCode;

  factory Merchant.fromJSON(Map<String, dynamic> json) {
    return Merchant(
      pubkey: json[pubkeyColumn],
      name: json[nameColumn],
      description: json[descriptionColumn],
      pricing: json[pricingColumn],
      contactDetails: json[contactDetailsColumn],
      latitude: json[latitudeColumn],
      longitude: json[longitudeColumn],
    );
  }
}

class MerchantList {
  List<Merchant> _merchantList = [];
  get merchantList => _merchantList;

  void upsertMerchant(Merchant merchant) {
    if (!merchantList.contains(merchant)) {
      _merchantList.add(merchant);
    } else {
      _merchantList[_merchantList.indexOf(merchant)] = merchant;
    }
  }

  void removeMerchant(Merchant merchant) {
    if (merchantList.contains(merchant)) _merchantList.remove(merchant);
  }

  MerchantList copyWith() {
    final newMerchantList = MerchantList();
    for (final merchant in _merchantList) {
      newMerchantList.upsertMerchant(merchant);
    }
    return newMerchantList;
  }
}

const String pubkeyColumn = 'pubkey';
const String nameColumn = 'name';
const String latitudeColumn = 'latitude';
const String longitudeColumn = 'longitude';
const String descriptionColumn = 'description';
const String pricingColumn = 'pricing';
const String contactDetailsColumn = 'contactDetails';
