//
//  NetworkService.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 09.08.2023.
//

import Alamofire
import Foundation
import Moya

enum ApiError: Swift.Error {
    case clientError(errorMessage: String, errorCode: Int)
    case serverError(errorMessage: String, errorCode: Int)
}

struct ApiErrorModel: Swift.Error {
    let type: String
    let message: String
    let code: Int
    let request: String
}

protocol NetworkServiceable {
    func request<T: Decodable>(_ endPoint: APIEndPoint, completion: @escaping (Result<T, ApiErrorModel>) -> Void)
    func requestData<T: Decodable>(_ endPoint: APIEndPoint, completion: @escaping (Result<T, ApiErrorModel>) -> Void)
    func requestVoid<T: Decodable>(
        _ endPoint: APIEndPoint,
        completion: @escaping (Result<T, ApiErrorModel>) -> Void
    )
    func requestWithProgress<T: Decodable>(
        _ endPoint: APIEndPoint,
        progress: ProgressBlock?,
        completion: @escaping (Result<T, ApiErrorModel>) -> Void
    ) -> Cancellable
}

typealias StatusCode = Int

final class NetworkService {
    private let provider = MoyaProvider<TargetProvider>(
        endpointClosure: NetworkService.endpointClosure,
        session: DefaultAlamofireManager.sharedManager
    )

    private static func customEndpointMapping(for target: TargetProvider) -> Endpoint {
        let url = "\(target.baseURL.absoluteString)\(target.path)"
        
        return Endpoint(
            url: url,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }

    static let endpointClosure = { (target: TargetProvider) -> Endpoint  in
        let defaultEndpoint = customEndpointMapping(for: target)
        return defaultEndpoint
    }
}

extension NetworkService: NetworkServiceable {
    func request<T: Decodable>(
        _ endPoint: APIEndPoint,
        completion: @escaping (Result<T, ApiErrorModel>) -> Void
    ) {
        guard isConnectedToInternet() else { return }
        let targetProvider = TargetProvider(with: endPoint)
        let urlRequest = "\(targetProvider.baseURL)\(targetProvider.path)\(targetProvider.parameters?.toQueryString() ?? "")"
        print("URLRequest - \(urlRequest)")

        provider.request(targetProvider, completion: { [weak self] result in
            switch result {
            case let .success(response):
                let statusCode = response.statusCode
                print("Status code - \(statusCode)")
                switch statusCode {
                case 200...210:
                    do {
                        let result: T = try response.data.decode()
                        completion(.success(result))
                    } catch {
                        completion(.failure(ApiErrorModel(type: "Invalid Data", message: "Decode error", code: statusCode, request: urlRequest)))
                    }

                default:
                    self?.handlerErrorResponse(
                        endPoint,
                        data: response,
                        urlRequest: urlRequest,
                        completion: completion
                    )
                }

            case .failure(let error):
                completion(.failure(ApiErrorModel(type: "Internal Error", message: "Internal Error", code: error.response?.statusCode ?? 0, request: urlRequest)))
                self?.handleError(endPoint, statusCode: error.errorCode)
            }
        })
    }
    
    func requestData<T: Decodable>(
        _ endPoint: APIEndPoint,
        completion: @escaping (Result<T, ApiErrorModel>) -> Void
    ) {
        guard isConnectedToInternet() else { return }
        let targetProvider = TargetProvider(with: endPoint)
        let urlRequest = "\(targetProvider.baseURL)\(targetProvider.path)\(targetProvider.parameters?.toQueryString() ?? "")"
        print("URLRequest - \(urlRequest)")

        provider.request(targetProvider, completion: { [weak self] result in
            switch result {
            case let .success(response):
                let statusCode = response.statusCode
                print("Status code - \(statusCode)")
                switch statusCode {
                case 200...210:
                    do {
                        let result: T = response.data as! T
                        completion(.success(result))
                    } catch {
                        completion(.failure(ApiErrorModel(type: "Invalid Data", message: "Decode error", code: statusCode, request: urlRequest)))
                    }

                default:
                    self?.handlerErrorResponse(
                        endPoint,
                        data: response,
                        urlRequest: urlRequest,
                        completion: completion
                    )
                }

            case .failure(let error):
                completion(
                    .failure(
                        ApiErrorModel(
                            type: "Internal Error",
                            message: "Internal Error",
                            code: error.response?.statusCode ?? 0,
                            request: urlRequest
                        )
                    )
                )
                self?.handleError(endPoint, statusCode: error.errorCode)
            }
        })
    }

    func requestVoid<T: Decodable>(
        _ endPoint: APIEndPoint,
        completion: @escaping (Result<T, ApiErrorModel>) -> Void
    ) {
        guard isConnectedToInternet() else { return }
        let targetProvider = TargetProvider(with: endPoint)
        let urlRequest = "\(targetProvider.baseURL)\(targetProvider.path)\(targetProvider.parameters?.toQueryString() ?? "")"

        provider.request(targetProvider) { [weak self] result in
            switch result {
            case let .success(response):
                completion(.success("OK" as! T))
                let statusCode = response.statusCode
                switch statusCode {
                case 200...210:
                    do {
                        completion(.success("OK" as! T))
                    } catch {
                        completion(.failure(ApiErrorModel(type: "Invalid Data", message: "Decode error", code: statusCode, request: urlRequest)))
                    }
                default:
                    self?.handlerErrorResponse(
                        endPoint,
                        data: response,
                        urlRequest: urlRequest,
                        completion: completion)
                }
            case .failure(let error):
                completion(
                    .failure(
                        ApiErrorModel(
                            type: "Internal Error",
                            message: "Internal Error",
                            code: error.response?.statusCode ?? 0,
                            request: urlRequest
                        )
                    )
                )
                self?.handleError(endPoint, statusCode: error.errorCode)
            }
        }
    }

    func requestWithProgress<T: Decodable>(
        _ endPoint: APIEndPoint,
        progress: ProgressBlock?,
        completion: @escaping (Result<T, ApiErrorModel>) -> Void
    ) -> Cancellable {
        let targetProvider = TargetProvider(with: endPoint)
        let urlRequest = "\(targetProvider.baseURL)\(targetProvider.path)\(targetProvider.parameters?.toQueryString() ?? "")"
        debugPrint(urlRequest)

        return provider.request(targetProvider, progress: progress) { [weak self] result in
            guard self?.isConnectedToInternet() == true else { return }
            switch result {
            case .success(let response):
                do {
                    let decodedObj = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(decodedObj))
                } catch {
                    completion(
                        .failure(
                            .init(
                                type: "Invalid Data",
                                message: error.localizedDescription,
                                code: -1,
                                request: urlRequest
                            )
                        )
                    )
                }

            case .failure(let error):
                completion(
                    .failure(
                        ApiErrorModel(
                            type: "Internal Error",
                            message: "Internal Error",
                            code: error.response?.statusCode ?? 0,
                            request: urlRequest
                        )
                    )
                )
            }
        }
    }
}

private extension NetworkService {
    func handlerErrorResponse<T: Decodable>(
        _ endPoint: APIEndPoint,
        data: Response,
        urlRequest: String,
        completion: @escaping (Result<T, ApiErrorModel>) -> Void
    ) {
        let statusCode = data.statusCode
        completion(
            .failure(
                ApiErrorModel(
                    type: fetchResponseType(with: statusCode),
                    message: fetchResponseMessage(with: statusCode),
                    code: statusCode,
                    request: urlRequest
                )
            )
        )
        self.handleError(endPoint, statusCode: statusCode)
    }
    
    func fetchResponseType(with statusCode: Int) -> String {
        let informationalType = 100..<105
        let successType = 200..<227
        let redirectionType = 300..<309
        let clientErrorType = 400..<500
        let serverErrorType = 500..<527
        if informationalType.contains(statusCode) {
            return "Informational"
        } else if successType.contains(statusCode) {
            return "Success"
        } else if redirectionType.contains(statusCode) {
            return "Redirection"
        } else if clientErrorType.contains(statusCode) {
            return "ClientError"
        } else if serverErrorType.contains(statusCode) {
            return "ServerError"
        } else {
            return "Unknown"
        }
    }
    
    func fetchResponseMessage(with statusCode: Int) -> String {
        switch statusCode {
        case 400:
            return .error400
        case 401:
            return .error401
        case 402:
            return .error402
        case 403:
            return .error403
        case 404:
            return .error404
        case 405:
            return .error405
        case 406:
            return .error406
        case 407:
            return .error407
        case 408:
            return .error408
        case 409:
            return .error409
        case 410:
            return .error410
        case 411:
            return .error411
        case 412:
            return .error412
        case 413:
            return .error413
        case 414:
            return .error414
        case 415:
            return .error415
        case 416:
            return .error416
        case 417:
            return .error417
        case 418:
            return .error418
        case 419:
            return .error419
        case 421:
            return .error421
        case 422:
            return .error422
        case 423:
            return .error423
        case 424:
            return .error424
        case 425:
            return .error425
        case 426:
            return .error426
        case 428:
            return .error428
        case 429:
            return .error429
        case 431:
            return .error431
        case 434:
            return .error434
        case 449:
            return .error449
        case 451:
            return .error451
        case 499:
            return .error499
        case 500:
            return .error500
        case 501:
            return .error501
        case 502:
            return .error502
        case 503:
            return .error503
        case 504:
            return .error504
        case 505:
            return .error505
        case 506:
            return .error506
        case 507:
            return .error507
        case 508:
            return .error508
        case 509:
            return .error509
        case 510:
            return .error510
        case 511:
            return .error511
        case 520:
            return .error520
        case 521:
            return .error521
        case 522:
            return .error522
        case 523:
            return .error523
        case 524:
            return .error524
        case 525:
            return .error525
        case 526:
            return .error526
        default:
            return .errorWTF
        }
    }
}

extension Data {
    func decode<T: Decodable>(type: T.Type = T.self) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let decoded = try decoder.decode(type, from: self)
            return decoded
        } catch {
            print("❗DECODING ERROR❗: \(error)")
            print(error.localizedDescription)
            throw error
        }
    }
}

extension Dictionary {
    func toQueryString() -> String {
        var result = "?"
        for param in self {
            if result == "?" {
                result = "\(result)\(param.key)=\(param.value)"
            } else {
                result = "\(result)&\(param.key)=\(param.value)"
            }
        }
        return result
    }
}

class DefaultAlamofireManager: Alamofire.Session {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireManager(configuration: configuration)
    }()
}

private extension NetworkService {
    private func handleError(_ endPoint: APIEndPoint, statusCode: Int) {
        switch statusCode {
        default:
            break
        }
    }

    private func isConnectedToInternet() -> Bool {
        let isConnected = NetworkReachabilityManager()?.isReachable ?? false
        if !isConnected {
            print("Ошибка соединения!!!!!")
        }
        return isConnected
    }
}
