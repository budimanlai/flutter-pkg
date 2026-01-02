class ApiResponse<T> {
  final Meta meta;
  final T? data;

  ApiResponse({
    required this.meta,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'meta': meta.toJson(),
      'data': data != null ? toJsonT(data!) : null,
    };
  }
}

class Meta {
  final bool? status;
  final bool? success;
  final String? message;
  final int? total;
  final int? totalPage;
  final int? page;
  final int? limit;

  bool get isSuccess => status == true || success == true;

  Meta({
    this.status,
    this.success,
    this.message,
    this.total,
    this.totalPage,
    this.page,
    this.limit,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      status: json['status'] as bool?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      total: json['total'] as int?,
      totalPage: json['total_page'] as int?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (status != null) 'status': status,
      if (success != null) 'success': success,
      if (message != null) 'message': message,
      if (total != null) 'total': total,
      if (totalPage != null) 'total_page': totalPage,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
  }
}
