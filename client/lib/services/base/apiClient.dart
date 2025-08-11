import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:dio/browser.dart'; // For BrowserHttpClientAdapter (web)
// For IOHttpClientAdapter (mobile/desktop)
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wordle/services/base/apiConstants.dart' show ApiConstants;

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    final baseUrl =
        "${dotenv.get('HTTP_PORTOCOL')}://${dotenv.get('HOST')}:${dotenv.get('PORT')}";

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
      ),
    );

    // 添加拦截器用于日志记录
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print(object),
      ),
    );

    if (kIsWeb) {
      _dio.httpClientAdapter = BrowserHttpClientAdapter();
    } else {
      // Mobile/Desktop configuration
      // (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      //   final client = HttpClient();
      //   client.badCertificateCallback = (
      //     X509Certificate cert,
      //     String host,
      //     int port,
      //   ) {
      //     print('🔓 调试模式：忽略证书验证 $host:$port');
      //     return true;
      //   };
      //   return client;
      // };
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: headers != null ? Options(headers: headers) : null,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        options: headers != null ? Options(headers: headers) : null,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path, {Map<String, String>? headers}) async {
    try {
      return await _dio.delete(
        path,
        options: headers != null ? Options(headers: headers) : null,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return Exception('Connection timeout');
        case DioExceptionType.receiveTimeout:
          return Exception('Receive timeout');
        case DioExceptionType.badResponse:
          return Exception('Server error: ${error.response?.statusCode}');
        default:
          return Exception('Network error: ${error.message}');
      }
    }
    return Exception('Unknown error: $error');
  }
}
