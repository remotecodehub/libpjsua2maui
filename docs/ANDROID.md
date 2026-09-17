# libpjsua2maui - pjsip bindings for .NET MAUI

## On: Android

On Android application, is mandatory set the CameraManager, also register the native libs into the JavaSystem. The lib have a extension method that performs it, or you can do it yourself.

### Extension Method

At the file `MauiProgram.cs, it's only needed add (conditionally only in android), the call to `builder.RegisterLibPjsua2Maui();`. The file may look like this:

```csharp
using Microsoft.Extensions.Logging;
using libpjsua2.maui;
namespace MauiPhone;

public static class MauiProgram
{
	public static MauiApp CreateMauiApp()
	{
		var builder = MauiApp.CreateBuilder();
		builder.UseMauiApp<App>()
			.ConfigureFonts(fonts =>
			{
				fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
				fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
			});

#if ANDROID
			builder.RegisterLibPjsua2Maui();
#endif
#if DEBUG
		builder.Logging.AddDebug();
#endif
		return builder.Build();
    }
}

```

### Manual Registration

At the file `MauiProgram.cs`, set the camera manager and register the native libraries adding an lifecycle event (OnCreate) at MauiProgram. The file may look like this:

```csharp
using Microsoft.Extensions.Logging;
using Microsoft.Maui.LifecycleEvents;

namespace MauiPhone;

public static class MauiProgram
{
	public static MauiApp CreateMauiApp()
	{
		var builder = MauiApp.CreateBuilder();
		builder.UseMauiApp<App>()
			.ConfigureFonts(fonts =>
			{
				fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
				fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
			});

		builder.ConfigureLifecycleEvents(events =>
		{
#if ANDROID
			events.AddAndroid((android) =>
			{
				android.OnCreate((activity, bundle) => 
				{
					try
					{
						IntPtr? classRef = Android.Runtime.JNIEnv.FindClass("org/pjsip/PjCameraInfo2");
						if (classRef.HasValue)
						{
							IntPtr? methodId = Android.Runtime.JNIEnv.GetStaticMethodID(
								classRef.Value,
								"SetCameraManager",
								"(Landroid/hardware/camera2/CameraManager;)V"
							);

							if (methodId.HasValue)
							{
								if (activity.Application?.GetSystemService(Android.Content.Context.CameraService) is CameraManager manager)
								{
									Android.Runtime.JNIEnv.CallStaticVoidMethod(classRef.Value, methodId.Value, new JValue(manager));
									System.Console.WriteLine("SUCCESS setting cameraManager");
								}
							}
						}

						Java.Lang.JavaSystem.LoadLibrary("c++_shared");
						Java.Lang.JavaSystem.LoadLibrary("crypto");
						Java.Lang.JavaSystem.LoadLibrary("ssl");
						Java.Lang.JavaSystem.LoadLibrary("openh264");
						Java.Lang.JavaSystem.LoadLibrary("bcg729");
						Java.Lang.JavaSystem.LoadLibrary("pjsua2");
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
#endif
		});
#if DEBUG
		builder.Logging.AddDebug();
#endif

		return builder.Build();
	}
}

```

That code is responsible for load the java camera classes and the native libraries from the package. On iOS, MacCatalyst and Windows there's no need to add nothing
