import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/document_model.dart';
import '../network/api_client.dart';
import '../utility/api_urls.dart';

class DocumentApiService {
  static Future<bool> uploadDocuments({
    required String objectType,
    required int objectId,
    required List<File> files,
    List<String>? captions,
  }) async {
    final uri = Uri.parse('${ApiUrls.uploadDocuments}/$objectType/$objectId');

    developer.log('Upload documents: $uri', name: 'DocumentApiService');

    final request = http.MultipartRequest('POST', uri);

    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    if (captions != null) {
      for (final cap in captions) {
        request.fields['captions'] = cap;
      }
    }

    try {
      final streamed = await ApiClient.sendMultipart(request);
      final response = await http.Response.fromStream(streamed);

      developer.log('Upload status: ${response.statusCode}', name: 'DocumentApiService');
      return response.statusCode == 200;
    } catch (e) {
      developer.log('Upload error: $e', name: 'DocumentApiService');
      return false;
    }
  }

  static Future<List<DocumentModel>> getDocuments({
    required String objectType,
    required int objectId,
  }) async {
    final uri = Uri.parse('${ApiUrls.downloadDocuments}/$objectType/$objectId');

    developer.log('Get documents: $uri', name: 'DocumentApiService');

    final response = await ApiClient.get(uri);

    developer.log('Status: ${response.statusCode}', name: 'DocumentApiService');

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch documents (${response.statusCode})');
    }

    final List decoded = jsonDecode(response.body) as List;
    return decoded
        .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
