namespace MauiPhone.DomainLayer.Mediator.Abstract;


// Abstrações de Mensagens Médias
public interface IRequest<out TResponse> { }
public interface ICommand<out TResponse> : IRequest<TResponse> { }
public interface IQuery<out TResponse> : IRequest<TResponse> { }
public interface INotification { }
public interface IStreamRequest<out TResponse> { }

// Abstrações de Handlers
public interface IRequestHandler<in TRequest, TResponse> where TRequest : IRequest<TResponse>
{
    Task<TResponse> HandleAsync(TRequest request, CancellationToken cancellationToken);
}

public interface INotificationHandler<in TNotification> where TNotification : INotification
{
    Task HandleAsync(TNotification notification, CancellationToken cancellationToken);
}

public interface IStreamRequestHandler<in TRequest, out TResponse> where TRequest : IStreamRequest<TResponse>
{
    IAsyncEnumerable<TResponse> HandleStreamAsync(TRequest request, CancellationToken cancellationToken);
}

// Abstrações de Pipeline
public delegate Task<TResponse> RequestHandlerDelegate<TResponse>();

public interface IPipelineBehavior<in TRequest, TResponse> where TRequest : IRequest<TResponse>
{
    Task<TResponse> HandleAsync(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken);
}