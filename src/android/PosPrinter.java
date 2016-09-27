package cordova.plugin.posprinter;
/**
 * cordova-plugin-posprinter
 * Created by BEN on 2016/8/25.
 */

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import net.posprinter.posprinterface.IMyBinder;
import net.posprinter.posprinterface.UiExecute;
import net.posprinter.service.PosprinterService;
import net.posprinter.utils.RoundQueue;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;

/**
 * This class echoes a string called from JavaScript.
 */
public class PosPrinter extends CordovaPlugin {
  boolean isConnect = false;
  IMyBinder binder;
  ServiceConnection conn = new ServiceConnection() {
    @Override
    public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
      binder = (IMyBinder) iBinder;
    }

    @Override
    public void onServiceDisconnected(ComponentName componentName) {
    }
  };
  BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
  CallbackContext scanCallback = null;
  CallbackContext enableCallback = null;
  BroadcastReceiver bluetoothReceiver = new BroadcastReceiver() {
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      // When discovery finds a device
      if (BluetoothDevice.ACTION_FOUND.equals(action)) {
        // Get the BluetoothDevice object from the Intent
        JSONObject callbackJsonObject = new JSONObject();
        BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        addProperty(callbackJsonObject, Constant.DEVICE_NAME, device.getName());
        addProperty(callbackJsonObject, Constant.DEVICE_BLUETOOTH_ADDRESS, device.getAddress());
        addProperty(callbackJsonObject, Constant.BOND_STATE, device.getBondState());
        sendUpdate(scanCallback, callbackJsonObject);
        // Logs
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
          Log.i("PosPrinter", device.getName() + "\n" + device.getAddress() + "\n" + device.getType());
        }
      }
    }
  };
  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent intent) {
    super.onActivityResult(requestCode, resultCode, intent);
    // Enable Bluetooth Callback
    if (Constant.REQUEST_ENABLE_BT == requestCode) {
      if (resultCode == Constant.RESULT_OK) {
        enableCallback.success();
      } else {
        enableCallback.error(Constant.REQUEST_ENABLE_BT_FAIL);
      }
    }
  }
  @Override
  public void onDestroy() {
    super.onDestroy();
    if (bluetoothAdapter != null)
      cordova.getActivity().unregisterReceiver(bluetoothReceiver);
    if (conn != null)
      cordova.getActivity().unbindService(conn);
  }

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    if (action.equals("initialize")) {
      initialize(callbackContext);
      return true;
    }
    if (action.equals("getBluetoothState")) {
      getBluetoothState(callbackContext);
      return true;
    }
    if (action.equals("enableBluetooth")) {
      enableBluetooth(callbackContext);
      return true;
    }
    if (action.equals("disableBluetooth")) {
      disableBluetooth(callbackContext);
      return true;
    }
    if (action.equals("scanBluetoothDevice")) {
      scanBluetoothDevice(callbackContext);
      return true;
    }
    if (action.equals("connectUsb")) {
      String usbPathName = args.getString(0);
      connectUsb(usbPathName, callbackContext);
      return true;
    }
    if (action.equals("connectBluetooth")) {
      String address = args.getString(0);
      connectBluetooth(address, callbackContext);
      return true;
    }
    if (action.equals("connectNet")) {
      String ip = args.getString(0);
      int port = args.optInt(1, 9100);
      connectNet(ip, port, callbackContext);
      return true;
    }
    if (action.equals("disconnectCurrentPort")) {
      disconnectCurrentPort(callbackContext);
      return true;
    }
    if (action.equals("write")) {
      byte[] data = new byte[args.length()];
      for (int index = 0; index < args.length(); ++index) {
        data[index] = (byte) args.getInt(index);
      }
      write(data, callbackContext);
      return true;
    }
    if (action.equals("read")) {
      read(callbackContext);
      return true;
    }
    return false;
  }

  private void initialize(final CallbackContext callbackContext) {
    cordova.getThreadPool().execute(new Runnable() {
      @Override
      public void run() {
        Intent intent = new Intent(cordova.getActivity(), PosprinterService.class);
        Context context = cordova.getActivity().getApplicationContext();
        context.bindService(intent, conn, Context.BIND_AUTO_CREATE);
        if (callbackContext != null)
          callbackContext.success();
      }
    });
  }

  private void getBluetoothState(CallbackContext callbackContext) {
    if (BluetoothAdapter.STATE_ON != bluetoothAdapter.getState()) {
      callbackContext.success(1);
    } else {
      callbackContext.success(0);
    }
  }

  private void enableBluetooth(final CallbackContext callbackContext) {
    if (!bluetoothAdapter.isEnabled()) {
      enableCallback = callbackContext;
      Intent intent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
      cordova.getActivity().startActivityForResult(intent, Constant.REQUEST_ENABLE_BT);
    }
  }

  private void disableBluetooth(final CallbackContext callbackContext) {
    boolean result = bluetoothAdapter.disable();
    if (result) {
      callbackContext.success();
    } else {
      callbackContext.error(Constant.DISABLE_BLUETOOTH_FAIL);
    }
  }

  private void scanBluetoothDevice(CallbackContext callbackContext) {
    scanCallback = callbackContext;
    IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
    cordova.getActivity().registerReceiver(bluetoothReceiver, filter);
    boolean result = bluetoothAdapter.startDiscovery();
    if (result) {
      callbackContext.success();
    } else {
      callbackContext.error(Constant.SCAN_BLUETOOTHDEVICE_FAIL);
    }
  }

  private void connectUsb(String usbPathName, final CallbackContext callbackContext) {
    binder.connectUsbPort(cordova.getActivity().getApplicationContext(), usbPathName, new UiExecute() {
      @Override
      public void onsucess() {
        isConnect = true;
        final PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
        binder.acceptdatafromprinter(new UiExecute() {
          @Override
          public void onsucess() {
          }

          @Override
          public void onfailed() {
            isConnect = false;
            callbackContext.error(Constant.USB_DISCONNECT);
          }
        });
      }

      @Override
      public void onfailed() {
        callbackContext.error(Constant.USB_CONNECT_FAIL);
      }
    });

  }

  private void connectBluetooth(String bluetoothAddress, final CallbackContext callbackContext) {
    if (bluetoothAdapter.isEnabled()) {
      binder.connectBtPort(bluetoothAddress, new UiExecute() {
        @Override
        public void onsucess() {
          isConnect = true;
          final PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
          pluginResult.setKeepCallback(true);
          callbackContext.sendPluginResult(pluginResult);
          binder.acceptdatafromprinter(new UiExecute() {
            @Override
            public void onsucess() {
            }

            @Override
            public void onfailed() {
              callbackContext.error(Constant.BLUETOOTH_DISCONNECT);
            }
          });
        }

        @Override
        public void onfailed() {
          isConnect = false;
          callbackContext.error(Constant.BLUETOOTH_CONNECT_FAIL);
        }
      });
    } else {
      callbackContext.error(Constant.REQUEST_ENABLE_BT_FAIL);
    }
  }

  private void connectNet(String ipAddress, int port, final CallbackContext callbackContext) {
    binder.connectNetPort(ipAddress, port, new UiExecute() {
      @Override
      public void onsucess() {
        isConnect = true;
        final PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
        binder.acceptdatafromprinter(new UiExecute() {
          @Override
          public void onsucess() {
          }

          @Override
          public void onfailed() {
            isConnect = false;
            callbackContext.error(Constant.NET_DISCONNECT);
          }
        });
      }

      @Override
      public void onfailed() {
        callbackContext.error(Constant.NET_CONNECT_FAIL);
      }
    });
  }

  private void disconnectCurrentPort(final CallbackContext callbackContext) {
    if (isConnect) {
      binder.disconnectCurrentPort(new UiExecute() {
        @Override
        public void onsucess() {
          callbackContext.success();
        }

        @Override
        public void onfailed() {
          callbackContext.error(Constant.DISCONNECT_FAIL);
        }
      });
    } else {
      callbackContext.error(Constant.NOT_CONNECT);
    }

  }

  private void write(byte[] data, final CallbackContext callbackContext) {
    if (isConnect) {
      binder.write(data, new UiExecute() {
        @Override
        public void onsucess() {
          callbackContext.success();
        }

        @Override
        public void onfailed() {
          callbackContext.error(Constant.WRITE_FAIL);
        }
      });
    } else {
      callbackContext.error(Constant.NOT_CONNECT);
    }
  }

  private void read(CallbackContext callbackContext) {
    RoundQueue<byte[]> readBuffer = binder.readBuffer();
    byte[] data = readBuffer.getLast();
    String res = Arrays.toString(data);
    Log.i("PosPrinter", "data=" + res);
    callbackContext.success(res);
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
