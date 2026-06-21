import 'dart:convert';
import 'package:http/http.dart' as http;

/// 统一 API 访问层
/// baseUrl 指向后端，根据实际部署地址修改
class ApiService {
  static const String baseUrl = 'http://shanpetcare.vip.cpolar.cn';

  // -------------------------------------------------------------------------
  // 内部辅助
  // -------------------------------------------------------------------------
  static Map<String, String> _headers({String? token}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Token $token';
    return h;
  }

  static dynamic _parse(http.Response res) {
    // 强制按 UTF-8 解码响应体，否则中文会变成 æ–‡å— 这类乱码
    // （http 包的 res.body 在响应头缺 charset 时默认用 Latin-1 解码）
    String decoded;
    try {
      decoded = utf8.decode(res.bodyBytes);
    } catch (_) {
      decoded = res.body;
    }
    try {
      return jsonDecode(decoded);
    } catch (_) {
      return decoded;
    }
  }

  // -------------------------------------------------------------------------
  // 认证
  // -------------------------------------------------------------------------

  /// 注册
  /// body: { username, phone, password, gender?, region? }
  /// 成功返回: { user: {...}, token: '...' }
  static Future<ApiResult> register({
    required String username,
    required String phone,
    required String password,
    String gender = 'unknown',
    String region = '',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/accounts/register/'),
            headers: _headers(),
            body: jsonEncode({
              'username': username,
              'phone': phone,
              'password': password,
              'gender': gender,
              'region': region,
            }),
          )
          .timeout(const Duration(seconds: 15));
      final data = _parse(res);
      if (res.statusCode == 201) {
        return ApiResult.success(data);
      }
      return ApiResult.error(_extractError(data));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// 登录
  /// body: { username (or phone), password }
  /// 成功返回: { user: {...}, token: '...' }
  static Future<ApiResult> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/accounts/login/'),
            headers: _headers(),
            body: jsonEncode({
              'username': identifier,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));
      final data = _parse(res);
      if (res.statusCode == 200) {
        return ApiResult.success(data);
      }
      return ApiResult.error(_extractError(data));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// 退出登录
  static Future<ApiResult> logout({required String token}) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/accounts/logout/'),
            headers: _headers(token: token),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return ApiResult.success(null);
      return ApiResult.error(_extractError(_parse(res)));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// 重置密码（通过手机号）
  /// body: { phone, new_password }
  static Future<ApiResult> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/accounts/reset-password/'),
            headers: _headers(),
            body: jsonEncode({
              'phone': phone,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));
      final data = _parse(res);
      if (res.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(_extractError(data));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  // -------------------------------------------------------------------------
  // 设备
  // -------------------------------------------------------------------------

  /// 获取设备最新一条数据（轻量接口）
  static Future<ApiResult> getDeviceLatest({required String deviceId}) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/device/latest/?device_id=$deviceId'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 10));
      final data = _parse(res);
      if (res.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(_extractError(data));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// 获取设备全部历史数据（备用）
  static Future<ApiResult> getDeviceData({String? deviceId}) async {
    try {
      final url = deviceId != null
          ? '$baseUrl/device/data/?device_id=$deviceId'
          : '$baseUrl/device/data/';
      final res = await http
          .get(Uri.parse(url), headers: _headers())
          .timeout(const Duration(seconds: 15));
      final data = _parse(res);
      if (res.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(_extractError(data));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// 绑定设备（需要登录）
  static Future<ApiResult> bindDevice({
    required String token,
    required String deviceId,
    String deviceName = '',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/device/bind/'),
            headers: _headers(token: token),
            body: jsonEncode({
              'device_id': deviceId,
              'device_name': deviceName,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final data = _parse(res);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return ApiResult.success(data);
      }
      return ApiResult.error(_extractError(data));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// 解绑设备（需要登录）
  static Future<ApiResult> unbindDevice({
    required String token,
    required String deviceId,
  }) async {
    try {
      final req = http.Request('DELETE', Uri.parse('$baseUrl/device/bind/'));
      req.headers.addAll(_headers(token: token));
      req.body = jsonEncode({'device_id': deviceId});
      final streamedRes = await req.send().timeout(const Duration(seconds: 10));
      final res = await http.Response.fromStream(streamedRes);
      if (res.statusCode == 200) return ApiResult.success(null);
      return ApiResult.error(_extractError(_parse(res)));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// 获取主页聚合数据（需登录）
  static Future<ApiResult> getDashboard({required String token}) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/device/dashboard/'),
            headers: _headers(token: token),
          )
          .timeout(const Duration(seconds: 15));
      final data = _parse(res);
      if (res.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(_extractError(data));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// 获取当前用户绑定的所有设备（含最新数据）
  static Future<ApiResult> getMyDevices({required String token}) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/device/mine/'),
            headers: _headers(token: token),
          )
          .timeout(const Duration(seconds: 10));
      final data = _parse(res);
      if (res.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(_extractError(data));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  // -------------------------------------------------------------------------
  // 内部工具
  // -------------------------------------------------------------------------
  static String _extractError(dynamic data) {
    if (data is Map) {
      return (data['detail'] ?? data['error'] ?? data.toString()).toString();
    }
    return data?.toString() ?? 'Unknown error';
  }

  // -------------------------------------------------------------------------
  // 植物图片上传到 MinIO（multipart/form-data）
  // 返回 { "image_url": "http://..." }
  // -------------------------------------------------------------------------
  static Future<ApiResult> uploadPlantImage({
    required String token,
    required String deviceId,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/device/upload-image/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Token $token'
        ..fields['device_id'] = deviceId
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
        ));

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      final data = _parse(res);
      if (res.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(_extractError(data));
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }
}

/// API 调用结果封装
class ApiResult {
  final bool ok;
  final dynamic data;
  final String? error;

  const ApiResult._({required this.ok, this.data, this.error});

  factory ApiResult.success(dynamic data) => ApiResult._(ok: true, data: data);
  factory ApiResult.error(String msg) => ApiResult._(ok: false, error: msg);
}
