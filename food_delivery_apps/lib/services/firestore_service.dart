import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

class FirestoreService {
  final CollectionReference _orders =
      FirebaseFirestore.instance.collection('orders');

  Future<void> createOrder(String userId, FoodItem item) async {
    await _orders.add({
      'userId': userId,
      'item': item.toJson(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<FoodItem>> getUserOrders(String userId) {
    return _orders
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItem.fromJson(doc['item']))
            .toList());
  }
}
