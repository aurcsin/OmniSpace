 // File: lib/models/user.dart

 /// A simple user model returned by the auth API.
 class User {
   final String id;
   final String email;
   final String? name;

   User({
     required this.id,
     required this.email,
     this.name,
   });

   /// Convert API JSON into a User.
   factory User.fromJson(Map<String, dynamic> json) {
     return User(
       id: json['id'] as String,
       email: json['email'] as String,
       name: json['name'] as String?,
     );
   }

   /// Convert User into JSON for API calls or storage.
   Map<String, dynamic> toJson() {
     final data = <String, dynamic>{
       'id': id,
       'email': email,
     };
     if (name != null) data['name'] = name;
     return data;
   }
 }
