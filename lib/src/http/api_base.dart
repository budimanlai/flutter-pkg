import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'api_response.dart';

export 'package:dio/dio.dart' show DioException;

abstract class Auth {
  void apply(Dio dio, RequestOptions options);
}

class BasicAuth implements Auth {
  String? _username;
  String? _password;

  void setUsername(String username) {
    _username = username;
  }

  void setPassword(String password) {
    _password = password;
  }

  @override
  void apply(Dio dio, RequestOptions options) {
    if (_username != null && _password != null) {
      String basicAuth =
          'Basic ${base64Encode(utf8.encode('$_username:$_password'))}';
      options.headers['authorization'] = basicAuth;
    }
  }
}

class JwtAuth implements Auth {
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  @override
  void apply(Dio dio, RequestOptions options) {
    if (_token != null) {
      options.headers['authorization'] = 'Bearer $_token';
    }
  }
}

class ApiKeyAuth implements Auth {
  String? _apiKey;
  String _headerName = 'x-api-key';

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  void setHeaderName(String headerName) {
    _headerName = headerName;
  }

  @override
  void apply(Dio dio, RequestOptions options) {
    if (_apiKey != null) {
      options.headers[_headerName] = _apiKey;
    }
  }
}

class QueryStringAuth implements Auth {
  final Map<String, String> _params = {};

  void setParam(String key, String value) {
    _params[key] = value;
  }

  @override
  void apply(Dio dio, RequestOptions options) {
    options.queryParameters.addAll(_params);
  }
}

class ApiBase {
  late Dio _dio;
  String? _baseUrl;
  Auth? _auth;

  ApiBase({bool debug = false}) {
    _dio = Dio();
    if (debug) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_auth != null) {
          _auth!.apply(_dio, options);
        }
        return handler.next(options);
      },
    ));
  }

  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    _dio.options.baseUrl = baseUrl;
  }

  void setAuth(Auth auth) {
    _auth = auth;
  }

  // Expose underlying Dio if needed
  Dio get dio => _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useApiResponse = true,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response, useApiResponse);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useApiResponse = true,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response, useApiResponse);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> upload(
    String path, {
    required List<File> files,
    required String fileField,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useApiResponse = true,
  }) async {
    try {
      final formData = FormData.fromMap(data ?? {});
      
      for (var file in files) {
         String fileName = file.path.split('/').last;
         formData.files.add(MapEntry(
            fileField,
            await MultipartFile.fromFile(file.path, filename: fileName),
         ));
      }

      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response, useApiResponse);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleResponse(Response response, bool useApiResponse) {
    if (!useApiResponse) {
      return response.data;
    }

    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('meta')) {
       // Automatic casting if possible, otherwise return raw structure wrapped in ApiResponse?
       // Since generic T is not known here, we might return ApiResponse<dynamic>
       return ApiResponse<dynamic>.fromJson(data, (json) => json);
    }
    return data;
  }

  Exception _handleError(DioException e) {
    // Custom error handling logic can be added here
     if (e.response != null) {
       // Try to parse API error response
       try {
         final data = e.response?.data;
         if (data is Map && data.containsKey('meta')) {
            return ApiException(ApiResponse<dynamic>.fromJson(Map<String, dynamic>.from(data), (json) => json));
         }
       } catch (_) {}
     }
    return e;
  }
}

class ApiException implements Exception {
  final ApiResponse response;
  ApiException(this.response);

  @override
  String toString() {
    return response.meta.message ?? 'Unknown Error';
  }
}
