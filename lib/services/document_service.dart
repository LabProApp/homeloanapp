import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/document_model.dart';
import '../network/api_client.dart';
import '../utility/api_urls.dart';

class DocumentApiService {
  static Future<void> uploadSingleDocument({
    required String objectType,
    required int objectId,
    required File file,
    required String caption,
  }) async {
    final uri = Uri.parse('${ApiUrls.uploadDocuments}/$objectType/$objectId');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('files', file.path));
    request.files.add(http.MultipartFile.fromString('captions', caption));

    final streamed = await ApiClient.sendMultipart(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Upload failed (${response.statusCode}): ${response.body}');
    }
  }

  static Future<bool> uploadDocuments({
    required String objectType,
    required int objectId,
    required List<File> files,
    List<String>? captions,
  }) async {
    final uri = Uri.parse('${ApiUrls.uploadDocuments}/$objectType/$objectId');

    final request = http.MultipartRequest('POST', uri);

    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    if (captions != null) {
      for (final cap in captions) {
        request.files.add(http.MultipartFile.fromString('captions', cap));
      }
    }

    try {
      final streamed = await ApiClient.sendMultipart(request);
      final response = await http.Response.fromStream(streamed);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<List<DocumentModel>> getDocuments({
    required String objectType,
    required int objectId,
  }) async {
    final uri = Uri.parse('${ApiUrls.downloadDocuments}/$objectType/$objectId');
    final response = await ApiClient.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch documents (${response.statusCode})');
    }

    final List decoded = jsonDecode(response.body) as List;
    return decoded
        .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
