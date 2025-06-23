import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const _url = 'https://fakestoreapi.com/products';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil produk');
  }
}
