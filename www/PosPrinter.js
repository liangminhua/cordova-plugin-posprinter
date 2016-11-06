var PluginName = "PosPrinter";
var exec = require('cordova/exec');
exports.initialize = function (success, args) {
    exec(success, success, PluginName, "initialize", [args]);
};

exports.enable = function (success, error) {
    exec(success, error, PluginName, "enable", []);
};

exports.disable = function (success, error) {
    exec(success, error, PluginName, "disable", []);
};

exports.startScan = function (success, error, args) {
    exec(success, error, PluginName, "startScan", [args]);
};

exports.stopScan = function (success, error) {
    exec(success, error, PluginName, "stopScan", []);
};

exports.connect = function (success, error, args) {
    exec(success, error, PluginName, "connect", [args]);
};

exports.disconnect = function (success, error) {
    exec(success, error, PluginName, "disconnect", []);
};

exports.write = function (success, error, args) {
    exec(success, error, PluginName, "write", [args]);
};
