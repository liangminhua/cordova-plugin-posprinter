//
//  XYSDK.h
//  Printer
//
//  Created by apple on 16/4/6.
//  Copyright © 2016年 Admin. All rights reserved.
//


/*
 简介：使用SDK需要添加系统依赖库
 SystemConfiguration.framework
 CFNetwork.framework
 CoreBluetooth.framework
 
 
 
 
 
 
 
 
 
在XprinterIosSdk的usr文件中，可见的头文件（.h文件）分别有：XYBLEManager.h,XYWIFIManager.h,TscCommand.h,PosCommand.h,ImageTranster.h和XYSDK.h.
 这几.h文件包含了蓝牙和wifi的连接：XYBLEMananger.h和XYWIFIManager，发送，接收数据的方法和需要遵循的代理，还有指令封装的工具类：TscCommand,PosCommand,图像处理类：ImageTranster;
 说明文档XYSDK.h
 XYBLEManager.h 是蓝牙管理类，处理蓝牙的连接相关和POS指令的发送。
 使用 [XYBLEManager sharedInstance] 单例方法创建管理对象，创建的同时遵循代理，实现代理方法. 调用 XYstartScan 方法开始扫描，并在代理方法 XYdidUpdatePeripheralList 中拿到扫描结果。 XYconnectDevice: 是蓝牙连接方法，连接指定的外设。XYBLEManager中有个 writePeripheral 属性，用来指定向哪个外设写数据，不指定默认位最后连接的那个外设。
 XYWIFIManager.h 是wifi管理类，处理wifi的连接和条码指令的发送。单个连接可使用单例方法 [XYWIFIManager shareWifiManager] 创建连接对象，并遵循代理，XYConnectWithHost:port:completion:是连接的方法，指定IP 和端口号，有 block 回调是否成功。多个连接时用 [[XYWIFIManager alloc] init] 方法初始化多个管理对象，并保存，使用相应的对象来发送指令。
 TscCommand.h条码指令封装工具类，所有返回值均为NSData类型；
 PosCommand.h,pos指令封装工具类，返回都是NSData类型。
 这俩个指令工具类里的方法均为类方法，直接用类名调用，返回值都是NSData类型，可用于数据直接发送
 蓝牙和WiFi的连接实现，都需要遵循代理，详细请参考示例代码.
 具体的发送数据的方法，在XYBLEManager.h和XYWIFIManager.h，都为-(void)XYWriteCommandWithData:(NSData *)data;以及带回调的方法
 -(void)XYWriteCommandWithData:(NSData *)data callBack:(XYTSCCompletionBlock)block;
 
 
 蓝牙管理类的使用说明：
 首先：使用[XYBLEManager sharedInstance] 单例方法创建管理对象，设置代理，并实现代理方法。注意：当创建了XYBLEManager的对象后，蓝牙已经开启了扫描，扫描结果也进行了保存。此时，在实现的代理方法 - (void)XYdidUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList;中，可以拿到扫描结果，通过扫描的设备，可以进行连接， XYconnectDevice: ；连接结成功或失败会分别调用代理方法- (void)XYdidConnectPeripheral:(CBPeripheral *)peripheral;和- (void)XYdidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;方法。
    连接成功后，获得写数据的特征，就可以调用发送数据的方法了，推荐使用XYWriteCommandWithData:方法发送。在数据发送后，会回调代理方法XYdidWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error;可以通过error来判断发送数据是否成功，再做相应的操作。也可用XYWriteCommandWithData:callblock:方法发送，用block回调是否成功。
 
 @protocol XYBLEManagerDelegate <NSObject>
 // 发现的蓝牙设备后执行
 - (void)XYdidUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList;
 // 连接成功后执行
 - (void)XYdidConnectPeripheral:(CBPeripheral *)peripheral;
 // 连接失败后执行
 - (void)XYdidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
 // 断开连接后执行
 - (void)XYdidDisconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect;
 // 发送数据后执行
 - (void)XYdidWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error;
 
 @end
 
 
 wifi管理类的使用说明：
 单个连接可使用单例方法 [XYWIFIManager shareWifiManager] 创建连接对象，设置代理，并实现代理方法。
 XYConnectWithHost:port:completion:是连接的方法，指定IP 和端口号，有 block 回调是否成功。也可以实现代理方法- (void)XYWIFIManager:(XYWIFIManager *)manager didConnectedToHost:(NSString *)host port:(UInt16)port;来处理连接成功或失败后的操作.
 
 连接成功后，发送数据推荐使用-(void)XYWriteCommandWithData:(NSData *)data;和
 
 -(void)XYWriteCommandWithData:(NSData *)data withResponse:(XYWIFICallBackBlock)block;
 来发送数据，对发送数据的结果可以用block回调，也可以在XYWIFIManager:(XYWIFIManager *)manager didWriteDataWithTag:(long)tag代理方法中执行判断后的操作。
 

@protocol XYWIFIManagerDelegate <NSObject>

// 成功连接主机后执行
- (void)XYWIFIManager:(XYWIFIManager *)manager didConnectedToHost:(NSString *)host port:(UInt16)port;
// 断开连接
- (void)XYWIFIManager:(XYWIFIManager *)manager willDisconnectWithError:(NSError *)error;
// 写入数据后执行
- (void)XYWIFIManager:(XYWIFIManager *)manager didWriteDataWithTag:(long)tag;
// 接收数据方法执行后执行的方法
- (void)XYWIFIManager:(XYWIFIManager *)manager didReadData:(NSData *)data tag:(long)tag;
// 断开连接后执行的方法
- (void)XYWIFIManagerDidDisconnected:(XYWIFIManager *)manager;
@end

 

 */


#ifndef XYSDK_h
#define XYSDK_h

#import "XYBLEManager.h"
#import "XYWIFIManager.h"
#endif /* XYSDK_h */
