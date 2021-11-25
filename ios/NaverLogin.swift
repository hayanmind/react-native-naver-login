import Foundation
import NaverThirdPartyLogin

@objc(NaverLogin)
class NaverLogin: NSObject, RCTBridgeModule, NaverThirdPartyLoginConnectionDelegate {
    private var loginPromiseResolve: RCTPromiseResolveBlock?
    private var loginPromiseReject: RCTPromiseRejectBlock?
    
    private var logoutPromiseResolve: RCTPromiseResolveBlock?
    private var logoutPromiseReject: RCTPromiseRejectBlock?
    
    static func moduleName() -> String! {
        return "NaverLogin"
    }

    static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc(initialize:)
    func initialize(options: Dictionary<String, String>) {
        if let connection = NaverThirdPartyLoginConnection.getSharedInstance() {
            NSLog("KDH initialize");
            
            if let appName = options["appName"] {
                NSLog(appName);
            }
            connection.consumerKey = options["consumerKey"]
            connection.consumerSecret = options["consumerSecret"]
            connection.appName = options["appName"]
            connection.serviceUrlScheme = options["serviceUrlScheme"]
            
            connection.delegate = self
        }
    }

    @objc(login:rejecter:)
    func login(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        loginPromiseResolve = resolve
        loginPromiseReject = reject
        
        if let connection = NaverThirdPartyLoginConnection.getSharedInstance() {
         
            DispatchQueue.main.async {
                connection.requestThirdPartyLogin()
            }
        }
    }

    @objc(logout:rejecter:)
    func logout(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        NSLog("logout");
        
        logoutPromiseResolve = resolve
        logoutPromiseReject = reject
        
        if let connection = NaverThirdPartyLoginConnection.getSharedInstance() {
            NSLog("hi");
            
            DispatchQueue.main.async {
                connection.requestDeleteToken()
            }
        }
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        if let connection = NaverThirdPartyLoginConnection.getSharedInstance(), let resolve = loginPromiseResolve {
            resolve(["accessToken": connection.accessToken])
        }
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        if let connection = NaverThirdPartyLoginConnection.getSharedInstance(), let resolve = loginPromiseResolve {
            resolve(["accessToken": connection.accessToken])
        }
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        NSLog("oauth20ConnectionDidFinishDeleteToken");
        if let resolve = logoutPromiseResolve {
            resolve(true)
        }
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        NSLog("didFailWithError %@", error.localizedDescription);
        if let reject = loginPromiseReject {
            reject("E_UNKNOWN", error.localizedDescription, error)
        }
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailAuthorizationWithRecieveType recieveType:THIRDPARTYLOGIN_RECEIVE_TYPE) {
        NSLog("Nearo didFailAuthorizationWithRecieveType");
        if let reject = loginPromiseReject {
            let errorMessage = String(format: "Error Code: %@", convertReceiveTypeToString(recieveType: recieveType));
            NSLog(errorMessage);
            if recieveType == CANCELBYUSER {
                reject("E_CANCELLED", errorMessage, nil);
            } else {
                reject("E_UNKNOWN", errorMessage, nil);
            }
        }
        
        if let reject = logoutPromiseReject {
            let errorMessage = String(format: "Error Code: %@", convertReceiveTypeToString(recieveType: recieveType));
            NSLog(errorMessage);
            if recieveType == CANCELBYUSER {
                reject("E_CANCELLED", errorMessage, nil);
            } else {
                reject("E_UNKNOWN", errorMessage, nil);
            }
        }
        
    }
    
    func convertReceiveTypeToString(recieveType: THIRDPARTYLOGIN_RECEIVE_TYPE) -> String {
        var result = "UNKNOWNERROR";

        switch(recieveType) {
            case SUCCESS:
                result = "SUCCESS";
                break;
            case PARAMETERNOTSET:
                result = "PARAMETERNOTSET";
                break;
            case CANCELBYUSER:
                result = "CANCELBYUSER";
                break;
            case NAVERAPPNOTINSTALLED:
                result = "NAVERAPPNOTINSTALLED";
                break;
            case NAVERAPPVERSIONINVALID:
                result = "NAVERAPPVERSIONINVALID";
                break;
            case OAUTHMETHODNOTSET:
                result = "OAUTHMETHODNOTSET";
                break;
            case INVALIDREQUEST:
                result = "INVALIDREQUEST";
                break;
            case CLIENTNETWORKPROBLEM:
                result = "CLIENTNETWORKPROBLEM";
                break;
            case UNAUTHORIZEDCLIENT:
                result = "UNAUTHORIZEDCLIENT";
                break;
            case UNSUPPORTEDRESPONSETYPE:
                result = "UNSUPPORTEDRESPONSETYPE";
                break;
            case NETWORKERROR:
                result = "NETWORKERROR";
                break;
            case UNKNOWNERROR:
                result = "UNKNOWNERROR";
                break;
            default:
                result = "UNKNOWNERROR";
        }

        return result;
    }
}
