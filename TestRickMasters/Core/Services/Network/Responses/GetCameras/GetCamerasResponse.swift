//
//  GetCamerasResponse.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 09.08.2023.
//

import Foundation

struct GetCamerasResponse: Decodable {
    let success: Bool?
    let data: GetCameras?
}

struct GetCameras: Decodable {
    let room: [String]?
    let cameras: [Camera]?
}

struct Camera: Decodable {
    let id: Int?
    let name: String?
    let snapshot: String?
    let room: String?
    let favorites: Bool?
    let rec: Bool?
}
