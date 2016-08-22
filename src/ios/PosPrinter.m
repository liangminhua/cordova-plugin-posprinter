/********* PosPrinter.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "XYSDK.h"
@interface PosPrinter : CDVPlugin<XYBLEManagerDelegate , XYWIFIManagerDelegate> {
    // Member variables go here.
    XYBLEManager*  bluetoothManager;
    XYWIFIManager* wifiManager;
}

- (void)coolMethod:(CDVInvokedUrlCommand*)command;
@end

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

-(void)scanBluetoothDevice:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    bluetoothManager =[XYBLEManager sharedInstance];
    bluetoothManager.delegate =self;
    [bluetoothManager XYstartScan];
}

- (void)connectBluetooth:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    bluetoothManager =[XYBLEManager sharedInstance];
    bluetoothManager.delegate =self;
}
- (void)connectNet:(CDVInvokedUrlCommand*)command{
    __block CDVPluginResult* pluginResult = nil;
    NSString* ipAddress=[command.arguments objectAtIndex:0];
    NSNumber* port= [command.arguments objectAtIndex:1];
    wifiManager =[XYWIFIManager shareWifiManager];
    wifiManager.delegate= self;
    [wifiManager XYConnectWithHost:ipAddress port:port.intValue completion:^(BOOL isConnect){
        if (isConnect) {
            pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }else{
            pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
-(void)disconnect:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult =nil;
    if (bluetoothManager==nil) {
        return;
    }
    [bluetoothManager XYdisconnectRootPeripheral];
    [wifiManager XYDisConnect];
}
- (void)write:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    NSString* data =[command.arguments objectAtIndex:0];
    [wifiManager XYSendMSGWith:data];
}

@end
