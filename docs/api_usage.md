# API Client Documentation

This package provides a robust API client `ApiBase` and a standardized response structure `ApiResponse` to simplify HTTP interactions.

## Table of Contents
- [Setup](#setup)
- [Authentication](#authentication)
- [Making Requests](#making-requests)
  - [GET](#get)
  - [POST](#post)
  - [Upload](#upload)
  - [Download](#download)
- [Response Handling](#response-handling)
- [Error Handling](#error-handling)

## Setup

Initialize the `ApiBase` with your base URL.

```dart
import 'package:flutter_pkg/src/http/api_base.dart';

final api = ApiBase(debug: true); // Enable debug logging
api.setBaseUrl("https://api.example.com/v1");
```

## Authentication

The client supports modular authentication strategies. You can set the authentication method using `setAuth`.

### Basic Auth

```dart
var basicAuth = BasicAuth();
basicAuth.setUsername("myuser");
basicAuth.setPassword("mypassword");

api.setAuth(basicAuth);
```

### JWT (Bearer Token)

```dart
var jwtAuth = JwtAuth();
jwtAuth.setToken("eyJhbGciOiJIUzI1Ni...");

api.setAuth(jwtAuth);
```

### API Key

By default, this uses the `x-api-key` header. You can customize the header name.

```dart
var apiKeyAuth = ApiKeyAuth();
apiKeyAuth.setApiKey("my-secret-api-key");
// Optional: change header name
// apiKeyAuth.setHeaderName("X-Custom-Key");

api.setAuth(apiKeyAuth);
```

### Query String

Adds parameters to every request URL.

```dart
var queryAuth = QueryStringAuth();
queryAuth.setParam("access_token", "12345");

api.setAuth(queryAuth);
```

## Making Requests

### GET

Retrieve data from the server.

```dart
try {
  // Returns generic ApiResponse
  ApiResponse response = await api.get("/users");
  
  // Access data
  print(response.meta.message);
  print(response.data);
} catch (e) {
  print(e);
}
```

### POST

Send data to the server.

```dart
var params = {
  "name": "New Item",
  "price": 100
};

try {
  ApiResponse response = await api.post("/items", data: params);
  if (response.meta.isSuccess) {
    print("Item created!");
  }
} catch (e) {
  print(e);
}
```

### Upload

Upload files using `MultipartFile`.

```dart
import 'dart:io';

File image = File('/path/to/image.jpg');

try {
  ApiResponse response = await api.upload(
    "/upload/profile",
    files: [image],
    fileField: "avatar", // Form field name for the file
    data: {"user_id": 123}, // Additional fields
  );
} catch (e) {
  print("Upload failed: $e");
}
```

### Download

Download a file to a local path.

```dart
try {
  await api.download(
    "/files/report.pdf",
    "/local/path/report.pdf",
  );
  print("Download complete");
} catch (e) {
  print("Download failed");
}
```

## Response Handling

The `ApiResponse<T>` class provides a structured way to handle API responses.

```dart
class ApiResponse<T> {
  final Meta meta;
  final T? data;
  // ...
}

class Meta {
  final bool? status;    // or success
  final String? message;
  final int? total;      // Pagination info
  // ...
  
  bool get isSuccess;    // Helper to check status/success
}
```

### specific Type Parsing

You can cast the response data if you know the structure.

```dart
// Explicitly casting response
final response = await api.get("/users") as ApiResponse;

// Or when parsing manually if not using the default automatic wrapping
final json = ...;
final response = ApiResponse<User>.fromJson(json, (data) => User.fromJson(data));
```

## Error Handling

The client wraps 4xx and 5xx errors. If the server returns a structured error response (matching `ApiResponse`), it will be thrown as an `ApiException`.

```dart
try {
  await api.get("/invalid-endpoint");
} on ApiException catch (e) {
  // Server returned a structured error (e.g. 400 Bad Request with message)
  print("API Error: ${e.response.meta.message}");
} on DioException catch (e) {
  // Network connection error, timeout, or unstructured server error
  print("Network Error: ${e.message}");
}
```
