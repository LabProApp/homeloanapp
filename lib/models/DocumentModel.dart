class DocumentModel {
  final int id;
  final String fileName;
  final String fileUrl;
  final String objectType;
  final int objectId;

  DocumentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.objectType,
    required this.objectId,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json["id"],
      fileName: json["fileName"] ?? "",
      fileUrl: json["fileUrl"] ?? "",
      objectType: json["objectType"],
      objectId: json["objectId"],
    );
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "fileName": fileName,
    "fileUrl": fileUrl,
    "objectType": objectType,
    "objectId": objectId,
  };
}
