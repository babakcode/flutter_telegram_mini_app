import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:git_src_currency_prces/config/config.dart';
import 'package:git_src_currency_prces/credential/credential_login_screen.dart';
import 'package:git_src_currency_prces/home/home_screen.dart';
import 'package:git_src_currency_prces/splash/splash_screen.dart';
import 'package:web/web.dart' as web;
import 'dart:js' as js;

class SplashScreenState extends State<SplashScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: '$apiBaseUrl/api/'));

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration(seconds: 2),
      () {
        _initData().then((value) {
          _dio
              .post('tel/validateData', data: jsonEncode({'initData': value}))
              .then((value) async {
            if (value.data['success'] == true) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(token: value.data['token'])));
              return;
            }

            _showErrorDialog();
          });
        }).catchError((e) {
          _showErrorDialog();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Git Source',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Currency Prices',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text('Loading ...'),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _initData() async {
    final winObj = js.JsObject.fromBrowserObject(web.window);
    final webApp = winObj['Telegram']?['WebApp'];

    String? initData = webApp?['initData'] as String?;

    if (initData != null) {
      return initData;
    }

    throw Exception('Empty');
  }

  void _showErrorDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Empty'),
              content: Text('Credential Login ( IO )'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CredentialLoginScreen(),
                          ));
                    },
                    child: Text('Navigate'))
              ],
            ));
  }
}
