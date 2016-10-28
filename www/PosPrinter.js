var PluginName = "PosPrinter";
var exec = require('cordova/exec');
exports.initialize = function (success, args) {
    exec(success, success, PluginName, "initialize", [args]);
};

exports.enable = function (success, error, args) {
    exec(success, error, PluginName, "enable", [args]);
};

exports.disable = function (success, error, args) {
    exec(success, error, PluginName, "disable", [args]);
};

exports.startScan = function (success, error, args) {
    exec(success, error, PluginName, "startScan", [args]);
};

exports.stopScan = function (success, error, args) {
    exec(success, error, PluginName, "stopScan", [args]);
};

exports.connectBluetooth = function (success, error, args) {
    exec(success, error, PluginName, "connectBluetooth", [args]);
};

exports.connectNet = function (success, error, args) {
    exec(success, error, PluginName, "connectNet", [args]);
};

exports.disconnectBluetooth = function (success, error, args) {
    exec(success, error, PluginName, "disconnectBluetooth", [args]);
};

exports.disconnectNet = function (success, error, args) {
    exec(success, error, PluginName, "disconnectNet", [args]);
};

exports.writeToBluetooth = function (success, error, args) {
    exec(success, error, PluginName, "writeToBluetooth", [args]);
};

exports.writeToNet = function (success, error, args) {
    exec(success, error, PluginName, "writeToNet", [args]);
};