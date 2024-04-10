import 'package:fiscal_module_taxi/ui/screens/my_app_page/my_app_page.dart';
import 'package:flutter/material.dart';
import 'package:receive_intent/receive_intent.dart%20';
void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  final receivedIntentExtra = await ReceiveIntent.getInitialIntent();
  print('___________________________________');
  print(receivedIntentExtra?.extra);
  print('___________________________________');

  final app = MyApp.create(receivedIntentExtra);
  runApp(app);
}
