import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';

class AdminService {
  static final AdminService instance = AdminService._();
  AdminService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Stats ───────────────────────────────────────────────────────────────
  Stream<Map<String, dynamic>> getDashboardStats() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      double revenue = 0;
      int pending = 0;
      int delivered = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'pending';
        final amount = (data['totalAmount'] ?? 0.0).toDouble();

        if (status == 'delivered') {
          revenue += amount;
          delivered++;
        } else if (status == 'pending' || status == 'preparing') {
          pending++;
        }
      }

      return {
        'totalOrders': snapshot.docs.length,
        'revenue': revenue,
        'pendingOrders': pending,
        'deliveredOrders': delivered,
      };
    });
  }

  // ── Orders ──────────────────────────────────────────────────────────────
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.name,
    });
  }
}
