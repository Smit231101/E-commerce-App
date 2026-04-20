import 'package:e_commerce_app/layers/data/models/product_model.dart';
import 'package:e_commerce_app/layers/domain/repositories_impl/product_repository_impl.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final ProductRepositoryImpl _productRepositoryImpl;

  HomeViewModel(this._productRepositoryImpl) {
    fetchProducts();
  }

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<String> get categories {
    if (_products.isEmpty) return [];

    final uniquecategories = _products
        .map((product) => product.category)
        .toSet()
        .toList();
    uniquecategories.sort();

    return ["All", ...uniquecategories];
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fetchedProducts = await _productRepositoryImpl.fetchProducts();
      _products = fetchedProducts;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> getProductsByCategory(String category) {
    if (category == "All") {
      return _products;
    }
    return _products.where((product) => product.category == category).toList();
  }

  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return [];

    final lowerCaseQuery = query.toLowerCase().trim();

    return _products.where((products) {
      final titleMatch = products.title.toLowerCase().contains(lowerCaseQuery);
      final categoryMatch = products.category.toLowerCase().contains(
        lowerCaseQuery,
      );
      return titleMatch || categoryMatch;
    }).toList();       
  }
}
