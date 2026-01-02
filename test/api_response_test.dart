
import 'package:flutter_pkg/src/http/api_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponse Tests', () {
    test('Response Success Parsing', () {
      final json = {
        "meta": {
          "status": true,
          "message": "Success",
        },
        "data": {"id": 1, "name": "Item"}
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(response.meta.status, true);
      expect(response.meta.isSuccess, true);
      expect(response.meta.message, "Success");
      expect(response.data , isNotNull);
      expect(response.data!['id'], 1);
    });

    test('Response Error Parsing', () {
      final json = {
        "meta": {
          "status": false,
          "message": "Error occurred",
        },
        "data": null
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(response.meta.status, false);
      expect(response.meta.isSuccess, false);
      expect(response.meta.message, "Error occurred");
      expect(response.data, isNull);
    });

    test('Response List Parsing', () {
      final json = {
        "meta": {
          "success": true,
          "message": "List retrieved",
          "total": 100,
          "total_page": 10,
          "page": 1,
          "limit": 10,
        },
        "data": [
          {"id": 1, "name": "Item 1"},
          {"id": 2, "name": "Item 2"}
        ]
      };

      final response = ApiResponse<List<dynamic>>.fromJson(
        json,
        (data) => data as List<dynamic>,
      );

      expect(response.meta.success, true);
      expect(response.meta.isSuccess, true);
      expect(response.meta.total, 100);
      expect(response.meta.totalPage, 10);
      expect(response.data, isNotNull);
      expect(response.data!.length, 2);
    });
  });
}
