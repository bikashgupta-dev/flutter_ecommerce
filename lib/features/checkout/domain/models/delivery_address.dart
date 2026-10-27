class DeliveryAddress {
  final String id;
  final String recipientName;
  final String phoneNumber;
  final String addressLine;
  final String locality;
  final String city;
  final String state;
  final String postalCode;
  final String? landmark;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine,
    required this.locality,
    required this.city,
    required this.state,
    required this.postalCode,
    this.landmark,
    this.isDefault = false,
  });

  /// Indian mobile number pattern: 10 digits starting with 6-9 (optional +91 prefix)
  static final RegExp _phoneRegex = RegExp(r'^(\+91[\-\s]?)?[6-9]\d{9}$');

  /// Indian PIN code pattern: 6 digits starting with 1-9
  static final RegExp _postalCodeRegex = RegExp(r'^[1-9][0-9]{5}$');

  static String? validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Recipient name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final sanitized = value.trim().replaceAll(' ', '').replaceAll('-', '');
    if (!_phoneRegex.hasMatch(sanitized)) {
      return 'Enter a valid 10-digit Indian phone number';
    }
    return null;
  }

  static String? validateAddressLine(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address line / street is required';
    }
    if (value.trim().length < 3) {
      return 'Address line must be at least 3 characters';
    }
    return null;
  }

  static String? validateLocality(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Area or locality is required';
    }
    if (value.trim().length < 2) {
      return 'Locality must be at least 2 characters';
    }
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }
    if (value.trim().length < 2) {
      return 'City must be at least 2 characters';
    }
    return null;
  }

  static String? validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'State is required';
    }
    if (value.trim().length < 2) {
      return 'State must be at least 2 characters';
    }
    return null;
  }

  static String? validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Postal code is required';
    }
    final sanitized = value.trim();
    if (!_postalCodeRegex.hasMatch(sanitized)) {
      return 'Enter a valid 6-digit Indian PIN code';
    }
    return null;
  }

  bool get isValid =>
      validateRecipientName(recipientName) == null &&
      validatePhoneNumber(phoneNumber) == null &&
      validateAddressLine(addressLine) == null &&
      validateLocality(locality) == null &&
      validateCity(city) == null &&
      validateState(state) == null &&
      validatePostalCode(postalCode) == null;

  String get formattedAddress {
    final parts = [
      addressLine,
      if (landmark != null && landmark!.trim().isNotEmpty)
        'Near ${landmark!.trim()}',
      locality,
      '$city, $state - $postalCode',
    ];
    return parts.join(', ');
  }

  DeliveryAddress copyWith({
    String? id,
    String? recipientName,
    String? phoneNumber,
    String? addressLine,
    String? locality,
    String? city,
    String? state,
    String? postalCode,
    String? landmark,
    bool? isDefault,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine: addressLine ?? this.addressLine,
      locality: locality ?? this.locality,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'addressLine': addressLine,
      'locality': locality,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'landmark': landmark,
      'isDefault': isDefault,
    };
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id']?.toString() ?? '',
      recipientName: json['recipientName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      addressLine: json['addressLine']?.toString() ?? '',
      locality: json['locality']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      isDefault: json['isDefault'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryAddress &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          recipientName == other.recipientName &&
          phoneNumber == other.phoneNumber &&
          addressLine == other.addressLine &&
          locality == other.locality &&
          city == other.city &&
          state == other.state &&
          postalCode == other.postalCode &&
          landmark == other.landmark &&
          isDefault == other.isDefault;

  @override
  int get hashCode => Object.hash(
    id,
    recipientName,
    phoneNumber,
    addressLine,
    locality,
    city,
    state,
    postalCode,
    landmark,
    isDefault,
  );
}
