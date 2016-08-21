package cordova.plugin.posprinter;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.util.Log;

import net.posprinter.posprinterface.IMyBinder;
import net.posprinter.posprinterface.UiExecute;
import net.posprinter.service.PosprinterService;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Set;

import static cordova.plugin.posprinter.Constant.*;

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
  UiExecute connectReturn = new UiExecute() {
    @Override
    public void onsucess() {
      isConnect = true;
      binder.acceptdatafromprinter(new UiExecute() {
        @Override
        public void onsucess() {

        }

        @Override
        public void onfailed() {
          isConnect = false;
        }
      });
    }

    @Override
    public void onfailed() {
      isConnect = false;
    }
  };

  BluetoothAdapter bluetoothAdapter = null;

  CallbackContext vailableDeviceCallbackContext = null;

  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
    //
    Intent intent = new Intent(cordova.getActivity(), PosprinterService.class);
    Context context = cordova.getActivity().getApplicationContext();
    context.bindService(intent, conn, Context.BIND_AUTO_CREATE);
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
  }

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    if (action.equals("scanBluetoothDevice")) {
      scanBlueboothDevice(callbackContext);
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
      int port = args.getInt(1);
      connectNet(ip, port, callbackContext);
      return true;
    }
    if (action.equals("diconnect")) {
      disconnectCurrentPort(callbackContext);
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

  private void connectUsb(String usbPathName, CallbackContext callbackContext) {
    binder.connectUsbPort(cordova.getActivity().getApplicationContext(), usbPathName, new UiExecute() {
      @Override
      public void onsucess() {

      }

      @Override
      public void onfailed() {

      }
    });

  }

  private void connectBluetooth(String bluetoothAddress, CallbackContext callbackContext) {
    binder.connectBtPort(bluetoothAddress, connectReturn);
  }

  private void connectNet(String ipAddress, int port, CallbackContext callbackContext) {
    binder.connectNetPort(ipAddress, port, connectReturn);
  }

  private void disconnectCurrentPort(final CallbackContext callbackContext) {
    binder.disconnectCurrentPort(new UiExecute() {
      @Override
      public void onsucess() {
        callbackContext.success();
      }

      @Override
      public void onfailed() {

      }
    });
  }

  private void write(byte[] data, CallbackContext callbackContext) {

    binder.write(data, new UiExecute() {
      @Override
      public void onsucess() {

      }

      @Override
      public void onfailed() {

      }
    });
  }

  private void read(CallbackContext callbackContext) {

  }

  private void scanBlueboothDevice(CallbackContext callbackContext) {
    vailableDeviceCallbackContext = callbackContext;
    bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    if (!bluetoothAdapter.isEnabled()) {
      Intent intent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
      cordova.getActivity().startActivityForResult(intent, REQUEST_ENABLE_BT);
    } else {
      findAvalibleDevice();
    }
  }

  private void findAvalibleDevice() {
    boolean result = bluetoothAdapter.startDiscovery();
    Set<BluetoothDevice> device = bluetoothAdapter.getBondedDevices();
    sendUpdate(vailableDeviceCallbackContext, null);
    IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
    cordova.getActivity().registerReceiver(new BroadcastReceiver() {
      public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        // When discovery finds a device
        if (BluetoothDevice.ACTION_FOUND.equals(action)) {
          // Get the BluetoothDevice object from the Intent
          BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
          // Add the name and address to an array adapter to show in a ListView
          Log.i("Xprinter", device.getName() + "\n" + device.getAddress());
        }
      }
    }, filter);
  }

  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent intent) {
    super.onActivityResult(requestCode, resultCode, intent);
    // Enable Bluetooth Callback
    if (Constant.REQUEST_ENABLE_BT == requestCode) {
      if (resultCode == RESULT_OK) {
        findAvalibleDevice();
      } else {

      }
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
