import 'dart:async';
import 'package:flutter/services.dart';


typedef void EventHandler(Object event);
class FlutterZjyPlugin {
  static const MethodChannel _channel =
  const MethodChannel('flutter_zjy_plugin');

  StreamSubscription<dynamic> _eventSubscripton;
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
  static Future<void> connectPrinterConnected(String shownName) async{
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
  static Future<bool>  print2dBarcode(String qrCode,String number,String serialNum,String printNum) async {
    final bool print2dBarcode = await _channel.invokeMethod('print2dBarcode',
        <String,dynamic>{"qrCode":qrCode,"number":number,"serialNum":serialNum,"printNum":printNum});
    return print2dBarcode;
  }

  static Future<void> iosBlueToothConnected() async {
    await _channel.invokeMethod(
        'iosBlueToothConnected');
  }

  static Future<void> iosPrintLabel(String qrCode,String number,String serialNum,String printNum) async {
    await _channel.invokeMethod(
        'iosPrintLabel',<String,dynamic>{"qrCode":qrCode,"number":number,"serialNum":serialNum,"printNum":printNum});
  }

  static Future<void> iosClosePrint() async {
    await _channel.invokeMethod(
        'iosClosePrint');
  }
}
