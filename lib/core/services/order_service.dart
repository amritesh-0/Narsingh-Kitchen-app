import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';
import 'auth_service.dart';

class OrderService {
  static final OrderService instance = OrderService._();
  OrderService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OrderModel>> getMyOrders() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> placeOrder(OrderModel order) async {
    await _firestore.collection('orders').add(order.toFirestore());
  }
}
