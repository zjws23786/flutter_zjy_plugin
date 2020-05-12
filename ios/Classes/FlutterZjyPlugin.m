#import "FlutterZjyPlugin.h"
#import "LPAPI.h"
#import "DzProgress.h"

@implementation FlutterZjyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_zjy_plugin"
            binaryMessenger:[registrar messenger]];
  FlutterZjyPlugin* instance = [[FlutterZjyPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

UIImage *_printLabelImage;
static int printCount;

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if([@"iosOpenPrinter" isEqualToString:call.method]){
      NSDictionary* argsMap = call.arguments;
      NSString* printerName = argsMap[@"shownName"];
            [LPAPI openPrinter:printerName
                   completion:^(BOOL isSuccess)
            {
                if (isSuccess)
                {
                    NSLog(@"连接成功");
                    result([NSString stringWithFormat:@"1"]);
                }
                else
                {
                    NSLog(@"连接失败");
                    result([NSString stringWithFormat:@"0"]);
                }
            }];
  }else if([@"iosBlueToothSearch" isEqualToString:call.method]){
                [LPAPI scanPrinters:NO
                         completion:^(NSArray *scanedPrinterNames)
                 {
                     NSLog(@"搜索到的打印机列表：%@", scanedPrinterNames);
                    if (scanedPrinterNames == nil || scanedPrinterNames.count < 1) {
                        NSDictionary* dict = @{@"state":@"0"};
                        result(dict);
//                        result([NSString stringWithFormat:@"0"]);
                    }else{
//                        result([NSString stringWithFormat:@"1"]);
                        NSDictionary* dict = @{@"state":@"1",@"bleList":scanedPrinterNames};
                        result(dict);
                    }
                 }
            didOpenedPrinterHandler:^(BOOL isSuccess)
                 {
                     if (isSuccess)
                     {
                         NSLog(@"连接成功");
                        result([NSString stringWithFormat:@"2"]);
                         // 获取当前连接的打印机详情
                         PrinterInfo *pi = [LPAPI connectingPrinterDetailInfos];
                     }
                     else
                     {
                         NSLog(@"连接失败");
                         result([NSString stringWithFormat:@"3"]);
                     }
                 }];
  }else if([@"iosPrintLabel" isEqualToString:call.method]){
      NSDictionary* argsMap = call.arguments;
      NSString* qrCode = argsMap[@"qrCode"];
      NSString* number = argsMap[@"number"];
      NSString* serialNum = argsMap[@"serialNum"];
      NSString* printNum = argsMap[@"printNum"];
      printCount = [printNum intValue];
      
      _printLabelImage = nil;
      
      // 设置打印机纸张类型
      //[LPAPI setPrintPageGapType:2];
      
      // 设置打印机打印浓度
      [LPAPI setPrintDarkness:4];
      
      // 设置打印机打印速度
      [LPAPI setPrintSpeed:3];
      
      double labelWidth  = 50;
      double labelHeight = 70;
      
      [LPAPI startDraw:labelWidth
                height:labelHeight
           orientation:0];
      
      [LPAPI drawQRCode:qrCode
          x:3
          y:8
      width:40];
      
      // 水平居中打印文本
      [LPAPI setItemHorizontalAlignment:1];
      NSString* numberStr = [@"管理编号:" stringByAppendingString: number];
      [LPAPI drawText:numberStr
                    x:3
                    y:50
                width:40
               height:5
           fontHeight:4.5];
      
      NSString* serialNumStr = [@"序列号:" stringByAppendingString: serialNum];
      [LPAPI drawText:serialNumStr
                    x:3
                    y:56
                width:40
               height:5
           fontHeight:4.5];
      
      // 结束绘制，并生成要打印的标签
      _printLabelImage = [LPAPI endDraw];
      
      if (_printLabelImage){
             [self printLabels];
        }else{
//             NSLog(@"请先生成标签");
            ShowDismissMark(@"请先生成标签")
         }
  }else if([@"iosClosePrint" isEqualToString:call.method]){
      [LPAPI closePrinter];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)printLabels{
    ShowState(@"正在打印……");
//    printCount = 1;
    [self printTest];
}

- (void)printTest
{
    if (printCount > 0){
        [LPAPI print:^(BOOL isSuccess)
         {
             printCount--;
             [self printTest];
             NSLog(@"打印成功");
         }];
    }else{
        ShowDismissMark(@"打印完成")
        [LPAPI closePrinter];
    }
}

@end
