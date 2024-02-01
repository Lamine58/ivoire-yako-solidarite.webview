import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IYS UK',
      home: MySplashScreen(),
    );
  }
}

class MySplashScreen extends StatefulWidget {
  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/IMG_5369.PNG',
          width: 200.0,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController _controller = WebViewController();
  bool _isConnected = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              print("====================================");
              print(error);
              print("====================================");
              setState(() {
                _isLoading = false;
              });
            },
            // onNavigationRequest: (NavigationRequest request) {
            //   // if (request.url.startsWith('https://iys-uk.org/')) {
            //   //   return NavigationDecision.prevent;
            //   // }
            //   return NavigationDecision.navigate;
            // },
          ),
        )
        ..loadRequest(Uri.parse('https://iys-uk.org/'));
        _isConnected = (result != ConnectivityResult.none);
      });
    });
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = (connectivityResult != ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        elevation: 0,
        backgroundColor: Color(0xff034803),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back,color:Colors.white),
            onPressed: () async {
              // Go to the previous page
              if (await _controller.canGoBack()) {
                _controller.goBack();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward,color:Colors.white),
            onPressed: () async {
              // Go to the next page
              if (await _controller.canGoForward()) {
                _controller.goForward();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh,color:Colors.white),
            onPressed: () {
              // Refresh the WebView
              _controller.reload()
              ;
            },
          ),
        ],
      ),
      body: _isConnected
          ? Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Container(
                    color: Color.fromARGB(108, 255, 255, 255),
                    height: MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff034803),
                      ),
                    ),
                  ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/no-connection_7733524.png',
                      width: 120),
                  SizedBox(height: 30),
                  Text('Pas de connexion Internet'),
                ],
              ),
            ),
    );
  }
}
