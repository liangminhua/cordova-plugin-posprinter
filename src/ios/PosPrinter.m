/********* PosPrinter.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <XYSDK.h>
@interface PosPrinter : CDVPlugin {
  // Member variables go here.
}

- (void)coolMethod:(CDVInvokedUrlCommand*)command;
@end

@implementation PosPrinter

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];

    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
-(void)scanBluetoothDevice:(CDVInvokedUrlCommand*)command{
CDVPluginResult* pluginResult = nil;
}
- (void)connectUsb:(CDVInvokedUrlCommand*)command{
CDVPluginResult* pluginResult = nil;
}
- (void)connectBluetooth:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
}
- (void)connectNet:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
}
- (void)write:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
}
- (void)read:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
}
@end
