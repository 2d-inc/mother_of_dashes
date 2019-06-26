import 'dart:convert';
import 'dart:io';
import 'data_directory.dart';
import 'web_service.dart';

class Tweet {
  final String text;
  final String author;
  final String url;

  Tweet(Map<String, dynamic> data)
      : text = data['text']?.toString(),
        author = extractScreenName(data),
		url = 'https://twitter.com/${extractScreenName(data)}/status/${data["id_str"]}';

  static String extractScreenName(Map<String, dynamic> data) {
    dynamic user = data['user'];
    if (user is Map<String, dynamic>) {
      return user['screen_name']?.toString();
    }
    return null;
  }
}

class MotherOfDashesService {
  final String host =
      'https://hiixh4lyvc.execute-api.us-east-1.amazonaws.com/default/mother_of_dashes';
  static const _dataDirName = 'mother_of_dashes';

  final WebService service;
  Directory _dataDirectory;

  MotherOfDashesService() : service = WebService() {
    dataDirectory(_dataDirName).then((directory) async {
      if (!await directory.exists()) {
        directory = await directory.create();
      }
      _dataDirectory = directory;
      if (await service.initialize(_dataDirectory)) {
        // Load user data.
      } else {}
    });
  }

  Future<Tweet> randomTweet() async {
    var response = await service.get(host);
    if (response.statusCode == 200) {
      Map<String, dynamic> data;
      try {
        String body = utf8.decode(response.bodyBytes);
        data = json.decode(body) as Map<String, dynamic>;
      } on FormatException catch (_) {
        return null;
      }
      if (data is Map<String, dynamic>) {
        return Tweet(data);
      }
    }
    return null;
  }
}
