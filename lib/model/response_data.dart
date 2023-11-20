class ResponseData<T> {
  final int? code;
  final String? message;
  final bool success;
  final T? result;

  const ResponseData({this.code, this.message, this.success = false, this.result});

  const ResponseData.error(this.code, this.message)
      : success = false,
        result = null;

  const ResponseData.success(this.result)
      : success = true,
        code = null,
        message = null;
}
