import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:receive_intent/receive_intent.dart%20';
import '../../../data/api_client/api_client.dart';
import 'package:xml/xml.dart' as xml;

import '../../../data/api_client/services/encode_service.dart';

class MyAppViewModel {
  final Intent? intent;

  MyAppViewModel(this.intent);

  final _apiClient = ApiClient();
  final _encodeService = EncodeService();
  Map<String, dynamic>? _closeResult;

  Future<void> startActivity() async {
    try {
      final fcid = _prepareExtra();
      final soap = await _getSoap(fcid);
      final mevResponse = await _getDataFiscalReceipt(soap);
      if (mevResponse == null) {
        log('mevResponse null');
        _closeResult = { 'errorCode': -1 };
        await _setActivityResult(_closeResult!);
      }
      final cloudResponse = await _sendMevResponse(mevResponse!, fcid);
      log('cloudResponse ${cloudResponse ?? -1}');

      _closeResult = { 'errorCode': cloudResponse };
      _setActivityResult(_closeResult!);
    } catch (e) {
      log('Error startActivity: ${e.toString()}');
      final containsData = intent?.extra?.keys.contains('data');
      if(containsData! == true){
        _closeResult = { 'errorCode': -1 };
        await _setActivityResult(_closeResult!);
        return;
      } else {
        return;
      }
    }
  }

  String _prepareExtra() {
    final data = intent?.extra;
    if (data == null) {
      log('Error _prepareExtra, intent null');
      return '';
    }
    final fcid = data['data'] as String;
    return fcid;
  }

  Future<Uint8List> _getSoap(String fcid) async {
    final response = await _apiClient.getTransactionSoap(fcid);
    if(response?['soap'] == null && response != null) {
      _closeResult = { 'errorCode': response['errorCode'] };
      await _setActivityResult(_closeResult!);
    }
    final soapString = response?['soap'] as String;
    final soapBytes = _encodeService.decodeData(fcid, soapString);
    return soapBytes;
  }

  Future<Map<String, dynamic>?> _getDataFiscalReceipt(Uint8List data) async {
    final response = await _apiClient.addFiscalReceipt(data);
    if (response == null) {
      log('addFiscalReceiptResponse null');
      return null;
    } else {
      final data = _parseXml(response);
      log('data fiscal receipt: $data');
      return data;
    }
  }

  Map<String, dynamic> _parseXml(String response) {
    Map<String, dynamic> data = {};
    try {
      xml.XmlDocument document = xml.XmlDocument.parse(response);
      final envelope = document.findElements('SOAP-ENV:Envelope').first;
      final body = envelope.findElements('SOAP-ENV:Body');
      final globalResponse = body.first.findElements('atrt:globalResponse');

      for (var item in globalResponse) {
        final id = item.findElements('id').first.innerText;
        final code = item.findElements('code').first.innerText;
        final state = item.findElements('state').first.innerText;
        final comment = item.findElements('comment').first.innerText;

        data['id'] = id;
        data['code'] = code;
        data['state'] = state;
        data['comment'] = comment;
        data['response'] = response;
      }
      return data;
    } catch(e) {
      return jsonDecode(response);
    }

  }

  Future<int?> _sendMevResponse(
      Map<String, dynamic> mevData, String fcid) async {
    DateTime dateTime = DateTime.parse(DateTime.now().toString());
    String mevDate = dateTime.toUtc().toIso8601String();
    final mevId = mevData['id'] as String;
    final mevResponse = mevData['response'] as String;
    final mevErrorCode = mevData['code'] as String;
    final date = mevId.isNotEmpty ? mevDate : '';
    String errorMessage = '';
    if(mevErrorCode != '1') {
      errorMessage = mevData['comment'] as String;
    }

    final mevIdEncode = _encodeService.encryptData(fcid, mevId);
    final mevResponseEncode = _encodeService.encryptData(fcid, mevResponse);

    final body = {
      'fcid': fcid,
      'mevid': mevIdEncode,
      'mevDate': date,
      'mevResponse': mevResponseEncode,
      'errorMessage': errorMessage
    };
    log('body: postUpdateTransactionState : $body');
    final response = await _apiClient.postUpdateTransactionState(body);
    log('postUpdateTransactionState response : $response');
    return response;
  }

  Future<void> _setActivityResult(Map<String, dynamic> value) async {
    await ReceiveIntent.setResult(kActivityResultOk,
        data: {'data': jsonEncode(value)}, shouldFinish: true);
  }


}
