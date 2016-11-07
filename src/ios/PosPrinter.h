#import <Cordova/CDV.h>

#import "XYWIFIManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface PosPrinter : CDVPlugin<CBCentralManagerDelegate,CBPeripheralDelegate,XYWIFIManagerDelegate> {
    
    CBCentralManager *centralManager;
    
    NSArray* scanPeripherals;
    
    NSString* initCallback;
    
    NSString* scanCallback;
    
    NSString* connectBluetoothCallback;
    
    NSString* connectNetCallback;
    
    NSString* writeBluetoothCallback;
    
    NSString* writeNetCallback;
    
    CBPeripheral *writePeripheral;
    
    CBCharacteristic *writeCharacteristic;
}

-(void) initialize:(CDVInvokedUrlCommand*)command;
-(void) enable:(CDVInvokedUrlCommand*)command;
-(void) disable:(CDVInvokedUrlCommand*)command;
-(void) startScan:(CDVInvokedUrlCommand*)command;
-(void) stopScan:(CDVInvokedUrlCommand*)command;
-(void) connect:(CDVInvokedUrlCommand*)command;
-(void) disconnect:(CDVInvokedUrlCommand*)command;
-(void) write:(CDVInvokedUrlCommand*)command;
@end
