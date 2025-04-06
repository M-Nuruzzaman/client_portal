class Bank {
  final String id;
  final String name;
  final String logoUrl;

  Bank({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo'],
    );
  }
}
