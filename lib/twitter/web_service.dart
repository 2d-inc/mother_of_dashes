import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart';

/// A callback for status code occurences.
typedef void StatusCodeHandler(http.Response response);

/// Web Service class to help facilitate making requests that have some form
/// of state maintained in cookies.
class WebService {
  final Map<String, String> headers = {"content-type": "text/json"};
  final Map<String, String> cookies = {};
  final Map<int, List<StatusCodeHandler>> statusCodeHandlers = {};

  /// We use this timer to schedule saving cookies locally.
  Timer _persistTimer;

  /// Encrypter we use to read/write the local session storage.
  static final _encrypter =
      Encrypter(AES(Key.fromUtf8('}Mk#33zm^PiiP9C2riMozVynojddVc6/')));
  Directory _dataDirectory;

  void addStatusCodeHandler(int code, StatusCodeHandler handler) {
    List<StatusCodeHandler> handlers = statusCodeHandlers[code];
    handlers ??= [];
    handlers.add(handler);
    statusCodeHandlers[code] = handlers;
  }

  bool removeStatusCodeHandler(int code, StatusCodeHandler handler) =>
      statusCodeHandlers[code]?.remove(handler) ?? false;

  void _processResponse(http.Response response) {
    // Update cookies.
    String allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      var changed = false;
      for (final setCookie in setCookies) {
        if (_setCookiesFromString(setCookie)) {
          changed = true;
        }
      }

      if (changed) {
        _persistTimer?.cancel();
        _persistTimer = Timer(Duration(seconds: 2), persist);
      }

      headers['cookie'] = _generateCookieHeader();
    }

    // Call status code handlers.
    statusCodeHandlers[response.statusCode]?.forEach((f) => f.call(response));
  }

  bool _setCookiesFromString(String cookieString) {
    var changed = false;
    var cookies = cookieString.split(';');
    for (final cookie in cookies) {
      if (_setCookie(cookie)) {
        changed = true;
      }
    }
    return changed;
  }

  bool _setCookie(String rawCookie) {
    if (rawCookie.isNotEmpty) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return false;

        var lastValue = cookies[key];
        if (lastValue != value) {
          cookies[key] = value;
          return true;
        }
      }
    }
    return false;
  }

  String _generateCookieHeader() {
    StringBuffer cookie = StringBuffer();

    for (final key in cookies.keys) {
      if (cookie.isNotEmpty) cookie.write(';');
      cookie.write(key);
      cookie.write('=');
      cookie.write(cookies[key]);
    }
    return cookie.toString();
  }

  Future<http.Response> get(String url) async {
    var response = await http.get(url, headers: headers);

    _processResponse(response);

    return response;
  }

  Future<http.Response> post(String url,
      {dynamic body, Encoding encoding}) async {
    var response =
        await http.post(url, body: body, headers: headers, encoding: encoding);

    _processResponse(response);
    return response;
  }

  Future<bool> initialize(Directory directory) async {
    _dataDirectory = directory;
    var file = File('${directory.path}/service');
    if (!await file.exists()) {
      return false;
    }

    var contents = await file.readAsBytes();
    var iv = IV.fromLength(16);
    var decrypted =
        _encrypter.decrypt(Encrypted(Uint8List.fromList(contents)), iv: iv);
    if (decrypted == null) {
      return false;
    }
    _setCookiesFromString(decrypted);
    headers['cookie'] = _generateCookieHeader();

    return true;
  }

  void persist() {
    var file = File('${_dataDirectory.path}/service');

    var iv = IV.fromLength(16);
    var encrypted = _encrypter.encrypt(_generateCookieHeader(), iv: iv);

    file.writeAsBytesSync(encrypted.bytes);
  }
}
