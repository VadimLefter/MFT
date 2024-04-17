import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> getTransactionSoap(String fcid) async {
    String url =
        'https://dev.edi.md/ISFiscalCloudServiceTaxi/GetTransactionSoap?fcid=$fcid';

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final jsonData = response.data;
        if (jsonData != null) {
          log('getTransactionSoap success');
          log('$jsonData');
          return jsonData;
        } else {
          throw Exception('Invalid response data');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }

  Future<String?> addFiscalReceipt(Uint8List soap) async {
    String url = 'https://sift-premev.sfs.md/api/v3/ATRT';
    final options = Options(
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'https://sift-premev.sfs.md/api/v3/ATRT/addFiscalReceipt',
      },
      validateStatus: (status) => status == 200 || status == 400,
      receiveTimeout: const Duration(seconds: 15),
    );

    try {
      final response = await _dio.post(url, data: soap , options: options);
      if(response.statusCode == 200) {
        log('addFiscalReceipt success , response:\n ${response.data}');
        String result = response.data;
        return result;
      } else if(response.statusCode == 400) {
        log('addFiscalReceipt error , response:\n ${response.data}');
        String result = response.data;
        return result;
      } else {
        throw Exception('Failed to load data');
      }

    } on DioException catch(e) {
      if(e.type == DioExceptionType.receiveTimeout) {
        final body = {
          'id': '0',
          'code': '14',
          'mevResponse': 'FAILED',
          'comment': 'Timeout Exception',
        };
        final bodyString = jsonEncode(body);
        return bodyString;
      } else if(e.type == DioExceptionType.badResponse) {
        final body = {
          'id': '0',
          'code': '13',
          'mevResponse': 'FAILED',
          'comment': 'Bad Response',
        };
        final bodyString = jsonEncode(body);
        return bodyString;
      }

    } on SocketException {
      final body = {
        'id': '0',
        'code': '15',
        'mevResponse': 'FAILED',
        'errorMessage': 'Socket Exception',
      };
      final bodyString = jsonEncode(body);
      return bodyString;

    } catch(e) {
      log('addFiscalReceipt error : $e');
      return null;
    }
    return null;
  }

  Future<int?> postUpdateTransactionState(Map<String, dynamic> body) async {
    const url = 'https://dev.edi.md/ISFiscalCloudServiceTaxi/UpdateTransactionState';

    try {
      final response = await _dio.post(url, data: body);
      if(response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
        log('postUpdateTransactionState success, response: ${response.data}');
        return jsonData['errorCode'] as int;
      }
    } catch(e) {
      log('error postUpdateTransactionState $e');
    }
    return null;
  }

}
