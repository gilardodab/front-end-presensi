class CutiModel {
  final int id;
  final String start;
  final String end;
  final String dateWork;
  final int total;
  final String? description;
  final int status;

  CutiModel({
    required this.id,
    required this.start,
    required this.end,
    required this.dateWork,
    required this.total,
    this.description,
    required this.status,
  });

  // Factory constructor to create a CutiModel from JSON
  factory CutiModel.fromJson(Map<String, dynamic> json) {
    return CutiModel(
      id: json['cuty_id'],
      start: json['cuty_start'],
      end: json['cuty_end'],
      dateWork: json['date_work'],
      total: json['cuty_total'],
      description: json['cuty_description'],
      status: json['cuty_status'],
    );
  }

  // Method to convert a CutiModel instance into JSON format
  Map<String, dynamic> toJson() {
    return {
      'cuty_id': id,
      'cuty_start': start,
      'cuty_end': end,
      'date_work': dateWork,
      'cuty_total': total,
      'cuty_description': description,
      'cuty_status': status,
    };
  }
}
