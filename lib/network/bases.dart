import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'package:Devdoot/core/enums/user_role.dart';
// import 'package:Devdoot/core/services/storage_services.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

//In this file all the API requests are created, we will call these requests for all the APIs

//const String baseUrl = 'http://192.168.31.93:3000/api/';
const String baseUrl = 'http://15.206.9.70:8080/api';
http.Client client = http.Client();
// final LocalStorageService _storageService = LocalStorageService();
// final StorageService _storageService = StorageService();
//         Future<String?> _getToken() async {
//     // Get token using your existing StorageService
//     return _storageService.getToken(role: UserRole.endUser);
//   }
class ApiService{
  final http.Client client;
  final String baseUrll;


  ApiService({required this.client ,  this.baseUrll="https://corporateapi.devdoot.org/api/"});

  Map<String, String> appendAccessTokenWith(
  Map<String, String> headers,
  String accessToken,
) {
  final Map<String, String> requestHeaders = {
    'Authorization': accessToken,
    // 'Content-Type': "application/json",
    // 'cookie':
    //     "userId=s%3Aix4c7OINKAeyLCNR6sbcQP6SAbb6RLPp.md4VFFVZmDN2vl53Eivr6Ai7cOfT%2BeZuI9nLNEhPKy4; userId=s%3A9F6ACNKpmKUQhK004CIBCyL-_TTy8h2V.HxisbshJy0VpHPCYBcIjbGp%2Be9QqH%2FC1Ov%2Br3M3plH4"
  }..addAll(headers);
  return requestHeaders;
}

Future<http.Response> fetchData({
  required String url,
  String queryParams = "",
  bool isCustomUrl = false,
}) async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

 //final token = await _getToken();

  // if (addToken) {
  //   requestHeaders = appendAccessTokenWith({}, sessionToken);
  // }

  // else {
  // requestHeaders.addAll({'x-access-token': '${token ?? ""}'});
  // // }

  if (queryParams.isNotEmpty) {
    url += "?$queryParams";
  }

  final response = await client.get(
    isCustomUrl ? Uri.parse(url) : Uri.parse(baseUrl + url),
    headers: requestHeaders,
  );

  return response;
}



Future<http.Response> postDataa<T>({
  required String url,
  required T body,
}) async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};
  // final token = await _getToken();
  //String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";

  // if (addToken) {
  //   requestHeaders = appendAccessTokenWith({}, sessionToken);
  // }

  // else {
  // requestHeaders.addAll({
  //   'x-access-token': '${token ?? ""}'
    
  //   });

  final response = await client.post(
    Uri.parse(baseUrl + url),
    headers: requestHeaders,
    body: jsonEncode(body),
  );

  return response;
}

Future<http.Response> postDataawithouttoken<T>({
  required String url,
  required T body,
}) async {
  Map<String, String> requestHeaders;

  requestHeaders = {'Content-Type': 'application/json'};
  requestHeaders.addAll({
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Im1hZGFhbmRocnV2MDNAZ21haWwuY29tIiwic2Nob29sSWQiOiI2OGE0MTE3ZjUxODcwMGJjNzVhZTA5ZmYiLCJpZCI6IjY4ZTNhMzc1MWRlOTEyNGQ2M2MwMmY0OCIsInJvbGUiOiJzdHVkZW50IiwiaWF0IjoxNzYzMTEzMjU4LCJleHAiOjE3NjM3MTgwNTh9.wwLIMI0of0xP0bSStS5FeXwjpTHO3NbvA1DkcnxbU7M }'
  });

  final response = await client.post(
    Uri.parse(url),
    headers: requestHeaders,
    body: jsonEncode(body),
  );

  return response;
}

Future<http.Response> postDataawithtoken<T>({
  required String url,
  required T body,
  String? token, // Add the token as an optional parameter
}) async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

  // If a token is provided, add it to the Authorization header
 // String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";
  // requestHeaders.addAll({
  //   'Authorization':
  //       'Bearer ${sessionToken ?? ""}'
  // });

  final response = await client.post(
    Uri.parse(baseUrl + url),
    headers: requestHeaders,
    body: jsonEncode(body),
  );

  return response;
}



Future<http.Response> putDataawithtoken<T>({
  required String url,
  required T body,
  String? token, // Add the token as an optional parameter
}) async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

  // If a token is provided, add it to the Authorization header
  // String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";
  // requestHeaders.addAll({
  //   'Authorization':
  //       'Bearer ${sessionToken ?? ""}'
  // });

  final response = await client.put(
    Uri.parse(baseUrl + url),
    headers: requestHeaders,
    body: jsonEncode(body),
  );

  return response;
}

Future<http.Response> putDataawithouttoken<T>({
  required String url,
  required T body,
  String? token, // Add the token as an optional parameter
}) async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

  // If a token is provided, add it to the Authorization header
  // String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";
  // requestHeaders.addAll({
  //   'Authorization':
  //       'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Im1hZGFhbmRocnV2MDNAZ21haWwuY29tIiwic2Nob29sSWQiOiI2OGE0MTE3ZjUxODcwMGJjNzVhZTA5ZmYiLCJpZCI6IjY4ZTNhMzc1MWRlOTEyNGQ2M2MwMmY0OCIsInJvbGUiOiJzdHVkZW50IiwiaWF0IjoxNzYzMTEzMjU4LCJleHAiOjE3NjM3MTgwNTh9.wwLIMI0of0xP0bSStS5FeXwjpTHO3NbvA1DkcnxbU7M'
  // });

  final response = await client.put(
    Uri.parse( url),
    headers: requestHeaders,
    body: jsonEncode(body),
  );

  return response;
}


Future<http.Response> deleteDataawithtoken<T>({
  required String url,
  required T body,
  String? token, // Add the token as an optional parameter
}) async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

  // If a token is provided, add it to the Authorization header
  // String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";
  // requestHeaders.addAll({
  //   'Authorization':
  //       'Bearer ${sessionToken ?? ""}'
  // });

  final response = await client.delete(
    Uri.parse(baseUrl + url),
    headers: requestHeaders,
    body: jsonEncode(body),
  );

  return response;
}


Future<http.Response> deleteDataawithouttoken<T>({
  required String url,
  required T body,
  String? token, // Add the token as an optional parameter
}) async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

  // If a token is provided, add it to the Authorization header
  // String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";
  // requestHeaders.addAll({
  //   'Authorization':
  //       'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Im1hZGFhbmRocnV2MDNAZ21haWwuY29tIiwic2Nob29sSWQiOiI2OGE0MTE3ZjUxODcwMGJjNzVhZTA5ZmYiLCJpZCI6IjY4ZTNhMzc1MWRlOTEyNGQ2M2MwMmY0OCIsInJvbGUiOiJzdHVkZW50IiwiaWF0IjoxNzYzMTEzMjU4LCJleHAiOjE3NjM3MTgwNTh9.wwLIMI0of0xP0bSStS5FeXwjpTHO3NbvA1DkcnxbU7M'
  // });

  final response = await client.delete(
    Uri.parse( url),
    headers: requestHeaders,
    body: jsonEncode(body),
  );

  return response;
}




// Future<http.Response> uploadImageDataAndData({
//   required Uint8List imageData,
//   required String filename,
//   required String url,

// }) async {
//   final request = http.MultipartRequest("POST", Uri.parse(baseUrl + url));

//   // request.headers.addAll(
//   //     {'Authorization': SharedPref.pref!.getString(Preferences.token) ?? ""});

//   request.files.add(
//     http.MultipartFile.fromBytes(
//       "file",
//       imageData,
//       filename: filename, // Use the provided filename for the image
//     ),
//   );

//   request.fields["district"] = district;
//   request.fields["block"] = block;
//   request.fields["school"] = school;
//   request.fields["program_name"] = programName;

//   //-------Send request

//   var resp = await request.send();

//   http.Response response = await http.Response.fromStream(resp);
//   return response;
// }

Future<http.Response> uploadDataWithImage({
  required String url,
  required Map<dynamic, dynamic> body,
  Uint8List? imageData,
  String? filename, // Add token parameter
}) async {
  final request = http.MultipartRequest("POST", Uri.parse(baseUrl + url));
  //  String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";

  // // Add headers from the curl example
  // request.headers.addAll({
  //   'Authorization': 'Bearer $sessionToken',
  //   'foldername': 'School',
  // });

  // Convert and add fields with correct naming
  body.forEach((key, value) {
    // Handle special cases for field names
    String fieldName = key;
    if (key == 'emergency_contact_name') fieldName = 'emergencyContactName';
    if (key == 'emergency_contact_number') fieldName = 'emergencyContactNumber';
    
    // Handle array fields (like allergies)
    if (value is List) {
      request.fields[fieldName] = jsonEncode(value);
    } else {
      request.fields[fieldName] = value.toString();
    }
  });

  // Add image file with correct field name 'School'
  if (imageData != null) {
    request.files.add(
      http.MultipartFile.fromBytes(
        'School', 
        imageData,
        filename: filename ?? 'profile.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  // ✅ Print response
  print("✅ Status Code: ${response.statusCode}");
  print("📨 Response Body: ${response.body}");

  return response;
  
}
Future<http.Response> uploadImageData({
  required Uint8List imageData,
  required String url,
  required String foldername,
}) async {
  //String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";

  final request = http.MultipartRequest("POST", Uri.parse(baseUrl + url));

  request.headers.addAll({
   // 'Authorization': 'Bearer $sessionToken',
    'foldername': foldername, // ✅ Correct header key
  });

  request.files.add(
    http.MultipartFile.fromBytes(
      "School", 
      imageData,
      filename: "profile.jpg",
      contentType: MediaType('image', 'jpeg'),
    ),
  );

  final streamedResponse = await request.send();
  return await http.Response.fromStream(streamedResponse);
}

Future<http.Response> getdataaa({
  required String url,
  bool isCustomUrl = false,
  bool addToken = true,
}) async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

  // String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";
//  final token = await _getToken();
//   if (addToken) {
//     requestHeaders = appendAccessTokenWith({}, sessionToken);
//   }

  //else {
  requestHeaders.addAll({
   //'Authorization': 'Bearer ${sessionToken}'
    
    });
  //}

  final response = await client.get(
    isCustomUrl ? Uri.parse(url) : Uri.parse(baseUrl + url),
    headers: requestHeaders,
  );

  return response;
}


Future<http.Response> getdataaatoken({
  required String url,
  bool isCustomUrl = false,
  bool addToken = true,
}) async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

 //  String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";
//  final token = await _getToken();
//   if (addToken) {
//     requestHeaders = appendAccessTokenWith({}, sessionToken);
//   }

  //else {
  requestHeaders.addAll({
   'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Im1hZGFhbmRocnV2MDNAZ21haWwuY29tIiwic2Nob29sSWQiOiI2OGE0MTE3ZjUxODcwMGJjNzVhZTA5ZmYiLCJpZCI6IjY4ZTNhMzc1MWRlOTEyNGQ2M2MwMmY0OCIsInJvbGUiOiJzdHVkZW50IiwiaWF0IjoxNzY0NzM5NTgzLCJleHAiOjE3NjUzNDQzODN9.F6HCUFhV-SkN1JRv6XiYvys9sMjhKfyJXv5N4EomYbg'
    
    });
  //}

  final response = await client.get(
    isCustomUrl ? Uri.parse(url) : Uri.parse(baseUrl + url),
    headers: requestHeaders,
  );

  return response;
}

Future<http.Response> getdataaaadmin({
  required String url,
  bool isCustomUrl = false,
  bool addToken = true,
}) async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

  // String sessionToken = SharedPref.pref!.getString(Preferences.token) ?? "";
//  final token = await _getToken();
//   if (addToken) {
//     requestHeaders = appendAccessTokenWith({}, sessionToken);
//   }

  //else {
  requestHeaders.addAll({
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImRzbXMuZGV2c2hhcm1hQGdtYWlsLmNvbSIsInNjaG9vbElkIjoiNjhhNWJjMDNlOTg0MTJiOGQ5ZTMxNWEzIiwiaWQiOiI2OGRkNDM2NWE1ZWFjZjQxMTkxMWNlMTQiLCJyb2xlIjoic3R1ZGVudCIsImlhdCI6MTc2MTczMTg1NSwiZXhwIjoxNzYyMzM2NjU1fQ.O1QgqIlDfj3dEBHA4N8ISr6rj-iwQGl3wl1NJ1L2fRc'
    
    });
  //}

  final response = await client.get(
    isCustomUrl ? Uri.parse(url) : Uri.parse(baseUrl + url),
    headers: requestHeaders,
  );

  return response;
}


}
