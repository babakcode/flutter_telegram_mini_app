import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:git_src_currency_prces/config/config.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: '$apiBaseUrl/api/'));
  List<Map> fiatList = [], cryptoList = [];

  @override
  void initState() {
    Future.microtask(() async{
      await _dio.get('tel/fiat/IRT',
          options: Options(
              headers: {
                'api-key': widget.token
              }
          )
      ).then((res) {
        setState(() {
          fiatList = (res.data as List<dynamic>?)?.map((e) => e as Map).toList() ?? [];
        });
      });
      await _dio.get('tel/crypto/IRT',
          options: Options(
              headers: {
                'api-key': widget.token
              }
          )
      ).then((res) {
        setState(() {
          cryptoList = (res.data as List<dynamic>?)?.map((e) => e as Map).toList() ?? [];
        });
      });

    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar.large(
              title: Text('Currency Prices'),
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(tabs: [
                Tab(text: 'Fiat'),
                Tab(text: 'Crypto'),
              ]),
            ),
          )
        ], body: TabBarView(children: [
          Builder(builder: (context) => CustomScrollView(
            slivers: [
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),

              fiatList.isEmpty ? SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ): SliverList.builder(
                itemCount: fiatList.length,
                itemBuilder: (context, index) {
                final fiat = fiatList[index];

                return ListTile(
                  title: Text(fiat['name']),
                  subtitle: Text(fiat['fa']),
                  trailing: Text(fiat['priceStr']),
                  leading: SvgPicture.network(fiat['svg'],
                    height: 30,
                    width: 30,
                  ),
                );
              },)
            ],
          )),
          Builder(builder: (context) => CustomScrollView(
            slivers: [
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),

              cryptoList.isEmpty ? SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ): SliverList.builder(
                itemCount: cryptoList.length,
                itemBuilder: (context, index) {
                final fiat = cryptoList[index];

                return ListTile(
                  title: Text(fiat['name']),
                  subtitle: Text(fiat['fa']),
                  trailing: Text(fiat['priceStr']),
                  leading: Image.network(fiat['logo'],
                    height: 30,
                    width: 30,
                  ),
                );
              },)
            ],
          )),
        ])),
      ),
    );
  }
}
