import 'package:wordle/services/base/apiConstants.dart' show ApiConstants;
import 'package:wordle/models/apiResponseModel.dart' show ApiResModel;
import 'base/apiClient.dart';

class GameService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResModel<Map<String, dynamic>>> createNewGame(
    String name,
    String gameId,
  ) async {
    final uri =
        '/api/v1/game/create-game/${Uri.encodeComponent(name)}/${Uri.encodeComponent(gameId)}';

    final response = await _apiClient.post(
      uri,
      headers: ApiConstants.formHeaders,
    );

    // Just pass through the raw response data
    return ApiResModel<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>, // Simple passthrough
    );
  }

  Future<ApiResModel<Map<String, dynamic>>> submitGuess(
    String name,
    String gameId,
    String guess,
  ) async {
    final uri = '/api/v1/game/$name/$gameId/submit-guess';
    final response = await _apiClient.post(
      uri,
      data: {'guess': guess},
      headers: ApiConstants.jsonHeaders,
    );

    return ApiResModel<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }
}
