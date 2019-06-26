import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkTextSpan extends TextSpan {
  LinkTextSpan({TextStyle style, String url, String text})
      : super(
            style: style,
            text: text ?? url,
            recognizer: TapGestureRecognizer()..onTap = () => launch(url));
}

class RichTextView extends StatelessWidget {
  final String text;
  final TextStyle style;

  const RichTextView({@required this.text, this.style});

  bool _isLink(String input) {
    final matcher = RegExp(
        r"^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$");
    return matcher.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    List<TextSpan> span = [];
    words.forEach((word) {
      span.add(_isLink(word)
          ? LinkTextSpan(
              text: '$word ',
              url: word,
              style: style.copyWith(color: Colors.blue))
          : TextSpan(text: '$word ', style: style));
    });
    if (span.isNotEmpty) {
      return RichText(
        text: TextSpan(text: '', children: span),
      );
    } else {
      return Text(text);
    }
  }
}
