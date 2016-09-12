#import "PosPrinter.h"

@implementation PosPrinter

//Bluetooth Delegate
// 发现周边
- (void)XYdidUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList{
    scanPeripherals=peripherals;
    if (scanCallback==nil) {
        return;
    }
    for (unsigned int index=0; index<peripherals.count; ++index) {
        NSMutableDictionary* returnObj = [NSMutableDictionary dictionary];
        CBPeripheral* peripheral= [peripherals objectAtIndex:index];
        NSLog(@"%@......%@",peripheral.name,peripheral.identifier.UUIDString);
        if (peripheral.name==nil) {
            [returnObj setObject:@"" forKey:@"name"];
        }else{
            [returnObj setObject:peripheral.name forKey:@"name"];
        }
        
        [returnObj setObject:peripheral.identifier.UUIDString forKey:@"address"];
        CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:scanCallback];
        
    }
};
// 连接成功
- (void)XYdidConnectPeripheral:(CBPeripheral *)peripheral{

};
// 连接失败
- (void)XYdidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
};
// 断开连接
- (void)XYdidDisconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect{
    
};
// 发送数据成功
- (void)XYdidWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error{
    
};
//Wi-Fi Delegate
// 成功连接主机
- (void)XYWIFIManager:(XYWIFIManager *)manager didConnectedToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"connect success!");
};
// 断开连接
- (void)XYWIFIManager:(XYWIFIManager *)manager willDisconnectWithError:(NSError *)error{
    NSLog(@"disconnect with error!");
};
// 写入数据成功
- (void)XYWIFIManager:(XYWIFIManager *)manager didWriteDataWithTag:(long)tag{
    NSLog(@"write success!");
};
// 收到回传
- (void)XYWIFIManager:(XYWIFIManager *)manager didReadData:(NSData *)data tag:(long)tag{
    NSLog(@"yi");
};
// 断开连接
- (void)XYWIFIManagerDidDisconnected:(XYWIFIManager *)manager{
    NSLog(@"disconnect!");
};


-(void) initialize:(CDVInvokedUrlCommand*)command{
    bluetoothManager=[XYBLEManager sharedInstance];
    bluetoothManager.delegate= self;
    wifiManager= [XYWIFIManager shareWifiManager];
    wifiManager.delegate=self;
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
};

-(void) scanBluetoothDevice:(CDVInvokedUrlCommand*)command{
    if (bluetoothManager!=nil) {
        [bluetoothManager XYstartScan];
        scanCallback =command.callbackId;
        CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [pluginResult setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
};

-(void) connectBluetooth:(CDVInvokedUrlCommand*)command{
    if(bluetoothManager!=nil){
        NSString* uuid= [command.arguments objectAtIndex:0];
        CBPeripheral* connectPeripheral=nil;
        for (CBPeripheral* peripheral in scanPeripherals) {
            if([peripheral.identifier.UUIDString isEqualToString: uuid])
            {  connectPeripheral=peripheral;
                break;
            }
        }
        CDVPluginResult* pluginResult=nil;
        if (bluetoothManager!=nil) {
            [bluetoothManager XYconnectDevice:connectPeripheral];
            pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }else{
            pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:1];
        }
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
};
-(void)write:(CDVInvokedUrlCommand*)command{
    [self writeToNetDevice:command];
    return;
}
-(void) connectNet:(CDVInvokedUrlCommand*)command{
    NSString* ipAddress= [command.arguments objectAtIndex:0];
    NSNumber* port= [command.arguments objectAtIndex:1];
    if (port==nil) {
        port=@(9100);
    }
    [wifiManager XYConnectWithHost:ipAddress port:port.intValue completion:^(BOOL isConnect) {
        if (isConnect) {
            CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [pluginResult setKeepCallbackAsBool:false];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
};

-(void) disconnectNetPort:(CDVInvokedUrlCommand*)command{
    [wifiManager XYDisConnect];
    CDVPluginResult* pluginResult=nil;
    if( wifiManager.connectOK)
    {
        pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }else{
        pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
    }
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
};

-(void) disconnectBluetoothPort:(CDVInvokedUrlCommand*)command{
    [wifiManager XYDisConnect];
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
};

-(void) writeToBluetoothDevice:(CDVInvokedUrlCommand*)command{
    return;
};

-(void) writeToNetDevice:(CDVInvokedUrlCommand*)command{
    NSMutableData* mutableData= [[NSMutableData alloc]initWithCapacity:command.arguments.count];
    for (NSNumber* number in command.arguments) {
        char byte =number.charValue;
        [mutableData appendBytes:&byte length:1];
    }
    [wifiManager XYWriteCommandWithData:mutableData];
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
};
@end