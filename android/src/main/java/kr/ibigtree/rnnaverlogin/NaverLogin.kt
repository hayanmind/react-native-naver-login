package kr.ibigtree.rnnaverlogin

import android.app.Activity
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.*
import com.facebook.react.uimanager.ViewManager
import com.nhn.android.naverlogin.OAuthLogin
import com.nhn.android.naverlogin.OAuthLoginHandler
import com.nhn.android.naverlogin.data.OAuthErrorCode
import java.lang.ref.WeakReference


class NaverLoginModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    override fun getName(): String {
        return "NaverLogin"
    }

    @ReactMethod
    fun initialize(options: ReadableMap) {
        val connection = OAuthLogin.getInstance()

        connection.init(
                reactContext.applicationContext,
                options.getString("consumerKey"),
                options.getString("consumerSecret"),
                options.getString("appName")
        )
    }

    @ReactMethod
    fun login(promise: Promise) {
        val connection = OAuthLogin.getInstance()

        reactContext.currentActivity!!.runOnUiThread {
            connection.startOauthLoginActivity(
                    this.currentActivity,
                    NaverLoginHandler(reactContext.currentActivity!!, promise)
            )
        }
    }

    @ReactMethod
    fun logout(promise: Promise) {
        val connection = OAuthLogin.getInstance()
        val isSuccessDeleteToken = connection.logoutAndDeleteToken(reactContext.applicationContext)

        if (!isSuccessDeleteToken) {
            val errorCode = connection.getLastErrorCode(reactContext.applicationContext).code;
            val errorDesc = connection.getLastErrorDesc(reactContext.applicationContext);
            promise.reject(errorCode, errorDesc);
        } else {
            promise.resolve(true);
        }
    }
}


class NaverLoginHandler(activity: Activity, private val promise: Promise) : OAuthLoginHandler() {
    private val activityRef: WeakReference<Activity> = WeakReference<Activity>(activity)

    override fun run(success: Boolean) {
        val activity = activityRef.get()

        val connection = OAuthLogin.getInstance()

        if (success) {
            val result = WritableNativeMap()

            result.putString("accessToken", connection.getAccessToken(activity))

            promise.resolve(result)
        } else {
            var reactErrorCode = "E_UNKNOWN"

            val errorCode = connection.getLastErrorCode(activity)

            if (errorCode == OAuthErrorCode.CLIENT_USER_CANCEL) {
                reactErrorCode = "E_CANCELLED"
            }

            promise.reject(reactErrorCode, connection.getLastErrorDesc(activity))
        }
    }
}

class NaverLoginPackage : ReactPackage {
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
        return mutableListOf(NaverLoginModule(reactContext))
    }

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return mutableListOf()
    }
}
