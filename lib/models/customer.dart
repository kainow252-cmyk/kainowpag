class Customer {
  final int? id;
  final String name;
  final String document;
  final String? birthdate;
  final Phone? phone;
  final String? email;
  final Address? address;

  Customer({
    this.id,
    required this.name,
    required this.document,
    this.birthdate,
    this.phone,
    this.email,
    this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      document: json['document'],
      birthdate: json['birthdate'],
      phone: json['phone'] != null ? Phone.fromJson(json['phone']) : null,
      email: json['email'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'document': document,
      if (birthdate != null) 'birthdate': birthdate,
      if (phone != null) 'phone': phone!.toJson(),
      if (email != null) 'email': email,
      if (address != null) 'address': address!.toJson(),
    };
  }
}

class Phone {
  final int countryCode;
  final int areaCode;
  final int number;

  Phone({
    required this.countryCode,
    required this.areaCode,
    required this.number,
  });

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      countryCode: json['countryCode'],
      areaCode: json['areaCode'],
      number: json['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'areaCode': areaCode,
      'number': number,
    };
  }

  String get formatted => '+$countryCode ($areaCode) $number';
}

class Address {
  final int? id;
  final String street;
  final String streetNumber;
  final String? lineTwo;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;

  Address({
    this.id,
    required this.street,
    required this.streetNumber,
    this.lineTwo,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      street: json['street'],
      streetNumber: json['streetNumber'],
      lineTwo: json['lineTwo'],
      neighborhood: json['neighborhood'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'street': street,
      'streetNumber': streetNumber,
      if (lineTwo != null) 'lineTwo': lineTwo,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }

  String get formatted => '$street, $streetNumber${lineTwo != null ? ", $lineTwo" : ""} - $neighborhood, $city/$state - CEP: $zipCode';
}
