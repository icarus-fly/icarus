class PaymentService {
  static void initialize() {
    // Mock initialization for preview version
    print('Payment service initialized (mock)');
  }

  static Future<bool> processPayment(double amount) async {
    // Mock payment processing for preview
    await Future.delayed(const Duration(seconds: 2));
    return true; // Always successful in preview
  }
}