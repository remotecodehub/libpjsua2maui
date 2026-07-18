namespace MauiPhone.ApplicationLayer.Mediator.Abstract;

public interface IMediator
{
    Task<TResponse> SendAsync<TResponse>(IRequest<TResponse> request, CancellationToken cancellationToken = default);
    Task PublishAsync<TNotification>(TNotification notification, CancellationToken cancellationToken = default) where TNotification : INotification;
    IAsyncEnumerable<TResponse> CreateStreamAsync<TResponse>(IStreamRequest<TResponse> request, CancellationToken cancellationToken = default);
}