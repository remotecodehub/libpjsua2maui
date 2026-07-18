namespace MauiPhone.Composition.MediatorExtensions;

public static class MauiMediatorExtensions
{
    public static IServiceCollection AddCustomMediator(this IServiceCollection services, params Assembly[] assemblies)
    {
        services.AddSingleton<IMediator, Mediator>();

        foreach (var assembly in assemblies)
        {
            var types = assembly.GetTypes().Where(t => !t.IsAbstract && !t.IsInterface);

            foreach (var type in types)
            {
                // 1. Register Requests Handlers (Commands & Queries)
                var requestInterfaces = type.GetInterfaces()
                    .Where(i => i.IsGenericType && i.GetGenericTypeDefinition() == typeof(IRequestHandler<,>));
                foreach (var iface in requestInterfaces)
                {
                    services.AddTransient(iface, type);
                }

                // 2. Register Notification Handlers
                var notificationInterfaces = type.GetInterfaces()
                    .Where(i => i.IsGenericType && i.GetGenericTypeDefinition() == typeof(INotificationHandler<>));
                foreach (var iface in notificationInterfaces)
                {
                    services.AddTransient(iface, type);
                }

                // 3. Register Stream Handlers
                var streamInterfaces = type.GetInterfaces()
                    .Where(i => i.IsGenericType && i.GetGenericTypeDefinition() == typeof(IStreamRequestHandler<,>));
                foreach (var iface in streamInterfaces)
                {
                    services.AddTransient(iface, type);
                }
            }
        }

        return services;
    }

    public static IServiceCollection AddOpenBehavior(this IServiceCollection services, Type behaviorType)
    {
        services.AddTransient(typeof(IPipelineBehavior<,>), behaviorType);
        return services;
    }
}