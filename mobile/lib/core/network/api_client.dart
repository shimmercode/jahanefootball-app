import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, this.timeout = const Duration(seconds: 12)})
      : _http = httpClient ?? http.Client();

  final http.Client _http;
  final Duration timeout;

  Future<dynamic> getJson(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final http.Response response = await _http
          .get(
            Uri.parse(url),
            headers: <String, String>{
              'Accept': 'application/json',
              'User-Agent': 'JahanFootball/${AppEnv.versionName}',
              ...?headers,
            },
          )
          .timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'پاسخ نامعتبر سرور (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }

      if (response.body.isEmpty) {
        throw const ApiException('پاسخ خالی از سرور');
      }

      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const ApiException('زمان اتصال به سرور به پایان رسید', offline: true);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('خطا در ارتباط با شبکه: $error', offline: true);
    }
  }

  String join(String base, String path) {
    final String normalizedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final String normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }
}
