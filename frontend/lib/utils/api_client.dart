import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ApiClient {
  final String baseUrl = 'http://10.0.2.2:5000/api';
  String? token;
  ApiClient({this.token});
  
  void setToken(String? newToken) {
    token = newToken;
  }
  
  Future<http.Response> get(String path, {Map<String, String>? queryParams}) {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return http.get(uri, headers: headers);
  }
  
  Future<http.Response> post(String path, {Map<String, dynamic>? body}) {
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> postMultipart(
    String path, {
    Map<String, String>? fields,
    File? imageFile,
    String imageFieldName = 'image',
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    
    // Add authorization header
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add fields
    if (fields != null) {
      request.fields.addAll(fields);
    }
    
    // Add image file
    if (imageFile != null && await imageFile.exists()) {
      var fileStream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        imageFieldName,
        fileStream,
        length,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    }
    
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> put(String path, {Map<String, dynamic>? body}) {
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> putMultipart(
    String path, {
    Map<String, String>? fields,
    File? imageFile,
    String imageFieldName = 'image',
  }) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl$path'));
    
    // Add authorization header
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add fields
    if (fields != null) {
      request.fields.addAll(fields);
    }
    
    // Add image file
    if (imageFile != null && await imageFile.exists()) {
      var fileStream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        imageFieldName,
        fileStream,
        length,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    }
    
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
  
  Future<http.Response> delete(String path) {
    return http.delete(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );
  }
  
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}
