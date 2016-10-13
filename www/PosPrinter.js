var PluginName = "PosPrinter";
var exec = require('cordova/exec');
exports.initialize = function (success) {
    exec(success, success, PluginName, "initialize", []);
};
exports.getBluetoothState = function (success) {
    exec(success, success, PluginName, "getBluetoothState", []);
};
exports.scanBluetoothDevice = function (success, error) {
    exec(success, error, PluginName, "scanBluetoothDevice", []);
};
exports.connectBluetooth = function (arg0, success, error) {
    exec(success, error, PluginName, "connectBluetooth", [arg0]);
};
exports.connectNet = function (arg0, arg1, success, error) {
    exec(success, error, PluginName, "connectNet", [arg0, arg1]);
};
exports.stopScanBluetoothDevices = function (success) {
    exec(success, success, PluginName, "stopScanBluetoothDevices", []);
};
// only ios 
exports.disconnectNetPort = function (success, error) {
    exec(success, error, PluginName, "disconnectNetPort", []);
};
exports.disconnectBluetoothPort = function (success, error) {
    exec(success, error, PluginName, "disconnectBluetoothPort", []);
};
exports.writeToNetDevice = function (arg0, success, error) {
    exec(success, error, PluginName, "writeToNetDevice", arg0);
};
exports.writeToBluetoothDevice = function (arg0, success, error) {
    exec(success, error, PluginName, "writeToBluetoothDevice", arg0);
};
// only android 
exports.enableBluetooth = function (success, error) {
    exec(success, error, PluginName, "enableBluetooth", []);
};
exports.disableBluetooth = function (success, error) {
    exec(success, error, PluginName, "disableBluetooth", []);
};
exports.connectUsb = function (arg0, success, error) {
    exec(success, error, PluginName, "connectUsb", [arg0]);
};
exports.disconnectCurrentPort = function (success, error) {
    exec(success, error, PluginName, "disconnectCurrentPort", []);
};
exports.write = function (arg0, success, error) {
    exec(success, error, PluginName, "write", arg0);
};
exports.read = function (success, error) {
    exec(success, error, PluginName, "read", []);
};

// error_code
var NOT_CONNECT = -1;
var DISCOVERY_ERROR = 1;
var DISCONNECT_ERROR = 2;
var BLUETOOTH_CONNECT_FAIL = 3;
var WRITE_FAIL = 6;
var USB_CONNECT_FAIL = 4;
var REQUEST_ENABLE_BT_FAIL = 7;
var NET_CONNECT_FAIL = 5;
var BLUETOOTH_DISCONNECT = 8;
var USB_DISCONNECT = 9;
var NET_DISCONNECT = 10;
var DISABLE_BLUETOOTH_FAIL = 11;
var SCAN_BLUETOOTHDEVICE_FAIL = 12;

//bluetooth_state