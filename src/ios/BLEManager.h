//
//  BLEManage.h
//  
//
//  Created by femto01 on 15/11/20.
//  Copyright © 2015年 WTT. All rights reserved.
//

/**
 *  #define kBLEM [BLEManager sharedBLEManager]
    if (kBLEM.isConnected) {
        [kBLEM writeDataToDevice:@[@(0)] command:1];
        [kBLEM writeDataToDevice:@[@(1),@(2)] command:2];
    }
 *
 *
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class BLEManager;

//扫描发现设备回调block
typedef void (^BleManagerDiscoverPeripheralCallBack) (NSArray *peripherals);
typedef void (^BleManagerConnectPeripheralCallBack) (BOOL isConnected);
typedef void (^BleManagerReceiveCallBack) (CBCharacteristic *characteristic );


/**
 定义代理BLEManagerDelegate
 */
@protocol BLEManagerDelegate <NSObject>
// 发现外设
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager updatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)RSSIArr;
// 连接成功
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager connectPeripheral:(CBPeripheral *)peripheral;
// 断开连接
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager disconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect;
// 连接设备失败
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
// 收到数据
//- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didReceiveDataFromPrinter:(CBCharacteristic *)characteristic;
// 发送数据成功
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error;
@end


@interface BLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCharacteristic *write_characteristic;
    CBCharacteristic *read_characteristic;
    int commandSendMode; //命令发送模式 0:立即发送 1：批量发送
}

#pragma mark -

@property (nonatomic,assign) id<BLEManagerDelegate> delegate;

#pragma mark 基本属性

@property (strong, nonatomic) CBCentralManager *manager;        //BLE 管理中心

@property (strong, nonatomic) CBPeripheral     *peripheral;     //外设-蓝牙硬件

@property (nonatomic,assign ) BOOL             isConnected;   //连接成功= yes，失败=no

@property (nonatomic,assign ) BOOL             isAutoDisconnect;     //是否自动连接，是=yes，不=no

@property (atomic,assign    ) BOOL           connectStatu;// 蓝牙连接状态

@property (strong, nonatomic  ) NSMutableArray        *peripherals;// 发现的所有 硬件设备

@property (strong, nonatomic) NSMutableArray *connectedPeripherals;//连接过的Peripherals

@property (strong, nonatomic) NSMutableArray *RSSIArray;// 蓝牙信号数组

@property (assign, readonly) BOOL isScaning; //是否正在扫描 是=yes，没有=no

// 发送数据到指定的外设
@property (nonatomic,strong) CBPeripheral *writePeripheral;
/**
 * Completion block for peripheral scanning
 */
@property (copy, nonatomic) BleManagerDiscoverPeripheralCallBack scanBlock;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *commandBuffer;
/*
 *连接蓝牙回调
 */
@property (copy, nonatomic) BleManagerConnectPeripheralCallBack connectBlock;
/*
 *接收数据回调
 */
@property (nonatomic,copy) BleManagerReceiveCallBack receiveBlock;
#pragma mark -
#pragma mark 基本方法
/**
 *  单例方法
 *
 *  @return self
 */
+ (instancetype)sharedBLEManager;

/*
 *  获取手机蓝牙状态
 */
- (BOOL)isLECapableHardware;

/**
 *  开启蓝牙扫描
 */
- (void)startScan;

/*
 *  开始扫描并在scanInterval秒后停止
 */
- (void)startScanWithInterval:(NSInteger)scanInterval completion:(BleManagerDiscoverPeripheralCallBack)callBack;

/**
 *  停止扫描
 */
- (void)stopScan;

/**
 *  连接到指定设备
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral;

/*
 *  连接蓝牙设备
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral completion:(BleManagerConnectPeripheralCallBack)callBack;

/*
 *  尝试重新连接
 */
- (void)reConnectPeripheral:(CBPeripheral *)peripheral;

/**
 *  断开连接
 */
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;


#pragma mark -
#pragma mark 自定义其他属性
/**
 *  向设备写入数据
 *
 *  @param dataArray 需要写入的数据
 *  @param command   命令值，1=消息提醒， 2=跑步目标， 3=跑步完成目标时的灯光提醒， 4=设置低电量灯光提醒， 5=设置灯光常开颜色， 6=灯光常开时间， 7=灯光常开模式， 8=设置设备时间
 */
//- (void)writeDataToDevice:(NSArray *)dataArray command:(int)command;

/**
 发送数据给设备，发送的数据是NSString类型的，并且要指定编码类型
 */
-(void)sendDataWithPeripheral:(CBPeripheral *)peripheral withString:(NSString *)dataString coding:(NSStringEncoding)EncodingType;

/**
 发送指令给打印机
 */
-(void)writeCommadnToPrinterWthitData:(NSData *)data;

/**
 发送指令给打印机,带回调方法
 */
-(void)writeCommadnToPrinterWthitData:(NSData  *)data withResponse:(BleManagerReceiveCallBack)block;



-(void)reScan;  /**断开现有设备的重新扫描*/

-(void)disconnectRootPeripheral;  //断开现连设备

//#pragma mark - ====================POS指令====================
//#pragma mark - 其他方法
///**
// * 1.水平定位
// */
//- (void)horizontalPosition;
///**
// * 2.打印并换行
// */
//- (void)printAndFeed;
///**
// * 3.打印并回到标准模式
// */
//- (void)printAndBackToNormalModel;
///**
// * 4.页模式下取消打印数据
// */
//- (void)cancelPrintData;
///**
// * 5.实时状态传送
// */
//- (void)updataPrinterState:(int)n
//                completion:(BleManagerReceiveCallBack)callBlock;
///**
// * 6.实时对打印机请求
// */
//- (void)updataPrinterAnswer:(int) n;
///**
// * 7.实时产生钱箱开启脉冲
// */
//- (void)openBoxAndPulse:(int) n m:(int) m t:(int) t;
///**
// * 8.页模式下打印
// */
//- (void)printOnPageModel;
///**
// * 9.设置字符右间距
// */
//- (void)setCharRightMargin:(int)n;
///**
// * 10.选择打印模式
// */
//- (void)selectPrintModel:(int)n;
///**
// * 11.设置绝对打印位置
// */
//- (void)setPrintLocationWithParam:(int)nL nH:(int)nH;
///**
// * 12.选择/取消用户自定义字符
// */
//- (void)selectOrCancelCustomCharacter:(int)n;
//
///**
// * 13.定义用户自定义字符
// */
//- (void)definCustomCharacter:(int)y c1:(int)c1 c2:(int)c2 dx:(NSArray *)points;
///**
// * 14.选择位图模式
// */
//- (void)selectBitmapModel:(int)m nL:(int)nL nH:(int)nH dx:(NSArray *)points;
//
///**
// * 15.取消下划线模式
// */
//- (void)cancelUnderLineModel:(int)n;
///**
// * 16.设置默认行间距
// */
//- (void)setDefaultLineMargin;
///**
// * 17.设置行间距
// */
//- (void)setLineMargin:(int)n;
///**
// * 18.选择打印机
// */
//- (void)selectPrinter:(int)n;
///**
// * 19.取消用户自定义字符
// */
//- (void)cancelCustomCharacter:(int)n;
///**
// * 20.初始化打印机
// */
//- (void)initializePrinter;
///**
// * 21.设置横向跳格位置
// */
//- (void)setTabLocationWith:(NSArray *)points;
///**
// * 22.选择/取消加粗模式
// */
//- (void)selectOrCancelBoldModel:(int)n;
///**
// * 23.选择/取消双重打印模式
// */
//- (void)selectOrCancelDoublePrintModel:(int)n;
///**
// * 24.打印并走纸
// */
//- (void)printAndPushPage:(int)n;
///**
// * 25.选择页模式
// */
//- (void)selectPageModel;
///**
// * 26.选择字体
// */
//- (void)selectFont:(int)n;
///**
// * 27.选择国际字符集
// */
//- (void)selectINTL_CHAR_SETWith:(int)n;
///**
// * 28.选择标准模式
// */
//- (void)selectNormalModel;
///**
// * 29.在页模式下选择打印区域方向
// */
//- (void)selectPrintDirectionOnPageModel:(int)n;
///**
// * 30.选择/取消顺时针旋转90度
// */
//- (void)selectOrCancelRotationClockwise:(int)n;
///**
// * 31.页模式下设置打印区域
// */
//- (void)setprintLocationOnPageModelWithXL:(int)xL
//                                       xH:(int)xH
//                                       yL:(int)yL
//                                       yH:(int)yH
//                                      dxL:(int)dxL
//                                      dxH:(int)dxH
//                                      dyL:(int)dyL
//                                      dyH:(int)dyH;
//
///**
// * 32.设置横向打印位置
// */
//- (void)setHorizonLocationWith:(int)nL nH:(int)nH;
///**
// * 33.选择对齐方式
// */
//- (void)selectAlignmentWithN:(int)n;
///**
// * 34.选择打印纸传感器以输出信号
// */
//- (void)selectSensorForOutputSignal:(int)n;
///**
// * 35.选择打印纸传感器以停止打印
// */
//- (void)selectSensorForStopPrint:(int)n;
///**
// * 36.允许/禁止按键
// */
//- (void)allowOrDisableKeypress:(int)n;
///**
// * 37.打印并向前走纸 N 行
// */
//- (void)printAndPushPageRow:(int)n;
///**
// * 38.产生钱箱控制脉冲
// */
//- (void)makePulseWithCashboxWithM:(int)m t1:(int)t1 t2:(int)t2;
///**
// * 39.选择字符代码表
// */
//- (void)selectCharacterTabN:(int)n;
///**
// * 40.选择/取消倒置打印模式
// */
//- (void)selectOrCancelInversionPrintModel:(int)n;
///**
// * 41.打印下载到FLASH中的位图
// */
//- (void)printFlashBitmapWithN:(int)n m:(int)m;
///**
// * 42.定义FLASH位图
// */
//- (void)definFlashBitmapWithN:(int)n Points:(NSArray *)points;
///**
// * 43.选择字符大小
// */
//- (void)selectCharacterSize:(int)n;
///**
// * 44.页模式下设置纵向绝对位置
// */
//- (void)setVertLocationOnPageModelWithnL:(int)nL nH:(int)nH;
///**
// * 45.定义下载位图
// */
//- (void)defineLoadBitmapWithX:(int)x Y:(int)y Points:(NSArray *)points;
///**
// * 46.执行打印数据十六进制转储
// */
//- (void)printDataAndSaveAsHexWithpL:(int)pL pH:(int)pH n:(int)n m:(int)m;
///**
// * 47.打印下载位图
// */
//- (void)printLoadBitmapM:(int)m;
///**
// * 48.开始/结束宏定义
// */
//- (void)beginOrEndDefine;
///**
// * 49.选择/取消黑白反显打印模式
// */
//- (void)selectORCancelBWPrintModel:(int)n;
///**
// * 50.选择HRI字符的打印位置
// */
//- (void)selectHRIPrintLocation:(int)n;
///**
// * 51.设置左边距
// */
//- (void)setLeftMarginWithnL:(int)nL nH:(int)nH;
///**
// * 52.设置横向和纵向移动单位
// */
//- (void)setHoriAndVertUnitXWith:(int)x y:(int)y;
///**
// * 53.选择切纸模式并切纸
// */
//- (void)selectCutPaperModelAndCutPaperWith:(int)m n:(int)n selectedModel:(int)model;
///**
// * 54.设置打印区域宽高
// */
//- (void)setPrintLocationWith:(int)nL nH:(int)nH;
///**
// * 55.页模式下设置纵向相对位置
// */
//- (void)setVertRelativeLocationOnPageModelWith:(int)nL nH:(int)nH;
///**
// * 56.执行宏命令
// */
//- (void)runMacroMommandWith:(int)r t:(int)t m:(int)m;
///**
// * 57.打开/关闭自动状态反传功能(ASB)
// */
//- (void)openOrCloseASB:(int)n;
///**
// * 58.选择HRI使用字体
// */
//- (void)selectHRIFontToUse:(int)n;
///**
// * 59. 选择条码高度
// */
//- (void)selectBarcodeHeight:(int)n;
///**
// * 60.打印条码
// */
//- (void)printBarCodeWithPoints:(int)m n:(int)n points:(NSArray *)points selectModel:(int)model;
///**
// * 61.返回状态
// */
//- (void)callBackStatus:(int)n completion:(BleManagerReceiveCallBack)block;
///**
// * 62.打印光栅位图
// */
//- (void)printRasterBitmapWith:(int)m
//                           xL:(int)xL
//                           xH:(int)xH
//                           yl:(int)yL
//                           yh:(int)yH
//                       points:(NSArray *)points;
///**
// * 63.设置条码宽度
// */
//- (void)setBarcodeWidth:(int)n;
//#pragma mark - ============汉字字符控制命令============
///**
// * 64.设置汉字字符模式
// */
//- (void)setChineseCharacterModel:(int)n;
///**
// * 65.选择汉字模式
// */
//- (void)selectChineseCharacterModel;
///**
// * 66.选择/取消汉字下划线模式
// */
//- (void)selectOrCancelChineseUderlineModel:(int)n;
///**
// * 67.取消汉字模式
// */
//- (void)cancelChineseModel;
///**
// * 68.定义用户自定义汉字
// */
//- (void)defineCustomChinesePointsC1:(int)c1 c2:(int)c2 points:(NSArray *)points;
///**
// * 69.设置汉字字符左右间距
// */
//- (void)setChineseMarginWithLeftN1:(int)n1 n2:(int)n2;
///**
// * 70.选择/取消汉字倍高倍宽
// */
//- (void)selectOrCancelChineseHModelAndWModel:(int)n;
//#pragma mark - ============打印机提示命令============
///**
// * 72.打印机来单打印蜂鸣提示
// */
//- (void)printerSound:(int)n t:(int)t;
///**
// * 73.打印机来单打印蜂鸣提示及报警灯闪烁
// */
//- (void)printerSoundAndAlarmLight:(int)m t:(int)t n:(int)n;
//
//#pragma mark - ＝＝＝＝＝＝＝＝＝TSC指令＝＝＝＝＝＝＝＝＝＝
///**
// * 1.设置标签尺寸
// */
//- (void)XYaddSizeWidth:(int)width height:(int)height;
///**
// * 2.设置间隙长度
// */
//- (void)XYaddGap:(int)gap;
///**
// * 3.产生钱箱控制脉冲
// */
//- (void)XYaddCashDrwer:(int)m  t1:(int)t1  t2:(int)t2;
///**
// * 4.控制每张标签的停止位置
// */
//- (void)XYaddOffset:(float)offset;
///**
// * 5.设置打印速度
// */
//- (void)XYaddSpeed:(float)speed;
///**
// * 6.设置打印浓度
// */
//- (void)XYaddDensity:(int)n;
///**
// * 7.设置打印方向和镜像
// */
//- (void)XYaddDirection:(int)n;
///**
// * 8.设置原点坐标
// */
//- (void)XYaddReference:(int)x  y:(int)y;
///**
// * 9.清除打印缓冲区数据
// */
//- (void)XYaddCls;
///**
// * 10.走纸
// */
//- (void)XYaddFeed:(int)feed;
///**
// * 11.退纸
// */
//- (void)XYaddBackFeed:(int)feed;
///**
// * 12.走一张标签纸距离
// */
//- (void)XYaddFormFeed;
///**
// * 13.标签位置进行一次校准
// */
//- (void)XYaddHome;
///**
// * 14.打印标签
// */
//- (void)XYaddPrint:(int)m;
///**
// * 15.设置国际代码页
// */
//- (void)XYaddCodePage:(int)page;
///**
// * 16.设置蜂鸣器
// */
//- (void)XYaddSound:(int)level interval:(int)interval;
///**
// * 17.设置打印机报错
// */
//- (void)XYaddLimitFeed:(int)feed;
///**
// * 18.在打印缓冲区绘制黑块
// */
//- (void)XYaddBar:(int)x y:(int)y width:(int)width height:(int)height;
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
//                content:(NSString *)content;
///**
// * 20.在打印缓冲区绘制矩形
// */
//- (void)XYaddBox:(int)x y:(int)y xend:(int)xend yend:(int)yend;
///**
// * 21.在打印缓冲区绘制位图
// */
//- (void)XYaddBitmap:(int)x
//                  y:(int)y
//              width:(int)width
//             height:(int)height
//               mode:(int)mode data:(int)data;
///**
// * 22.擦除打印缓冲区中指定区域的数据
// */
//- (void)XYaddErase:(int)x y:(int)y xwidth:(int)xwidth yheight:(int)yheight;
///**
// * 23.将指定区域的数据黑白反色
// */
//- (void)XYaddReverse:(int)x y:(int)y xwidth:(int)xwidth yheight:(int)yheight;
///**
// * 24.在打印缓冲区中绘制文字
// */
//- (void)XYaddText:(int)x y:(int)y font:(NSString *)font rotation:(int)rotation x_mul:(int)xmul y_mul:(int)ymul content:(NSString *)content;
///**
// * 25.在打印缓冲区中绘制文字
// */
//- (void)XYaddQRCode:(int)x y:(int)y level:(int)level cellWidth:(int)cellWidth rotation:(int)totation data:(NSString *)dataStr;
///**
// * 26.设置剥离功能是否开启
// */
//- (void)XYaddPeel:(NSString *)enable;
///**
// * 27.设置撕离功能是否开启
// */
//- (void)XYaddTear:(NSString *)enable;
///**
// * 28.设置切刀功能是否开启
// */
//- (void)XYaddCut:(NSString *)enable;
///**
// * 29.设置打印机出错时，是否打印上一张内容
// */
//- (void)XYaddReprint:(NSString *)enable;
///**
// * 30.设置是否按走纸键打印最近一张标签
// */
//- (void)XYaddPrintKeyEnable:(NSString *)enable;
///**
// * 31.设置按走纸键打印最近一张标签的份数
// */
//- (void)XYaddPrintKeyNum:(int)m;
/**
 * 32.返回待发送缓冲区内容
 */
-(NSArray*)GetBuffer;
/**
 * 33.清空缓冲区内容
 */
-(void)ClearBuffer;
/**
 * 34.发送缓冲区命令
 */
-(void)SendCommandBuffer;
/**
 * 34.发送单条命令
 */
-(void)sendCommand:(NSData *)data;

- (void)XYSetCommandMode:(int)Mode;
@end

