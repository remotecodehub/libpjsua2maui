# libpjsua2maui - pjsip bindings for .NET MAUI

## 2. Overriding SWIG Generated classes

In order to get a better experience with the nupkg, its a common-practice override the swig generated classes that have high usage at the app, for a better development experience, like callbacks and events consumption. 

Here folows an example:

```csharp

using System.Diagnostics;

namespace SoftPhone.Models;

public partial class SoftLogWriter : LogWriter
{
    public event Action<string>? OnLogReceived;

    public override void write(LogEntry entry)
    {
        if (entry == null || string.IsNullOrEmpty(entry.msg)) return;

        string cleanMessage = entry.msg.Trim();
         
        OnLogReceived?.Invoke($"[LIBPJSUA2MAUI SDK] ({entry.level}) {cleanMessage}");
    }
}
```