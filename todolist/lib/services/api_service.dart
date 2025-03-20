import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://localhost:8000/api"));
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> setToken(String token) async {
    await _storage.write(key: "token", value: token);
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  Future<String> getToken() async {
    String? token = await _storage.read(key: "token");
    return token ?? "";
  }

  Future<void> logout() async {
    await _storage.delete(key: "token");
    _dio.options.headers.remove("Authorization");
  }

  Future<Response> register(String name, String email, String password) async {
    return await _dio.post(
      "/auth/register",
      data: {"name": name, "email": email, "password": password},
    );
  }

  Future<Response> login(String email, String password) async {
    Response response = await _dio.post(
      "/auth/login",
      data: {"email": email, "password": password},
    );

    if (response.statusCode == 200 && response.data["token"] != null) {
      await setToken(response.data["token"]);
    }

    return response;
  }

  Future<Response> getTodos() async {
    String token = await getToken();
    if (token.isEmpty)
      throw Exception("Token tidak ditemukan. Silakan login ulang.");

    _dio.options.headers["Authorization"] = "Bearer $token";

    try {
      return await _dio.get("/services/todos");
    } catch (e) {
      throw Exception("Error fetching todos: $e");
    }
  }

  /*************  ✨ Codeium Command ⭐  *************/
  /// Sends a POST request to add a new todo item with the provided data.
  ///

  /******  487a8890-f4da-45f0-ab40-38b440af705a  *******/
  Future<Response> addTodo(Map<String, dynamic> data) async {
    try {
      return await _dio.post("/services/todos", data: data);
    } catch (e) {
      throw Exception("Error creating todo: $e");
    }
  }

  Future<Response> updateTodo(int id, Map<String, dynamic> data) async {
    try {
      return await _dio.put("/services/todos/$id", data: data);
    } catch (e) {
      throw Exception("Error updating todo: $e");
    }
  }

  Future<Response> deleteTodo(int id) async {
    try {
      return await _dio.delete("/services/todos/$id");
    } catch (e) {
      throw Exception("Error deleting todo: $e");
    }
  }

  Future<Response> getCategories() async {
    try {
      String token = await getToken();
      if (token.isEmpty)
        throw Exception("Token tidak ditemukan. Silakan login ulang.");

      _dio.options.headers["Authorization"] = "Bearer $token";
      return await _dio.get("/services/category");
    } catch (e) {
      throw Exception("Error fetching category: $e");
    }
  }

  Future<Response> addCategories(Map<String, dynamic> data) async {
    try {
      return await _dio.post("/services/category", data: data);
    } catch (e) {
      throw Exception("Error adding category: $e");
    }
  }

  Future<Response> updateCategories(int id, Map<String, dynamic> data) async {
    try {
      return await _dio.put("/services/category/$id", data: data);
    } catch (e) {
      throw Exception("Error updating category: $e");
    }
  }

  Future<Response> deleteCategories(int id) async {
    try {
      return await _dio.delete("/services/category/$id");
    } catch (e) {
      throw Exception("Error deleting category: $e");
    }
  }

  Future<Response> getLabels() async {
    try {
      String token = await getToken();
      if (token.isEmpty)
        throw Exception("Token tidak ditemukan. Silakan login ulang.");

      _dio.options.headers["Authorization"] = "Bearer $token";
      return await _dio.get("/services/label");
    } catch (e) {
      throw Exception("Error fetching label: $e");
    }
  }

  Future<Response> addLabels(Map<String, dynamic> data) async {
    try {
      return await _dio.post("/services/label", data: data);
    } catch (e) {
      throw Exception("Error adding label: $e");
    }
  }

  Future<Response> updateLabels(int id, Map<String, dynamic> data) async {
    try {
      return await _dio.put("/services/label/$id", data: data);
    } catch (e) {
      throw Exception("Error updating label: $e");
    }
  }

  Future<Response> deleteLabels(int id) async {
    try {
      return await _dio.delete("/services/label/$id");
    } catch (e) {
      throw Exception("Error deleting label: $e");
    }
  }
}
