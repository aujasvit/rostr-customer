import 'dart:async';
import 'dart:developer';
import 'package:nostr/nostr.dart';
import 'package:rostr_customer/models/relay.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class RelayPool {
  RelayList relayList;
  RelayPool({required this.relayList});

  List<WebSocketChannel> _channels = [];

  final Set<Relay> _connectedRelays = {};

  final Map<Relay, WebSocketChannel> _relayToChannel = {};

  StreamController<Message> _controller =
      StreamController<Message>.broadcast(sync: true);
  get controller => _controller;

  Future<void> connectSingleRelay(Relay relay) async {
    if (_connectedRelays.contains(relay)) return;
    try {
      final relayUrl = relay.url;
      final channel = WebSocketChannel.connect(Uri.parse(relayUrl));
      await channel.ready;
      _channels.add(channel);
      _connectedRelays.add(relay);
      _relayToChannel[relay] = channel;
      channel.stream.listen((event) {
        Message message = Message.deserialize(event);
        _controller.add(message);
      }, onDone: () {
        _connectedRelays.remove(relay);
        _channels.remove(channel);
        _relayToChannel.remove(relay);
      }, onError: (error) {
        _connectedRelays.remove(relay);
        _channels.remove(channel);
        _relayToChannel.remove(relay);
      });
    } catch (e) {
      log('Error connecting to relay ${relay.url} $e');
    }
  }

  void subSingleRelay(List<Filter> filters, WebSocketChannel channel) {
    final message = Request(generate64RandomHexChars(), filters);
    if (_channels.contains(channel)) {
      channel.sink.add(message.serialize());
    }
  }

  Future<void> connectAndSub(List<Filter> filter) async {
    for (final relay in relayList.relayList) {
      connectSingleRelay(relay).then(
        (value) {
          if (_connectedRelays.contains(relay) &&
              _relayToChannel.containsKey(relay)) {
            subSingleRelay(filter, _relayToChannel[relay]!);
          }
        },
      );
    }
  }

  void close() {
    for (final channel in _channels) {
      if (channel.closeCode == null) {
        channel.sink.close(status.normalClosure);
      }
    }

    _channels.clear();
    _connectedRelays.clear();
    _relayToChannel.clear();
    _controller.close();
    _controller = StreamController<Message>();
  }

  Set<Relay> get connectedRelays => _connectedRelays;

  RelayPool copyWith() {
    final newRelayGroup = RelayPool(relayList: relayList);
    newRelayGroup._channels = _channels;
    newRelayGroup._connectedRelays.addAll(_connectedRelays);
    newRelayGroup._controller = _controller;
    return newRelayGroup;
  }
}
