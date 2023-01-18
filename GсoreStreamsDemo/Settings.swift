import Foundation
import KeychainAccess

final class Settings {
    private enum ItemKey: String {
        case username, password, accessToken, refreshToken
    }
    
    static let shared = Settings()
    private init() { }
    
    private let keychain = Keychain()
    
    var userPassword: String? {
        get { 
            do { 
                return try keychain.get(ItemKey.password.rawValue)
            } catch {
                print((error as NSError).description)
                return nil
            }
        }
        set { 
            do { 
                if let password = newValue {
                    try keychain.set(password, key: ItemKey.password.rawValue)
                } else {
                    try keychain.remove(ItemKey.password.rawValue)
                }
            } catch {
                print((error as NSError).description)
            }
        }
    }
    
    var username: String? {
        get { 
            do { 
                return try keychain.get(ItemKey.username.rawValue)
            } catch {
                print((error as NSError).description)
                return nil
            }
        }
        set { 
            do { 
                if let username = newValue {
                    try keychain.set(username, key: ItemKey.username.rawValue)
                } else {
                    try keychain.remove(ItemKey.username.rawValue)
                }
            } catch {
                print((error as NSError).description)
            }
        }
    }
    
    var accessToken: String? {
        get { 
            do { 
                return try keychain.get(ItemKey.accessToken.rawValue)
            } catch {
                print((error as NSError).description)
                return nil
            }
        }
        set { 
            do { 
                if let accessToken = newValue {
                    try keychain.set(accessToken, key: ItemKey.accessToken.rawValue)
                } else {
                    try keychain.remove(ItemKey.accessToken.rawValue)
                }
            } catch {
                print((error as NSError).description)
            }
        }
    }
    
    var refreshToken: String? {
        get { 
            do { 
                return try keychain.get(ItemKey.refreshToken.rawValue)
            } catch {
                print((error as NSError).description)
                return nil
            }
        }
        set { 
            do { 
                if let refreshToken = newValue {
                    try keychain.set(refreshToken, key: ItemKey.refreshToken.rawValue)
                } else {
                    try keychain.remove(ItemKey.refreshToken.rawValue)
                }
            } catch {
                print((error as NSError).description)
            }
        }
    }
}
