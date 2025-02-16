import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:html';
import 'dart:js' as js;
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  final Dio _dio = Dio(
      BaseOptions(
          baseUrl: 'http://localhost:8000/api/'
      )
  );

  List<Map> fiatList = [];

  @override
  void initState() {
    super.initState();

    _initData().then((value) {
      print(value);
      _dio.post('tel/validateData',
          data: jsonEncode({
            'initData': 'user=%7B%22id%22%3A32C%22first_name%22%3A%22BabakTest%22%2C%22last_name%22%3A%22Gahremanzadeh%22%2C%22username%22%3A%22BabakCode%22%2C%22language_code%21000032%2%3A%22en%22%2C%22allows_write_to_pm%22%3Atrue%7D&chat_instance=338584334934182876&chat_type=sender&auth_date=1726927328&hash=0ab351eb85d118a608cf3b3ce6ac24220b4d4edaca3ca88fc2359e6cf107ab6c'
          })).then((value) async {

        final res = await _dio.get('tel/fiat/IRT',
            options: Options(
                headers: {
                  'api-key': value.data['token']
                }
            )
        ).then((res) {
          print(value);
          setState(() {
            fiatList = (res.data as List<dynamic>?)?.map((e) => e as Map).toList() ?? [];
          });
        });


      });
    }).catchError((e) {
      _dio.post('tel/validateData',
          data: jsonEncode({
            'initData': 'user=%7B%22id%22%3A32C%22first_name%22%3A%22BabakTest%22%2C%22last_name%22%3A%22Gahremanzadeh%22%2C%22username%22%3A%22BabakCode%22%2C%22language_code%21000032%2%3A%22en%22%2C%22allows_write_to_pm%22%3Atrue%7D&chat_instance=338584334934182876&chat_type=sender&auth_date=1726927328&hash=0ab351eb85d118a608cf3b3ce6ac24220b4d4edaca3ca88fc2359e6cf107ab6c'
          })).then((value) => print(value.data),).catchError((e) {
        print(e);
      });
      // showDialog(context: context, builder: builder)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Currency data"),
        ),
        body: fiatList.isNotEmpty ? ListView.builder(itemBuilder: (context, index) {
          final fiat = fiatList[index];

          return ListTile(
            title: Text(fiat['name']),
            subtitle: Text(fiat['fa']),
            trailing: Text(fiat['priceStr']),
          );
        },) : Center(child: CircularProgressIndicator())
    );
  }

  Future<String> _initData() async {

    final winObj = js.JsObject.fromBrowserObject(window);
    final webApp = winObj['Telegram']?['WebApp'];

    String? initData = webApp?['initData'] as String?;

    if(initData != null){
      return initData;
    }

    throw Exception('Empty');
  }
}
