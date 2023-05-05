import Combine
import Foundation

/// Defines a function that processes the 401 response and returns whether to attempt to refresh the token.
public protocol UnauthorizedResponseHandling {
    /// Function that handles 401 response.
    /// - Parameters:
    ///   - response: URLResponse from backend
    ///   - data: payload from the 401 response
    func handleResponse(
        response: URLResponse,
        data: Data
    ) -> AnyPublisher<CometClient.Output, CometClientError>
}
