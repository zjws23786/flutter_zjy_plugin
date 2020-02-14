import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_zjy_plugin/flutter_zjy_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List bleList;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterZjyPlugin.platformVersion;
//      bool isOpenble = await FlutterZjyPlugin.isPrinterConnected;
      print("蓝牙是否打开::");
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          margin: EdgeInsets.only(top: 50,left: 50),
          child: Column(
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              RaisedButton(
                onPressed: ()async{
//                  int flag = await FlutterZjyPlugin.isPrinterConnected;
//                  print("打印内容::"+flag.toString());
                  Map<dynamic,dynamic> mapObj = await FlutterZjyPlugin.isOpenBle;
//                  print("打印内容::"+string);
                  print(mapObj);
                  int openState = mapObj["openState"];
                  print(openState.toString());
                  if(openState == 1){
                    bool flag = mapObj["bleConnectedSuccess"]??false;
                    print(flag);
                    if(!flag){
                      bleList = mapObj["bleList"];
                      setState(() {
                        bleList;
                      });
//                      print(list[0]);
//                    showAlertDialog(context,bleList);
                    }else{
                      print("蓝牙连接成功");
                    }
                  }
                },
                child: Text("测试调用底层代码",style:
                TextStyle(fontSize: 18,color: Colors.red,fontWeight: FontWeight.bold),),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "请选择对应蓝牙",
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
//                width: MediaQuery.of(context).size.width,
                height: 40,
                decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: Color(0xffeeeeee)),
                    )),
              ),
              bleList==null ? Container():Column(
                  children: bleList.asMap().keys.map((index) {
                    return RawMaterialButton(
                      child: Container(
                        height: 70,
                        padding: EdgeInsets.only(left: 15, right: 15),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          bleList[index],
                          style: TextStyle(
                              color: Color(0xff666666), fontSize: 15),
                        ),
                        // color: Colors.grey,
                        decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1, color: Color(0xffeeeeee)),
                            )),
                      ),
                      onPressed: ()async{
                        FlutterZjyPlugin.setConnectBlePrint(bleList[index]);
                      },
                    );
                  }).toList(),
                ),
              RaisedButton(
                onPressed: ()async{
                  String qrCode = "http://www.equipmentsafety.cn/?recode=201810061727081030604";
                  String number = "SRX00395";
                  String serialNum = "XUG0143SJJRL02484";
                  bool flag = await FlutterZjyPlugin.print2dBarcode(qrCode,number,serialNum);
                  print("打印状态：："+flag.toString());

                },
                child: Text("调用对应蓝牙的打印机",style:
                TextStyle(fontSize: 18,color: Colors.red,fontWeight: FontWeight.bold),),
              ),
            ],
          )
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context, List list) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding:
            EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 15),
            content: Container(
              height: 400,
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "请选择对应蓝牙",
                      style: TextStyle(
                          color: Color(0xff333333),
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
//                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1, color: Color(0xffeeeeee)),
                        )),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: list.asMap().keys.map((index) {
                        return RawMaterialButton(
                          child: Container(
//                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            padding: EdgeInsets.only(left: 15, right: 15),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              list[index],
                              style: TextStyle(
                                  color: Color(0xff666666), fontSize: 15),
                            ),
                            // color: Colors.grey,
                            decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xffeeeeee)),
                                )),
                          ),
                          onPressed: ()async{

                          },
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
