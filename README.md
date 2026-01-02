# flutter_pkg

A Flutter package providing core utilities for network requests, API handling, and other common functionalities.

## Features

- **HTTP Client Wrapper**: built on top of `Dio` with simplified API response handling.
- **API Response Structure**: Standardized `ApiResponse` with `Meta` and `Data`.
- **Authentication Strategies**: Built-in support for Basic Auth, Bearer Token, API Key, and Query Param auth.

## Getting started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_pkg:
    path: /path/to/flutter-pkg
```

## Usage

### HTTP Requests

Use `ApiBase` to make network requests. It automatically handles typical JSON responses.

```dart
import 'package:flutter_pkg/http.dart';

void main() async {
  // 1. Initialize
  var api = ApiBase();
  api.setBaseUrl("https://api.example.com/v1");

  // 2. Set Authentication (Optional)
  var auth = BasicAuth();
  auth.setUsername("myuser");
  auth.setPassword("mypassword");
  api.setAuth(auth);

  // 3. Make Requests
  try {
    // GET Request
    ApiResponse response = await api.get('/users', queryParameters: {'page': 1});
    
    if (response.meta.isSuccess) {
      print("Users: ${response.data}");
    }
    
    // POST Request
    await api.post('/users', data: {
      'name': 'New User',
      'email': 'user@example.com'
    });
    
  } catch (e) {
    print("Error: $e");
  }
}
```

### Response Handling

The package expects a standard response format:

```json
{
  "meta": {
    "success": true,
    "message": "app.success",
    "total": 10
  },
  "data": [ ... ]
}
```

Calls using `ApiBase` return an `ApiResponse<dynamic>` object allowing easy access to `meta` and `data`.

## Additional information

This package is intended for internal use within the CariSoftware ecosystem.
