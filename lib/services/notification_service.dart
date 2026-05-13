import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/product.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

    await _createNotificationChannels();
    await _requestPermissions();
  }

  //crear canales de notificación para Android
  Future<void> _createNotificationChannels() async {
    const lowStockChannel = AndroidNotificationChannel(
      'low_stock_channel',
      'Stock bajo',
      description: 'Canal para alertas de productos con poco stock',
      importance: Importance.max,
    );

    const promoChannel = AndroidNotificationChannel(
      'promo_channel',
      'Promociones',
      description: 'Canal para anuncios y promociones',
      importance: Importance.high,
    );
    // Registrar los canales en Android
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(lowStockChannel);
    await androidImplementation?.createNotificationChannel(promoChannel);
  }

  // Solicitar permisos de notificación
  Future<void> _requestPermissions() async {
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  // Aquí revisamos la lista de productos y enviamos una notificación si hay alguno con stock bajo
  Future<void> showLowStockNotification(List<Product> products) async {
    final lowStockProducts = products.where((p) => p.stock < 5).toList();

    if (lowStockProducts.isEmpty) return;
    //Convertir la lista en texto para mostrar en la notificación
    final names =
        lowStockProducts.map((p) => '${p.name} (${p.stock})').join(', ');

    //Le decimos a android que canal usar, su prioridad y el contenido de la notificación
    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Stock bajo',
      channelDescription: 'Canal para alertas de productos con poco stock',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    // Enviamos la notificación
    await _plugin.show(
      1,
      'Alerta de inventario',
      'Hay productos con menos de 5 unidades: $names',
      details,
    );
  }

  // Esta función programa una notificación futura
  Future<void> schedulePromoNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'promo_channel',
      'Promociones',
      channelDescription: 'Canal para anuncios y promociones',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
// Programamos la notificación para que se muestre después de 1 minuto
    await _plugin.zonedSchedule(
      2,
      'Oferta especial',
      'Oye, entra a la app, tenemos una oferta para ti.',
      tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
