//
//  DoorsRM.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 09.08.2023.
//

import RealmSwift
import Foundation

class DoorsRM: Object {
    var data = List<DoorsDataRM>()
    
    convenience init(data: List<DoorsDataRM>) {
        self.init()
        self.data = data
    }
}

class DoorsDataRM: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var room = ""
    @objc dynamic var favorites = false
    @objc dynamic var snapshot = ""
    
    convenience init(id: Int,
                     name: String,
                     room: String,
                     favorites: Bool,
                     snapshot: String) {
        self.init()
        self.id = id
        self.name = name
        self.room = room
        self.favorites = favorites
        self.snapshot = snapshot
    }
}
