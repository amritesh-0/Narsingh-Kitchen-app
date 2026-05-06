import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, preparing, outForDelivery, delivered, cancelled }

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final String deliveryAddress;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return OrderModel(
      id: docId,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Customer',
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryAddress: json['deliveryAddress'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'items': items,
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryAddress': deliveryAddress,
    };
  }
}
