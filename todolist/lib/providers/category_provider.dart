import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  final ApiService _apiService = ApiService();

  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.getCategories();

      if (response.data is List) {
        _categories =
            (response.data as List)
                .map((json) => Category.fromJson(json))
                .toList();
      } else {
        print("Unexpected response format: ${response.data}");
        throw Exception("Invalid response format");
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

 Future<void> addCategory(Map<String, dynamic> data) async {
  try {
    print("📨 Data yang dikirim: $data");
    final response = await _apiService.addCategories(data);
    print("📥 Response status: ${response.statusCode}");
    print("📥 Response body: ${response.data}");

    if (response.statusCode == 201) {
      _categories.add(Category.fromJson(response.data['data']));
      print("✅ Category berhasil ditambahkan.");
      notifyListeners();
    } else {
      print("❌ Error: Format response tidak sesuai atau status code bukan 201.");
    }
  } catch (e) {
    print("❌ Error adding category: $e");
  }
}


  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      // Konversi id ke int
      final int categoryId = int.tryParse(id) ?? -1;

      if (categoryId == -1) {
        print("⚠ Error: Invalid category ID");
        return;
      }

      print("🔄 Mengirim request update kategori: $data");

      // Kirim request update ke API
      final response = await _apiService.updateCategories(categoryId, data);

      if (response.statusCode == 200 && response.data != null) {
        int index = _categories.indexWhere(
          (category) => category.id == categoryId,
        );

        if (index != -1) {
          // Debugging untuk melihat perubahan
          print("✅ Data sebelum update: ${_categories[index]}");
          print("✅ Data dari API: ${response.data}");

          // Jika response kosong, gunakan data input sebagai fallback
          String newTitle = response.data['title'] ?? data['title'];

          _categories[index] = Category(id: categoryId, title: newTitle);

          print("✅ Data setelah update: ${_categories[index]}");
          notifyListeners(); // Memperbarui UI
        }
      } else {
        print("⚠ Failed to update category. Response: ${response.data}");
      }
    } catch (e) {
      print("❌ Error updating category: $e");
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final response = await _apiService.deleteCategories(id as int);
      if (response.statusCode == 200) {
        _categories.removeWhere((category) => category.id == id);
        notifyListeners();
      }
    } catch (e) {
      print("Error deleting category: $e");
    }
  }
}