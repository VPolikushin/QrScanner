import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'qr_database.g.dart';

@JsonSerializable()
class QrInformation {
  String? idQr;

  QrInformation({this.idQr});

  factory QrInformation.fromJson(Map<String, dynamic> json) =>
      _$QrInformationFromJson(json);
  Map<String, dynamic> toJson() => _$QrInformationToJson(this);
}

@JsonSerializable()
class NoteInformation {
  String? qrId;
   String? noteId;
   String? header;
   String? text;
   List<String>? idImg;
   String? timestamp;

  NoteInformation({this.noteId, this.header, this.text, this.idImg, this.timestamp});

  factory NoteInformation.fromJson(Map<String, dynamic> json) {
   // json["timestamp"] = ((json["timestamp"] as Timestamp).toDate().toString());
    return _$NoteInformationFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NoteInformationToJson(this);
}
