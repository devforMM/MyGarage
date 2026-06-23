import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "providers/TokenProvider.dart";
import 'routes.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash_route,
      routes: Routes.all_routes,
      theme: AppTheme.darkTheme,
    );
  }
}

void main() {
  runApp(
    
    MultiProvider(providers: 
    [
      ChangeNotifierProvider(create: (_)=>TokenProvider())
    ],
    child: const MyApp())
  );
}