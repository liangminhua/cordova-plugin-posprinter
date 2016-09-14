#import <Cordova/CDV.h>

#import "XYSDK.h"

@interface PosPrinter : CDVPlugin<XYWIFIManagerDelegate,XYBLEManagerDelegate> {

    // Member variables go here.

    XYBLEManager*  bluetoothManager;

    XYWIFIManager* wifiManager;

    NSArray* scanPeripherals;

    NSString* scanCallback;
    
    // NSString* scanCallback;

    // NSMutableArray* CBPeripherals;

    // CBCentralManager* centralManager;

}

-(void) initialize:(CDVInvokedUrlCommand*)command;

-(void) scanBluetoothDevice:(CDVInvokedUrlCommand*)command;

-(void) connectBluetooth:(CDVInvokedUrlCommand*)command;

-(void) connectNet:(CDVInvokedUrlCommand*)command;

-(void) disconnectNetPort:(CDVInvokedUrlCommand*)command;

-(void) disconnectBluetoothPort:(CDVInvokedUrlCommand*)command;

-(void) writeToBluetoothDevice:(CDVInvokedUrlCommand*)command;

-(void) writeToNetDevice:(CDVInvokedUrlCommand*)command;

@end