//
//  GetDoorsResponse.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 09.08.2023.
//

import Foundation

struct GetDoorsResponse: Decodable {
    let success: Bool?
    let data: [GetDoors?]
}

struct GetDoors: Decodable {
    let id: Int?
    let name: String?
    let room: String?
    let favorites: Bool?
    let snapshot: String?
}
