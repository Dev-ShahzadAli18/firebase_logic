import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_logic/auth_service.dart';

class ProductService {
  Future<AuthResult> addProduct(
    String name,
    String price,
    String oldPrice,
    String image,
    String category,
  ) async {
    try {
      await FirebaseFirestore.instance.collection("products").add({
        "name": name,
        "price": price,
        "oldPrice": oldPrice,
        "image": image,
        "category": category,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("products")
          .orderBy("createdAt", descending: true)
          .get();

      List<Map<String, dynamic>> list = [];

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        list.add(data);
      }

      return list;
    } catch (e) {
      return [];
    }
  }
}
