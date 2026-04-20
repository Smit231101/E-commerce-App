import 'package:e_commerce_app/core/network/api_client.dart';
import 'package:e_commerce_app/layers/data/models/product_model.dart';

class ProductRepositoryImpl {
  final ApiClient _apiClient;

  ProductRepositoryImpl(this._apiClient);

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _apiClient.get("/products");
      final List<dynamic> data = response.data["products"];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
