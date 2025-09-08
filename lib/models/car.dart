class Car {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String imagePath;
  final double pricePerDay;
  final String transmission;
  final String fuelType;
  final int seats;
  final String category;
  final bool available;
  final String description;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.imagePath,
    required this.pricePerDay,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.category,
    required this.available,
    required this.description,
  });

  String get fullName => '$brand $model ($year)';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'imagePath': imagePath,
      'pricePerDay': pricePerDay,
      'transmission': transmission,
      'fuelType': fuelType,
      'seats': seats,
      'category': category,
      'available': available,
      'description': description,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      year: map['year'],
      imagePath: map['imagePath'],
      pricePerDay: map['pricePerDay'],
      transmission: map['transmission'],
      fuelType: map['fuelType'],
      seats: map['seats'],
      category: map['category'],
      available: map['available'],
      description: map['description'],
    );
  }

  Car copyWith({
    String? id,
    String? brand,
    String? model,
    int? year,
    String? imagePath,
    double? pricePerDay,
    String? transmission,
    String? fuelType,
    int? seats,
    String? category,
    bool? available,
    String? description,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      imagePath: imagePath ?? this.imagePath,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      seats: seats ?? this.seats,
      category: category ?? this.category,
      available: available ?? this.available,
      description: description ?? this.description,
    );
  }
}
