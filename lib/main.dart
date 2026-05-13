import 'package:flutter/material.dart';

import 'data/product_data.dart';
import 'models/product.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.init();

  final List<Product> products = ProductData.products;

  await NotificationService.instance.showLowStockNotification(products);
  await NotificationService.instance.schedulePromoNotification();

  runApp(MyApp(products: products));
}

class MyApp extends StatelessWidget {
  final List<Product> products;

  const MyApp({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tienda Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(products: products),
    );
  }
}
