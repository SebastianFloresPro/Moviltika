import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class DioClient {
  static final Dio dio = Dio();
  static final CookieJar cookieJar = CookieJar();

  static void init() {
    dio.interceptors.add(CookieManager(cookieJar));
    dio.options.baseUrl = 'https://moviltika-production.up.railway.app/';
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.followRedirects = false;
    dio.options.validateStatus = (status) => status != null && status < 500;
  }
}