import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  User(this.id, this.username, this.email);

  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  String username;

  @JsonKey(required: true)
  String email;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
