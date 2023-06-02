//
//  AuthService.swift
//  Tracker
//
//  Created by Александр Зиновьев on 09.05.2023.
//

import Foundation

final class AuthService {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults()) {
        self.userDefaults = userDefaults
    }
    
    enum Key: String {
        case isLogin
    }
    
    var isLogin: Bool {
        get {
            userDefaults.bool(forKey: Key.isLogin.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.isLogin.rawValue)
        }
    }
}
