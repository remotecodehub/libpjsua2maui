
namespace MauiPhone.ApplicationLayer.Mediator.Concrete;


public class Mediator : IMediator
{
    private readonly IServiceProvider _serviceProvider;

    public Mediator(IServiceProvider serviceProvider) => _serviceProvider = serviceProvider;

    public async Task<TResponse> SendAsync<TResponse>(IRequest<TResponse> request, CancellationToken cancellationToken = default)
    {
        var requestType = request.GetType();
        var wrapperType = typeof(RequestHandlerWrapperImpl<,>).MakeGenericType(requestType, typeof(TResponse));
        var wrapper = (RequestHandlerWrapper<TResponse>)Activator.CreateInstance(wrapperType)!;
        return await wrapper.HandleAsync(request, _serviceProvider, cancellationToken);
    }

    public async Task PublishAsync<TNotification>(TNotification notification, CancellationToken cancellationToken = default) where TNotification : INotification
    {
        var handlers = _serviceProvider.GetServices<INotificationHandler<TNotification>>();
        var tasks = handlers.Select(h => h.HandleAsync(notification, cancellationToken));
        await Task.WhenAll(tasks);
    }

    public IAsyncEnumerable<TResponse> CreateStreamAsync<TResponse>(IStreamRequest<TResponse> request, CancellationToken cancellationToken = default)
    {
        var requestType = request.GetType();
        var handlerType = typeof(IStreamRequestHandler<,>).MakeGenericType(requestType, typeof(TResponse));
        var handler = _serviceProvider.GetRequiredService(handlerType);
        var method = handlerType.GetMethod(nameof(IStreamRequestHandler<IStreamRequest<TResponse>, TResponse>.HandleStreamAsync));
        return (IAsyncEnumerable<TResponse>)method!.Invoke(handler, [request, cancellationToken])!;
    }
}

// Wrappers para resolver dinamicamente os Pipelines de Execução
internal abstract class RequestHandlerWrapper<TResponse>
{
    public abstract Task<TResponse> HandleAsync(IRequest<TResponse> request, IServiceProvider provider, CancellationToken cancellationToken);
}

internal class RequestHandlerWrapperImpl<TRequest, TResponse> : RequestHandlerWrapper<TResponse> where TRequest : IRequest<TResponse>
{
    public override Task<TResponse> HandleAsync(IRequest<TResponse> request, IServiceProvider provider, CancellationToken cancellationToken)
    {
        var handler = provider.GetRequiredService<IRequestHandler<TRequest, TResponse>>();
        var behaviors = provider.GetServices<IPipelineBehavior<TRequest, TResponse>>().ToList();

        RequestHandlerDelegate<TResponse> delegateFactory()
        {
            int index = 0;
            Task<TResponse> Next()
            {
                if (index < behaviors.Count)
                {
                    var behavior = behaviors[index++];
                    return behavior.HandleAsync((TRequest)request, Next, cancellationToken);
                }
                return handler.HandleAsync((TRequest)request, cancellationToken);
            }
            return Next;
        }

        return delegateFactory()();
    }
}