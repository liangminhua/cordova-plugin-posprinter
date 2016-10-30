package cordova.plugin.posprinter;
/**
 * cordova-plugin-posprinter
 * Created by BEN on 2016/8/25.
 */

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Base64;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.OutputStream;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.Socket;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.net.UnknownHostException;
import java.util.UUID;

/**
 * This class echoes a string called from JavaScript.
 */
public class PosPrinter extends CordovaPlugin {
  private final String statusDisabled = "disabled";
  private final String statusEnabled = "enabled";
  private final String statusConnected = "connected";
  private final String statusDisconnected = "disconnected";
  private final String statusScanStarted = "scanStarted";
  private final String statusScanStopped = "scanStopped";
  private final String statusScanResult = "scanResult";
  private final String statusWritten = "written";

  private final String keyStatus = "status";
  private final String keyRequest = "request";
  private final String keyStatusReceiver = "statusReceiver";
  private final String keyName = "name";
  private final String keyAddress = "address";
  private final String keyError = "error";
  private final String keyMessage = "message";
  private final String keyValue = "value";

  //Error Messages
  private final String errorInitialize = "initialize";
  private final String errorinitializePeripheral = "initializePeripheral";
  private final String errorEnable = "enable";
  private final String errorDisable = "disable";
  private final String errorStartScan = "startScan";
  private final String errorStopScan = "stopScan";
  private final String errorConnect = "connect";
  private final String errorDisconnect = "disconnect";
  private final String errorWrite = "write";
  private final String errorArguments = "arguments";
  private final String errorIsDisconnected = "isDisconnected";

  //Initialization
  private final String logNotEnabled = "Bluetooth not enabled";
  private final String logNotDisabled = "Bluetooth not disabled";
  private final String logNotInit = "Bluetooth not initialized";
  private final String logOperationUnsupported = "Operation unsupported";
  //Scanning
  private final String logAlreadyScanning = "Scanning already in progress";
  private final String logScanStartFail = "Scan failed to start";
  private final String logNotScanning = "Not scanning";
  //Connection
  private final String logPreviouslyConnected = "Device previously connected, reconnect or close for new device";
  private final String logConnectFail = "Connection failed";
  private final String logDisConnectFail = "Disconnection failed";
  private final String logNoDevice = "Device not found";
  private final String logNoAddress = "No device address";
  private final String logIsDisconnected = "Device is disconnected";

  //write
  private final String logNoArgObj = "Argument object not found";
  private final String logWriteFail = "Unable to write";
  private final String logWriteValueNotFound = "Write value not found";

  private static final int REQUEST_ENABLE_BT = 7319; /*Random integer*/
  private static final UUID SPP_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

  private BluetoothAdapter bluetoothAdapter;
  private BluetoothDevice bluetoothDevice;
  private BluetoothSocket bluetoothSocket;

  private Socket socket = new Socket();

  private CallbackContext initCallbackContext;
  private CallbackContext scanCallbackContext;
  private CallbackContext connectCallbackContext;

  private boolean isStatusReceiverRegistered;
  private BroadcastReceiver statusReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      if (initCallbackContext == null) {
        return;
      }
      if (intent.getAction().equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
        PluginResult pluginResult;
        JSONObject returnObj = new JSONObject();
        switch (intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)) {
          case BluetoothAdapter.STATE_OFF:
            addProperty(returnObj, keyStatus, statusDisabled);
            pluginResult = new PluginResult(PluginResult.Status.OK, returnObj);
            pluginResult.setKeepCallback(true);
            initCallbackContext.sendPluginResult(pluginResult);
            break;
          case BluetoothAdapter.STATE_ON:
            addProperty(returnObj, keyStatus, statusEnabled);
            pluginResult = new PluginResult(PluginResult.Status.OK, returnObj);
            pluginResult.setKeepCallback(true);
            initCallbackContext.sendPluginResult(pluginResult);
            break;
        }
      }
    }
  };

  private BroadcastReceiver scanReceiver = new BroadcastReceiver() {
    public void onReceive(Context context, Intent intent) {
      if (scanCallbackContext == null)
        return;
      String action = intent.getAction();
      // When discovery finds a device
      if (BluetoothDevice.ACTION_FOUND.equals(action)) {
        // Get the BluetoothDevice object from the Intent
        JSONObject callbackJsonObject = new JSONObject();
        BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        addProperty(callbackJsonObject, keyStatus, statusScanResult);
        addDevice(callbackJsonObject, device);
        sendUpdate(scanCallbackContext, callbackJsonObject);
      }
      if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
        JSONObject callbackJsonObject = new JSONObject();
        addProperty(callbackJsonObject, keyStatus, statusScanStopped);
        scanCallbackContext.success(callbackJsonObject);
        scanCallbackContext = null;
      }
    }
  };
  private BroadcastReceiver connectReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      if (connectCallbackContext == null)
        return;
      String action = intent.getAction();
      JSONObject returnObj = new JSONObject();
      if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(action)) {
        BluetoothDevice bluetoothDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        addDevice(returnObj, bluetoothDevice);
        addProperty(returnObj, keyStatus, statusConnected);
        sendUpdate(connectCallbackContext, returnObj);
      } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action)) {
        BluetoothDevice bluetoothDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        addDevice(returnObj, bluetoothDevice);
        addProperty(returnObj, keyStatus, statusDisconnected);
        connectCallbackContext.error(returnObj);
      }
    }
  };
  @Override
  public void onDestroy() {
    super.onDestroy();
    if (isStatusReceiverRegistered) {
      cordova.getActivity().unregisterReceiver(statusReceiver);
    }
  }

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    if (action.equals("initialize")) {
      initialize(args, callbackContext);
      return true;
    }
    if (action.equals("enable")) {
      enable(callbackContext);
      return true;
    }
    if (action.equals("disable")) {
      disbale(callbackContext);
      return true;
    }
    if (action.equals("startScan")) {
      startScan(callbackContext);
      return true;
    }
    if (action.equals("stopScan")) {
      stopScan(callbackContext);
      return true;
    }
    if (action.equals("connectBluetooth")) {
      connect(args, callbackContext);
      return true;
    }
    if (action.equals("disconnectBluetooth")) {
      disconnect(callbackContext);
      return true;
    }
    if (action.equals("writeToBluetooth")) {
      write(args, callbackContext);
      return true;
    }
    if (action.equals("connectNet")) {
      connectNet(args, callbackContext);
      return true;
    }
    if (action.equals("disconnectNet")) {
      disconnectNet(args, callbackContext);
      return true;
    }
    if (action.equals("writeToNet")) {
      writeToNet(args, callbackContext);
      return true;
    }
    return false;
  }

  private void initialize(JSONArray args, final CallbackContext callbackContext) {
    initCallbackContext = callbackContext;
    if (bluetoothAdapter != null) {
      JSONObject returnObj = new JSONObject();
      PluginResult pluginResult;
      if (bluetoothAdapter.isEnabled()) {
        addProperty(returnObj, keyStatus, statusEnabled);
        pluginResult = new PluginResult(PluginResult.Status.OK, returnObj);
        pluginResult.setKeepCallback(true);
        initCallbackContext.sendPluginResult(pluginResult);
      } else {
        addProperty(returnObj, keyStatus, statusDisabled);
        pluginResult = new PluginResult(PluginResult.Status.OK, returnObj);
        pluginResult.setKeepCallback(true);
        initCallbackContext.sendPluginResult(pluginResult);
      }
      return;
    }
    JSONObject obj = getArgsObject(args);
    if (obj != null && getStatusReceiver(obj)) {
      cordova.getActivity().registerReceiver(statusReceiver, new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED));
      isStatusReceiverRegistered = true;
    }
    JSONObject returnObj = new JSONObject();
    bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    if (bluetoothAdapter == null) {
      addProperty(returnObj, "error", errorinitializePeripheral);
      addProperty(returnObj, "message", logOperationUnsupported);
      callbackContext.error(returnObj);
    }
    if (bluetoothAdapter.isEnabled()) {
      addProperty(returnObj, keyStatus, statusEnabled);
      PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, returnObj);
      pluginResult.setKeepCallback(true);
      initCallbackContext.sendPluginResult(pluginResult);
      return;
    }
    if (obj != null && getRequest(obj)) {
      Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
      cordova.startActivityForResult(this, enableIntent, REQUEST_ENABLE_BT);
    } else {
      addProperty(returnObj, keyStatus, statusDisabled);
      PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, returnObj);
      pluginResult.setKeepCallback(true);
      initCallbackContext.sendPluginResult(pluginResult);
    }
  }

  private void enable(final CallbackContext callbackContext) {
    if (isNotInitialized(callbackContext, false)) {
      return;
    }

    if (isNotDisabled(callbackContext)) {
      return;
    }

    boolean result = bluetoothAdapter.enable();

    if (!result) {
      //Throw an enabling error
      JSONObject returnObj = new JSONObject();

      addProperty(returnObj, keyError, errorEnable);
      addProperty(returnObj, keyMessage, logNotEnabled);

      callbackContext.error(returnObj);
    }
  }

  private void disbale(final CallbackContext callbackContext) {
    if (isNotInitialized(callbackContext, true)) {
      return;
    }

    boolean result = bluetoothAdapter.disable();

    if (!result) {
      //Throw a disabling error
      JSONObject returnObj = new JSONObject();

      addProperty(returnObj, keyError, errorDisable);
      addProperty(returnObj, keyMessage, logNotDisabled);

      callbackContext.error(returnObj);
    }
  }

  private void startScan(final CallbackContext callbackContext) {
    if (isNotInitialized(callbackContext, true)) {
      return;
    }
    if (scanCallbackContext != null) {
      JSONObject returnObj = new JSONObject();
      addProperty(returnObj, keyError, errorStartScan);
      addProperty(returnObj, keyMessage, logAlreadyScanning);
      callbackContext.error(returnObj);
      return;
    }
    scanCallbackContext = callbackContext;
    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(BluetoothDevice.ACTION_FOUND);
    intentFilter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
    cordova.getActivity().registerReceiver(scanReceiver, intentFilter);
    boolean result = bluetoothAdapter.startDiscovery();
    JSONObject returnObj = new JSONObject();
    if (result) {
      addProperty(returnObj, keyStatus, statusScanStarted);
      PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, returnObj);
      pluginResult.setKeepCallback(true);
      callbackContext.sendPluginResult(pluginResult);
    } else {
      addProperty(returnObj, keyError, errorStartScan);
      addProperty(returnObj, keyMessage, logScanStartFail);
      callbackContext.error(returnObj);
      scanCallbackContext = null;
    }
  }

  private void stopScan(final CallbackContext callbackContext) {
    if (isNotInitialized(callbackContext, true)) {
      return;
    }
    JSONObject returnObj = new JSONObject();
    if (scanCallbackContext == null) {
      addProperty(returnObj, keyError, errorStopScan);
      addProperty(returnObj, keyMessage, logNotScanning);
      callbackContext.error(returnObj);
      return;
    }

    bluetoothAdapter.cancelDiscovery();
    addProperty(returnObj, keyStatus, statusScanStopped);
    callbackContext.success(returnObj);
    scanCallbackContext = null;
  }

  private void connect(JSONArray args, final CallbackContext callbackContext) {
    if (isNotInitialized(callbackContext, true)) {
      return;
    }
    JSONObject obj = getArgsObject(args);
    if (isNotArgsObject(obj, callbackContext)) {
      return;
    }
    String address = getAddress(obj);
    if (isNotAddress(address, callbackContext)) {
      return;
    }
    if (isConnected(callbackContext)) {
      return;
    }

    JSONObject returnObj = new JSONObject();

    bluetoothDevice = bluetoothAdapter.getRemoteDevice(address);
    //Ensure device exists
    BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);
    if (device == null) {
      addProperty(returnObj, keyError, errorConnect);
      addProperty(returnObj, keyMessage, logNoDevice);
      addProperty(returnObj, keyAddress, address);
      callbackContext.error(returnObj);
      return;
    }
    connectCallbackContext = callbackContext;
    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
    intentFilter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
    cordova.getActivity().registerReceiver(connectReceiver, intentFilter);
    try {
      bluetoothSocket = bluetoothDevice.createRfcommSocketToServiceRecord(SPP_UUID);
      bluetoothSocket.connect();
    } catch (IOException e) {
      e.printStackTrace();
      addProperty(returnObj, keyError, errorConnect);
      addProperty(returnObj, keyMessage, logConnectFail);
      callbackContext.error(returnObj);
    }

  }

  private void disconnect(final CallbackContext callbackContext) {
    if (isNotInitialized(callbackContext, true)) {
      return;
    }
    if (isDisConnected(callbackContext)) {
      return;
    }
    JSONObject returnObj = new JSONObject();
    try {
      bluetoothSocket.close();
      addProperty(returnObj, keyStatus, statusDisconnected);
      addDevice(returnObj, bluetoothDevice);
      callbackContext.success(returnObj);
    } catch (IOException e) {
      e.printStackTrace();
      addProperty(returnObj, keyError, errorDisconnect);
      addProperty(returnObj, keyMessage, logDisConnectFail);
      addDevice(returnObj, bluetoothDevice);
      callbackContext.error(returnObj);
    }
  }

  private void write(JSONArray args, final CallbackContext callbackContext) {
    if (isNotInitialized(callbackContext, true)) {
      return;
    }
    if (isDisConnected(callbackContext)) {
      return;
    }
    JSONObject obj = getArgsObject(args);
    JSONObject returnObj = new JSONObject();
    byte[] value = getPropertyBytes(obj, keyValue);
    if (value == null) {
      addProperty(returnObj, keyError, errorWrite);
      addProperty(returnObj, keyMessage, logWriteValueNotFound);
      callbackContext.error(returnObj);
      return;
    }
    try {
      OutputStream writeStream = bluetoothSocket.getOutputStream();
      writeStream.write(value);
      addProperty(returnObj, keyStatus, statusWritten);
      addDevice(returnObj, bluetoothDevice);
      addPropertyBytes(returnObj, keyValue, value);
      callbackContext.success(returnObj);
    } catch (IOException e) {
      e.printStackTrace();
      addProperty(returnObj, keyError, errorWrite);
      addProperty(returnObj, keyMessage, logWriteFail);
      callbackContext.error(returnObj);
    }
  }

  private void connectNet(JSONArray args, final CallbackContext callbackContext) {
    try {
      InetAddress address = InetAddress.getByName("baidu.com");
      SocketAddress socketAddress = new InetSocketAddress(address, 80);
      socket.connect(socketAddress);
      callbackContext.success(1);
    } catch (UnknownHostException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    }

  }

  private void disconnectNet(JSONArray args, final CallbackContext callbackContext) {

  }

  private void writeToNet(JSONArray args, final CallbackContext callbackContext) {

  }

  private void addPropertyBytes(JSONObject returnObj, String keyValue, byte[] bytes) {
    String string = Base64.encodeToString(bytes, Base64.NO_WRAP);
    addProperty(returnObj, keyValue, string);
  }

  private byte[] getPropertyBytes(JSONObject obj, String key) {
    String string = obj.optString(key, null);

    if (string == null) {
      return null;
    }

    byte[] bytes = Base64.decode(string, Base64.NO_WRAP);

    if (bytes == null || bytes.length == 0) {
      return null;
    }

    return bytes;
  }

  private boolean isConnected(CallbackContext callbackContext) {
    if (bluetoothSocket != null && bluetoothSocket.isConnected()) {
      JSONObject returnObj = new JSONObject();
      addProperty(returnObj, keyError, errorConnect);
      addProperty(returnObj, keyMessage, logPreviouslyConnected);
      addDevice(returnObj, bluetoothDevice);
      callbackContext.success(returnObj);
      return true;
    }
    return false;
  }

  private boolean isDisConnected(CallbackContext callbackContext) {
    if (bluetoothSocket != null && bluetoothSocket.isConnected()) {
      return false;
    }
    JSONObject returnObj = new JSONObject();

    addProperty(returnObj, keyError, errorIsDisconnected);
    addProperty(returnObj, keyMessage, logIsDisconnected);
    if (bluetoothDevice != null)
      addDevice(returnObj, bluetoothDevice);
    callbackContext.error(returnObj);
    return true;
  }

  //Helpers to Check Conditions
  private boolean isNotInitialized(CallbackContext callbackContext, boolean checkIsNotEnabled) {
    if (bluetoothAdapter == null) {
      JSONObject returnObj = new JSONObject();
      addProperty(returnObj, keyError, errorInitialize);
      addProperty(returnObj, keyMessage, logNotInit);
      callbackContext.error(returnObj);
      return true;
    }
    if (checkIsNotEnabled) {
      return isNotEnabled(callbackContext);
    } else {
      return false;
    }
  }

  private boolean isNotEnabled(CallbackContext callbackContext) {
    if (!bluetoothAdapter.isEnabled()) {
      JSONObject returnObj = new JSONObject();

      addProperty(returnObj, keyError, errorEnable);
      addProperty(returnObj, keyMessage, logNotEnabled);

      callbackContext.error(returnObj);

      return true;
    }

    return false;
  }

  private boolean isNotDisabled(CallbackContext callbackContext) {
    if (bluetoothAdapter.isEnabled()) {
      JSONObject returnObj = new JSONObject();

      addProperty(returnObj, keyError, errorDisable);
      addProperty(returnObj, keyMessage, logNotDisabled);

      callbackContext.error(returnObj);

      return true;
    }

    return false;
  }

  private boolean isNotArgsObject(JSONObject obj, CallbackContext callbackContext) {
    if (obj != null) {
      return false;
    }

    JSONObject returnObj = new JSONObject();

    addProperty(returnObj, keyError, errorArguments);
    addProperty(returnObj, keyMessage, logNoArgObj);

    callbackContext.error(returnObj);

    return true;
  }

  private boolean isNotAddress(String address, CallbackContext callbackContext) {
    if (address == null) {
      JSONObject returnObj = new JSONObject();

      addProperty(returnObj, keyError, errorConnect);
      addProperty(returnObj, keyMessage, logNoAddress);

      callbackContext.error(returnObj);
      return true;
    }

    return false;
  }

  private JSONObject getArgsObject(JSONArray args) {
    if (args.length() == 1) {
      try {
        return args.getJSONObject(0);
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }

    return null;
  }

  private String getAddress(JSONObject obj) {
    //Get the address string from arguments
    String address = obj.optString(keyAddress, null);

    if (address == null) {
      return null;
    }

    //Validate address format
    if (!BluetoothAdapter.checkBluetoothAddress(address)) {
      return null;
    }

    return address;
  }

  private boolean getRequest(JSONObject obj) {
    return obj.optBoolean(keyRequest, false);
  }

  private boolean getStatusReceiver(JSONObject obj) {
    return obj.optBoolean(keyStatusReceiver, true);
  }

  private void addDevice(JSONObject returnObj, BluetoothDevice device) {
    addProperty(returnObj, keyAddress, device.getAddress());
    addProperty(returnObj, keyName, device.getName());
  }

  //General Helpers
  private void addProperty(JSONObject obj, String key, Object value) {
    //Believe exception only occurs when adding duplicate keys, so just ignore it
    try {
      if (value == null) {
        obj.put(key, JSONObject.NULL);
      } else {
        obj.put(key, value);
      }
    } catch (JSONException e) {
      Log.e("PosPrinter", e.getMessage());
    }
  }

  /**
   * Create a new plugin result and send it back to JavaScript
   *
   * @param obj the printer info to set as navigator.connection
   */
  private void sendUpdate(CallbackContext callbackContext, JSONObject obj) {
    if (callbackContext != null) {
      PluginResult result = new PluginResult(PluginResult.Status.OK, obj);
      result.setKeepCallback(true);
      callbackContext.sendPluginResult(result);
    }
  }
}
