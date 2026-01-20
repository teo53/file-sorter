import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/demo_data_service.dart';
import '../models/subscription_model.dart';

/// 구독 목록 상태
class SubscriptionsState {
  final List<Subscription> subscriptions;
  final bool isLoading;

  const SubscriptionsState({
    this.subscriptions = const [],
    this.isLoading = false,
  });

  SubscriptionsState copyWith({
    List<Subscription>? subscriptions,
    bool? isLoading,
  }) {
    return SubscriptionsState(
      subscriptions: subscriptions ?? this.subscriptions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 구독 목록 Notifier
class SubscriptionsNotifier extends StateNotifier<SubscriptionsState> {
  SubscriptionsNotifier() : super(const SubscriptionsState());

  Future<void> loadSubscriptions() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      subscriptions: DemoDataService.demoSubscriptions,
      isLoading: false,
    );
  }
}

/// Provider
final subscriptionsProvider = StateNotifierProvider<SubscriptionsNotifier, SubscriptionsState>((ref) {
  return SubscriptionsNotifier();
});

/// 활성 구독 Provider
final activeSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  return ref.watch(subscriptionsProvider)
      .subscriptions
      .where((s) => s.isActive)
      .toList();
});
