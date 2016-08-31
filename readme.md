## PosPrinter ##
   使用ESC/TSC命令在POS打印机上打印

## Methods ##
* [PosProinter.initialize](#initialize)
* [PosProinter.getBluetoothState](#getbluetoothstate)
* [PosProinter.enableBluetooth](#enablebluetooth)
* [PosProinter.disableBluetooth](#disablebluetooth)
* [PosProinter.scanBluetoothDevice](#scanbluetoothdevice)
* [PosProinter.connectUsb](#connectusb)
* [PosProinter.connectBluetooth](#connectbluetooth)
* [PosProinter.connectNet](#connectnet)
* [PosProinter.disconnectCurrentPort](#disconnectcurrentport)
* [PosProinter.write](#write)
* [PosProinter.read](#read)

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
PosProinter.initialize(Success,Error);
```
### getBluetoothState ###
获取蓝牙设备的状态。

```javascript
PosProinter.getBluetoothState(Success,Error);
```
### enableBluetooth ###
打开蓝牙端口。

```javascript
PosProinter.enableBluetooth(Success,Error);
```
### disableBluetooth ###
关闭蓝牙端口。

```javascript
PosProinter.disableBluetooth(Success,Error);
```

### scanBluetoothDevice ###
扫描周围的蓝牙设备,12秒后自动停止。

```javascript
PosProinter.scanBluetoothDevice(Success, Error);
```

##### Success #####
* "OK"=> result => Scan has stopped (after 12s)

```javascript
///BOND_BONDED 12
///BOND_BONDING 11
///BOND_NONE 10
///result
{
  "deviceName": "Gprinter",
  "deviceAddress": "8C:DE:52:C7:5A:C8",
  "bondState": 10
}
```

### connectUsb ###
连接Usb端口

```javascript
PosProinter.connectUsb(usbDeviceName,Success, Error);
```

##### Params #####
* usbDeviceName-USB 端口名字（字符串）。

### connectBluetooth ###
连接蓝牙打印机

```javascript
PosProinter.connectBluetooth(bluetoothAddress,Success, Error);
```
##### Params #####
* bluetoothAddress - 蓝牙地址（字符串）。

### connectNet ###
连接网络打印机
```javascript
PosProinter.connectNet(ipAddress,port,Success, Error);
```
##### Params #####
* ipAddress- Ip地址（字符串）。
* port- 端口号（number）。默认9100


### disconnectCurrentPort ###
断开最近连接打印机

```javascript
PosProinter.disconnect(null,Success, Error);
```

### write ###
以byte数组形式传输数据到打印机。

```javascript
PosProinter.write(data,Success, Error);
```
##### Params #####
* data - 一个包含打印内容的byte数组。因为javascript没有byte，所以以数字替代。

### read ###
读取打印机缓存区数据

```javascript
bluetoothle.read(Success, Error);
```

##### Success #####
* 返回一个byte数组，因为javascript没有byte，所以以数字替代。如：[3,...,1,...,97,...]。 
