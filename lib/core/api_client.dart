import 'package:dio/dio.dart';
import 'api_config.dart';
import '../data/auth_storage.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  )..interceptors.add(
    InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    }),
  );
}


// কাজ হলো:
//
// একটি Dio HTTP client তৈরি করা।
//
// base URL, timeout, এবং default headers সেট করা।
//
// প্রতিটি request-এর আগে স্বয়ংক্রিয়ভাবে Authorization token attach করা।