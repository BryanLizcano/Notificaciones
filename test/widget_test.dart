import 'package:flutter_test/flutter_test.dart';
import 'package:notifications/main.dart';

void main() {
  testWidgets('Verifica que la Tienda Demo cargue correctamente', (WidgetTester tester) async {
    // 1. Construimos la app pasándole una lista vacía de productos
    await tester.pumpWidget(const MyApp(products: []));

    // 2. Verificamos que el título de la AppBar esté presente
    expect(find.text('Tienda Demo'), findsOneWidget);

    // 3. Verificamos que el título del resumen exista
    expect(find.text('Resumen del inventario'), findsOneWidget);

    // 4. Como le pasamos una lista vacía, el total debe ser 0
    expect(find.text('Total de productos: 0'), findsOneWidget);

    // 5. El contador de stock bajo también debe ser 0
    expect(find.text('Productos con stock bajo: 0'), findsOneWidget);
  });
}