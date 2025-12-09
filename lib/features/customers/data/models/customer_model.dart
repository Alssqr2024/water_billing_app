import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  CustomerModel({
    int? id,
    required String name,
    required String phone,
  }) : super(id: id, name: name, phone: phone);

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
    );
  }

  CustomerEntity toEntity() => CustomerEntity(
        id: id,
        name: name,
        phone: phone,
      );
}
