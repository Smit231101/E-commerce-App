import 'package:e_commerce_app/layers/data/datasources/remote/razorpay_service.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckoutViewmodel extends ChangeNotifier {
  final RazorpayService _razorpayService;

  bool _isProccessing = false;
  bool get isProccessing => _isProccessing;

  CheckoutViewmodel(this._razorpayService) {
    _razorpayService.initialize();
  }

  void startPayment({
    required double totalAmount,
    required String email,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    _isProccessing = true;
    notifyListeners();

    _razorpayService.onSuccess = (PaymentSuccessResponse response) {
      _isProccessing = false;
      notifyListeners();
      onSuccess();
    };

    _razorpayService.onFailure = (PaymentFailureResponse response) {
      _isProccessing = false;
      notifyListeners();
      onError(response.message ?? "Payment Failed");
    };

    try {
      _razorpayService.openCheckout(
        amount: totalAmount,
        userEmail: email,
        userContact: "9974366550",
        appName: "LUXE",
      );
    } catch (e) {
      _isProccessing = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }
}
