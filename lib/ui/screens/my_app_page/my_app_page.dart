import 'package:fiscal_module_taxi/ui/screens/my_app_page/my_app_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:receive_intent/receive_intent.dart%20' as intent;

import '../home_page/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static Widget create(intent.Intent? intent) {
    return Provider(
      create: (context) => MyAppViewModel(intent),
      child: const MyApp(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(720, 1280),
      builder: (_, child) {
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
