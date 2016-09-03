/********* PosPrinter.m Cordova Plugin Implementation *******/

#import "PosPrinter.h"

@implementation PosPrinter
-(void)XYdidConnectPeripheral:(CBPeripheral *)peripheral{
    
}
-(void)XYdidUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList{
    for (int i =0; i<[rssiList count]; i++) {
        NSLog(@"%@",[rssiList objectAtIndex:i]);
    }
}
-(void)XYdidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
}
-(void)XYdidDisconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect{
    
}
-(void)XYdidWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error{
    
}

-(void)XYWIFIManager:(XYWIFIManager *)manager didReadData:(NSData *)data tag:(long)tag{
    
}
-(void)XYWIFIManager:(XYWIFIManager *)manager didWriteDataWithTag:(long)tag{
    
}
-(void)XYWIFIManager:(XYWIFIManager *)manager didConnectedToHost:(NSString *)host port:(UInt16)port{
    
}
-(void)XYWIFIManager:(XYWIFIManager *)manager willDisconnectWithError:(NSError *)error{
    
}
-(void)XYWIFIManagerDidDisconnected:(XYWIFIManager *)manager{
    
}

-(void)initialize:(CDVInvokedUrlCommand*)command{
    bluetoothManager =[XYBLEManager sharedInstance];
    wifiManager =[XYWIFIManager shareWifiManager];
    bluetoothManager.delegate =self;
    wifiManager.delegate= self;
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)scanBluetoothDevice:(CDVInvokedUrlCommand*)command{
    scanCallback =command.callbackId;
    [bluetoothManager XYstartScan];
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)connectBluetooth:(CDVInvokedUrlCommand*)command{
    NSString* bluetoothAddress=[command.arguments objectAtIndex:0];
    NSString* connectcommnd=command.callbackId;
    if(bluetoothManager!=nil){

    }else{
        
    }
}
- (void)connectNet:(CDVInvokedUrlCommand*)command{
    NSString* ipAddress=[command.arguments objectAtIndex:0];
    NSNumber* port= [command.arguments objectAtIndex:1];
    if (port==nil) {
        port=@(9100);
    }
    [wifiManager XYConnectWithHost:ipAddress port:port.intValue completion:^(BOOL isConnect){
        CDVPluginResult* pluginResult = nil;
        if (isConnect) {
            pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }else{
            pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
-(void)disconnect:(CDVInvokedUrlCommand*)command{
    [bluetoothManager XYdisconnectRootPeripheral];
    [wifiManager XYDisConnect];
    CDVPluginResult* pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)write:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    NSData* data =[command.arguments objectAtIndex:0];
    if(wifiManager.connectOK){
        [wifiManager XYWritePOSCommandWithData:data withResponse:^(NSData *data){
            
        }];
    }
}


@end

