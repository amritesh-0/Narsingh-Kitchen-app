import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';

class AdminService {
  static final AdminService instance = AdminService._();
  AdminService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Stats ───────────────────────────────────────────────────────────────
  Stream<Map<String, dynamic>> getDashboardStats() {
    return _firestore.collection('orders').snapshots().asyncMap((snapshot) async {
      double revenue = 0;
      int pending = 0;
      int delivered = 0;
      
      // Weekly orders data map: day name -> count
      final weeklyMap = <String, int>{};
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: i));
        final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1];
        weeklyMap[dayName] = 0;
      }

      // Top products map: emoji+name -> count
      final productMap = <String, Map<String, dynamic>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'pending';
        final amount = (data['totalAmount'] ?? 0.0).toDouble();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        if (status == 'delivered') {
          revenue += amount;
          delivered++;
        } else if (status == 'pending' || status == 'preparing') {
          pending++;
        }

        // Weekly logic (last 7 days)
        if (now.difference(createdAt).inDays < 7) {
          final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][createdAt.weekday - 1];
          if (weeklyMap.containsKey(dayName)) {
            weeklyMap[dayName] = (weeklyMap[dayName] ?? 0) + 1;
          }
        }

        // Top products logic
        final items = data['items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final name = item['name'] as String? ?? 'Unknown';
          final emoji = item['emoji'] as String? ?? '🍔';
          final key = '$emoji $name';
          if (!productMap.containsKey(key)) {
            productMap[key] = {'name': name, 'emoji': emoji, 'orders': 0};
          }
          productMap[key]!['orders'] = (productMap[key]!['orders'] as int) + 1;
        }
      }

      // Convert maps to sorted lists for the UI
      final weeklyOrders = weeklyMap.entries
          .map((e) => {'day': e.key, 'orders': e.value})
          .toList()
          .reversed // Oldest first
          .toList();

      final topProducts = productMap.values.toList();
      topProducts.sort((a, b) => (b['orders'] as int).compareTo(a['orders'] as int));

      // Customer count
      final usersSnap = await _firestore.collection('users').get();
      final customerCount = usersSnap.docs.length;

      return {
        'totalOrders': snapshot.docs.length,
        'revenue': revenue,
        'pendingOrders': pending,
        'deliveredOrders': delivered,
        'customerCount': customerCount,
        'weeklyOrders': weeklyOrders,
        'topProducts': topProducts.take(5).toList(),
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
