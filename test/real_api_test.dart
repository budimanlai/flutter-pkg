
import 'package:flutter_pkg/src/http/api_base.dart';
import 'package:flutter_pkg/src/http/api_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Integration Test with Real API', () async {
    // 1. Setup ApiBase
    final api = ApiBase();
    api.setBaseUrl("http://127.0.0.1:8081/api/v1");

    // 2. Setup Auth
    final basicAuth = BasicAuth();
    basicAuth.setUsername("5awzaHszTjyb6OnrbrHkmrLoBZuJs3RM_123");
    basicAuth.setPassword("dk7RjMLdLb3NEazmbcJNepXK8SLpK5aPf4eihI2utCsXx3rQ5YsPV1H9ajaclTwc");
    api.setAuth(basicAuth);

    // 3. Call Endpoint
    print("Calling /region/provinces...");
    try {
      final response = await api.get("/region/provinces?limit=50");

      // 4. Verify Response
      // print("Raw Response Type: ${response.runtimeType}");
      
      if (response is ApiResponse) {
        print("Status: ${response.meta.status}");
        print("Success: ${response.meta.success}");
        print("Message: ${response.meta.message}");
        
        if (response.data != null) {
          print("Data found. Type: ${response.data.runtimeType}");
        //   print("Data: ${response.data}");
          expect(response.meta.isSuccess, true);
        } else {
          print("Data is null");
        }
      } else {
        print("Response is not ApiResponse: $response");
      }
      
    } catch (e) {
      print("Error occurred: $e");
      if (e is ApiException) {
        print("Api Message: ${e.response.meta.message}");
      }
      rethrow;
    }
  });
}
