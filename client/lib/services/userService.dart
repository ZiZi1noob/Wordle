import 'package:dio/dio.dart';
import 'package:wordle/services/base/apiConstants.dart' show ApiConstants;
import 'package:wordle/models/apiResponseModel.dart' show ApiResModel;
import 'package:wordle/models/userModel.dart' show UserModel;
import 'package:wordle/services/base/apiClient.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  // In your UserService
  Future<ApiResModel<UserModel>> getUserInfo(String name) async {
    final uri = '/api/v1/user/get-info/$name';
    final response = await _apiClient.get(
      uri,
      headers: ApiConstants.formHeaders,
    );

    final apiResponse = ApiResModel<UserModel>.fromJson(
      response.data,
      (data) => UserModel.fromJson(data),
    );

    return apiResponse;
  }
}
