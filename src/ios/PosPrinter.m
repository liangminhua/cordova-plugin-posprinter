#import "PosPrinter.h"
NSString *const keyStatus=@"status";
NSString *const keyError=@"error";
NSString *const keyRequest=@"request";
NSString *const keyStatusReceiver=@"statusReceiver";
NSString *const keyMessage=@"message";
NSString *const keyAddress=@"address";
NSString *const keyAllowDuplicates = @"allowDuplicates";
NSString *const keyValue=@"value";
NSString *const keyType=@"type";
NSString *const keyName=@"name";

//Write Type
NSString *const writeTypeNoResponse = @"noResponse";

// status types
NSString *const statusEnabled=@"enabled";
NSString *const statusDisabled=@"disabled";
NSString *const statusWritten=@"written";
NSString *const statusScanStarted=@"scanStarted";
NSString *const statusScanStopped=@"scanStopped";
NSString *const statusScanResult=@"scanResult";
NSString *const statusConnected=@"connected";
NSString *const statusDisconnected=@"disconnected";
//Error Types
NSString *const errorInitialize = @"initialize";
NSString *const errorEnable = @"enable";
NSString *const errorDisable = @"disable";
NSString *const errorArguments = @"arguments";
NSString *const errorStartScan = @"startScan";
NSString *const errorStopScan = @"stopScan";
NSString *const errorConnect = @"connect";
NSString* const errorWrite=@"write";
NSString *const errorIsNotDisconnected = @"isNotDisconnected";
NSString *const errorIsNotConnected = @"isNotConnected";

//Error Messages
//Initialization
NSString *const logPoweredOff = @"Bluetooth powered off";
NSString *const logUnauthorized = @"Bluetooth unauthorized";
NSString *const logUnknown = @"Bluetooth unknown state";
NSString *const logResetting = @"Bluetooth resetting";
NSString *const logUnsupported = @"Bluetooth unsupported";
NSString *const logNotInit = @"Bluetooth not initialized";
NSString *const logNotEnabled = @"Bluetooth not enabled";
NSString *const logOperationUnsupported = @"Operation unsupported";
//Scanning
NSString *const logAlreadyScanning = @"Scanning already in progress";
NSString *const logNotScanning = @"Not scanning";

//Connection
NSString *const logIsDisconnected = @"Device is disconnected";
NSString *const logNoAddress = @"No connection address";
NSString *const logNoDevice = @"Device not found";
NSString *const logIsNotConnected = @"Device isn't connected";
NSString *const logIsNotDisconnected = @"Device isn't disconnected";

//write
//Read/write
NSString *const logNoArgObj = @"Argument object not found";
NSString *const logNoService = @"Service not found";
NSString *const logNoCharacteristic = @"Characteristic not found";
NSString *const logWriteValueNotFound = @"Write value not found";


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
        CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:0];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:connectBluetoothCallback];
    }
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if(connectBluetoothCallback!=nil){
        CDVPluginResult* pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                           messageAsInt:0];
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
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:0];
        
    }else{
        pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:writeBluetoothCallback];
}

-(void) initialize:(CDVInvokedUrlCommand*)command{
    initCallback= command.callbackId;
    if(centralManager!=nil){
        NSDictionary* returnObj=nil;
        CDVPluginResult* pluginResult=nil;
        if([centralManager state]==CBCentralManagerStatePoweredOn){
            returnObj =[NSDictionary dictionaryWithObjectsAndKeys:statusEnabled , keyStatus,nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
        }else{
            returnObj =[NSDictionary dictionaryWithObjectsAndKeys:statusDisabled,keyStatus, nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        }
        [pluginResult setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:initCallback];
        return;
    }
    NSNumber* request= [NSNumber numberWithBool:NO];
    
    NSDictionary* obj =[self getArgsObject:command.arguments];
    if(obj!=nil){
        request=[self getRequest:obj];
    }
    NSMutableDictionary* options= [NSMutableDictionary dictionary];
    if(request){
        [options setValue:request forKey:CBCentralManagerOptionShowPowerAlertKey];
    }
    centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
}
- (void)enable:(CDVInvokedUrlCommand *)command {
    NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorEnable, keyError, logOperationUnsupported, keyMessage, nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)disable:(CDVInvokedUrlCommand *)command {
    NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorDisable, keyError, logOperationUnsupported, keyMessage, nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
-(void)startScan:(CDVInvokedUrlCommand*)command{
    if([self isNotEnabled:command]){
        return;
    }
    if (scanCallback!=nil) {
        NSDictionary* returnObj= [NSDictionary dictionaryWithObjectsAndKeys:errorStartScan,keyError,logAlreadyScanning,keyMessage, nil];
        CDVPluginResult* pluginResult= [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    NSDictionary* obj =[self getArgsObject:command.arguments];
    NSNumber* allowDuplicates = [NSNumber numberWithBool:NO];
    if (obj != nil) {
        allowDuplicates = [self getAllowDuplicates:obj];
    }
    scanCallback=command.callbackId;
    
    NSDictionary* returnObj= [NSDictionary dictionaryWithObjectsAndKeys:statusScanStarted,keyStatus, nil];
    CDVPluginResult* pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    // startScan
    [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:allowDuplicates}];
}

-(void) stopScan:(CDVInvokedUrlCommand*)command{
    if([self isNotInitialized:command]){
        return;
    }
    if(scanCallback==nil){
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorStartScan, keyError, logNotScanning, keyMessage, nil];
        CDVPluginResult *pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    scanCallback=nil;
    [centralManager stopScan];
    
    NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: statusScanStopped, keyStatus, nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
-(void) connect:(CDVInvokedUrlCommand *)command{
    if([self isNotInitialized:command]){
        return;
    }
    NSDictionary* obj= [self getArgsObject:command.arguments];
    
    NSUUID* address = [self getAddress:obj];
    if ([self isNotAddress:address :command]) {
        return;
    }
    NSArray* peripherals= [centralManager retrievePeripheralsWithIdentifiers:@[address]];
    if (peripherals.count==0) {
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorConnect, keyError, logNoDevice, keyMessage, [address UUIDString], keyAddress, nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    CBPeripheral* peripheral=peripherals[0];
    
    writePeripheral= peripheral;
    
    [peripheral setDelegate:self];
    [centralManager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

-(void)disconnect:(CDVInvokedUrlCommand *)command{
    if ([self isNotInitialized:command]) {
        return;
    }
    NSMutableDictionary* returnObj = [NSMutableDictionary dictionary];
    [self addDevice:writePeripheral :returnObj];
    
    [centralManager cancelPeripheralConnection:writePeripheral];
    writeCharacteristic=nil;
    writePeripheral=nil;
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)write:(CDVInvokedUrlCommand *)command{
    if ([self isNotInitialized:command]) {
        return;
    }
    NSDictionary* obj= [self getArgsObject:command.arguments];
    if ([self isNotArgsObject:obj:command]) {
        return;
    }
    
    CBPeripheral* peripheral= writePeripheral;
    //Ensure connection is connected
    if ([self isNotConnected:peripheral :command]) {
        return;
    }
    
    NSData* value=[self getValue:obj];
    //And ensure it's not empty
    if (value == nil) {
        NSMutableDictionary* returnObj = [NSMutableDictionary dictionary];
        
        [self addDevice:peripheral :returnObj];
        
        [returnObj setValue:errorWrite forKey:keyError];
        [returnObj setValue:logWriteValueNotFound forKey:keyMessage];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    //Get the write type (response or no response)
    int writeType = [self getWriteType:obj];
    
    [peripheral writeValue:value forCharacteristic:writeCharacteristic type:writeType];
    if (writeType == CBCharacteristicWriteWithoutResponse) {
        NSMutableDictionary* returnObj = [NSMutableDictionary dictionary];
        
        [self addDevice:peripheral :returnObj];
        
        [self addValue:value toDictionary:returnObj];
        
        [returnObj setValue:statusWritten forKey:keyStatus];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}


//Helpers to check conditions and send callbacks
- (BOOL) isNotInitialized:(CDVInvokedUrlCommand *)command {
    if (centralManager == nil) {
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorInitialize, keyError, logNotInit, keyMessage, nil];
        
        CDVPluginResult *pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        return true;
    }
    
    return [self isNotEnabled:command];
}
- (BOOL) isNotEnabled:(CDVInvokedUrlCommand *)command {
    if (centralManager.state != CBCentralManagerStatePoweredOn) {
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorEnable, keyError, logNotEnabled, keyMessage, nil];
        
        CDVPluginResult *pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        return true;
    }
    
    return false;
}
-(NSNumber*) getAllowDuplicates:(NSDictionary *)obj {
    NSNumber* allowDuplicates = [obj valueForKey:keyAllowDuplicates];
    
    if (allowDuplicates == nil) {
        return [NSNumber numberWithBool:NO];
    }
    
    if (![allowDuplicates isKindOfClass:[NSNumber class]]) {
        return [NSNumber numberWithBool:NO];
    }
    
    return allowDuplicates;
}
-(NSNumber*) getStatusReceiver:(NSDictionary *)obj {
    NSNumber* checkStatusReceiver = [obj valueForKey:keyStatusReceiver];
    
    if (checkStatusReceiver == nil) {
        return [NSNumber numberWithBool:YES];
    }
    
    if (![checkStatusReceiver isKindOfClass:[NSNumber class]]) {
        return [NSNumber numberWithBool:YES];
    }
    
    return checkStatusReceiver;
}
-(NSUUID*) getAddress:(NSDictionary *)obj {
    NSString* addressString = [obj valueForKey:keyAddress];
    
    if (addressString == nil) {
        return nil;
    }
    
    if (![addressString isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    return [[NSUUID UUID] initWithUUIDString:addressString];
}
-(NSNumber*)getRequest:(NSDictionary*)obj{
    NSNumber* request=[obj valueForKey:keyRequest];
    if(request==nil){
        return [NSNumber numberWithBool:NO];
    }
    if (![request isKindOfClass:[NSNumber class]]) {
        return [NSNumber numberWithBool:NO];
    }
    return request;
}
-(NSData*) getValue:(NSDictionary *) obj {
    NSString* string = [obj valueForKey:keyValue];
    
    if (string == nil) {
        return nil;
    }
    
    if (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    
    if (data == nil || data.length == 0) {
        return nil;
    }
    
    return data;
}
-(int) getWriteType:(NSDictionary *)obj {
    NSString* writeType = [obj valueForKey:keyType];
    
    if (writeType == nil || [writeType compare:writeTypeNoResponse]) {
        return CBCharacteristicWriteWithResponse;
    }
    return CBCharacteristicWriteWithoutResponse;
}
-(NSDictionary*) getArgsObject:(NSArray *)args {
    if (args == nil) {
        return nil;
    }
    
    if (args.count != 1) {
        return nil;
    }
    
    NSObject* arg = [args objectAtIndex:0];
    
    if (![arg isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return (NSDictionary *)[args objectAtIndex:0];
}
-(void) addValue:(NSData *) bytes toDictionary:(NSMutableDictionary *) obj {
    //TODO what if the value is null
    
    NSString *string = [bytes base64EncodedStringWithOptions:0];
    
    if (string == nil || string.length == 0) {
        return;
    }
    
    [obj setValue:string forKey:keyValue];
}
- (BOOL) isNotAddress:(NSUUID *)address :(CDVInvokedUrlCommand *)command {
    if (address == nil) {
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorConnect, keyError, logNoAddress, keyMessage, nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return true;
    }
    
    return false;
}
- (BOOL) isNotConnected:(CBPeripheral *)peripheral :(CDVInvokedUrlCommand *)command {
    if (peripheral.state == CBPeripheralStateConnected) {
        return false;
    }
    
    NSMutableDictionary* returnObj = [NSMutableDictionary dictionary];
    
    [self addDevice:peripheral :returnObj];
    
    [returnObj setValue:errorIsNotConnected forKey:keyError];
    [returnObj setValue:logIsNotConnected forKey:keyMessage];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    return true;
}
- (BOOL) isNotArgsObject:(NSDictionary*) obj :(CDVInvokedUrlCommand *)command {
    if (obj != nil) {
        return false;
    }
    
    NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorArguments, keyError, logNoArgObj, keyMessage, nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    return true;
}
-(void) addDevice:(CBPeripheral*)peripheral :(NSDictionary*)returnObj {
    NSObject* name = [self formatName:peripheral.name];
    [returnObj setValue:name forKey:keyName];
    [returnObj setValue:peripheral.identifier.UUIDString forKey:keyAddress];
}
@end
