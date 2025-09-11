# libpjsua2maui - pjsip bindings for .NET MAUI

## Usage

1 . Install the package (on solutions that target only android and/or ios) with ``` dotnet add package libpjsua2maui --version 2.15.1.1 ```

2 . On Android application, in the file ```MainApplication.cs``` put the following code on the constructor:

```csharp

public MainApplication(IntPtr handle, JniHandleOwnership ownership)
: base(handle, ownership)
{
    try
    {
        IntPtr? class_ref = JNIEnv.FindClass("org/pjsip/PjCameraInfo2");
        if (class_ref != null)
        {
            IntPtr? method_id = JNIEnv.GetStaticMethodID(class_ref.Value,
                               "SetCameraManager", "(Landroid/hardware/camera2/CameraManager;)V");

            if (method_id != null)
            {
                CameraManager manager = GetSystemService(Android.Content.Context.CameraService) as CameraManager;
                JNIEnv.CallStaticVoidMethod(class_ref.Value, method_id.Value, new JValue(manager));
                Console.WriteLine("SUCCESS setting cameraManager");
            }
        }

        JavaSystem.LoadLibrary("c++_shared");
        JavaSystem.LoadLibrary("crypto");
        JavaSystem.LoadLibrary("ssl");
        JavaSystem.LoadLibrary("bcg729");
        JavaSystem.LoadLibrary("openh264");
        JavaSystem.LoadLibrary("pjsua2");
    }
    catch (System.Exception ex)
    {
        Android.Util.Log.Error("MainApplication", $"EXCEPTION: {ex}");
        if (ex.InnerException != null)
            Android.Util.Log.Error("MainApplication", $"INNER: {ex.InnerException}");
        throw;
    }
}

```

that code is responsible for load the java camera classes and the native libs from the package. On iOS there's no need to add nothing

3 . Override the desired classes from nuget package for use in the application like this, e.g.:

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

4 . For callbacks of the classes from the package, is necessary to override the callbacks from the classes of package.

5 . Enjoy SIP functionalities.
