package cordova.plugin.posprinter;

/**
 * Created by BEN on 2016/8/19.
 */
public class Constant {
    public static final int REQUEST_ENABLE_BT = 1;
    public static final int RESULT_OK = -1;

    // retrun property key
    public static final String DEVICE_NAME = "deviceName";
    public static final String DEVICE_BLUETOOTH_ADDRESS = "deviceAddress";
    public static final String BOND_STATE = "bondState";

    // error_code
    public static final int NOT_CONNECT = 1;
    public static final int DISCONNECT_FAIL = 2;
    public static final int BLUETOOTH_CONNECT_FAIL = 3;
    public static final int USB_CONNECT_FAIL = 4;
    public static final int NET_CONNECT_FAIL = 5;
    public static final int WRITE_FAIL = 6;
    public static final int REQUEST_ENABLE_BT_FAIL = 7;
    public static final int BLUETOOTH_DISCONNECT = 8;
    public static final int USB_DISCONNECT = 9;
    public static final int NET_DISCONNECT = 10;
    public static final int DISABLE_BLUETOOTH_FAIL = 11;
    public static final int SCAN_BLUETOOTHDEVICE_FAIL = 12;
}
