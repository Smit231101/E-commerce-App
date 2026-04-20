import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  Razorpay? _razorpay;

  // We use callbacks so our ViewModel knows when the payment finishes
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;
  Function(ExternalWalletResponse)? onExternalWallet;

  void initialize() {
    if (_razorpay != null) {
      return;
    }

    final razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _razorpay = razorpay;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess?.call(response);
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    onFailure?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onExternalWallet?.call(response);
  }

  void openCheckout({
    required double amount,
    required String userEmail,
    required String userContact,
    required String appName,
  }) {
    final razorpay = _razorpay;
    if (razorpay == null) {
      throw Exception('Razorpay is not initialized.');
    }

    final int amountInPaise = (amount * 100).toInt();

    final options = {
      'key': 'rzp_test_SfoLMZNBAgCHEz',
      'amount': amountInPaise,
      'name': appName,
      'description': 'Order Checkout',
      'prefill': {'contact': userContact, 'email': userEmail},
      'theme': {'color': '#1A1A1A'},
    };
    try {
      razorpay.open(options);
    } catch (e) {
      throw Exception('Error opening Razorpay: $e');
    }
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
