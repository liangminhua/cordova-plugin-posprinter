var exec = require('cordova/exec');
exports.initService = function (arg0, success, error) {
    exec(success, error, "PosPrinter", "initService", []);
};
exports.scanBluetoothDevice = function (arg0, success, error) {
    exec(success, error, "PosPrinter", "scanBluetoothDevice", []);
};
exports.connectUsb = function (arg0, success, error) {
    exec(success, error, "PosPrinter", "connectUsb", [arg0]);
};
exports.connectBluetooth = function (arg0, success, error) {
    exec(success, error, "PosPrinter", "connectBluetooth", [arg0]);
};
exports.connectNet = function (arg0, success, error) {
    exec(success, error, "PosPrinter", "connectNet", [arg0]);
};
exports.disconnect = function (arg0, success, error) {
    exec(success, error, "PosPrinter", "disconnect", []);
};
exports.write = function (arg0, success, error) {
    exec(success, error, "PosPrinter", "write", arg0);
};
exports.read = function (arg0, success, error) {
    exec(success, error, "PosPrinter", "read", []);
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