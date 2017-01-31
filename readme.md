# cordova-plugin-posprinter (Deprecated) 
   使用ESC/TSC命令在POS打印机上打印。这个项目已经废弃，请查看[cordova-posprinter-sample](https://github.com/liangminhua/cordova-posprinter-sample)以获得更多的帮助。

## Methods ##
* [posprinter.initialize](#initialize)
* [posprinter.getBluetoothState](#getbluetoothstate)
* [posprinter.enableBluetooth](#enablebluetooth(Android))
* [posprinter.disableBluetooth](#disablebluetooth)(Android)
* [posprinter.scanBluetoothDevice](#scanbluetoothdevice)
* [posprinter.stopScanBluetoothDevices](#stopscanbluetoothdevices)
* [posprinter.connectUsb](#connectusb)(Android)
* [posprinter.connectBluetooth](#connectbluetooth)
* [posprinter.connectNet](#connectnet)
* [posprinter.disconnectCurrentPort](#disconnectcurrentport)(Android)
* [posprinter.write](#write)(Android)
* [posprinter.disconnectNetPort](#disconnectnetport)(IOS)
* [posprinter.disconnectBluetoothPort](#disconnectbluetoothport)(IOS)
* [posprinter.writeToNetDevice](#writetonetdevice)(IOS)
* [posprinter.writeToBluetoothDevice](#writetobluetoothdevice)(IOS)
* [posprinter.read](#read)(Android)

## Errors ##
    NOT_CONNECT = -1; 没有连接设备
    DISCOVERY_ERROR = 1;  扫描蓝牙设备错误
    DISCONNECT_ERROR = 2; 断开连接错误
    BLUETOOTH_CONNECT_FAIL = 3; 蓝牙连接失败
    WRITE_FAIL = 6; 往设备写数据失败
    USB_CONNECT_FAIL = 4; USB连接失败
    REQUEST_ENABLE_BT_FAIL = 7;  打开蓝牙设备失败
    NET_CONNECT_FAIL = 5; 网络连接失败
    BLUETOOTH_DISCONNECT = 8; 蓝牙打印机断开
    USB_DISCONNECT = 9; USB打印机断开
    NET_DISCONNECT = 10; 网络打印机断开
    DISABLE_BLUETOOTH_FAIL = 11; 关闭蓝牙失败
    SCAN_BLUETOOTHDEVICE_FAIL = 12; 扫描周围的蓝牙设备失败

## API Reference ##

### initialize ###
必须先初始化，才能调用其他函数接口。

```javascript
posprinter.initService(Success,Error);
```
### getBluetoothState ###
获取蓝牙设备的状态。

```javascript
posprinter.getBluetoothState(Success,Error);
```
##### Success #####
*  1 --- 蓝牙设备打开
*  2 --- 蓝牙设备关闭

### enableBluetooth ###
打开蓝牙端口。

```javascript
posprinter.enableBluetooth(Success,Error);
```
### disableBluetooth ###
关闭蓝牙端口。

```javascript
posprinter.disableBluetooth(Success,Error);
```

### scanBluetoothDevice ###
扫描周围的蓝牙设备,12秒后自动停止。

```javascript
posprinter.scanBluetoothDevice(Success, Error);
```

##### Success #####
* Android 会在扫描12秒后自动关闭扫描，IOS需要调用stopScanBluetoothDevices

```javascript
{
  "deviceName": "Gprinter",
  "deviceAddress": "8C:DE:52:C7:5A:C8",
  "bondState": 10
}
```

### stopScanBluetoothDevices ###
* IOS设备停止扫描周围的蓝牙设备。

```javascript
posprinter.stopScanBluetoothDevices(Success);
```

### connectUsb ###
连接Usb端口

```javascript
posprinter.connectUsb(usbDeviceName,Success, Error);
```

##### Params #####
* usbDeviceName-USB 端口名字（字符串）。

### connectBluetooth ###
连接蓝牙打印机

```javascript
posprinter.connectBluetooth(bluetoothAddress,Success, Error);
```
##### Params #####
* bluetoothAddress - 蓝牙地址（字符串）。

### connectNet ###
连接网络打印机
```javascript
posprinter.connectNet(ipAddress,port,Success, Error);
```
##### Params #####
* ipAddress- Ip地址（字符串）。
* port- 端口号（number）。默认9100


### disconnectCurrentPort ###
断开最近连接打印机

```javascript
posprinter.disconnect(Success, Error);
```

### write ###
以byte数组形式传输数据到打印机。

```javascript
posprinter.write(data,Success, Error);
```
##### Params #####
* data - 一个包含打印内容的byte数组。因为javascript没有byte，所以以数字替代。

### disconnectNetPort ###
IOS设断开已经连接的网络端口。

```javascript
posprinter.disconnectNetPort(Success, Error);
```

### disconnectBluetoothPort ###
IOS设备断开已经连接的蓝牙端口。

```javascript
posprinter.disconnectBluetoothPort(Success, Error);
```


### writeToNetDevice ###
IOS设备通过网络形式以byte数组形式传输数据到打印机。

```javascript
posprinter.write(data,Success, Error);
```
##### Params #####
* data - 一个包含打印内容的byte数组。因为javascript没有byte，所以以数字替代

### writeToBluetoothDevice ###
IOS设备通过蓝牙形式以byte数组形式传输数据到打印机。

```javascript
posprinter.write(data,Success, Error);
```
##### Params #####
* data - 一个包含打印内容的byte数组。因为javascript没有byte，所以以数字替代

### read ###
读取打印机缓存区数据

```javascript
bluetoothle.read(Success, Error);
```

##### Success #####
* 返回一个byte数组，因为javascript没有byte，所以以数字替代。如：[3,...,1,...,97,...]。 
