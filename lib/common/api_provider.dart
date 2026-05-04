import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Result of an HTTP call with success flag, parsed JSON when possible, and a user-facing message.
class ApiResponse {
  const ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    required this.rawBody,
    required this.message,
  });

  final bool isSuccess;
  final int statusCode;
  final dynamic data;
  final String rawBody;
  final String message;

  /// True for 2xx responses (typically 200, 201; 204 is success with optional empty body).
  bool get isOk => statusCode >= 200 && statusCode < 300;
}

class ApiProvider {
  ApiProvider._();

  static http.Client _client = http.Client();

  /// Override for testing (inject a mock [http.Client]).
  static void setClient(http.Client client) {
    _client = client;
  }

  /// Optional default headers merged into every request (e.g. `Authorization`).
  static Map<String, String> defaultHeaders = {};

  /// Default timeout when none is passed on a single call.
  static Duration defaultTimeout = const Duration(seconds: 30);

  static Uri _resolveUri(String url, [Map<String, dynamic>? queryParameters]) {
    final base = Uri.parse(url);
    if (queryParameters == null || queryParameters.isEmpty) {
      return base;
    }
    final qp = queryParameters.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
    return base.replace(queryParameters: {...base.queryParameters, ...qp});
  }

  static Map<String, String> _headers({
    Map<String, String>? headers,
    bool sendJsonBody = false,
    String? bearerToken,
  }) {
    final map = <String, String>{
      'Accept': 'application/json',
      if (sendJsonBody) 'Content-Type': 'application/json; charset=utf-8',
      ...defaultHeaders,
      if (bearerToken != null && bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken',
      ...?headers,
    };
    return map;
  }

  static dynamic _tryDecodeJson(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return null;
    }
  }

  static String _messageForSuccess(int code) {
    switch (code) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 202:
        return 'Accepted';
      case 204:
        return 'No content';
      default:
        return 'Success';
    }
  }

  static String _messageForError(
    int code,
    dynamic parsed,
    String rawBody,
  ) {
    if (parsed is Map) {
      final m = Map<String, dynamic>.from(parsed);
      final msg = m['message'] ?? m['error'] ?? m['detail'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join(', ');
    }
    switch (code) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 408:
        return 'Request timeout';
      case 409:
        return 'Conflict';
      case 422:
        return 'Validation error';
      case 429:
        return 'Too many requests';
      case 500:
        return 'Server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      default:
        if (rawBody.isNotEmpty && rawBody.length < 300) return rawBody;
        return 'Request failed ($code)';
    }
  }

  static ApiResponse _fromResponse(http.Response response) {
    final code = response.statusCode;
    final raw = response.body;
    final parsed = _tryDecodeJson(raw);
    final success = code >= 200 && code < 300;
    final message = success ? _messageForSuccess(code) : _messageForError(code, parsed, raw);
    return ApiResponse(
      isSuccess: success,
      statusCode: code,
      data: parsed,
      rawBody: raw,
      message: message,
    );
  }

  static ApiResponse _fromException(Object e) {
    final text = e.toString();
    return ApiResponse(
      isSuccess: false,
      statusCode: 0,
      data: null,
      rawBody: '',
      message: text.replaceFirst('Exception: ', ''),
    );
  }

  static Future<T> _withTimeout<T>(
    Future<T> future,
    Duration? timeout,
  ) {
    final t = timeout ?? defaultTimeout;
    return future.timeout(t, onTimeout: () {
      throw TimeoutException('Connection timed out', t);
    });
  }

  /// GET — pass [queryParameters] for optional query string (?a=1&b=2).
  static Future<ApiResponse> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String? bearerToken,
    Duration? timeout,
  }) async {
    try {
      final uri = _resolveUri(url, queryParameters);
      final res = await _withTimeout(
        _client.get(
          uri,
          headers: _headers(headers: headers, bearerToken: bearerToken),
        ),
        timeout,
      );
      return _fromResponse(res);
    } on TimeoutException catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 408,
        data: null,
        rawBody: '',
        message: e.message ?? 'Request timeout',
      );
    } catch (e) {
      return _fromException(e);
    }
  }

  /// POST — optional JSON [body].
  static Future<ApiResponse> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? bearerToken,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(url);
      final bodyStr = body == null || body.isEmpty ? null : jsonEncode(body);
      final res = await _withTimeout(
        _client.post(
          uri,
          headers: _headers(
            headers: headers,
            sendJsonBody: bodyStr != null,
            bearerToken: bearerToken,
          ),
          body: bodyStr,
        ),
        timeout,
      );
      return _fromResponse(res);
    } on TimeoutException catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 408,
        data: null,
        rawBody: '',
        message: e.message ?? 'Request timeout',
      );
    } catch (e) {
      return _fromException(e);
    }
  }

  /// PUT — optional JSON [body].
  static Future<ApiResponse> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? bearerToken,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(url);
      final bodyStr = body == null || body.isEmpty ? null : jsonEncode(body);
      final res = await _withTimeout(
        _client.put(
          uri,
          headers: _headers(
            headers: headers,
            sendJsonBody: bodyStr != null,
            bearerToken: bearerToken,
          ),
          body: bodyStr,
        ),
        timeout,
      );
      return _fromResponse(res);
    } on TimeoutException catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 408,
        data: null,
        rawBody: '',
        message: e.message ?? 'Request timeout',
      );
    } catch (e) {
      return _fromException(e);
    }
  }

  /// DELETE — optional JSON [body] (some APIs use it).
  static Future<ApiResponse> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? bearerToken,
    Duration? timeout,
  }) async {
    try {
      final uri = _resolveUri(url, queryParameters);
      final bodyStr = body == null || body.isEmpty ? null : jsonEncode(body);
      final res = await _withTimeout(
        _client.delete(
          uri,
          headers: _headers(
            headers: headers,
            sendJsonBody: bodyStr != null,
            bearerToken: bearerToken,
          ),
          body: bodyStr,
        ),
        timeout,
      );
      return _fromResponse(res);
    } on TimeoutException catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 408,
        data: null,
        rawBody: '',
        message: e.message ?? 'Request timeout',
      );
    } catch (e) {
      return _fromException(e);
    }
  }
}
