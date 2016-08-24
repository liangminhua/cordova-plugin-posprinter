package cordova.plugin.posprinter;

/**
 * Created by BEN on 2016/8/19.
 */
public class Constant {
    public static final int REQUEST_ENABLE_BT = 1;
    public static final int RESULT_CANCELED = 0;
    public static final int RESULT_FIRST_USER = 1;
    public static final int RESULT_OK = -1;
    // error_code
    public static final int DISCOVERY_ERROR = 1;
    public static final int DISCONNECT_ERROR = 2;
    public static final int BLUETOOTH_CONNECT_FAIL = 3;
    public static final int USB_CONNECT_FAIL = 4;
    public static final int NET_CONNECT_FAIL = 5;
    public static final int WRITE_FAIL = 6;
    public static final int REQUEST_ENABLE_BT_FAIL = 7;

    // retrun property key
    public static final String DEVICE_NAME = "deviceName";
    public static final String DEVICE_BLUETOOTH_ADDRESS = "deviceAddress";
    public static final String BOND_STATE = "bondState";
    public static final String UUID = "uuid";
}
