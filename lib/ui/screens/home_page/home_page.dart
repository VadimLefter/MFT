import 'dart:convert';
import 'package:fiscal_module_taxi/ui/screens/home_page/home_page_view_model.dart';
import 'package:fiscal_module_taxi/resource/app_color/app_color.dart';
import 'package:fiscal_module_taxi/resource/app_color/app_style.dart';
import 'package:fiscal_module_taxi/ui/screens/my_app_page/my_app_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:receive_intent/receive_intent.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomePageViewModel(),
      child: const _View(),
    );
  }
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {

  @override
  void initState() {
    final appModel = context.read<MyAppViewModel>();
    final homePageModel = context.read<HomePageViewModel>();
    appModel.startActivity().then((_) => homePageModel.updateBodyTitle());
    super.initState();
  }

  Future<void> _setActivityResult(Map<String, dynamic> value) async {
    await ReceiveIntent.setResult(kActivityResultOk,
        data: {'data': jsonEncode(value)}, shouldFinish: true);
  }

  @override
  Widget build(BuildContext context) {
    final homePageModel = context.watch<HomePageViewModel>();
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final closeResult = {
              'status': 'success'
            };
            await _setActivityResult(closeResult);
          },
          child: const Icon(Icons.exit_to_app_sharp),
        ),
        appBar: AppBar(
          title: Text(
            'MFT',
            style: AppStyle.appBarTitle,
          ),
          centerTitle: true,
          backgroundColor: AppColor.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 25.sp),
              Text(homePageModel.bodyTitle),
            ],
          ),
        ),
      );
  }
}
