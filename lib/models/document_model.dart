class DocumentModel {
  final int id;
  final String s3key;
  final String docUrl;
  final String objectType;
  final int objectId;

  DocumentModel({
    required this.id,
    required this.s3key,
    required this.docUrl,
    required this.objectType,
    required this.objectId,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json["id"],
      s3key: json["s3key"] ?? "",
      docUrl: json["docUrl"] ?? "",
      objectType: json["objectType"],
      objectId: json["objectId"],
    );
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "s3key": s3key,
    "docUrl": docUrl,
    "objectType": objectType,
    "objectId": objectId,
  };
}
