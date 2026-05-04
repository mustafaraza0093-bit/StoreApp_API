import 'package:store_app_api/common/api_constants.dart';
import 'package:store_app_api/common/api_provider.dart';
import 'package:store_app_api/modules/auth/models/user_model.dart';

abstract final class AuthService {
  AuthService._();

  static Future<ApiResponse> login({
    required String email,
    required String password,
  }) {
    return ApiProvider.post(
      ApiConstants.loginPath,
      body: {
        'email': email.trim(),
        'password': password,
      },
    );
  }

  static Future<ApiResponse> fetchProfile({required String accessToken}) {
    return ApiProvider.get(
      ApiConstants.profilePath,
      bearerToken: accessToken,
    );
  }

  /// Returns parsed tokens or null when response shape is unexpected.
  static ({String accessToken, String refreshToken})? tokensFromLoginData(dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    final access = map['access_token'] as String?;
    final refresh = map['refresh_token'] as String?;
    if (access == null || access.isEmpty) return null;
    return (accessToken: access, refreshToken: refresh ?? '');
  }

  static UserModel? userFromProfileData(dynamic data) {
    if (data is! Map) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }
}
