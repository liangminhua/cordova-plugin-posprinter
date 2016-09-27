#import <Cordova/CDV.h>

#import "XYWIFIManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

int const NOT_CONNECT = -1;
int const DISCOVERY_ERROR = 1;
int const DISCONNECT_ERROR = 2;
int const BLUETOOTH_CONNECT_FAIL = 3;
int const NET_CONNECT_FAIL = 5;
int const WRITE_FAIL = 6;
int const BLUETOOTH_DISCONNECT = 8;
int const NET_DISCONNECT = 10;
int const SCAN_BLUETOOTHDEVICE_FAIL = 12;

@interface PosPrinter : CDVPlugin<CBCentralManagerDelegate,CBPeripheralDelegate,XYWIFIManagerDelegate> {

    XYWIFIManager* wifiManager;
    
    CBCentralManager *centralManager;
    
    NSArray* scanPeripherals;
    
    NSString* scanCallback;
    
    NSString* connectBluetoothCallback;
    
    NSString* connectNetCallback;
    
    NSString* writeBluetoothCallback;
    
    NSString* writeNetCallback;
    
    CBPeripheral *writePeripheral;
    
    CBCharacteristic *writeCharacteristic;
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
