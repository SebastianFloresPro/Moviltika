import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static String? sessionCookie;

  // Cargar la cookie desde SharedPreferences
  static Future<void> loadCookie() async {
    final prefs = await SharedPreferences.getInstance();
    sessionCookie = prefs.getString('session_cookie');
    print('🔄 Cookie cargada desde disco: $sessionCookie');
  }

  // Guardar la cookie en memoria y en SharedPreferences
  static Future<void> saveCookie(http.Response response) async {
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      final cookies = setCookie.split(';');
      final connectSid = cookies.firstWhere(
        (c) => c.trim().startsWith('connect.sid='),
        orElse: () => '',
      );
      if (connectSid.isNotEmpty) {
        sessionCookie = connectSid.trim();
        print('🍪 Cookie guardada: $sessionCookie');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_cookie', sessionCookie!);
      }
    }
  }

  static Map<String, String> get headers {
    final headers = {'Content-Type': 'application/json'};
    if (sessionCookie != null) {
      headers['cookie'] = sessionCookie!;
    }
    return headers;
  }

  static Future<void> clearCookie() async {
    sessionCookie = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
  }
}