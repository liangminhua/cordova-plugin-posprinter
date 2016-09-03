/********* PosPrinter.m Cordova Plugin Implementation *******/

#import "PosPrinter.h"

@implementation PosPrinter

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    return;
}
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"discover %@ %@",peripheral.name,peripheral.identifier.UUIDString);
    NSDictionary* returnObj=[NSDictionary dictionaryWithObjectsAndKeys:peripheral.name,@"name",peripheral.identifier.UUIDString,@"address", nil];
    [centralManager connectPeripheral:peripheral options:nil];
    //[bluetoothManager XYconnectDevice:peripheral];
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:scanCallback];
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
    centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    wifiManager.delegate= self;
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)scanBluetoothDevice:(CDVInvokedUrlCommand*)command{
    scanCallback =command.callbackId;
    NSMutableArray* serviceUuids=nil;
    NSNumber* allowDuplicates=[NSNumber numberWithBool:NO];
    [centralManager scanForPeripheralsWithServices:serviceUuids options:@{CBCentralManagerScanOptionAllowDuplicatesKey:allowDuplicates}];
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)connectBluetooth:(CDVInvokedUrlCommand*)command{
    NSUUID* bluetoothAddress=[command.arguments objectAtIndex:0];
    if(bluetoothAddress==nil)return;
    NSLog(@"%@",bluetoothAddress);
    NSArray* peripherals= [centralManager retrievePeripheralsWithIdentifiers:@[bluetoothAddress]];
    if(peripherals.count==0){
        return;
    }
    CBPeripheral* peripheral=peripherals[0];
    [centralManager connectPeripheral:peripheral options:nil];
    //[bluetoothManager XYconnectDevice:peripheral];
    CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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

