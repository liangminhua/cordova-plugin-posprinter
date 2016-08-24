var exec = require('cordova/exec');
exports.initService = function (arg0, success, error) {
    exec(success, error, "PosPrinter", "initService", []);
};
exports.scanBluetoothDevice = function(arg0, success, error) {
    exec(success, error, "PosPrinter", "scanBluetoothDevice", []);
};
exports.connectUsb = function(arg0, success, error) {
    exec(success, error, "PosPrinter", "connectUsb", [arg0]);
};
exports.connectBluetooth = function(arg0, success, error) {
    exec(success, error, "PosPrinter", "connectBluetooth", [arg0]);
};
exports.connectNet = function(arg0, success, error) {
    exec(success, error, "PosPrinter", "connectNet", [arg0]);
};
exports.disconnect = function(arg0, success, error) {
    exec(success, error, "PosPrinter", "disconnect", []);
};
exports.write = function(arg0, success, error) {
    exec(success, error, "PosPrinter", "write", arg0);
};
exports.read = function(arg0, success, error) {
    exec(success, error, "PosPrinter", "read", []);
};