class FoodItem {
  final String name;
  final DateTime expiryDate;
  String? imageUrl;

  FoodItem({required this.name, required this.expiryDate, this.imageUrl});

  Map<String, dynamic> toJson() => {
        'name': name,
        'expiryDate': expiryDate.toIso8601String(),
        'imageUrl': imageUrl,
      };

  static FoodItem fromJson(Map<String, dynamic> json) => FoodItem(
        name: json['name'],
        expiryDate: DateTime.parse(json['expiryDate']),
        imageUrl: json['imageUrl'],
      );
}
