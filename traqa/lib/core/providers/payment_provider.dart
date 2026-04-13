import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final paymentHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('payments')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
});

final subscriptionStatusProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value({});

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
        final data = snapshot.data() ?? {};
        final subscription = data['subscription'] ?? {};

        return {
          'familySlots': subscription['familySlots'] ?? 0,
          'familySlotsExpiry': subscription['familySlotsExpiry'],
          'premiumTracking': subscription['premiumTracking'] ?? false,
          'hasActiveSubscription': (subscription['familySlots'] ?? 0) > 0 ||
              (subscription['premiumTracking'] ?? false),
        };
      });
});

class PaymentState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? lastPayment;

  PaymentState({
    this.isLoading = false,
    this.error,
    this.lastPayment,
  });

  PaymentState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? lastPayment,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastPayment: lastPayment ?? this.lastPayment,
    );
  }
}

final paymentStateProvider = StateNotifierProvider<PaymentStateNotifier, PaymentState>((ref) {
  return PaymentStateNotifier();
});

class PaymentStateNotifier extends StateNotifier<PaymentState> {
  PaymentStateNotifier() : super(PaymentState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void setSuccess(Map<String, dynamic> paymentData) {
    state = state.copyWith(
      lastPayment: paymentData,
      isLoading: false,
      error: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearState() {
    state = PaymentState();
  }
}