import 'package:json_annotation/json_annotation.dart';

// auto generated file
part 'user.g.dart';

// this object could be converted from or to JSON string
@JsonSerializable()
class User {
  User(this.id, this.username, this.email);

  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  String username;

  @JsonKey(required: true)
  String email;

  /// Convert from JSON string to User object
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
