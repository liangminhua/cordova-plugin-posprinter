package cordova.plugin.posprinter;
/**
 * cordova-plugin-posprinter
 * Created by BEN on 2016/8/25.
 */

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class PosPrinter extends CordovaPlugin {
  private static final String keyStatus = "status";
  private static final String statusDisabled = "disabled";
  private static final String statusEnabled = "enabled";
  private static final String keyRequest = "request";
  private static final String keyStatusReceiver = "statusReceiver";
  private static final String keyName = "name";
  private static final String keyAddress = "address";
  private static final String keyBondStatus = "boodStatus";
  private final String statusScanStarted = "scanStarted";
  private final String statusScanStopped = "scanStopped";
  private final String statusScanResult = "scanResult";

  private static final int REQUEST_ENABLE_BT = 1;

  private BluetoothAdapter bluetoothAdapter;
  private CallbackContext initCallbackContext;
  private CallbackContext scanCallbackContext;

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

  private final static String keyType = "type";
  private final static String keyUuids = "Uuid";
  BroadcastReceiver scanReceiver = new BroadcastReceiver() {
    public void onReceive(Context context, Intent intent) {
      if(scanCallbackContext==null)
        return;
      String action = intent.getAction();
      // When discovery finds a device
      if (BluetoothDevice.ACTION_FOUND.equals(action)) {
        // Get the BluetoothDevice object from the Intent
        JSONObject callbackJsonObject = new JSONObject();
        BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        addProperty(callbackJsonObject,keyStatus,statusScanResult);
        addProperty(callbackJsonObject, keyName, device.getName());
        addProperty(callbackJsonObject, keyAddress, device.getAddress());
//        addProperty(callbackJsonObject, keyBondStatus, device.getBondState());
//        addProperty(callbackJsonObject, keyUuids, device.getUuids());
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
//          addProperty(callbackJsonObject, keyType, device.getType());
//          Log.i("PosPrinter", device.getName() + "\n" + device.getAddress() + "\n" + device.getType());
//        }
        sendUpdate(scanCallbackContext, callbackJsonObject);
      }
      if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)){
        JSONObject callbackJsonObject= new JSONObject();
        addProperty(callbackJsonObject,keyStatus,statusScanStopped);
        scanCallbackContext.success(callbackJsonObject);
        scanCallbackContext=null;
      }
    }
  };


  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    if (action.equals("initialize")) {
      initialize(args, callbackContext);
      return true;
    }
    if (action.equals("scanBluetoothDevice")) {
      startScan(callbackContext);
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
    bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    JSONObject returnObj = new JSONObject();
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

  private void startScan(final CallbackContext callbackContext) {
    if (scanCallbackContext != null) {
      JSONObject returnObj = new JSONObject();
      callbackContext.error(returnObj);
      return;
    }
    scanCallbackContext = callbackContext;
    IntentFilter intentFilter= new IntentFilter();
    intentFilter.addAction(BluetoothDevice.ACTION_FOUND);
    //intentFilter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
    cordova.getActivity().registerReceiver(scanReceiver, intentFilter);
    boolean result = bluetoothAdapter.startDiscovery();
    if (result) {
      JSONObject returnObj= new JSONObject();
      addProperty(returnObj,keyStatus,statusScanStarted);
      sendUpdate(callbackContext,returnObj);
    }else {
      callbackContext.error(1);
    }
  }

  private void stopScan(final CallbackContext callbackContext) {
    scanCallbackContext = null;
    bluetoothAdapter.cancelDiscovery();
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    if (isStatusReceiverRegistered) {
      cordova.getActivity().unregisterReceiver(statusReceiver);
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

  private JSONObject getArgsObject(JSONArray args) {
    if (args.length() == 1) {
      try {
        return args.getJSONObject(0);
      } catch (JSONException ex) {
      }
    }

    return null;
  }

  private boolean getRequest(JSONObject obj) {
    return obj.optBoolean(keyRequest, false);
  }

  private boolean getStatusReceiver(JSONObject obj) {
    return obj.optBoolean(keyStatusReceiver, true);
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

}
