class ApiConstants {
  // 默认请求头（表单类型）
  static const Map<String, String> formHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': '*/*',
  };

  // JSON请求头
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': '*/*',
  };

  // 文件上传请求头
  static const Map<String, String> multipartHeaders = {
    'Content-Type': 'multipart/form-data',
    'Accept': '*/*',
  };

  // HTTP状态码
  static const int successCode = 200;
  static const String successMessage = 'success';

  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  static const int connectTimeout = 60;
  static const int receiveTimeout = 60;
}
