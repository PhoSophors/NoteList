
import Foundation
import KeychainAccess

class LoginHelper {
    
    private static let keychain = Keychain(service: "com.aditi.notelist")
    
    static func checkLoginStatus(completion: @escaping (Bool, String?) -> Void) {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if isLoggedIn {
            let username = getUsernameFromKeychain()
            completion(true, username)
        } else {
            completion(false, nil)
        }
    }
    
    static func saveLoginState(username: String) {
        setUsernameInKeychain(username)
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
    }
    
    static func clearLoginState() {
        removeUsernameFromKeychain()
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
    
    static func validateCredentials(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard !username.isEmpty, !password.isEmpty else {
            completion(false, "Username and password can't be empty!")
            return
        }
        
        if (username.lowercased() == "aditi" || username.lowercased() == "admin") && password == "2024" {
            completion(true, nil)
        } else {
            completion(false, "Incorrect username or password!")
        }
    }
    
    private static func setUsernameInKeychain(_ username: String) {
        do {
            try keychain.set(username, key: "username")
        } catch let error {
            print("Error saving username to keychain: \(error)")
        }
    }
    
    private static func getUsernameFromKeychain() -> String? {
        do {
            let username = try keychain.get("username")
            return username
        } catch let error {
            print("Error retrieving username from keychain: \(error)")
            return nil
        }
    }
    
    private static func removeUsernameFromKeychain() {
        do {
            try keychain.remove("username")
        } catch let error {
            print("Error removing username from keychain: \(error)")
        }
    }
}
