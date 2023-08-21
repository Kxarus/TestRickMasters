//
//  CamerasRM.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 09.08.2023.
//

import RealmSwift
import Foundation


class CamerasRM: Object {
    var data = List<CamerasDataRM>()
    
    convenience init(data: List<CamerasDataRM>) {
        self.init()
        self.data = data
    }
}

class CamerasDataRM: Object {
    var room = List<String>()
    var cameras = List<CamerasStructRM>()
    
    convenience init(room: List<String>,
                     cameras: List<CamerasStructRM>) {
        self.init()
        self.room = room
        self.cameras = cameras
    }
}

class CamerasStructRM: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var snapshot = ""
    @objc dynamic var room = ""
    @objc dynamic var favorites = false
    @objc dynamic var rec = false
    
    convenience init(id: Int,
                     name: String,
                     snapshot: String,
                     room: String,
                     favorites: Bool,
                     rec: Bool) {
        self.init()
        self.id = id
        self.name = name
        self.snapshot = snapshot
        self.room = room
        self.favorites = favorites
        self.rec = rec
    }
}
