//
//  XYBLEManager.m
//  Printer
//
//  Created by apple on 16/4/5.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "XYBLEManager.h"
#import "BLEManager.h"

static XYBLEManager *shareInstance = nil;

@interface XYBLEManager ()<BLEManagerDelegate>
@property (nonatomic,strong) BLEManager *manager;
@end

@implementation XYBLEManager
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[XYBLEManager alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    if (self == [super init]) {
        _manager = [BLEManager sharedBLEManager];
        _manager.delegate = self;
 
    }
    return self;
}
- (void)setWritePeripheral:(CBPeripheral *)writePeripheral {
    _writePeripheral = writePeripheral;
    _manager.writePeripheral = writePeripheral;
}
#pragma mark - 开始扫描
- (void)XYstartScan {
    [_manager startScan];
}

#pragma mark - 停止扫描
- (void)XYstopScan {
    [_manager stopScan]; 
}

#pragma mark - 手动断开现连设备 不会重连
- (void)XYdisconnectRootPeripheral {
    [_manager disconnectRootPeripheral];
}

#pragma mark - 发送数据
- (void)XYsendDataToPeripheral:(CBPeripheral *)peripheral dataString:(NSString *)dataStr {
    [_manager sendDataWithPeripheral:peripheral withString:dataStr coding:encodingType];
}


//发送指令的方法
-(void)XYWriteCommandWithData:(NSData *)data{

    [_manager writeCommadnToPrinterWthitData:data];
}
//发送指令，并带回调的方法
-(void)XYWriteCommandWithData:(NSData *)data callBack:(XYTSCCompletionBlock)block{

    [_manager writeCommadnToPrinterWthitData:data withResponse:^(CBCharacteristic *characteristic) {
        block(characteristic);
    }];
}
#pragma mark - 发送TSC指令
//- (void)XYWriteTSCCommondWithData:(NSData *)data callBack:(XYTSCCompletionBlock)block {
//    [_manager writeTSCCommndWithData:data withResponse:^(CBCharacteristic *characteristic) {
//        block(characteristic);
//    }];
//}
//#pragma mark - 发送POS指令
//- (void)XYWritePOSCommondWithData:(NSData *)data callBack:(XYTSCCompletionBlock)block {
//    [_manager writePOSCommndWithData:data withResponse:^(CBCharacteristic *characteristic) {
//        block(characteristic);
//    }];
//}
#pragma mark - 连接指定设备
- (void)XYconnectDevice:(CBPeripheral *)peripheral {
    [_manager connectPeripheral:peripheral completion:^(BOOL isConnected) {
        if (isConnected) {
            if ([self.delegate respondsToSelector:@selector(XYdidConnectPeripheral:)]) {
                [self.delegate XYdidConnectPeripheral:peripheral];
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(XYdidFailToConnectPeripheral:error:)]) {
                [self.delegate XYdidFailToConnectPeripheral:peripheral error:NULL];
            }
        }
    }];
}

#pragma mark - BLEManagerDelegate
/**
 *  扫描到设备后
 */
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager updatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)RSSIArr{
    if ([self.delegate respondsToSelector:@selector(XYdidUpdatePeripheralList:RSSIList:)]) {
        [self.delegate XYdidUpdatePeripheralList:peripherals RSSIList:RSSIArr];
    }
}
/**
 *  连接上设备
 */
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager connectPeripheral:(CBPeripheral *)peripheral {
    
    //    if ([self.delegate respondsToSelector:@selector(didConnectPeripheral:)]) {
    //        [self.delegate didConnectPeripheral:peripheral];
    //    }
}

/**
 *  断开设备
 */
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager disconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect{
    if ([self.delegate respondsToSelector:@selector(XYdidDisconnectPeripheral:isAutoDisconnect:)]) {
        [self.delegate XYdidDisconnectPeripheral:peripheral isAutoDisconnect:isAutoDisconnect];
    }
}

- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(XYdidWriteValueForCharacteristic:error:)]) {
        [self.delegate XYdidWriteValueForCharacteristic:character error:error];
    }
}

- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(XYdidFailToConnectPeripheral:error:)]) {
        [self.delegate XYdidFailToConnectPeripheral:peripheral error:error];
    }
}

//#pragma mark - 其他方法
//#pragma mark - 水平定位
//- (void)XYhorizontalPosition {
//    [_manager horizontalPosition];
//}
//
//#pragma mark - 打印并换行
//- (void)XYprintAndFeed {
//    [_manager printAndFeed];
//}
//
//#pragma mark - 打印并回到标准模式
//- (void)XYPrintAndBackToNormalModel {
//    [_manager printAndBackToNormalModel];
//}
//
//#pragma mark - 取消打印
//- (void)XYCancelPrintData {
//    [_manager cancelPrintData];
//}
//
//#pragma mark - 实时状态传送
//- (void)XYUpdataPrinterState:(int)param completion:(XYPOSCompletionBlock)callBlock{
//    [_manager updataPrinterState:param completion:^(CBCharacteristic *characteristic) {
//        callBlock(characteristic);
//    }];
//}
//
//#pragma mark - 实时请求打印机
//- (void)XYUpdataPrinterAnswer:(int)param {
//    [_manager updataPrinterAnswer:param];
//}
//
//#pragma mark - 实时产生钱箱脉冲
//- (void)XYOpenBoxAndPulse:(int)n m:(int)m t:(int)t {
//    [_manager openBoxAndPulse:n m:m t:t];
//}
//
//#pragma mark - 页模式下打印
//- (void)XYPrintOnPageModel {
//    [_manager printOnPageModel];
//}
//
//#pragma mark - 设置字符右间距
//- (void)XYSetCharRightMargin:(int)n {
//    [_manager setCharRightMargin:n];
//}
//
//#pragma mark - 选择打印模式
//- (void)XYSelectPrintModel:(int)n {
//    [_manager selectPrintModel:n];
//}
//
///**
// * 11.设置绝对打印位置
// *  0 <= nL <= 255
// *  0 <= nh <= 255
// */
//- (void)XYSetPrintLocationWithParam:(int)nL nH:(int)nH
//{
//    [_manager setPrintLocationWithParam:nL nH:nH];
//}
//
///**
// * 12.选择/取消用户自定义字符
// *   0 <= n <= 255
// */
//- (void)XYSelectOrCancelCustomCharacter:(int)n {
//    [_manager selectOrCancelCustomCharacter:n];
//}
//
///**
// * 13.定义用户自定义字符
// */
//- (void)XYDefinCustomCharacter:(int)y c1:(int)c1 c2:(int)c2 dx:(NSArray *)points {
//    [_manager definCustomCharacter:y c1:c1 c2:c2 dx:points];
//}
//
///**
// * 14.选择位图模式
// */
//- (void)XYSelectBitmapModel:(int)m nL:(int)nL nH:(int)nH dx:(NSArray *)points
//{
//    [_manager selectBitmapModel:m nL:nL nH:nH dx:points];
//}
//
///**
// * 15.取消下划线模式
// */
//- (void)XYCancelUnderLineModelWith:(int)n {
//    [_manager cancelUnderLineModel:n];
//}
//
///**
// * 16.设置默认行间距
// */
//- (void)XYSetDefaultLineMargin {
//    [_manager setDefaultLineMargin];
//}
//
///**
// * 17.设置行间距
// */
//- (void)XYSetLineMarginWith:(int)n {
//    [_manager setLineMargin:n];
//}
//
///**
// * 18.选择打印机
// */
//- (void)XYSelectPrinterWith:(int)n {
//    [_manager selectPrinter:n];
//}
//
///**
// * 19.取消用户自定义字符
// */
//- (void)XYCancelCustomCharacterWith:(int)n {
//    [_manager cancelCustomCharacter:n];
//}
//
///**
// * 20.初始化打印机
// */
//- (void)XYInitializePrinter {
//    [_manager initializePrinter];
//}
//
///**
// * 21.设置横向跳格位置
// */
//- (void)XYSetTabLocationWith:(NSArray *)points {
//    [_manager setTabLocationWith:points];
//}
///**
// * 22.选择/取消加粗模式
// */
//- (void)XYSelectOrCancelBoldModelWith:(int)n {
//    [_manager selectOrCancelBoldModel:n];
//}
///**
// * 23.选择/取消双重打印模式
// */
//- (void)XYSelectOrCancelDoublePrintModel:(int)n {
//    [_manager selectOrCancelDoublePrintModel:n];
//}
///**
// * 24.打印并走纸
// */
//- (void)XYPrintAndPushPageWith:(int)n {
//    [_manager printAndPushPage:n];
//}
///**
// * 25.选择页模式
// */
//- (void)XYSelectPageModel {
//    [_manager selectPageModel];
//}
///**
// * 26.选择字体
// */
//- (void)XYSelectFontWith:(int)n {
//    [_manager selectFont:n];
//}
///**
// * 27.选择国际字符集
// */
//- (void)XYSelectINTL_CHAR_SETWith:(int)n {
//    [_manager selectINTL_CHAR_SETWith:n];
//}
///**
// * 28.选择标准模式
// */
//- (void)XYSelectNormalModel {
//    [_manager selectNormalModel];
//}
///**
// * 29.在页模式下选择打印区域方向
// */
//- (void)XYSelectPrintDirectionOnPageModel:(int)n {
//    [_manager selectPrintDirectionOnPageModel:n];
//}
///**
// * 30.选择/取消顺时针旋转90度
// */
//- (void)XYSelectOrCancelRotationClockwise:(int)n {
//    [_manager selectOrCancelRotationClockwise:n];
//}
///**
// * 31.页模式下设置打印区域
// */
//- (void)XYSetprintLocationOnPageModelWithXL:(int)xL
//                                         xH:(int)xH
//                                         yL:(int)yL
//                                         yH:(int)yH
//                                        dxL:(int)dxL
//                                        dxH:(int)dxH
//                                        dyL:(int)dyL
//                                        dyH:(int)dyH
//{
//    [_manager setprintLocationOnPageModelWithXL:xL xH:xH yL:yL yH:yH dxL:dxL dxH:dxH dyL:dyL dyH:dyH];
//}
//
///**
// * 32.设置横向打印位置
// */
//- (void)XYSetHorizonLocationWith:(int)nL nH:(int)nH {
//    [_manager setHorizonLocationWith:nL nH:nH];
//}
///**
// * 33.选择对齐方式
// */
//- (void)XYSelectAlignmentWithN:(int)n {
//    [_manager selectAlignmentWithN:n];
//}
///**
// * 34.选择打印纸传感器以输出信号
// */
//- (void)XYSelectSensorForOutputSignal:(int)n {
//    [_manager selectSensorForOutputSignal:n];
//}
///**
// * 35.选择打印纸传感器以停止打印
// */
//- (void)XYSelectSensorForStopPrint:(int)n {
//    [_manager selectSensorForStopPrint:n];
//}
///**
// * 36.允许/禁止按键
// */
//- (void)XYAllowOrDisableKeypress:(int)n {
//    [_manager allowOrDisableKeypress:n];
//}
///**
// * 37.打印并向前走纸 N 行
// */
//- (void)XYPrintAndPushPageRow:(int)n {
//    [_manager printAndPushPageRow:n];
//}
///**
// * 38.产生钱箱控制脉冲
// */
//- (void)XYMakePulseWithCashboxWithM:(int)m t1:(int)t1 t2:(int)t2 {
//    [_manager makePulseWithCashboxWithM:m t1:t1 t2:t2];
//}
///**
// * 39.选择字符代码表
// */
//- (void)XYSelectCharacterTabN:(int)n {
//    [_manager selectCharacterTabN:n];
//}
///**
// * 40.选择/取消倒置打印模式
// */
//- (void)XYSelectOrCancelInversionPrintModel:(int)n {
//    [_manager selectOrCancelInversionPrintModel:n];
//}
///**
// * 41.打印下载到FLASH中的位图
// */
//- (void)XYPrintFlashBitmapWithN:(int)n m:(int)m {
//    [_manager printFlashBitmapWithN:n m:m];
//}
///**
// * 42.定义FLASH位图
// */
//- (void)XYDefinFlashBitmapWithN:(int)n Points:(NSArray *)points {
//    [_manager definFlashBitmapWithN:n Points:points];
//}
///**
// * 43.选择字符大小
// */
//- (void)XYSelectCharacterSize:(int)n {
//    [_manager selectCharacterSize:n];
//}
///**
// * 44.页模式下设置纵向绝对位置
// */
//- (void)XYSetVertLocationOnPageModelWithnL:(int)nL nH:(int)nH {
//    [_manager setVertLocationOnPageModelWithnL:nL nH:nH];
//}
///**
// * 45.定义下载位图
// */
//- (void)XYDefineLoadBitmapWithX:(int)x Y:(int)y Points:(NSArray *)points; {
//    [_manager defineLoadBitmapWithX:x Y:y Points:points];
//}
///**
// * 46.执行打印数据十六进制转储
// */
//- (void)XYPrintDataAndSaveAsHexWithpL:(int)pL pH:(int)pH n:(int)n m:(int)m {
//    [_manager printDataAndSaveAsHexWithpL:pL pH:pH n:n m:m];
//}
///**
// * 47.打印下载位图
// */
//- (void)XYPrintLoadBitmapM:(int)m {
//    [_manager printLoadBitmapM:m];
//}
///**
// * 48.开始/结束宏定义
// */
//- (void)XYBeginOrEndDefine {
//    [_manager beginOrEndDefine];
//}
///**
// * 49.选择/取消黑白反显打印模式
// */
//- (void)XYSelectORCancelBWPrintModel:(int)n {
//    [_manager selectORCancelBWPrintModel:n];
//}
///**
// * 50.选择HRI字符的打印位置
// */
//- (void)XYSelectHRIPrintLocation:(int)n {
//    [_manager selectHRIPrintLocation:n];
//}
///**
// * 51.设置左边距
// */
//- (void)XYSetLeftMarginWithnL:(int)nL nH:(int)nH {
//    [_manager setLeftMarginWithnL:nL nH:nH];
//}
///**
// * 52.设置横向和纵向移动单位
// */
//- (void)XYSetHoriAndVertUnitXWith:(int)x y:(int)y {
//    [_manager setHoriAndVertUnitXWith:x y:y];
//}
///**
// * 53.选择切纸模式并切纸
// */
//- (void)XYSelectCutPaperModelAndCutPaperWith:(int)m n:(int)n selectedModel:(int)model {
//    [_manager selectCutPaperModelAndCutPaperWith:m n:n selectedModel:model];
//}
///**
// * 54.设置打印区域宽高
// */
//- (void)XYSetPrintLocationWith:(int)nL nH:(int)nH {
//    [_manager setPrintLocationWith:nL nH:nH];
//}
///**
// * 55.页模式下设置纵向相对位置
// */
//- (void)XYSetVertRelativeLocationOnPageModelWith:(int)nL nH:(int)nH {
//    [_manager setVertRelativeLocationOnPageModelWith:nL nH:nH];
//}
///**
// * 56.执行宏命令
// */
//- (void)XYRunMacroMommandWith:(int)r t:(int)t m:(int)m {
//    [_manager runMacroMommandWith:r t:t m:m];
//}
///**
// * 57.打开/关闭自动状态反传功能(ASB)
// */
//- (void)XYOpenOrCloseASB:(int)n {
//    [_manager openOrCloseASB:n];
//}
///**
// * 58.选择HRI使用字体
// */
//- (void)XYSelectHRIFontToUse:(int)n {
//    [_manager selectHRIFontToUse:n];
//}
///**
// * 59. 选择条码高度
// */
//- (void)XYSelectBarcodeHeight:(int)n {
//    [_manager selectBarcodeHeight:n];
//}
///**
// * 60.打印条码
// */
//- (void)XYPrintBarCodeWithPoints:(int)m n:(int)n points:(NSArray *)points selectModel:(int)model {
//    [_manager printBarCodeWithPoints:m n:n points:points selectModel:model];
//}
///**
// * 61.返回状态
// */
//- (void)XYCallBackStatus:(int)n completion:(XYPOSCompletionBlock)block {
//    [_manager callBackStatus:n completion:^(CBCharacteristic *characteristic) {
//        block(characteristic);
//    }];
//}
///**
// * 62.打印光栅位图
// */
//- (void)XYPrintRasterBitmapWith:(int)m
//                             xL:(int)xL
//                             xH:(int)xH
//                             yl:(int)yL
//                             yh:(int)yH
//                         points:(NSArray *)points
//{
//    [_manager printRasterBitmapWith:m xL:xL xH:xH yl:yL yh:yH points:points];
//}
///**
// * 63.设置条码宽度
// */
//- (void)XYSetBarcodeWidth:(int)n {
//    [_manager setBarcodeWidth:n];
//}
//#pragma mark - ============汉字字符控制命令============
///**
// * 64.设置汉字字符模式
// */
//- (void)XYSetChineseCharacterModel:(int)n {
//    [_manager setChineseCharacterModel:n];
//}
///**
// * 65.选择汉字模式
// */
//- (void)XYSelectChineseCharacterModel {
//    [_manager selectChineseCharacterModel];
//}
///**
// * 66.选择/取消汉字下划线模式
// */
//- (void)XYSelectOrCancelChineseUderlineModel:(int)n {
//    [_manager selectOrCancelChineseUderlineModel:n];
//}
///**
// * 67.取消汉字模式
// */
//- (void)XYCancelChineseModel {
//    [_manager cancelChineseModel];
//}
///**
// * 68.定义用户自定义汉字
// */
//- (void)XYDefineCustomChinesePointsC1:(int)c1 c2:(int)c2 points:(NSArray *)points {
//    [_manager defineCustomChinesePointsC1:c1 c2:c2 points:points];
//}
///**
// * 69.设置汉字字符左右间距
// */
//- (void)XYSetChineseMarginWithLeftN1:(int)n1 n2:(int)n2 {
//    [_manager setChineseMarginWithLeftN1:n1 n2:n2];
//}
///**
// * 70.选择/取消汉字倍高倍宽
// */
//- (void)XYSelectOrCancelChineseHModelAndWModel:(int)n {
//    [_manager selectOrCancelChineseHModelAndWModel:n];
//}
//#pragma mark - ============打印机提示命令============
///**
// * 72.打印机来单打印蜂鸣提示
// */
//- (void)XYPrinterSound:(int)n t:(int)t {
//    [_manager printerSound:n t:t];
//}
///**
// * 73.打印机来单打印蜂鸣提示及报警灯闪烁
// */
//- (void)XYPrinterSoundAndAlarmLight:(int)m t:(int)t n:(int)n {
//    [_manager printerSoundAndAlarmLight:m t:t n:n];
//}
//
//#pragma mark - ＝＝＝＝＝＝＝＝＝TSC指令＝＝＝＝＝＝＝＝＝＝
///**
// * 1.设置标签尺寸
// */
//- (void)XYaddSizeWidth:(int)width height:(int)height {
//    [_manager XYaddSizeWidth:width height:height];
//}
///**
// * 2.设置间隙长度
// */
//- (void)XYaddGap:(int)gap {
//    [_manager XYaddGap:gap];
//}
///**
// * 3.产生钱箱控制脉冲
// */
//- (void)XYaddCashDrwer:(int)m  t1:(int)t1  t2:(int)t2 {
//    [_manager XYaddCashDrwer:m t1:t1 t2:t2];
//}
///**
// * 4.控制每张标签的停止位置
// */
//- (void)XYaddOffset:(float)offset {
//    [_manager XYaddOffset:offset];
//}
///**
// * 5.设置打印速度
// */
//- (void)XYaddSpeed:(float)speed {
//    [_manager XYaddSpeed:speed];
//}
///**
// * 6.设置打印浓度
// */
//- (void)XYaddDensity:(int)n {
//    [_manager XYaddDensity:n];
//}
///**
// * 7.设置打印方向和镜像
// */
//- (void)XYaddDirection:(int)n {
//    [_manager XYaddDirection:n];
//}
///**
// * 8.设置原点坐标
// */
//- (void)XYaddReference:(int)x  y:(int)y {
//    [_manager XYaddReference:x y:y];
//}
///**
// * 9.清除打印缓冲区数据
// */
//- (void)XYaddCls {
//    [_manager XYaddCls];
//}
///**
// * 10.走纸
// */
//- (void)XYaddFeed:(int)feed {
//    [_manager XYaddFeed:feed];
//}
///**
// * 11.退纸
// */
//- (void)XYaddBackFeed:(int)feed {
//    [_manager XYaddBackFeed:feed];
//}
///**
// * 12.走一张标签纸距离
// */
//- (void)XYaddFormFeed {
//    [_manager XYaddFormFeed];
//}
///**
// * 13.标签位置进行一次校准
// */
//- (void)XYaddHome {
//    [_manager XYaddHome];
//}
///**
// * 14.打印标签
// */
//- (void)XYaddPrint:(int)m {
//    [_manager XYaddPrint:m];
//}
///**
// * 15.设置国际代码页
// */
//- (void)XYaddCodePage:(int)page {
//    [_manager XYaddCodePage:page];
//}
///**
// * 16.设置蜂鸣器
// */
//- (void)XYaddSound:(int)level interval:(int)interval {
//    [_manager XYaddSound:level interval:interval];
//}
///**
// * 17.设置打印机报错
// */
//- (void)XYaddLimitFeed:(int)feed {
//    [_manager XYaddLimitFeed:feed];
//}
///**
// * 18.在打印缓冲区绘制黑块
// */
//- (void)XYaddBar:(int)x y:(int)y width:(int)width height:(int)height {
//    [_manager XYaddBar:x y:y width:width height:height];
//}
///**
// * 19.在打印缓冲区绘制一维条码
// */
//- (void)XYadd1DBarcodeX:(int)x
//                      y:(int)y
//                   type:(NSString *)type
//                 height:(int)height
//               readable:(int)readable
//               rotation:(int)rotation
//                 narrow:(int)narrow
//                   wide:(int)wide
//                content:(NSString *)content {
//    [_manager XYadd1DBarcodeX:x y:y type:type height:height readable:readable rotation:rotation narrow:narrow wide:wide content:content];
//}
///**
// * 20.在打印缓冲区绘制矩形
// */
//- (void)XYaddBox:(int)x y:(int)y xend:(int)xend yend:(int)yend {
//    [_manager XYaddBox:x y:y xend:xend yend:yend];
//}
///**
// * 21.在打印缓冲区绘制位图
// */
//- (void)XYaddBitmap:(int)x
//                  y:(int)y
//              width:(int)width
//             height:(int)height
//               mode:(int)mode data:(int)data {
//    [_manager XYaddBitmap:x y:y width:width height:height mode:mode data:data];
//}
///**
// * 22.擦除打印缓冲区中指定区域的数据
// */
//- (void)XYaddErase:(int)x y:(int)y xwidth:(int)xwidth yheight:(int)yheight {
//    [_manager XYaddErase:x y:y xwidth:xwidth yheight:yheight];
//}
///**
// * 23.将指定区域的数据黑白反色
// */
//- (void)XYaddReverse:(int)x y:(int)y xwidth:(int)xwidth yheight:(int)yheight {
//    [_manager XYaddReverse:x y:y xwidth:xwidth yheight:yheight];
//}
///**
// * 24.在打印缓冲区中绘制文字
// */
//- (void)XYaddText:(int)x y:(int)y font:(NSString *)font rotation:(int)rotation x_mul:(int)xmul y_mul:(int)ymul content:(NSString *)content {
//    [_manager XYaddText:x y:y font:font rotation:rotation x_mul:xmul y_mul:ymul content:content];
//}
///**
// * 25.在打印缓冲区中绘制文字
// */
//- (void)XYaddQRCode:(int)x y:(int)y level:(int)level cellWidth:(int)cellWidth rotation:(int)totation data:(NSString *)dataStr {
//    [_manager XYaddQRCode:x y:y level:level cellWidth:cellWidth rotation:totation data:dataStr];
//}
///**
// * 26.设置剥离功能是否开启
// */
//- (void)XYaddPeel:(NSString *)enable {
//    [_manager XYaddPeel:enable];
//}
///**
// * 27.设置撕离功能是否开启
// */
//- (void)XYaddTear:(NSString *)enable {
//    [_manager XYaddTear:enable];
//}
///**
// * 28.设置切刀功能是否开启
// */
//- (void)XYaddCut:(NSString *)enable {
//    [_manager XYaddCut:enable];
//}
///**
// * 29.设置打印机出错时，是否打印上一张内容
// */
//- (void)XYaddReprint:(NSString *)enable {
//    [_manager XYaddReprint:enable];
//}
///**
// * 30.设置是否按走纸键打印最近一张标签
// */
//- (void)XYaddPrintKeyEnable:(NSString *)enable {
//    [_manager XYaddPrintKeyEnable:enable];
//}
///**
// * 31.设置按走纸键打印最近一张标签的份数
// */
//- (void)XYaddPrintKeyNum:(int)m {
//    [_manager XYaddPrintKeyNum:m];
//}

-(NSArray*)XYGetBuffer
{
    return [_manager GetBuffer];
}

-(void)XYClearBuffer
{
    [_manager ClearBuffer];
}

-(void)sendCommand:(NSData *)data
{
    [_manager sendCommand:data];
    
}

-(void)XYSendCommandBuffer
{
    [_manager SendCommandBuffer];
    [self XYClearBuffer];
}


- (void)XYSetCommandMode:(BOOL)Mode{
    [_manager XYSetCommandMode:Mode];
}

-(void)XYSetDataCodingType:(NSStringEncoding) codingType
{
    encodingType=codingType;
}
@end
