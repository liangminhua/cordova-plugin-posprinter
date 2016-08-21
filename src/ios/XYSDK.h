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
 
 XYBLEManager.h 是蓝牙管理类，处理蓝牙的连接相关和POS指令的发送。
 使用 [XYBLEManager sharedInstance] 单例方法创建管理对象，创建的同时遵循代理，实现代理方法. 调用 XYstartScan 方法开始扫描，并在代理方法 XYdidUpdatePeripheralList 中拿到扫描结果。 XYconnectDevice: 是蓝牙连接方法，连接指定的外设。XYBLEManager中有个 writePeripheral 属性，用来指定向哪个外设写数据，不指定默认位最后连接的那个外设。
 参数的传递，各指令的参数都是数组类型，数组中封装需要传递的变量参数，类型为字符串类型，按十进制形式输入。
 
 XYWIFIManager.h 是wifi管理类，处理wifi的连接和条码指令的发送。单个连接可使用单例方法 [XYWIFIManager shareWifiManager] 创建连接对象，并遵循代理，XYConnectWithHost:port:completion:是连接的方法，指定IP 和端口号，有 block 回调是否成功。多个连接时用 [[XYWIFIManager alloc] init] 方法初始化多个管理对象，并保存，使用相应的对象来发送指令。
 参数的传递，以字符串的形式传递，按照相应指令的规则传入相应的变量参数。 XYSendMSGWith 是发送完整指令的接口。XYWritePOSCommandWithData: 方法是发送POS指令的相关方法，接收Data类型的参数，将一条完整的POS指令转换成 NSData 类型传入。
 */


#ifndef XYSDK_h
#define XYSDK_h

#import "XYBLEManager.h"
#import "XYWIFIManager.h"

#endif /* XYSDK_h */
