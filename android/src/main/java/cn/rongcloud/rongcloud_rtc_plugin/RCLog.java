package cn.rongcloud.rongcloud_rtc_plugin;

import android.util.Log;

public class RCLog {

    private static String TAG = "[Rong Android]";

    public static void i(String msg) {
        Log.i(TAG,msg);
    }

    public static void e(String msg) {
        Log.e(TAG,msg);
    }
}
