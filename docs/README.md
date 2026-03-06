# libpjsua2maui - pjsip bindings for .NET MAUI

## Usage

1 . Install the package (on solutions that targets only android and/or ios) with ``` dotnet add package libpjsua2maui --version 2.16 --framework net10.0-ios ``` for ios and ``` dotnet add package libpjsua2maui --version 2.16 --framework net10.0-android ``` for android.

### On: Android

1 . On Android application, in the file ```MainApplication.cs``` and put the following code, overriding the OnCreate void method:

```csharp

 public override void OnCreate()
 {
     try
     {
         IntPtr? class_ref = JNIEnv.FindClass("org/pjsip/PjCameraInfo2");
         if (class_ref != null && class_ref.HasValue)
         {
             IntPtr? method_id = JNIEnv.GetStaticMethodID(class_ref.Value,
                 "SetCameraManager", "(Landroid/hardware/camera2/CameraManager;)V");

             if (method_id != null && method_id.HasValue)
             {
                 CameraManager manager = (this.GetSystemService(Context.CameraService) as CameraManager)!;
                 JNIEnv.CallStaticVoidMethod(class_ref.Value, method_id.Value, new JValue(manager));
                 Console.WriteLine("SUCCESS setting cameraManager");
             }
         }

         JavaSystem.LoadLibrary("c++_shared");
         JavaSystem.LoadLibrary("crypto");
         JavaSystem.LoadLibrary("ssl");
         JavaSystem.LoadLibrary("openh264");
         JavaSystem.LoadLibrary("bcg729");
         JavaSystem.LoadLibrary("pjsua2");
     }
     catch (System.Exception ex)
     {
         Android.Util.Log.Error("MainApplication", $"EXCEPTION: {ex}");
         if (ex.InnerException != null)
             Android.Util.Log.Error("MainApplication", $"INNER: {ex.InnerException}");
         throw;
     }
     base.OnCreate();
 }

```

That code is responsible for load the java camera classes and the native libs from the package. On iOS there's no need to add nothing

## : Main Usage

1 . Override the desired classes from nuget package to use in the application like this, e.g.:

```csharp
using pjsua2maui.pjsua2;

namespace Application.Models;
public class SoftCall : Call
{
    public VideoWindow vidWin;
    public VideoPreview vidPrev;

    public SoftCall(SoftAccount acc, int call_id) : base(acc, call_id)
    {
        vidWin = null;
        vidPrev = null;
    }

    override public void onCallState(OnCallStateParam prm)
    {
        try
        {
            CallInfo ci = getInfo();
            if (ci.state ==
                pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED)
            {
                SoftApp.ep.utilLogWrite(3, "SoftCall", this.dump(true, ""));
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error : " + ex.Message);
        }

        // Should not delete this call instance (self) in this context,
        // so the observer should manage this call instance deletion
        // out of this callback context.
        SoftApp.observer.notifyCallState(this);
    }

    override public void onCallMediaState(OnCallMediaStateParam prm)
    {
        CallInfo ci;
        try
        {
            ci = getInfo();
        }
        catch (Exception)
        {
            return;
        }

        CallMediaInfoVector cmiv = ci.media;

        for (int i = 0; i < cmiv.Count; i++)
        {
            CallMediaInfo cmi = cmiv[i];
            if (cmi.type == pjmedia_type.PJMEDIA_TYPE_AUDIO &&
                (cmi.status ==
                        pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE ||
                 cmi.status ==
                        pjsua_call_media_status.PJSUA_CALL_MEDIA_REMOTE_HOLD))
            {
                // connect ports
                try
                {
                    AudDevManager audMgr = SoftApp.ep.audDevManager();
                    AudioMedia am = getAudioMedia(i);
                    audMgr.getCaptureDevMedia().startTransmit(am);
                    am.startTransmit(audMgr.getPlaybackDevMedia());
                }
                catch (Exception e)
                {
                    Console.WriteLine("Failed connecting media ports" +
                                      e.Message);
                    continue;
                }
            }
            else if (cmi.type == pjmedia_type.PJMEDIA_TYPE_VIDEO &&
                       cmi.status == pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE &&
                       cmi.videoIncomingWindowId != pjsua2.INVALID_ID)
            {
                vidWin = new VideoWindow(cmi.videoIncomingWindowId);
                vidPrev = new VideoPreview(cmi.videoCapDev);
            }
        }

        SoftApp.observer.notifyCallMediaState(this);
    }
}
```

2 . For callbacks of the classes from the package, is necessary to override the callbacks from the classes of package, and it's recommended use the Monitor pattern to comunicate the events between classes.

3 . For Video its necessary implement a handler for the UI of video window that will be rendered. Same for iOS.

4 . Enjoy SIP functionalities.
