
import 'package:dio/dio.dart';
import 'package:flutter_pkg/src/http/api_base.dart';
import 'package:flutter_pkg/src/http/api_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('ApiBase Authentication Tests', () {
    late ApiBase apiBase;
    late DioAdapter dioAdapter;

    setUp(() {
      apiBase = ApiBase();
      apiBase.setBaseUrl('https://api.example.com/v1');
      
      // Use dioAdapter to mock requests on the exposed Dio instance
      dioAdapter = DioAdapter(dio: apiBase.dio);
    });

    test('Basic Auth injection', () async {
      final basicAuth = BasicAuth();
      basicAuth.setUsername('user');
      basicAuth.setPassword('pass');
      apiBase.setAuth(basicAuth);

      dioAdapter.onGet(
        '/test-auth',
        (server) => server.reply(200, {'data': 'ok'}),
        headers: {
          'authorization': 'Basic dXNlcjpwYXNz', // user:pass base64 encoded
        },
      );

      final response = await apiBase.get('/test-auth', useApiResponse: false);
      expect(response['data'], 'ok');
    });

    test('JWT Auth injection', () async {
      final jwtAuth = JwtAuth();
      jwtAuth.setToken('my-secret-token');
      apiBase.setAuth(jwtAuth);

      dioAdapter.onGet(
        '/test-jwt',
        (server) => server.reply(200, {'data': 'ok'}),
        headers: {
          'authorization': 'Bearer my-secret-token',
        },
      );

      final response = await apiBase.get('/test-jwt', useApiResponse: false);
      expect(response['data'], 'ok');
    });
    
     test('ApiKey Auth injection', () async {
      final apiKeyAuth = ApiKeyAuth();
      apiKeyAuth.setApiKey('my-api-key');
      apiBase.setAuth(apiKeyAuth);
      // Default header name is x-api-key

      dioAdapter.onGet(
        '/test-api-key',
        (server) => server.reply(200, {'data': 'ok'}),
        headers: {
          'x-api-key': 'my-api-key',
        },
      );

      final response = await apiBase.get('/test-api-key', useApiResponse: false);
      expect(response['data'], 'ok');
    });
  });

  group('ApiBase Response Tests', () {
    late ApiBase apiBase;
    late DioAdapter dioAdapter;

    setUp(() {
      apiBase = ApiBase();
      apiBase.setBaseUrl('https://api.example.com/v1');
      dioAdapter = DioAdapter(dio: apiBase.dio);
    });

    test('GET Returns ApiResponse on success with metadata', () async {
       dioAdapter.onGet(
        '/success',
        (server) => server.reply(200, {
          'meta': {'success': true, 'message': 'Ok'},
          'data': {'id': 1}
        }),
      );

      final result = await apiBase.get('/success');
      expect(result, isA<ApiResponse>());
      expect((result as ApiResponse).meta.message, 'Ok');
      expect((result.data as Map)['id'], 1);
    });

     test('GET Returns raw data when useApiResponse is false', () async {
       dioAdapter.onGet(
        '/raw',
        (server) => server.reply(200, {
          'other': 'structure'
        }),
      );

      final result = await apiBase.get('/raw', useApiResponse: false);
      expect(result['other'], 'structure');
    });
    
    test('POST success', () async {
       dioAdapter.onPost(
        '/create',
        (server) => server.reply(200, {
           'meta': {'success': true},
           'data': null
        }),
        data: {'name': 'new item'}
      );

      final result = await apiBase.post('/create', data: {'name': 'new item'});
      expect(result, isA<ApiResponse>());
      expect((result as ApiResponse).meta.success, true);
    });
  });

   group('ApiBase Error Handling', () {
    late ApiBase apiBase;
    late DioAdapter dioAdapter;

    setUp(() {
      apiBase = ApiBase();
      apiBase.setBaseUrl('https://api.example.com/v1');
      dioAdapter = DioAdapter(dio: apiBase.dio);
    });

    test('Handles 500 error', () async {
       dioAdapter.onGet(
        '/error',
        (server) => server.reply(500, {'error': 'Server Error'}),
      );

      expect(
        () async => await apiBase.get('/error'),
        throwsA(isA<DioException>()),
      );
    });

    test('Parses API Error structure into ApiException', () async {
       dioAdapter.onGet(
        '/api-error',
        (server) => server.reply(400, {
           'meta': {'status': false, 'message': 'Invalid input'},
           'data': null
        }),
      );

      try {
        await apiBase.get('/api-error');
        fail('Should throw');
      } catch (e) {
        expect(e, isA<ApiException>());
        expect(e.toString(), 'Invalid input');
      }
    });
   });
}
