namespace MauiPhone.ApplicationLayer.Common.Behaviors;

public class LoggingBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse> where TRequest : IRequest<TResponse>
{
    public async Task<TResponse> HandleAsync(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        Debug.WriteLine($"[START] Executando {typeof(TRequest).Name}");
        var response = await next();
        Debug.WriteLine($"[END] Finalizado {typeof(TRequest).Name}");
        return response;
    }
}