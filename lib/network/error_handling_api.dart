import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';


import 'package:http/http.dart' as http;


enum DataState { empty, error, loading, loaded }

class OnComplete<T> {
  T? data;
  bool? isUnauthenticated;
  bool? isSuccessed;
  String? message;
  OnComplete(
      {this.data,
      this.isSuccessed,
      this.message,
      this.isUnauthenticated = false});
  factory OnComplete.success(T data) {
    return OnComplete(
      data: data,
      isSuccessed: true,
      isUnauthenticated: false,
    );
  }

  factory OnComplete.error(String message) {
    return OnComplete(
      data: null,
      isSuccessed: false,
      message: message,
      isUnauthenticated: false,
    );
  }
}

class RequestedData<T> {
  final DataState dataState;
  final T? data;
  final String? message;
  RequestedData({this.dataState = DataState.empty, this.data, this.message});

  factory RequestedData.initial() =>
      RequestedData<T>(dataState: DataState.empty, data: null, message: null);
  factory RequestedData.loading() =>
      RequestedData<T>(dataState: DataState.loading, data: null, message: null);

  factory RequestedData.success(T data) =>
      RequestedData<T>(dataState: DataState.loaded, data: data, message: null);
  factory RequestedData.error(String message) => RequestedData<T>(
      dataState: DataState.error, data: null, message: message);
}

class ApiResponse<T> {
  final int? statusCode;
  T? result;
  bool? success;
  String? message;
  ApiResponse({
    this.result,
    this.statusCode,
    this.success,
    this.message,
  });
}

Future<ApiResponse> apiRequest(
    {Future<dynamic>? request, BuildContext? context}) async {
  print('apiRequest');
  try {
    http.Response response = await request;
    log('response: ${response.statusCode}');
    if (response.body != null) {
      log('response.body: ${response.body}');
    }

    switch (response.statusCode) {
      case 200:
        return ApiResponse(
            success: true,
            message: "",
            result: (response.body.isNotEmpty)
                ? jsonDecode(utf8.decode(response.bodyBytes))
                : "");
      case 202:
        return ApiResponse(
            success: true,
            message: (response.body.isNotEmpty)
                ? jsonDecode(response.body)['message']
                : "",
            result:
                (response.body.isNotEmpty) ? jsonDecode(response.body) : "");
      case 201:
        return ApiResponse(
            success: true,
            message: (response.body.isNotEmpty)
                ? (jsonDecode(response.body) != null &&
                        (response.body.contains("message"))
                    ? jsonDecode(response.body)['message']
                    : "")
                : "",
            result:
                (response.body.isNotEmpty) ? jsonDecode(response.body) : "");

      case 401:
        return ApiResponse(
          
            statusCode: 401,
            success: false,
            message: (response.body.isNotEmpty)
                ? jsonDecode(response.body)['message']
                : "Something Went Wrong",
            result: 
            //logOut(),
               (response.body.isNotEmpty) ? jsonDecode(response.body) : ""
                
                );

      case 400:
        return ApiResponse(
            statusCode: 400,
            success: false,
            message: jsonDecode(response.body)['message'] ?? "",
            result:
                (response.body.isNotEmpty) ? jsonDecode(response.body) : "");
      case 503:
        return ApiResponse(
            statusCode: 503,
            success: false,
            message: "Service Not Available",
            result: (response.body.isNotEmpty) ? response.body : "");

      case 403:
        return ApiResponse(
            statusCode: 403,
            success: false,
            message: jsonDecode(response.body)['message'] ?? "",
            result:
                (response.body.isNotEmpty) ? jsonDecode(response.body) : "");

      default:
        return ApiResponse(
            success: false,
            message: (response.body.isNotEmpty)
                ? jsonDecode(response.body)['message']
                : "Something Went Wrong",
            result: (response.body.isNotEmpty)
                ? jsonDecode(response.body)['data']
                : "");
    }

   
  } catch (e) {
    return ApiResponse(
      success: false,
      message: "Something went wrong",
    );
  }
  
}