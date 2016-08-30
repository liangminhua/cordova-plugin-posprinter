## PosPrinter ##
   使用ESC/TSC命令在POS打印机上打印

## Methods ##
* [PosProinter.initService](#initService)
* [PosProinter.scanBluetoothDevice](#scanBluetoothDevice)
* [PosProinter.connectUsb](#connectUsb)
* [PosProinter.connectBluetooth](#connectBluetooth)
* [PosProinter.connectNet](#connectNet)
* [PosProinter.disconnect](#disconnect)
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

## API Reference ##

### initService ###
初始化服务。必须先初始化，才能调用其他函数接口。

```javascript
PosProinter.initService(null,Success,Error);
```


### scanBluetoothDevice ###
扫描周围的蓝牙设备,12秒后自动停止。

```javascript
PosProinter.scanBluetoothDevice(null,Success, Error);
```

##### Success #####
* "OK"=> result => Scan has stopped

```javascript
///BOND_BONDED 12
///BOND_BONDING 11
///BOND_NONE 10
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
##### Success #####
* "OK"

### connectBluetooth ###
连接蓝牙设备

```javascript
PosProinter.connectBluetooth(bluetoothAddress,Success, Error);
```
##### Params #####
* bluetoothAddress - 蓝牙地址（字符串）。
##### Success #####
* "OK"

### connectNet ###

```javascript
PosProinter.connectNet(ipAddress,port,Success, Error);
```
##### Params #####
* ipAddress- Ip地址（字符串）。
* port- 端口号（number）。
##### Success #####
* "OK"

### disconnect ###
扫描周围的蓝牙设备,12秒后自动停止。

```javascript
PosProinter.disconnect(null,Success, Error);
```

##### Success #####
* "OK"

### write ###
往打印机写数据，把数据转换byte数组形式，传输到打印机。

```javascript
PosProinter.write(data,Success, Error);
```
##### Params #####
* data - 一个包含打印内容的byte数组。
##### Success #####
* "OK"

### read ###
读取打印机缓存区数据

```javascript
bluetoothle.read(null,Success, Error);
```

##### Success #####
* 返回一个byte数组;
