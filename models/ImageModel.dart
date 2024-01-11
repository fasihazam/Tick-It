class ImageModel {
  final String path;
  final int id;

  const ImageModel({
    required this.path,
    required this.id,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      path: json['path'],
      id: int.parse(json['id'].toString()),
    );
  }
}