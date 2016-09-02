#import <Cordova/CDV.h>
#import "XYSDK.h"
@interface PosPrinter : CDVPlugin<XYBLEManagerDelegate , XYWIFIManagerDelegate> {
    // Member variables go here.
    XYBLEManager*  bluetoothManager;
    XYWIFIManager* wifiManager;
    NSString* scanCallback;
}
-(void) initialize:(CDVInvokedUrlCommand*)command;
-(void) scanBluetoothDevice:(CDVInvokedUrlCommand*)command;
-(void) connectBluetooth:(CDVInvokedUrlCommand*)command;
-(void) connectNet:(CDVInvokedUrlCommand*)command;
-(void) disconnect:(CDVInvokedUrlCommand*)command;
-(void) write:(CDVInvokedUrlCommand*)command;
@end