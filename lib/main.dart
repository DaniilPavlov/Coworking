import 'package:coworking/screens/app/my_app.dart';
import 'package:coworking/screens/app/my_app_model.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MyAppModel.doFirebaseConnection();
  const app = MyApp();
  runApp(app);
}
