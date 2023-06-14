# Comet

Comet is a lightweight HTTP networking library written in Swift.

## Usage

To start using the Comet networking client, you have to properly initialize `CometClient` first.

``` swift
let cometClient = CometClient(
    urlSession: .shared,
    tokenProvider: TokenProvider(),
    authenticatedRequestBuilder: AuthenticatedRequestBuilder(),
    requestResponseHandler: CometRequestResponseHandler(),
    logConfiguration: .init(
        logLevel: .full,
        logger: { Swift.print($0) }
    )
)
```

### TokenProviding

The first mandatory parameter to create an instance of `CometClient` is a token provider, that must conform to `TokenProviding` protocol.

``` swift
struct TokenProvider: TokenProviding {
    var accessToken: AnyPublisher<String, TokenProvidingError> {
        // This is where you usually load the access token from the local storage.
    }

    var refreshAccessToken: AnyPublisher<String, TokenProvidingError> {
        // This is where you usually request a new access token from a backend or perform silent login if possible.
    }
}
```

### AuthenticatedRequestBuilding

The second mandatory parameter to create an instance of `CometClient` is a request builder, that must conform to `AuthenticatedRequestBuilding` protocol.

``` swift
struct AuthenticatedRequestBuilder: AuthenticatedRequestBuilding {
    func authenticatedRequest(
        from request: URLRequest, 
        with token: String
    ) -> URLRequest {
        // This is where you would usually add the provided access token to the header.
    }
}
```

### RequestResponseHandling

An optional parameter to create an instance of `CometClient` is a response handler, that must conform to `RequestResponseHandling` protocol. The response handler is responsible for handling the response from the API request. You can use the predefined `CometRequestResponseHandler` that decodes data with a default `JSONDecoder` and maps HTTP stutus codes to `CometClientError`.

### CometClient

Using the `CometClient` is very easy. Just call: 

``` swift
let urlRequest: URLRequest
cometClient.performAuthenticatedRequest(urlRequest)
```

or

``` swift
let urlRequest: URLRequest
cometClient.performAuthenticatedRequest(urlRequest, responseType: Object.self)
```