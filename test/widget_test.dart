import 'package:flutter_ecommerce/app/app.dart';
import 'package:flutter_ecommerce/app/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ShopSphereApp home route smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ShopSphereApp());
    await tester.pumpAndSettle();

    expect(find.text('ShopSphere'), findsOneWidget);
    expect(find.text('Welcome to ShopSphere'), findsOneWidget);
  });

  testWidgets('Invalid route displays page not found error page',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ShopSphereApp());
    await tester.pumpAndSettle();

    AppRouter.config.go('/invalid-route-test');
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
  });
}
