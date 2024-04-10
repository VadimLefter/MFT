import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiClient {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> postGetTransactionSoap(
      Map<String, dynamic> data) async {
    const url =
        'https://dev.edi.md/ISFiscalCloudServiceTaxi/GetTransactionSoap';

    try {
      final response = await _dio.post(url, data: data);
      if (response.statusCode == 200) {
        final jsonData = response.data;
        if (jsonData != null) {
          print('succes');
          return jsonData;
        } else {
          throw Exception('Invalid response data');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
