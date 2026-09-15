import '../../domain/entities/product.dart';

final List<Product> mockProducts = [
  Product(
    id: 'prod-001',
    name: 'AuraSound Wireless Headphones',
    description:
        'Experience immersive sound with active noise cancellation, 30-hour battery life, ergonomic memory foam earcups, and crystal-clear microphone quality.',
    price: 1999,
    originalPrice: 2499,
    discountPercentage: 20,
    category: 'Electronics',
    brand: 'AuraSound',
    rating: 4.6,
    reviewCount: 142,
    images: const [
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&q=80',
      'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=800&q=80',
      'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=800&q=80',
    ],
    availableColors: const ['Midnight Black', 'Silver Grey', 'Navy Blue'],
    isInStock: true,
  ),
  Product(
    id: 'prod-002',
    name: 'PulseFit Smart Watch Pro',
    description:
        'Track your heart rate, sleep metrics, workout routines, and SPO2 levels with a vibrant AMOLED display, 7-day battery endurance, and 50m water resistance.',
    price: 2999,
    originalPrice: 3999,
    discountPercentage: 25,
    category: 'Electronics',
    brand: 'PulseFit',
    rating: 4.8,
    reviewCount: 98,
    images: const [
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80',
      'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=800&q=80',
    ],
    availableColors: const ['Space Grey', 'Rose Gold', 'Matte Black'],
    isInStock: true,
  ),
];
