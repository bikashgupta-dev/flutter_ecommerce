import 'package:flutter_ecommerce/features/checkout/domain/models/delivery_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryAddress validation', () {
    test('Valid address passes all validation rules', () {
      const address = DeliveryAddress(
        id: 'addr-001',
        recipientName: 'Aarav Patel',
        phoneNumber: '9876543210',
        addressLine: 'Flat 302, Palm Heights',
        locality: 'Indiranagar',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560038',
        landmark: 'Near Metro Station',
        isDefault: true,
      );

      expect(address.isValid, isTrue);
      expect(
        DeliveryAddress.validateRecipientName(address.recipientName),
        isNull,
      );
      expect(DeliveryAddress.validatePhoneNumber(address.phoneNumber), isNull);
      expect(DeliveryAddress.validateAddressLine(address.addressLine), isNull);
      expect(DeliveryAddress.validateLocality(address.locality), isNull);
      expect(DeliveryAddress.validateCity(address.city), isNull);
      expect(DeliveryAddress.validateState(address.state), isNull);
      expect(DeliveryAddress.validatePostalCode(address.postalCode), isNull);
    });

    test('Valid phone numbers with +91 and spaces are recognized', () {
      expect(DeliveryAddress.validatePhoneNumber('+91 9876543210'), isNull);
      expect(DeliveryAddress.validatePhoneNumber('+91-8765432109'), isNull);
      expect(DeliveryAddress.validatePhoneNumber('7654321098'), isNull);
      expect(DeliveryAddress.validatePhoneNumber('6543210987'), isNull);
    });

    test('Missing required fields return error messages', () {
      expect(
        DeliveryAddress.validateRecipientName(null),
        'Recipient name is required',
      );
      expect(
        DeliveryAddress.validateRecipientName(''),
        'Recipient name is required',
      );
      expect(
        DeliveryAddress.validateRecipientName('A'),
        'Name must be at least 2 characters',
      );

      expect(
        DeliveryAddress.validatePhoneNumber(null),
        'Phone number is required',
      );
      expect(
        DeliveryAddress.validatePhoneNumber('   '),
        'Phone number is required',
      );

      expect(
        DeliveryAddress.validateAddressLine(''),
        'Address line / street is required',
      );
      expect(
        DeliveryAddress.validateAddressLine('12'),
        'Address line must be at least 3 characters',
      );

      expect(
        DeliveryAddress.validateLocality(''),
        'Area or locality is required',
      );
      expect(DeliveryAddress.validateCity(''), 'City is required');
      expect(DeliveryAddress.validateState(''), 'State is required');
      expect(DeliveryAddress.validatePostalCode(''), 'Postal code is required');
    });

    test('Invalid postal code fails validation', () {
      // Must be 6 digits and cannot start with 0
      expect(
        DeliveryAddress.validatePostalCode('012345'),
        'Enter a valid 6-digit Indian PIN code',
      );
      expect(
        DeliveryAddress.validatePostalCode('56003'), // 5 digits
        'Enter a valid 6-digit Indian PIN code',
      );
      expect(
        DeliveryAddress.validatePostalCode('5600389'), // 7 digits
        'Enter a valid 6-digit Indian PIN code',
      );
      expect(
        DeliveryAddress.validatePostalCode('56003A'), // Alphanumeric
        'Enter a valid 6-digit Indian PIN code',
      );
    });

    test('Invalid phone format fails validation', () {
      // Must be 10 digits starting with 6, 7, 8, or 9
      expect(
        DeliveryAddress.validatePhoneNumber('1234567890'), // Starts with 1
        'Enter a valid 10-digit Indian phone number',
      );
      expect(
        DeliveryAddress.validatePhoneNumber('987654321'), // 9 digits
        'Enter a valid 10-digit Indian phone number',
      );
      expect(
        DeliveryAddress.validatePhoneNumber('98765432101'), // 11 digits
        'Enter a valid 10-digit Indian phone number',
      );
      expect(
        DeliveryAddress.validatePhoneNumber('abcdefghij'),
        'Enter a valid 10-digit Indian phone number',
      );
    });

    test(
      'Formatted address output strings include landmarks when provided',
      () {
        const withLandmark = DeliveryAddress(
          id: 'addr-1',
          recipientName: 'Test',
          phoneNumber: '9876543210',
          addressLine: '123 Street',
          locality: 'Area',
          city: 'City',
          state: 'State',
          postalCode: '110001',
          landmark: 'Old Temple',
        );
        expect(
          withLandmark.formattedAddress,
          '123 Street, Near Old Temple, Area, City, State - 110001',
        );

        const withoutLandmark = DeliveryAddress(
          id: 'addr-2',
          recipientName: 'Test',
          phoneNumber: '9876543210',
          addressLine: '456 Road',
          locality: 'Sector 5',
          city: 'City',
          state: 'State',
          postalCode: '110001',
        );
        expect(
          withoutLandmark.formattedAddress,
          '456 Road, Sector 5, City, State - 110001',
        );
      },
    );

    test(
      'JSON serialization and deserialization roundtrip preserves all fields',
      () {
        const original = DeliveryAddress(
          id: 'addr-test',
          recipientName: 'Deepa Roy',
          phoneNumber: '9123456789',
          addressLine: 'Building 12, Floor 3',
          locality: 'HSR Layout',
          city: 'Bengaluru',
          state: 'Karnataka',
          postalCode: '560102',
          landmark: 'BDA Complex',
          isDefault: true,
        );

        final json = original.toJson();
        final restored = DeliveryAddress.fromJson(json);

        expect(restored, equals(original));
        expect(restored.isDefault, isTrue);
        expect(restored.landmark, 'BDA Complex');
      },
    );
  });
}
