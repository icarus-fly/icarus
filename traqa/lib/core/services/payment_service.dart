import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static final Razorpay _razorpay = Razorpay();
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static void initialize() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  static void dispose() {
    _razorpay.clear();
  }

  static Future<Map<String, dynamic>> createPaymentOrder({
    required String feature,
    String? memberId,
    String? memberName,
  }) async {
    try {
      final callable = _functions.httpsCallable('createPaymentOrder');
      final result = await callable.call(<String, dynamic>{
        'feature': feature,
        'memberId': memberId,
        'memberName': memberName,
      });

      return result.data;
    } catch (e) {
      print('Error creating payment order: $e');
      rethrow;
    }
  }

  static Future<void> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final callable = _functions.httpsCallable('verifyPayment');
      await callable.call(<String, dynamic>{
        'razorpayPaymentId': paymentId,
        'razorpayOrderId': orderId,
        'razorpaySignature': signature,
      });
    } catch (e) {
      print('Error verifying payment: $e');
      rethrow;
    }
  }

  static Future<void> startPayment({
    required String orderId,
    required int amount,
    required String keyId,
    String description = 'Traqa Health Services',
    Map<String, dynamic>? prefill,
  }) async {
    final options = {
      'key': keyId,
      'amount': amount,
      'name': 'Traqa Health',
      'description': description,
      'order_id': orderId,
      'prefill': {
        'contact': prefill?['phone'] ?? '',
        'email': prefill?['email'] ?? '',
      },
      'theme': {
        'color': '#0066FF',
        'hide_topbar': false,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
      rethrow;
    }
  }

  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment successful: ${response.paymentId}');

    // Verify the payment with backend
    verifyPayment(
      paymentId: response.paymentId!,
      orderId: response.orderId!,
      signature: response.signature!,
    ).then((_) {
      print('Payment verified successfully');
      // TODO: Show success UI and update app state
    }).catchError((error) {
      print('Payment verification failed: $error');
      // TODO: Show error UI
    });
  }

  static void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment failed: ${response.code} - ${response.message}');
    // TODO: Show error UI
  }

  static void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet: ${response.walletName}');
    // TODO: Handle external wallet flow
  }

  static Future<Map<String, dynamic>> getPaymentHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .get();

      return {
        'payments': snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList(),
        'total': snapshot.size,
      };
    } catch (e) {
      print('Error fetching payment history: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};
      final subscription = data['subscription'] ?? {};

      return {
        'familySlots': subscription['familySlots'] ?? 0,
        'familySlotsExpiry': subscription['familySlotsExpiry'],
        'premiumTracking': subscription['premiumTracking'] ?? false,
        'hasActiveSubscription': (subscription['familySlots'] ?? 0) > 0 ||
            (subscription['premiumTracking'] ?? false),
      };
    } catch (e) {
      print('Error fetching subscription status: $e');
      rethrow;
    }
  }
}