
import 'dart:convert';

Publication publicationFromJson(String str) => Publication.fromJson(json.decode(str));

String publicationToJson(Publication data) => json.encode(data.toJson());

class Publication {
  Publication({
    required this.title,
    required this.description,
    required this.user,
    required this.date,
    required this.category,
  });

  String title;
  String description;
  String user;
  String date;
  String category;

  factory Publication.fromJson(Map<String, dynamic> json) => Publication(
    title: json["title"],
    description: json["description"],
    user: json["user"],
    date: json["date"],
    category: json["category"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "user": user,
    "date": date,
    "category" : category
  };
}

