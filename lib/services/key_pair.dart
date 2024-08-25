import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nostr/nostr.dart';

class KeyPairService {
  final _storage = FlutterSecureStorage();

  Future<String> generateAndStoreKeyPair() async {
    // Check if the keys are already stored
    String? privateKeyString = await _storage.read(key: 'private_key');

    if (privateKeyString == null) {
      // Generate the key pair
      final keyPair = Keychain.generate();

      // Store the keys securely
      privateKeyString = keyPair.private;

      await _storage.write(key: 'private_key', value: privateKeyString);

      log('Keys generated and stored');
    }

    return privateKeyString;
  }

  Future<Keychain> getPrivateKey() async {
    String? privateKeyString = await _storage.read(key: 'private_key');
    privateKeyString ??= await generateAndStoreKeyPair();
    return Keychain(privateKeyString);
  }
}
