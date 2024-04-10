import 'dart:convert';
import 'dart:developer';

import 'package:fiscal_module_taxi/data/api_client/api_client.dart';
import 'package:fiscal_module_taxi/resource/app_color/app_color.dart';
import 'package:fiscal_module_taxi/resource/app_color/app_style.dart';
import 'package:fiscal_module_taxi/ui/screens/my_app_page/my_app_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:receive_intent/receive_intent.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _apiClient = ApiClient();

  String _bodyTitle = 'Aşteptaţi răspunsul...';

  Map<String, dynamic>? _response;

  Future<void> _setActivityResult(Map<String, dynamic> value) async {
    await ReceiveIntent.setResult(kActivityResultOk,
        data: {'data': jsonEncode(value)}, shouldFinish: true);
  }

  void _startActivity() async {
    try {
      final appModel = context.read<MyAppViewModel>();
      final data = appModel.intent?.extra;
      if (data == null) {
        print('erroare, intentul e null');
        return;
      }
      final result = data['data'];
      final dataSend = jsonDecode(result);
      await Future.delayed(const Duration(seconds: 5));
      _response = {"status": "succes"}; //await _apiClient.postGetTransactionSoap(dataSend);
      if (_response == null) {
        print('erroare, _response e null');
        return;
      } else {
        setState(() {
          _bodyTitle = 'Răspunsul este primit!';
        });
        await _setActivityResult(_response!);
      }
    }catch(e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    _startActivity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
             await _setActivityResult(_response!);
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
              Text(_bodyTitle),
            ],
          ),
        ),
      ),
    );
  }
}
