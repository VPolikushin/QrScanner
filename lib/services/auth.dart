import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_scanner/models/user.dart';

class AuthService {
  final FirebaseAuth _fAuth = FirebaseAuth.instance;

  Future<MyUser?> signInWithEmailAndPassword(String email, String password) async {
    try{
      final UserCredential result = await _fAuth.signInWithEmailAndPassword(email: email, password: password);
      final User ?user = result.user;
      return MyUser.fromFirebase(user!);
    }on FirebaseAuthException catch(e){
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return null;
    }
  }

  Future<MyUser?> registerInWithEmailAndPassword(String email, String password) async {
    try{
      final UserCredential result = await _fAuth.createUserWithEmailAndPassword(email: email, password: password);
      final User user = result.user!;
      await _fAuth.signInWithEmailAndPassword(email: email, password: password);
      return MyUser.fromFirebase(user);
    }on FirebaseAuthException catch(e){
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return null;
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try{
      await _fAuth.sendPasswordResetEmail(email: email);
    }on FirebaseAuthException catch(e){
      return e.code;
    }

  }

  Future logOut() async {
    await _fAuth.signOut();
  }

  Stream<MyUser?> get currentUser {
    return _fAuth.authStateChanges()
        .map((User ?user) => user != null ? MyUser.fromFirebase(user) : null);
  }

}