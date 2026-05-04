import 'package:store_app_api/common/api_constants.dart';
import 'package:store_app_api/common/api_provider.dart';
import 'package:store_app_api/modules/home/model/product_model.dart';

abstract final class HomeService {
  HomeService._();

  static Future<ApiResponse> fetchProducts() {
    return ApiProvider.get(ApiConstants.productsPath);
  }

  static List<ProductModel> parseProducts(dynamic data) {
    if (data is! List) return [];
    return data.map((dynamic e) {
      if (e is Map<String, dynamic>) return ProductModel.fromJson(e);
      return ProductModel.fromJson(Map<String, dynamic>.from(e as Map));
    }).toList();
  }
}
