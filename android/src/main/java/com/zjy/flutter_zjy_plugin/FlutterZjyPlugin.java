package com.zjy.flutter_zjy_plugin;

import androidx.annotation.NonNull;

import com.zjy.flutter_zjy_plugin.uitls.BleUtils;
import com.zjy.flutter_zjy_plugin.uitls.ConstraintsMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterZjyPlugin */
public class FlutterZjyPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel mMethodChannel;
  //事件派发对象
  private EventChannel.EventSink eventSink;
  private EventChannel eventChannel;
  //事件派发流
  private EventChannel.StreamHandler streamHandler = new EventChannel.StreamHandler() {
    @Override
    public void onListen(Object arguments, EventChannel.EventSink sinks) {
      eventSink = sinks;
//      if (eventSink != null){
//        ConstraintsMap params = new ConstraintsMap();
//        params.putString("event","demoEvent");
//        params.putString("value","value is 10");
//        eventSink.success(params.toMap());
//      }
    }

    @Override
    public void onCancel(Object arguments) {
//      eventSink = null;
    }
  };

  //此处是新的插件加载注册方式
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    mMethodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_zjy_plugin");
    mMethodChannel.setMethodCallHandler(this);

    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(),"flutter_zjy_plugin_event");
    eventChannel.setStreamHandler(streamHandler);

  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_zjy_plugin");
    channel.setMethodCallHandler(new FlutterZjyPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    BleUtils bleUtils = BleUtils.getInstant();
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("isOpenBle")){  //是否打开蓝牙（蓝牙状态）
      ConstraintsMap params = new ConstraintsMap();
      params.putMap("openBle", bleUtils.isOpenBle());
      System.out.println("Android底层集合：："+params.toMap().toString());
      result.success(params.toMap());
    }else if (call.method.equals("connectPrinterConnected")){ //开始连接打印机
      if (eventSink != null){
        System.out.println("");
        System.out.println("");
        System.out.println("");
      }
      String shownName = call.argument("shownName");
      bleUtils.connectPrinterConnected(eventSink,shownName);
    }else if (call.method.equals("isPrinterConnected")){ //对应蓝牙的打印机是否连接成功
      result.success(bleUtils.isPrinterConnected());

//      if (eventSink != null){
//        ConstraintsMap params = new ConstraintsMap();
//        params.putString("event","demoEvent");
//        params.putString("value","value is 10");
//        eventSink.success(params.toMap());
//      }

    }else if (call.method.equals("setConnectBlePrint")){  //连接对应蓝牙的打印机
      String shownName = call.argument("shownName");
      int flag = bleUtils.setConnectBlePrint(shownName);
      result.success(flag);
    }else if (call.method.equals("print2dBarcode")){  //打印二维码
      String qrCode = call.argument("qrCode");
      String number = call.argument("number");
      String serialNum = call.argument("serialNum");
      String printNum = call.argument("printNum");
      result.success(bleUtils.print2dBarcode(qrCode,number,serialNum,printNum));
    }else if (call.method.equals("getConnectSuccessBleName")){  //获取连接成功后打印机的名字
      String bleName = bleUtils.getConnectSuccessBleName();
      result.success(bleName);
    }else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
