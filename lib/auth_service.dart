import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  bool success;
  String message;
  String name;
  String email;

  AuthResult({
    required this.success,
    this.message = "",
    this.name = "",
    this.email = "",
  });
}

class AuthService {
  Future<AuthResult> signup(String name, String email, String password) async {
    try {
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(result.user!.uid)
          .set({"name": name, "email": email});

      return AuthResult(success: true, name: name, email: email);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: getMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(result.user!.uid)
          .get();

      String name = "";
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        name = data["name"] ?? "";
      }

      return AuthResult(success: true, name: name, email: email);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: getMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  String getMessage(String code) {
    if (code == "email-already-in-use") {
      return "This email is already registered";
    } else if (code == "weak-password") {
      return "Password is too weak";
    } else if (code == "invalid-email") {
      return "Email is not valid";
    } else if (code == "user-not-found") {
      return "No account found with this email";
    } else if (code == "wrong-password" || code == "invalid-credential") {
      return "Email or password is wrong";
    }
    return "Something went wrong";
  }
}
