import 'package:flutter_ecommerce/features/cart/data/models/cart_item.dart';
import 'package:flutter_ecommerce/features/orders/domain/models/order_item.dart';
import 'package:flutter_ecommerce/features/orders/domain/models/order_pricing_calculator.dart';
import 'package:flutter_ecommerce/features/products/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

Product _createProduct({
  required String id,
  required String name,
  required double price,
  double? originalPrice,
}) {
  return Product(
    id: id,
    name: name,
    description: 'Test description',
    price: price,
    originalPrice: originalPrice,
    category: 'Electronics',
    rating: 4.5,
    images: const ['https://example.com/image.jpg'],
    isInStock: true,
  );
}

void main() {
  group('OrderPricingCalculator', () {
    test('Calculates zero pricing for empty cart', () {
      final pricing = OrderPricingCalculator.calculateFromCart(const []);

      expect(pricing.subtotal, 0.0);
      expect(pricing.discount, 0.0);
      expect(pricing.deliveryCharge, 0.0);
      expect(pricing.total, 0.0);
      expect(pricing.isFreeDelivery, isFalse);
    });

    test('Calculates subtotal and quantity multiplication correctly', () {
      final p1 = _createProduct(id: 'p1', name: 'Product 1', price: 200.0);
      final p2 = _createProduct(id: 'p2', name: 'Product 2', price: 150.0);

      final items = [
        CartItem(product: p1, quantity: 2), // 400
        CartItem(product: p2, quantity: 3), // 450
      ];

      final pricing = OrderPricingCalculator.calculateFromCart(items);

      // Subtotal = 400 + 450 = 850
      expect(pricing.subtotal, 850.0);
    });

    test(
      'Applies standard delivery fee when subtotal is below threshold (999)',
      () {
        final p1 = _createProduct(id: 'p1', name: 'Product 1', price: 500.0);
        final items = [CartItem(product: p1, quantity: 1)]; // 500

        final pricing = OrderPricingCalculator.calculateFromCart(items);

        expect(pricing.subtotal, 500.0);
        expect(pricing.isFreeDelivery, isFalse);
        expect(
          pricing.deliveryCharge,
          OrderPricingCalculator.standardDeliveryCharge,
        );
        expect(
          pricing.total,
          500.0 + OrderPricingCalculator.standardDeliveryCharge,
        );
        expect(pricing.amountNeededForFreeDelivery, 499.0);
      },
    );

    test(
      'Applies free delivery when subtotal meets or exceeds threshold (999)',
      () {
        final p1 = _createProduct(id: 'p1', name: 'Product 1', price: 1000.0);
        final items = [CartItem(product: p1, quantity: 1)]; // 1000

        final pricing = OrderPricingCalculator.calculateFromCart(items);

        expect(pricing.subtotal, 1000.0);
        expect(pricing.isFreeDelivery, isTrue);
        expect(pricing.deliveryCharge, 0.0);
        expect(pricing.total, 1000.0);
        expect(pricing.amountNeededForFreeDelivery, 0.0);
      },
    );

    test('Calculates discount savings correctly based on original prices', () {
      final p1 = _createProduct(
        id: 'p1',
        name: 'Product 1',
        price: 300.0,
        originalPrice: 400.0, // 100 discount each
      );
      final p2 = _createProduct(
        id: 'p2',
        name: 'Product 2',
        price: 500.0,
        originalPrice: 700.0, // 200 discount each
      );

      final items = [
        CartItem(product: p1, quantity: 2), // 200 total discount
        CartItem(product: p2, quantity: 1), // 200 total discount
      ];

      final pricing = OrderPricingCalculator.calculateFromCart(items);

      // Subtotal: 600 + 500 = 1100
      expect(pricing.subtotal, 1100.0);
      // Discount: (400-300)*2 + (700-500)*1 = 200 + 200 = 400
      expect(pricing.discount, 400.0);
      expect(pricing.isFreeDelivery, isTrue);
      expect(pricing.total, 1100.0);
    });

    test('Calculates identical pricing from snapshot OrderItems', () {
      const orderItems = [
        OrderItem(
          productId: 'p1',
          productName: 'Product 1',
          unitPrice: 250.0,
          quantity: 2,
          originalUnitPrice: 300.0,
        ),
        OrderItem(
          productId: 'p2',
          productName: 'Product 2',
          unitPrice: 100.0,
          quantity: 1,
          originalUnitPrice: 100.0,
        ),
      ];

      // Subtotal: 500 + 100 = 600 (< 999)
      // Discount: (300-250)*2 = 100
      // Delivery fee: 49
      // Total: 649
      final pricing = OrderPricingCalculator.calculateFromOrderItems(
        orderItems,
      );

      expect(pricing.subtotal, 600.0);
      expect(pricing.discount, 100.0);
      expect(pricing.deliveryCharge, 49.0);
      expect(pricing.total, 649.0);
      expect(pricing.isFreeDelivery, isFalse);
    });
  });
}
