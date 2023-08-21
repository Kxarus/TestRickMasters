//
//  RealmService.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 09.08.2023.
//

import RealmSwift
import UIKit

protocol RealmServiceProtocol {
    func create<T: Object>(_ object: T)
    func read<T: Object>(_ object: T.Type) -> Results<T>
    func cascadeDelete<T: Object>(_ object: T.Type)
}

protocol RealmObserviable {
    func post(_ error: Error)
    func observeRealmErrors(in vc: UIViewController, complition: @escaping (Error?) -> Void)
    func stopObservingErrors(in vc: UIViewController)
}

class RealmService {
    
    static let shared = RealmService()
    private init() {}
    
    var realm: Realm {
        do {
            let realm = try Realm(configuration: .defaultConfiguration)
            return realm
        } catch  {
            post(error)
            fatalError("RealmServiceError in instance initialize Realm() - \(error.localizedDescription)")
        }
    }
}

// MARK: - RealmServiceProtocol
extension RealmService: RealmServiceProtocol {

    // MARK: - Create
    func create<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            post(error)
            print("RealmServiceError in func create() - \(error.localizedDescription)")
        }
    }
    // MARK: - Read
    func read<T: Object>(_ object: T.Type) -> Results<T> {
        return realm.objects(T.self)
    }
    
    func cascadeDelete<T: Object>(_ object: T.Type) {
        do {
            try realm.write {
                let item = realm.objects(object.self)
                realm.delete(item, cascading: true)
            }
        } catch {
            post(error)
            print("RealmServiceError in func delete() - \(error.localizedDescription)")
        }
    }
}

// MARK: - RealmObserviable
extension RealmService: RealmObserviable {
    
    func post(_ error: Error) {
        NotificationCenter.default.post(name: Notification.Name("RealmError"), object: error)
    }
    
    func observeRealmErrors(in vc: UIViewController, complition: @escaping (Error?) -> Void) {
        NotificationCenter.default.addObserver(forName: Notification.Name("RealmError"), object: nil, queue: nil) { (notification) in
            complition(notification.object as? Error)
        }
    }
    
    func stopObservingErrors(in vc: UIViewController) {
        NotificationCenter.default.removeObserver(vc, name: Notification.Name("RealmError"), object: nil)
    }
}
