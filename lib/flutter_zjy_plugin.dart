import 'dart:async';
import 'package:flutter/services.dart';


typedef void EventHandler(dynamic event);
class FlutterZjyPlugin {
  static const MethodChannel _channel =
  const MethodChannel('flutter_zjy_plugin');

  // StreamSubscription<dynamic> _eventSubscripton;
//  FlutterZjyPlugin(){
//    //初始化事件
//    initEvent();
//  }

//  initEvent(){
//    _eventSubscripton = _eventChannelFor()
//        .receiveBroadcastStream()
//        .listen(eventListener,onError: errorListener);
//  }

  static listenEvent(EventHandler onEvent, EventHandler onError) {
    EventChannel("flutter_zjy_plugin_event").
    receiveBroadcastStream()
        .listen(onEvent,onError: onError);
  }


  void eventListener(dynamic event){
//    Map<dynamic,dynamic> map = event;
//    switch(map['event']){
//      case "connect":
//        String value = map["value"];
//
//        break;
//    }
  }

  void errorListener(Object obj){

  }

  EventChannel _eventChannelFor(){
    return EventChannel("flutter_zjy_plugin_event");
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  //蓝牙是否打开
  static Future<Map<dynamic,dynamic>> get isOpenBle async {
    print("调用了");
    var response = await _channel.invokeMethod('isOpenBle');
    print("打印内容：："+response.toString());
    Map<dynamic,dynamic> mapObj = response["openBle"];
    return mapObj;
  }

  //连接打印机
  static Future<void>  connectPrinterConnected(String shownName) async{
    await _channel.invokeMethod(
        'connectPrinterConnected', <String, dynamic>{'shownName': shownName});
  }

  //打印机是否连接成功
  static Future<int> get isPrinterConnected async {
    final int isPrinterConnected = await _channel.invokeMethod('isPrinterConnected');
    return isPrinterConnected;
  }

  //连接对应的蓝牙的打印机
  static Future<int> setConnectBlePrint(String shownName) async {
    final int backCall = await _channel.invokeMethod(
        'setConnectBlePrint', <String, dynamic>{'shownName': shownName});
    return backCall;
  }

  //打印二维码
  static Future<bool> print2dBarcode(String qrCode,String number,String serialNum,String printNum) async {
    final bool print2dBarcode = await _channel.invokeMethod('print2dBarcode',
        <String,dynamic>{"qrCode":qrCode,"number":number,"serialNum":serialNum,"printNum":printNum});
    return print2dBarcode;
  }

  //搜索ios蓝牙打印机列表
  static Future<Map<dynamic,dynamic>> iosBlueToothSearch() async {
    Map<dynamic,dynamic> response = await _channel.invokeMethod(
        'iosBlueToothSearch');
    return response;
  }

  //连接ios指定名字的打印机
  static Future<String> iosOpenPrinter(String shownName) async {
    String response = await _channel.invokeMethod(
        'iosOpenPrinter', <String, dynamic>{'shownName': shownName});
    return response;
  }

  //ios读取当前连接的打印机的的名称
  static Future<String> iosConnectingPrinterName() async {
    String response = await _channel.invokeMethod(
        'iosConnectingPrinterName');
    return response;
  }

  //开始打印二维码
  static Future<void> iosPrintLabel(String qrCode,String number,String serialNum,String printNum) async {
    await _channel.invokeMethod(
        'iosPrintLabel',<String,dynamic>{"qrCode":qrCode,"number":number,"serialNum":serialNum,"printNum":printNum});
  }

  //android读取当前连接的打印机的的名称
  static Future<String> get getConnectSuccessBleName async {

    var response = await _channel.invokeMethod('getConnectSuccessBleName');
    print("连接打印机名字：："+response.toString());
    return response;
  }

  static Future<void> get iosClosePrint async {
    await _channel.invokeMethod(
        'iosClosePrint');
  }
}
