#import <Cordova/CDV.h>

#import "XYWIFIManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface PosPrinter : CDVPlugin<CBCentralManagerDelegate,CBPeripheralDelegate,XYWIFIManagerDelegate> {

    XYWIFIManager* wifiManager;
    
    CBCentralManager *centralManager;
    
    NSMutableDictionary* connections;

    NSArray* scanPeripherals;

    NSString* scanCallback;
    
    NSString* connectCallback;
    
    NSString* writeCallback;

    CBPeripheral *writePeripheral;
    
    CBCharacteristic *writeCharacteristic;
}

-(void) initialize:(CDVInvokedUrlCommand*)command;

-(void) scanBluetoothDevice:(CDVInvokedUrlCommand*)command;

-(void) connectBluetooth:(CDVInvokedUrlCommand*)command;

-(void) connectNet:(CDVInvokedUrlCommand*)command;

//-(void) disconnect:(CDVInvokedUrlCommand*)command;

-(void) disconnectNetPort:(CDVInvokedUrlCommand*)command;

-(void) disconnectBluetoothPort:(CDVInvokedUrlCommand*)command;

-(void) writeToBluetoothDevice:(CDVInvokedUrlCommand*)command;

-(void) writeToNetDevice:(CDVInvokedUrlCommand*)command;

@end
