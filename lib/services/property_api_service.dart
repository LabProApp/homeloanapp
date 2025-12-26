import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:property/models/property_model.dart';
import 'package:property/utility/ApiUrls.dart';

class PropertyApiService {
  //static const String apiUrl =
      //"http://15.206.9.70:8080/api/property/search";

  Future<List<PropertyModel>> fetchProperties() async {
    final response = await http.get(Uri.parse(ApiUrls.propertySearch));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PropertyModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load properties");
    }
  }
}
