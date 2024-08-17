class Relay {
  final String pubkey;
  final String name;
  final String url;
  final String pricing;
  final String description;
  final Map<String, dynamic> contactDetails;
  final double latitude;
  final double longitude;
  final Map<dynamic, dynamic> locationFormat;

  Relay({
    required this.pubkey,
    required this.name,
    required this.url,
    required this.pricing,
    required this.description,
    required this.contactDetails,
    required this.latitude,
    required this.longitude,
    required this.locationFormat,
  });

  @override
  bool operator ==(covariant Relay other) {
    return pubkey == other.pubkey;
  }

  @override
  int get hashCode => pubkey.hashCode;

  factory Relay.fromJSON(Map<String, dynamic> json) {
    return Relay(
      pubkey: json[pubkeyColumn],
      name: json[nameColumn],
      url: json[urlColumn],
      pricing: json[pricingColumn],
      description: json[descriptionColumn],
      contactDetails: json[contactDetailsColumn],
      latitude: json[latitudeColumn],
      longitude: json[longitudeColumn],
      locationFormat: json[locationFormatColumn],
    );
  }
}

class RelayList {
  List<Relay> _relayList = [];
  get relayList => _relayList;

  void upsertRelay(Relay relay) {
    if (!relayList.contains(relay)) {
      _relayList.add(relay);
    } else {
      _relayList[_relayList.indexOf(relay)] = relay;
    }
  }

  void removeRelay(Relay relay) {
    if (relayList.contains(relay)) _relayList.remove(relay);
  }

  RelayList copyWith() {
    final newRelayList = RelayList();
    for (final relay in _relayList) {
      newRelayList.upsertRelay(relay);
    }
    return newRelayList;
  }
}

const String pubkeyColumn = 'pubkey';
const String nameColumn = 'name';
const String urlColumn = 'url';
const String pricingColumn = 'pricing';
const String descriptionColumn = 'description';
const String contactDetailsColumn = 'contactDetails';
const String latitudeColumn = 'latitude';
const String longitudeColumn = 'longitude';
const String locationFormatColumn = 'locationFormat';
