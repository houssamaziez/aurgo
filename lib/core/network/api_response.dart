class ApiResponse<T> {
  final T? data;
  final String? message;
  final int? statusCode;
  final bool success;

  ApiResponse.success(this.data, {this.statusCode, this.message})
    : success = true;
  ApiResponse.failure({this.message, this.statusCode})
    : data = null,
      success = false;
}
