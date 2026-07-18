namespace MauiPhone.Composition.MauiExtensions;

public static class MauiAppBuilderExtensions
{
    public static MauiAppBuilder UseMauiMediator(this MauiAppBuilder builder)
    {
        var applicationAssembly = typeof(IMediator).Assembly;  
        builder.Services.AddCustomMediator(applicationAssembly);
         
        builder.Services.AddOpenBehavior(typeof(LoggingBehavior<,>));
        return builder;
    }

    public static MauiAppBuilder UseMauiComposition(this MauiAppBuilder builder)
    {
        builder.UseMauiMediator();
        return builder;
    }
}
