//
//  APIEndPoint.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 07.08.2023.
//

import Alamofire
import Foundation
import Moya

enum APIEndPoint {
    case getCameras
    case getDoors
}

struct TargetProvider: TargetType {
    var type: APIEndPoint
    private var defaults: UserDefaults
    
    init(with type: APIEndPoint) {
        self.type = type
        defaults = .standard
    }
    
    public mutating func handle(for type: APIEndPoint) {
        self.type = type
    }
}

extension TargetProvider {
    var baseHeaders: [String: String]? {
        var headers: [String: String] = [:]
        return headers
    }

    var headers: [String: String]? {
        guard var newHeaders = baseHeaders else { return baseHeaders }

        switch type {
        default:
            newHeaders = baseHeaders!
        }
        
        return newHeaders
    }

    var baseURL: URL {
        switch type {
        default:
            return URL(string: "http://\(Constants.apiDomain)")!
        }
    }

    var path: String {
        switch type {
        case .getCameras:
            return "/cameras"
        case .getDoors:
            return "/doors"
        }
    }

    var method: Moya.Method {
        switch type {
        default:
            return .get
        }
    }

    var methodDesc: String {
        switch method {
        case .post:
            return "POST"

        case .put:
            return "PUT"

        case .delete:
            return "DELETE"
            
        case .patch:
            return "PATCH"

        default:
            return "GET"
        }
    }

    var parameters: [String: Any]? {
        switch type {
        default:
            return nil
        }
    }

    var task: Task {
        switch type {
        default:
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        return Data()
    }
}

// MARK: - Private methods

private extension TargetProvider {
    func requestCompositeParameters(_ body: Encodable) -> Task {
        var bodyDict: [String: Any] = [:]

        do {
            bodyDict = try body.asDictionary()
        } catch  let error {
            print(error.localizedDescription)
        }

        return .requestCompositeParameters(
            bodyParameters: bodyDict,
            bodyEncoding: JSONEncoding(),
            urlParameters: parameters ?? [:]
        )
    }
}


