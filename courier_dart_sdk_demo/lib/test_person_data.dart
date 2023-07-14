class Person {
  String name;
  Person({required this.name});

  Person.fromJson(Map<String, dynamic> json) : name = json['name'];
  Map<String, dynamic> toJson() => {'name': name};
}
