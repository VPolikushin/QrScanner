import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_scanner/models/qr_database.dart';
import 'package:qr_scanner/models/user_database.dart';
import 'package:firebase_storage/firebase_storage.dart';


class DatabaseService {

  final CollectionReference _userInfoCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference _qrInfoCollection = FirebaseFirestore.instance.collection('qr');
  final FirebaseStorage _instance = FirebaseStorage.instance;

 Future addOrUpdateUserInformation(UserInformation userInfo) async {
   final firebaseUser = FirebaseAuth.instance.currentUser;
   return _userInfoCollection.doc(firebaseUser!.uid).set(userInfo.toJson());
 }

  Future<UserInformation> getUserInformation() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return _userInfoCollection.doc(firebaseUser!.uid).get().then(
            (DocumentSnapshot documentSnapshot) => UserInformation.fromJson(documentSnapshot.data() as Map<String, dynamic>));
  }

  Future setNoteInformation(String qrCode, NoteInformation note) async {
    String docId = _qrInfoCollection.doc(qrCode).collection('notes').doc().id;
    note.noteId = docId;
    note.qrId = qrCode;
    return _qrInfoCollection.doc(qrCode).collection('notes').doc(docId).set(note.toJson());
  }

  Future updateNoteImageInformation(String qrId, String noteId, List<String> idImg) async {
    return _qrInfoCollection.doc(qrId).collection('notes').doc(noteId).update({'idImg': idImg});
  }
  
  Future updateNoteInformation(NoteInformation note) async {
    return _qrInfoCollection.doc(note.qrId).collection('notes').doc(note.noteId).set(note.toJson());
  }

  Future deleteNoteInformation(NoteInformation note) async {
    return _qrInfoCollection.doc(note.qrId).collection('notes').doc(note.noteId).delete();
  }

  Stream<NoteInformation> getNoteInformation(String qrId, String noteId)  {
    return  _qrInfoCollection.doc(qrId).collection('notes').doc(noteId).snapshots().map(
            (DocumentSnapshot documentSnapshot) => NoteInformation.fromJson(documentSnapshot.data() as Map<String, dynamic>)); ;
  }

  Future addNoteInformation(String qrCode, NoteInformation note) async {
    return _qrInfoCollection.doc(qrCode).collection('notes').add(note.toJson());
  }

  Future noteDocId(String qrCode) async {
    return _qrInfoCollection.doc(qrCode).collection('notes').doc();
  }

  Future addOrUpdateQrInformation(QrInformation qrInfo, String qrCode) async {
    return _qrInfoCollection.doc(qrCode).set(qrInfo.toJson());
  }

  Stream<List<NoteInformation>> getNotesInformation(String qrCode) {
    return  _qrInfoCollection.doc(qrCode).collection('notes').orderBy('timestamp', descending: true).snapshots().map((QuerySnapshot data) =>
    data.docs.map((DocumentSnapshot documentSnapshot) => NoteInformation.fromJson(documentSnapshot.data() as Map<String, dynamic>)).toList());
  }

  Future isQrExists(String id) async{
    final snapshot = await _qrInfoCollection.doc(id).get();
    if(snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<String>getImgUrl(String qrId, String noteId, File? _image) async {
    final _dateTime = DateTime.now().toString();
    try {
      final uploadTask = await _instance.ref().child(qrId).child('${noteId}_$_dateTime.jpg').putFile(_image!);
      final downloadURL = await uploadTask.ref.getDownloadURL();

      return downloadURL;
    } on FirebaseException catch (e) {
      return e.code;
    }
  }

  Future deleteImgStorage(String url) async {
    return _instance.refFromURL(url).delete();
  }
}
