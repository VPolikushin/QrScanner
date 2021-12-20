import 'package:json_annotation/json_annotation.dart';

part 'user_database.g.dart';

@JsonSerializable()
class UserInformation {
  bool? isAdmin;

  UserInformation({this.isAdmin});

  factory UserInformation.fromJson(Map<String, dynamic> json) =>
      _$UserInformationFromJson(json);
  Map<String, dynamic> toJson() => _$UserInformationToJson(this);
}