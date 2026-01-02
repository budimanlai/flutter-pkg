
import 'package:flutter_pkg/src/http/api_base.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

// Example of a custom response structure DIFFERENT from ApiResponse
class CustomResponse {
  final String status;
  final dynamic payload;

  CustomResponse({required this.status, this.payload});

  factory CustomResponse.fromJson(Map<String, dynamic> json) {
    return CustomResponse(
      status: json['status'],
      payload: json['payload'],
    );
  }
}

void main() {
  test('Test Custom Response Structure (Non-ApiResponse)', () async {
    // 1. Setup ApiBase
    final api = ApiBase();
    api.setBaseUrl("https://api.custom.com");
    
    // Mocking the server
    final dioAdapter = DioAdapter(dio: api.dio);

    // 2. Define a response that DOES NOT match standard {meta, data} structure
    // Let's say it returns: { "status": "ok", "payload": { ... } }
    dioAdapter.onGet(
      '/custom-endpoint',
      (server) => server.reply(200, {
        "status": "ok",
        "payload": {"id": 999, "info": "Custom Data"}
      }),
    );

    // 3. Call endpoint with `useApiResponse: false`
    // This tells ApiBase NOT to try parsing it into ApiResponse
    final rawData = await api.get('/custom-endpoint', useApiResponse: false);

    print("Raw Data Received: $rawData");

    // 4. Manually parse into our CustomResponse class
    final customResponse = CustomResponse.fromJson(rawData);

    // 5. Verify received data
    expect(customResponse.status, "ok");
    expect(customResponse.payload['id'], 999);
    
    print("Parsed Status: ${customResponse.status}");
    print("Parsed Payload: ${customResponse.payload}");
  });
}
