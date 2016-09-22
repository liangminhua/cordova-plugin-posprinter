#import "PosPrinter.h"

@implementation PosPrinter
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    //NSLog(@"update: %ld",(long)central.state);
}
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSMutableDictionary* returnObj = [NSMutableDictionary dictionary];
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
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSUUID * filterUuid= [[NSUUID UUID]initWithUUIDString:@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"];
    [peripheral discoverServices:@[filterUuid]];
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
       // NSLog(@"Discovered service %@", service);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (connectBluetoothCallback==nil) {
        return;
    }
    CDVPluginResult* pluginResult=nil;
    for (CBCharacteristic *characteristic in service.characteristics) {
       // NSLog(@"Discovered characteristic %@", characteristic);
        //49535343-1E4D-4BD9-BA61-23C647249616 "LED"
        //49535343-8841-43F4-A8D4-ECBE34729BB3 "WriteData"
        if ([characteristic.UUID.UUIDString isEqualToString:@"49535343-8841-43F4-A8D4-ECBE34729BB3"]) {
            writeCharacteristic=characteristic;
            pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        if ([characteristic.UUID.UUIDString isEqualToString:@"49535343-1E4D-4BD9-BA61-23C647249616"]){
            [peripheral setNotifyValue:YES forCharacteristic: characteristic];
        }
    }
    if (pluginResult==nil) {
        pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:connectBluetoothCallback];
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if (connectBluetoothCallback!=nil) {
        CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:BLUETOOTH_CONNECT_FAIL];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:connectBluetoothCallback];
    }
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if(connectBluetoothCallback!=nil){
        CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
            messageAsInt:BLUETOOTH_DISCONNECT];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:connectBluetoothCallback];
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (writeBluetoothCallback==nil) {
        return;
    }
    CDVPluginResult *pluginResult =nil;
    if (error) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:1];
        
    }else{
        pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:writeBluetoothCallback];
}

//Wi-Fi Delegate
//成功连接主机
- (void)XYWIFIManager:(XYWIFIManager *)manager didConnectedToHost:(NSString *)host port:(UInt16)port{
    if (connectNetCallback!=nil) {
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:connectNetCallback];
    }
};
// 断开连接
- (void)XYWIFIManager:(XYWIFIManager *)manager willDisconnectWithError:(NSError *)error{
    if (connectNetCallback!=nil) {
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:NET_DISCONNECT];
    [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:connectNetCallback];
    }
};
// 写入数据成功
- (void)XYWIFIManager:(XYWIFIManager *)manager didWriteDataWithTag:(long)tag{
    if (writeNetCallback!=nil) {
        CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [pluginResult setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:writeNetCallback];
    }
};
// 收到回传
- (void)XYWIFIManager:(XYWIFIManager *)manager didReadData:(NSData *)data tag:(long)tag{
 
};
// 断开连接
- (void)XYWIFIManagerDidDisconnected:(XYWIFIManager *)manager{
   // NSLog(@"disconnect!");
};


-(void) initialize:(CDVInvokedUrlCommand*)command{
    NSNumber* request =[NSNumber numberWithBool:YES];
    NSMutableDictionary* options= [NSMutableDictionary dictionary];
    if (request) {
        [options setValue:request forKey:CBCentralManagerOptionShowPowerAlertKey];
    }
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    wifiManager = [XYWIFIManager shareWifiManager];
    wifiManager.delegate =self;
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
};

-(void) scanBluetoothDevice:(CDVInvokedUrlCommand*)command{
    if (centralManager.state!=CBManagerStatePoweredOn) {
        CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:BLUETOOTH_CONNECT_FAIL];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    if(scanCallback!=nil){
        return;
    }
    NSNumber* allowDuplicates = [NSNumber numberWithBool:NO];
    [centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:allowDuplicates }];
    scanCallback= command.callbackId;
};
-(void) stopScanBluetoothDevices:(CDVInvokedUrlCommand*)command{
    [centralManager stopScan];
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
};
-(void) connectBluetooth:(CDVInvokedUrlCommand*)command{
    NSString* address= [command.arguments objectAtIndex:0];
    NSUUID * uuid= [[NSUUID UUID]initWithUUIDString:address];
    NSArray* peripherals =[centralManager retrievePeripheralsWithIdentifiers:@[uuid]];
    if (peripherals.count==0) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:1];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    connectBluetoothCallback= command.callbackId;
    CBPeripheral * peripheral =peripherals[0];
    [peripheral setDelegate:self];
    writePeripheral=peripheral;
    [centralManager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
};
-(void) disconnectBluetoothPort:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult=nil;
    if (writePeripheral!=nil) {
        [centralManager cancelPeripheralConnection:writePeripheral];
        pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }else{
        pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:NOT_CONNECT];
    }
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
};
-(void)writeToBluetoothDevice:(CDVInvokedUrlCommand*)command{
    if (writePeripheral==nil) {
        CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:NOT_CONNECT];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    writeBluetoothCallback= command.callbackId;
    NSMutableData* mutableData= [[NSMutableData alloc]initWithCapacity:command.arguments.count];
    for (NSNumber* number in command.arguments) {
        char byte =number.charValue;
        [mutableData appendBytes:&byte length:1];
    }
    [writePeripheral writeValue:mutableData forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
};
-(void) connectNet:(CDVInvokedUrlCommand*)command{
    connectNetCallback= command.callbackId;
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

-(void) writeToNetDevice:(CDVInvokedUrlCommand*)command{
    writeNetCallback=command.callbackId;
    NSMutableData* mutableData= [[NSMutableData alloc]initWithCapacity:command.arguments.count];
    for (NSNumber* number in command.arguments) {
        char byte =number.charValue;
        [mutableData appendBytes:&byte length:1];
    }
    [wifiManager XYWriteCommandWithData:mutableData];
};
@end
