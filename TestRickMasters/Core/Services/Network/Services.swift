//
//  Services.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 09.08.2023.
//

import Alamofire
import Foundation
import Moya
import UIKit

final class Services {
    private let service: NetworkServiceable
    
    init(service: NetworkServiceable) {
        self.service = service
    }
}

// MARK: - Public methods

extension Services {
    //MARK: - GetCameras
    func performGetCameras(complition: @escaping (Result<GetCamerasResponse, ApiErrorModel>) -> Void) {
        service.request(.getCameras, completion: complition)
    }
    
    //MARK: - GetDoors
    func performGetDoors(complition: @escaping (Result<GetDoorsResponse, ApiErrorModel>) -> Void) {
        service.request(.getDoors, completion: complition)
    }
}

