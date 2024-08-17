import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rostr_customer/models/relay.dart';
import 'package:rostr_customer/models/relay_pool.dart';
import 'package:rostr_customer/services/relay_list_provider.dart';

final StateNotifierProvider<RelayPoolNotifier, RelayPool> relayPoolProvider =
    StateNotifierProvider<RelayPoolNotifier, RelayPool>((ref) {
  final relayPool =
      RelayPoolNotifier(relayListInit: ref.read(relayListProvider));
  ref.listen(
    relayListProvider,
    (previous, next) {
      relayPool.updateRelayList(next);
    },
  );

  return relayPool;
});

class RelayPoolNotifier extends StateNotifier<RelayPool> {
  RelayPoolNotifier({required RelayList relayListInit})
      : super(RelayPool(relayList: relayListInit));

  void updateRelayList(RelayList relayList) {
    state.relayList = relayList;
  }
}
