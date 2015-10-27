//
//  LoginHelper.swift
//  KOSeek
//
//  Created by Alzhan on 26.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class LoginHelper {
    
    private static let baseURL = "https://auth.fit.cvut.cz"
    private static let login = "/login.do?"
    private static let authorize = "/oauth/authorize"
    //private static let token = "/oauth/token";
    
    private static let appID = "659b7e1d-e8c2-4781-aefa-a8d6fff099db"
    
    //private static let appSecret = "QZIGl69NMif1l5GTy1TuuBWm8UiBXNxz"
    
    private static let redirectURI = "http://client.kosios.cz/auth/response"
    
    private init(){ }
    
    private class func errorOcurredIn(response: NSURLResponse?) -> Bool {
        if let httpResponse = response as? NSHTTPURLResponse {
            if let resp = httpResponse.URL {
                let respStr = String(resp)
                if respStr.rangeOfString("authentication_error=true") != nil {
                    return true
                }
            }
            if httpResponse.statusCode != 200 {
                print("Unexpected status code: \(httpResponse.statusCode)")
                return true
            }
        }
        return false
    }
    
    class func getAuthToken(username username: String, password: String) -> (success: Bool, tokenORerror: String) {
        
        if username == "" {
            return (false, "Username cannot be empty!")
        }
        
        if password == "" {
            return (false, "Password cannot be empty!")
        }
        
        print("Try to log in with username: '\(username)', password: '\(password)'")
        
        let loginRequest = NSMutableURLRequest(URL: NSURL(string: baseURL + login)!)
        loginRequest.HTTPMethod = "POST"
        print("Login request = \(loginRequest)")
        
        let postString = "j_username=" + username + "&j_password=" + password
        
        var loginFailed = false
        var loginRunning = false
        
        loginRequest.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let loginTask = NSURLSession.sharedSession().dataTaskWithRequest(loginRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                loginFailed = true
                return
            }
            
            print("Login response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Login response string = \(responseString)")
            loginRunning = false
        }
        loginRunning = true
        loginTask.resume()
        
        while loginRunning && !loginFailed {
            //print("waiting for login response...")
            //sleep(1)
        }
        
        if loginFailed || errorOcurredIn(loginTask.response){
            return (false, "Log in failed. Please try again.")
        }
        
        var authRunning = false
        
        let authRequest = NSMutableURLRequest(URL: NSURL(string: baseURL + authorize + "?response_type=code&client_id=" + appID + "&redirect_uri=" + redirectURI)!)
        authRequest.HTTPMethod = "GET"
        
        print("Auth request = \(authRequest)")
        
        let authTask = NSURLSession.sharedSession().dataTaskWithRequest(authRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                loginFailed = true
                return
            }
            
            print("response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            authRunning = false
        }
        authRunning = true
        authTask.resume()
        
        while authRunning && !loginFailed {
            //print("waiting for auth response...")
            //sleep(1)
        }
        
        if loginFailed || errorOcurredIn(authTask.response){
            return (false, "Log in failed. Please try again. Error 401")
        }
        
        authRunning = false
        let auth2Request = NSMutableURLRequest(URL: NSURL(string: baseURL + authorize + "?response_type=code&client_id=" + appID + "&redirect_uri=" + redirectURI + "user_oauth_approval=true")!)
        auth2Request.HTTPMethod = "POST"
        print("Auth 2 request = \(auth2Request)")
   
        let auth2Task = NSURLSession.sharedSession().dataTaskWithRequest(auth2Request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                loginFailed = true
                return
            }
            
            print("Login response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Login response string = \(responseString)")
            authRunning = false
        }
        authRunning = true
        auth2Task.resume()

        while authRunning && !loginFailed {
            //print("waiting for auth 2 response...")
            //sleep(1)
        }
        
        if loginFailed || errorOcurredIn(auth2Task.response){
            return (false, "Log in failed. Please try again.")
        }
        
        return (true, "authToken")
    }


}
