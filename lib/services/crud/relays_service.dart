import 'dart:developer';

import 'package:rostr_customer/models/relay.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

class RelaysService {
  Database? _db;

  Database getDatabaseOrThrow() {
    if (_db == null) {
      throw StateError('Database not opened');
    } else {
      return _db!;
    }
  }

  Future<void> deleteRelay({required String pubkey}) async {
    final db = getDatabaseOrThrow();
    final deletedCount = await db.delete(
      relayTable,
      where: '$pubkeyColumn = ?',
      whereArgs: [pubkey],
    );
    if (deletedCount == 0) {
      log('No relay with pubkey $pubkey found');
    }
  }

  Future<void> upsertRelay({required Relay relay}) async {
    final db = getDatabaseOrThrow();
    final results = await db.query(
      relayTable,
      where: '$pubkeyColumn = ?',
      whereArgs: [relay.pubkey],
    );

    final row = {
      pubkeyColumn: relay.pubkey,
      nameColumn: relay.name,
      urlColumn: relay.url,
      pricingColumn: relay.pricing,
      descriptionColumn: relay.description,
      contactDetailsColumn: relay.contactDetails,
      latitudeColumn: relay.latitude,
      longitudeColumn: relay.longitude,
      locationFormatColumn: relay.locationFormat,
      addedOnColumn: DateTime.now().toIso8601String(),
    };

    if (results.isEmpty) {
      await db.insert(relayTable, row);
    } else {
      await db.update(relayTable, row,
          where: '$pubkeyColumn = ?', whereArgs: [relay.pubkey]);
    }

    await db.insert(relayTable, row);
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      return;
    }

    await db.close();
    _db = null;
  }

  Future<void> open() async {
    if (_db != null) {
      return;
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createRelayTable);
    } catch (e) {
      log('Error opening database: $e');
    }
  }

  Future<DatabaseRelay?> getRelay({required String pubkey}) async {
    final db = getDatabaseOrThrow();
    final results = await db.query(
      relayTable,
      where: '$pubkeyColumn = ?',
      whereArgs: [pubkey],
    );
    if (results.isEmpty) {
      return null;
    }
    return DatabaseRelay.fromRow(results.first);
  }

  Future<RelayList> getRelayList() async {
    final db = getDatabaseOrThrow();
    final dbRelayList = await getAllRelays();
    final relayList = RelayList();
    for (final dbRelay in dbRelayList) {
      relayList.upsertRelay(Relay(
        pubkey: dbRelay.pubkey,
        name: dbRelay.name,
        url: dbRelay.url,
        pricing: dbRelay.pricing,
        description: dbRelay.description,
        contactDetails: dbRelay.contactDetails,
        latitude: dbRelay.latitude,
        longitude: dbRelay.longitude,
        locationFormat: dbRelay.locationFormat,
      ));
    }
    return relayList;
  }

  Future<List<DatabaseRelay>> getAllRelays() async {
    final db = getDatabaseOrThrow();
    final results = await db.query(relayTable);
    return results.map((row) => DatabaseRelay.fromRow(row)).toList();
  }
}

class DatabaseRelay {
  final String pubkey;
  final String name;
  final String url;
  final String pricing;
  final String description;
  final Map<String, dynamic> contactDetails;
  final double latitude;
  final double longitude;
  final Map<dynamic, dynamic> locationFormat;
  late final String addedOn;

  DatabaseRelay({
    required this.pubkey,
    required this.name,
    required this.url,
    required this.pricing,
    required this.description,
    required this.contactDetails,
    required this.latitude,
    required this.longitude,
    required this.locationFormat,
    required this.addedOn,
  }) {
    addedOn = DateTime.now().toIso8601String();
  }

  DatabaseRelay.fromRow(Map<String, Object?> map)
      : pubkey = map[pubkeyColumn] as String,
        name = map[nameColumn] as String,
        url = map[urlColumn] as String,
        pricing = map[pricingColumn] as String,
        description = map[descriptionColumn] as String,
        contactDetails = map[contactDetailsColumn] as Map<String, dynamic>,
        latitude = map[latitudeColumn] as double,
        longitude = map[longitudeColumn] as double,
        locationFormat = map[locationFormatColumn] as Map<dynamic, dynamic>;

  @override
  String toString() => 'Relay: pubkey=$pubkey, name=$name, url=$url, '
      'pricing=$pricing, description=$description, contactDetails=$contactDetails, '
      'latitude=$latitude, longitude=$longitude, locationFormat=$locationFormat, addedOn=$addedOn';

  @override
  bool operator ==(covariant DatabaseRelay other) {
    return pubkey == other.pubkey;
  }

  @override
  int get hashCode => pubkey.hashCode;
}

const dbName = 'customer.db';
const relayTable = 'relays';
const pubkeyColumn = 'pubkey';
const nameColumn = 'name';
const urlColumn = 'url';
const pricingColumn = 'pricing';
const descriptionColumn = 'description';
const contactDetailsColumn = 'contactDetails';
const latitudeColumn = 'latitude';
const longitudeColumn = 'longitude';
const locationFormatColumn = 'locationFormat';
const addedOnColumn = 'addedOn';
const createRelayTable = '''CREATE TABLE IF NOT EXISTS "relays" (
	"pubkey"	TEXT NOT NULL UNIQUE,
	"name"	TEXT NOT NULL,
	"url"	TEXT NOT NULL,
	"pricing"	TEXT NOT NULL,
	"description"	TEXT NOT NULL,
	"contactDetails"	TEXT NOT NULL,
	"latitude"	NUMERIC NOT NULL,
	"longitude"	NUMERIC NOT NULL,
	"locationFormat"	TEXT NOT NULL,
	"addedOn"	TEXT NOT NULL,
	PRIMARY KEY("pubkey")
);
''';
