class CodebaseModel {
  final String file_name, folder_name, class_name;
  final String? ori_code, code;
  final List<String>? new_codes;
  String get path => '$folder_name/$file_name';
  CodebaseModel(
      {required this.file_name,
      required this.folder_name,
      required this.class_name,
      required this.code,
      required this.new_codes,
      required this.ori_code});
  factory CodebaseModel.fromJson(Map<String, dynamic> json) {
    return CodebaseModel(
        file_name: json['file_name'],
        folder_name: json['folder_name'],
        class_name: json['class_name'],
        code: json['code'],
        ori_code: json['ori_code'],
        new_codes: json['new_codes'] == null
            ? null
            : (json['new_codes'] as List<dynamic>).cast<String>());
  }
  Map<String, dynamic> toJson() {
    return {
      'file_name': file_name,
      'folder_name': folder_name,
      'class_name': class_name,
      'new_codes': new_codes,
      'code': code,
      'ori_code': ori_code,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
