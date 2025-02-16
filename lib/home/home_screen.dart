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
    Future.microtask(() async {
      await _dio
          .get('tel/fiat/IRT',
              options: Options(headers: {'api-key': widget.token}))
          .then((res) {
        setState(() {
          fiatList =
              (res.data as List<dynamic>?)?.map((e) => e as Map).toList() ?? [];
        });
      });
      await _dio
          .get('tel/crypto/IRT',
              options: Options(headers: {'api-key': widget.token}))
          .then((res) {
        setState(() {
          cryptoList =
              (res.data as List<dynamic>?)?.map((e) => e as Map).toList() ?? [];
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
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar.medium(
                title: Text('Currency Prices'),
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(tabs: [
                  Tab(text: 'Fiat'),
                  Tab(text: 'Crypto'),
                ]),
              ),
            )
          ],
          body: TabBarView(
            children: [
              Builder(
                builder: (context) => CustomScrollView(
                  slivers: [
                    SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context)),
                    fiatList.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : SliverList.builder(
                            itemCount: fiatList.length,
                            itemBuilder: (context, index) {
                              final fiat = fiatList[index];

                              return ListTile(
                                title: Text(fiat['name']),
                                subtitle: Text(fiat['fa']),
                                trailing: Text(fiat['priceStr']),
                                leading: SvgPicture.network(
                                  fiat['svg'],
                                  height: 30,
                                  width: 30,
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
              Builder(
                builder: (context) => CustomScrollView(
                  slivers: [
                    SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context)),
                    cryptoList.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )

                        /// Display Items:
                        /// [ data ] [ data ]
                        /// Depends on the page width size.
                        : SliverGrid.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  MediaQuery.sizeOf(context).width ~/ 300 + 1,
                            ),
                            itemCount: cryptoList.length,
                            itemBuilder: (context, index) {
                              final crypto = cryptoList[index];

                              return Card(
                                child: Center(
                                  child: SingleChildScrollView(
                                    physics: NeverScrollableScrollPhysics(),
                                    controller: ScrollController(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      spacing: 4,
                                      children: [
                                        Card(
                                          shape: CircleBorder(),
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: Image.network(
                                            crypto['logo'],
                                            height: 36,
                                            width: 36,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Text(
                                          crypto['name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          crypto['fa'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        Text(crypto['priceStr'])
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              /// what we wrote in the tutorial
                              return ListTile(
                                title: Text(crypto['name']),
                                subtitle: Text(crypto['fa']),
                                trailing: Text(crypto['priceStr']),
                                leading: Image.network(
                                  crypto['logo'],
                                  height: 30,
                                  width: 30,
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
