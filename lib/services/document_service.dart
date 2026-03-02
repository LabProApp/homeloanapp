import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/DocumentModel.dart';
import '../utility/APIUrls.dart';

class DocumentApiService {
  /// 📤 Upload documents (USER / PROPERTY etc)
  static Future<bool> uploadDocuments({
    required String objectType, // e.g. USER
    required int objectId,       // e.g. 10
    required List<File> files,
    List<String>? captions,
  }) async {
    final uri =
    Uri.parse("${ApiUrls.uploadDocuments}/$objectType/$objectId");

    developer.log("📤 Upload Documents API", name: "DocumentApiService");
    developer.log("URL: $uri", name: "DocumentApiService");
    developer.log(
      "FILES: ${files.map((e) => e.path).toList()}",
      name: "DocumentApiService",
    );

    try {
      final request = http.MultipartRequest("POST", uri);

      /// add files
      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath("files", file.path),
        );
      }

      /// add captions (optional)
      if (captions != null && captions.isNotEmpty) {
        for (var cap in captions) {
          request.fields["captions"] = cap;
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      developer.log("STATUS: ${response.statusCode}",
          name: "DocumentApiService");
      developer.log("RESPONSE: ${response.body}",
          name: "DocumentApiService");

      if (response.statusCode == 200) {
        return true; // ✅ success
      } else {
        return false; // ❌ failure
      }
    } on SocketException {
      developer.log("❌ No Internet", name: "DocumentApiService");
      return false;
    } on FormatException {
      return false;
    } catch (e) {
      developer.log("❌ ERROR: $e", name: "DocumentApiService");
      return false;
    }
  }

  /// 📥 Get documents by object
  static Future<List<DocumentModel>> getDocuments({
    required String objectType, // USER / PROPERTY etc
    required int objectId,
  }) async {
    final uri = Uri.parse("${ApiUrls.downloadDocuments}/$objectType/$objectId");


    developer.log("📥 Get Documents API", name: "DocumentApiService");
    developer.log("URL: $uri", name: "DocumentApiService");

    http.Response res;

    try {
      res = await http
          .get(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      developer.log("❌ No Internet", name: "DocumentApiService");
      throw Exception("No internet connection");
    }

    developer.log("STATUS: ${res.statusCode}", name: "DocumentApiService");
    developer.log("RESPONSE: ${res.body}", name: "DocumentApiService");

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch documents");
    }

    final List decoded = jsonDecode(res.body) as List;

    return decoded
        .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
