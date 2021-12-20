// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_database.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrInformation _$QrInformationFromJson(Map<String, dynamic> json) =>
    QrInformation(
      idQr: json['idQr'] as String?,
    );

Map<String, dynamic> _$QrInformationToJson(QrInformation instance) =>
    <String, dynamic>{
      'idQr': instance.idQr,
    };

NoteInformation _$NoteInformationFromJson(Map<String, dynamic> json) =>
    NoteInformation(
      noteId: json['noteId'] as String?,
      header: json['header'] as String?,
      text: json['text'] as String?,
      idImg:
          (json['idImg'] as List<dynamic>?)?.map((e) => e as String).toList(),
      timestamp: json['timestamp'] as String?,
    )..qrId = json['qrId'] as String?;

Map<String, dynamic> _$NoteInformationToJson(NoteInformation instance) =>
    <String, dynamic>{
      'qrId': instance.qrId,
      'noteId': instance.noteId,
      'header': instance.header,
      'text': instance.text,
      'idImg': instance.idImg,
      'timestamp': instance.timestamp,
    };
