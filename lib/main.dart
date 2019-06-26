import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'rich_text_view.dart';
import 'twitter/mother_of_dashes_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mother of Dashes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Mother of Dashes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MotherOfDashesService _service = MotherOfDashesService();
  Tweet _tweet;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service.randomTweet().then((tweet) {
      setState(() {
        _tweet = tweet;
      });
    });
  }

  void _refresh() {
    setState(() {
      _isLoading = true;
      _service.randomTweet().then((tweet) {
        setState(() {
          _isLoading = false;
          _tweet = tweet;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var devicePadding = MediaQuery.of(context).padding;
    return Scaffold(
      body: Container(
        constraints: BoxConstraints(
            minWidth: double.infinity, minHeight: double.infinity),
        color: const Color.fromRGBO(200, 200, 200, 1.0),
        child: Column(
          children: [
            Expanded(
              child: FlareActor('assets/Mother of Dashes.flr',
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.contain,
                  boundsNode: 'focus',
                  animation: 'Untitled'),
            ),
            GestureDetector(
              onTap: () {
                if (_tweet != null) {
                  launch(_tweet.url);
                }
              },
              child: Container(
                constraints: BoxConstraints(minWidth: double.infinity),
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mother of Dashes',
                      style: TextStyle(
                        fontFamily: 'RobotoBold',
                        fontSize: 32,
                        color: const Color.fromARGB(255, 79, 72, 90),
                      ),
                    ),
                    const SizedBox(height: 13),
                    RichTextView(
                      text: _tweet?.text ?? "...",
                      style: TextStyle(
                          fontFamily: 'RobotoRegular',
                          fontSize: 20,
                          height: 1.1,
                          color: const Color.fromARGB(255, 79, 72, 90)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '@' + (_tweet?.author ?? "..."),
                      style: TextStyle(
                        fontFamily: 'RobotoBlack',
                        fontSize: 16,
                        color: const Color.fromARGB(255, 79, 72, 90),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      constraints: BoxConstraints(minWidth: double.infinity),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 78, 72, 96),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          onTap: _isLoading ? null : _refresh,
                          child: Container(
                            constraints:
                                BoxConstraints(minWidth: double.infinity),
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                _isLoading ? 'Loading...' : 'Refresh!',
                                style: TextStyle(
                                    fontFamily: 'RobotoBold',
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: devicePadding.bottom)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
