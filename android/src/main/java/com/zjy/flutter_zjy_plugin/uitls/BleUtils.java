package com.zjy.flutter_zjy_plugin.uitls;

import android.bluetooth.BluetoothAdapter;
import android.graphics.Bitmap;
import android.os.Bundle;

import com.dothantech.lpapi.LPAPI;
import com.dothantech.printer.IDzPrinter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BleUtils {

    /********************************************************************************************************************************************/
    // DzPrinter连接打印功能相关
    /********************************************************************************************************************************************/

    // LPAPI 打印机操作相关的回调函数。
    private final LPAPI.Callback mCallback = new LPAPI.Callback() {

        /****************************************************************************************************************************************/
        // 所有回调函数都是在打印线程中被调用，因此如果需要刷新界面，需要发送消息给界面主线程，以避免互斥等繁琐操作。
        /****************************************************************************************************************************************/

        // 打印机连接状态发生变化时被调用
        @Override
        public void onStateChange(IDzPrinter.PrinterAddress arg0, IDzPrinter.PrinterState arg1) {
            final IDzPrinter.PrinterAddress printer = arg0;
            switch (arg1) {
                case Connected:
                case Connected2:
                    // 打印机连接成功，发送通知，刷新界面提示
//                    mHandler.post(new Runnable() {
//                        @Override
//                        public void run() {
//                            onPrinterConnected(printer);
//                        }
//                    });
                    break;

                case Disconnected:
                    // 打印机连接失败、断开连接，发送通知，刷新界面提示
//                    mHandler.post(new Runnable() {
//                        @Override
//                        public void run() {
//                            onPrinterDisconnected();
//                        }
//                    });
                    break;

                default:
                    break;
            }
        }

        // 蓝牙适配器状态发生变化时被调用
        @Override
        public void onProgressInfo(IDzPrinter.ProgressInfo arg0, Object arg1) {
        }

        @Override
        public void onPrinterDiscovery(IDzPrinter.PrinterAddress arg0, IDzPrinter.PrinterInfo arg1) {
        }

        // 打印标签的进度发生变化是被调用
        @Override
        public void onPrintProgress(IDzPrinter.PrinterAddress address, Object bitmapData, IDzPrinter.PrintProgress progress, Object addiInfo) {
            switch (progress) {
                case Success:
                    // 打印标签成功，发送通知，刷新界面提示
//                    mHandler.post(new Runnable() {
//                        @Override
//                        public void run() {
//                            onPrintSuccess();
//                        }
//                    });
                    break;

                case Failed:
                    // 打印标签失败，发送通知，刷新界面提示
//                    mHandler.post(new Runnable() {
//                        @Override
//                        public void run() {
//                            onPrintFailed();
//                        }
//                    });
                    break;

                default:
                    break;
            }
        }
    };

    private static BleUtils instant = null;
    private LPAPI api;
    // 上次连接成功的设备对象
    private IDzPrinter.PrinterAddress mPrinterAddress = null;
    // 打印参数
    private int printQuality = -1;
    private int printDensity = -1;
    private int printSpeed = -1;
    private int gapType = -1;

    public static BleUtils getInstant(){
        if (instant == null){
            instant = new BleUtils();
        }
        return instant;
    }

    //搜索蓝牙地址
    private List<IDzPrinter.PrinterAddress> pairedPrinters = new ArrayList<IDzPrinter.PrinterAddress>();

    /**
     *
     * @return  0:蓝牙未打开  1:蓝牙以打开  2不支持蓝牙
     */
    public Map<String,Object> isOpenBle(){
        Map<String,Object> map = new HashMap<>();
        BluetoothAdapter btAdapter = BluetoothAdapter.getDefaultAdapter();
        if (btAdapter == null) {
            map.put("openState",2);
            return map;
        }
        if (!btAdapter.isEnabled()) {
            map.put("openState",0);
            return map;
        }


        if (api == null){
            // 调用LPAPI对象的init方法初始化对象
            this.api = LPAPI.Factory.createInstance(mCallback);
        }

        // 尝试连接上次成功连接的打印机
        if (mPrinterAddress != null && api.openPrinterByAddress(mPrinterAddress)) {
            // 连接打印机的请求提交成功，刷新界面提示
//          onPrinterConnecting(mPrinterAddress, false);
//          return;
            map.put("bleConnectedSuccess",true);
        }else{
            pairedPrinters = api.getAllPrinterAddresses(null);
            List<String> list = new ArrayList<>();
            for (IDzPrinter.PrinterAddress item:pairedPrinters){
                list.add(item.shownName);
                setConnectBlePrint(item.shownName);
            }
            map.put("bleList",list);
//            System.out.println("蓝牙列表::"+list.toString());
//            map.put("bleList",pairedPrinters);
        }
//

//        new AlertDialog.Builder(MainActivity.this).setTitle(R.string.selectbondeddevice).setAdapter(new DeviceListAdapter(), new DeviceListItemClicker()).show();
        map.put("openState",1);

        return map;
    }

    /**
     * 判断当前打印机是否连接
     * @return  0:打印机未连接 1:打印机已连接 2:打印机正在连接
     */
    public int isPrinterConnected() {
        // 调用LPAPI对象的getPrinterState方法获取当前打印机的连接状态
        IDzPrinter.PrinterState state = api.getPrinterState();

        // 打印机未连接
        if (state == null || state.equals(IDzPrinter.PrinterState.Disconnected)) {
            return 0;
        }

        // 打印机正在连接
        if (state.equals(IDzPrinter.PrinterState.Connecting)) {
            return 2;
        }

        // 打印机已连接
        return 1;
    }

    /**
     * 配对蓝牙成功后的打印机是否连接成功（提前是蓝牙要配对成功）
     * @param shownName 0 连接失败  1 连接成功
     * @return
     */
    public int setConnectBlePrint(String shownName){
        for (IDzPrinter.PrinterAddress item:pairedPrinters){
            if (item.shownName.equals(shownName)){
                if (api.openPrinterByAddress(item)) {
                    System.out.println("Android底层：：打印机连接成功");
                    return 1;
                }
                break;
            }
        }
        return 0;
    }

    // 获取打印时需要的打印参数
    private Bundle getPrintParam(int copies, int orientation) {
        Bundle param = new Bundle();

        // 打印浓度
        if (printDensity >= 0) {
            param.putInt(IDzPrinter.PrintParamName.PRINT_DENSITY, printDensity);
        }

        // 打印速度
        if (printSpeed >= 0) {
            param.putInt(IDzPrinter.PrintParamName.PRINT_SPEED, printSpeed);
        }

        // 间隔类型
        if (gapType >= 0) {
            param.putInt(IDzPrinter.PrintParamName.GAP_TYPE, gapType);
        }

        // 打印页面旋转角度
        if (orientation != 0) {
            param.putInt(IDzPrinter.PrintParamName.PRINT_DIRECTION, orientation);
        }

        // 打印份数
        if (copies > 1) {
            param.putInt(IDzPrinter.PrintParamName.PRINT_COPIES, copies);
        }

        return param;
    }

    /********************************************************************************************************************************************/
    // LPAPI绘图打印相关
    /********************************************************************************************************************************************/

    // 打印文本
    private boolean printText(String text, Bundle param) {

        // 开始绘图任务，传入参数(页面宽度, 页面高度)
        api.startJob(48, 50, 0);

        // 开始一个页面的绘制，绘制文本字符串
        // 传入参数(需要绘制的文本字符串, 绘制的文本框左上角水平位置, 绘制的文本框左上角垂直位置, 绘制的文本框水平宽度, 绘制的文本框垂直高度, 文字大小, 字体风格)
        api.drawText(text, 4, 5, 40, 40, 4);

        // 结束绘图任务提交打印
        return api.commitJob();
    }

    // 打印文本一维码
    private boolean printText1DBarcode(String text, String onedBarcde, Bundle param) {

        // 开始绘图任务，传入参数(页面宽度, 页面高度)
        api.startJob(48, 48, 90);

        // 开始一个页面的绘制，绘制文本字符串
        // 传入参数(需要绘制的文本字符串, 绘制的文本框左上角水平位置, 绘制的文本框左上角垂直位置, 绘制的文本框水平宽度, 绘制的文本框垂直高度, 文字大小, 字体风格)
        api.drawText(text, 4, 4, 40, 20, 4);

        // 设置之后绘制的对象内容旋转180度
        api.setItemOrientation(180);

        // 绘制一维码，此一维码绘制时内容会旋转180度，
        // 传入参数(需要绘制的一维码的数据, 绘制的一维码左上角水平位置, 绘制的一维码左上角垂直位置, 绘制的一维码水平宽度, 绘制的一维码垂直高度)
        api.draw1DBarcode(onedBarcde, LPAPI.BarcodeType.AUTO, 4, 25, 40, 15, 3);

        // 结束绘图任务提交打印
        return api.commitJob();
    }

    // 打印二维码
    public boolean print2dBarcode(String qrCode,String number,String serialNum) {
        // 开始绘图任务，传入参数(页面宽度, 页面高度)
        api.startJob(48, 66, 0);

        // 开始一个页面的绘制，绘制二维码
        // 传入参数(需要绘制的二维码的数据, 绘制的二维码左上角水平位置, 绘制的二维码左上角垂直位置, 绘制的二维码的宽度(宽高相同))
        api.draw2DQRCode(qrCode, 4, 10, 38);

        // 开始一个页面的绘制，绘制文本字符串
        // 传入参数(需要绘制的文本字符串,
        // 绘制的文本框左上角水平位置, 绘制的文本框左上角垂直位置,
        // 绘制的文本框水平宽度, 绘制的文本框垂直高度,
        // 文字大小, 字体风格)
        api.drawText("自编号："+number, 4, 50, 40, 20, 4);
        api.drawText("序列号："+serialNum, 4, 56, 40, 20, 4);

        // 结束绘图任务提交打印
        return api.commitJob();
    }

    // 打印图片
    private boolean printBitmap(Bitmap bitmap, Bundle param) {
        // 打印
        return api.printBitmap(bitmap, param);
    }

    /**
     * 退出蓝牙
     */
    private void exitBle(){
        if (api != null){
            api.quit();
        }
        instant = null;
        mPrinterAddress = null;

    }

}
