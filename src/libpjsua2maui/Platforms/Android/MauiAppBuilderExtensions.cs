using Android.Content;
using Android.Hardware.Camera2;
using Android.Runtime;
using Java.Lang;
using Microsoft.Maui.LifecycleEvents;
namespace libpjsua2.maui;
public static class MauiAppBuilderExtensions
{
    public static MauiAppBuilder RegisterLibPjsua2Maui(this MauiAppBuilder builder)
    {
        builder.ConfigureLifecycleEvents(events =>
        {
            events.AddAndroid((android) =>
            {
                android.OnCreate((activity, bundle) =>
                {
                    try
                    {
                        IntPtr? classRef = JNIEnv.FindClass("org/pjsip/PjCameraInfo2");
                        if (classRef.HasValue)
                        {
                            IntPtr? methodId = JNIEnv.GetStaticMethodID(
                                classRef.Value,
                                "SetCameraManager",
                                "(Landroid/hardware/camera2/CameraManager;)V"
                            );

                            if (methodId.HasValue)
                            {
                                if (activity.Application?.GetSystemService(Context.CameraService) is CameraManager manager)
                                {
                                    JNIEnv.CallStaticVoidMethod(classRef.Value, methodId.Value, new JValue(manager));
                                    Console.WriteLine("SUCCESS setting cameraManager");
                                }
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
                        Android.Util.Log.Error("PjSipInit", $"EXCEPTION: {ex}");
                        if (ex.InnerException != null)
                            Android.Util.Log.Error("PjSipInit", $"INNER: {ex.InnerException}");
                        throw;
                    }
                });
            }); 
        });
        return builder;
    }
}