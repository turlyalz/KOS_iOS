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
    private static let token = "/oauth/token";
    
    //private static let appID = "33830907-8eb1-4bf4-9e92-0d149ccb8dee"
    private static let appID = "54a10db9-e1c5-4536-8fde-13ed7caf755a"
    
    private static let appSecret = "QZIGl69NMif1l5GTy1TuuBWm8UiBXNxz"
    
    private static let redirectURI = "http://client.kosandroid.cz/auth/response"
    //private static let redirectURI = "http://client.kosios.cz/response"
    
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
    
    private class func loginRequest(username: String, password: String) -> (success: Bool, error: String) {
        if username == "" {
            return (false, "Username cannot be empty!")
        }
        
        if password == "" {
            return (false, "Password cannot be empty!")
        }
        
        print("Try to log in with username: '\(username)', password: '\(password)'")
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + login)!)
        request.HTTPMethod = "POST"
        print("Login request = \(loginRequest)")
        
        let postString = "j_username=" + username + "&j_password=" + password
        
        var failed = false
        var running = false
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            
            print("Login response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Login response string = \(responseString)")
            running = false
        }
        running = true
        task.resume()
        
        while running && !failed {
            //print("waiting for login response...")
            //sleep(1)
        }
        
        if failed || errorOcurredIn(task.response) {
            return (false, "Log in failed. Please try again.")
        }
        
        return (true, "200 OK")
    }
    
    private class func authRequest() -> (success: Bool, error: String) {
        
        var running = false
        var failed = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + authorize + "?response_type=code&client_id=" + appID + "&redirect_uri=" + redirectURI)!)
        request.HTTPMethod = "GET"
        
        print("Auth request = \(authRequest)")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            
            print("Auth response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Auth response string = \(responseString)")
            running = false
        }
        running = true
        task.resume()
        
        while running && !failed {
            //print("waiting for auth response...")
            //sleep(1)
        }
        
        if failed || errorOcurredIn(task.response){
            return (false, "Log in failed. Please try again.")
        }
        
        return (true, "200 OK")
    }
    
    private class func authPostRequest() -> (success: Bool, codeORerror: String) {
        var code: String = ""
        
        var running = false
        var failed = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + authorize + "?response_type=code&client_id=" + appID + "&redirect_uri=" + redirectURI)!)
        request.HTTPMethod = "POST"
        
        let postStr = "user_oauth_approval=true"
        
        request.HTTPBody = postStr.dataUsingEncoding(NSUTF8StringEncoding)
        
        print("Auth 2 request = \(request)")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            
            print("Auth 2 response = \(response)")
            //code = "" + String(response?.URL)
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Auth 2 response string = \(responseString)")
            running = false
        }
        running = true
        task.resume()
        
        while running && !failed {
            //print("waiting for auth 2 response...")
            //sleep(1)
        }
        
        if failed || errorOcurredIn(task.response){
            return (false, "Log in failed. Please try again.")
        }
        
        //TODO: Get there a code
        code = "xxxx"
    
        return (true, code)
    }
    
    private class func getToken(code: String) -> (success: Bool, tokenORerror: String) {
        var running = false
        var failed = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + token)!)
        request.HTTPMethod = "POST"
        request.addValue("Basic NTRhMTBkYjktZTFjNS00NTM2LThmZGUtMTNlZDdjYWY3NTVhOlZKemVvOHlZUU9qTEc0akhpQnFzdGtEdkhmbFdLanVB", forHTTPHeaderField: "Authorization")
        
        
        let postStr = "code=" + code + "&grant_type=authorization_code&client_id=" + appID + "&client_secret=" + appSecret + "&redirect_uri" + redirectURI
        
        request.HTTPBody = postStr.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            
            print("accessToken response = \(response)")
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("accessToken response string = \(responseString)")
            running = false
        }
        running = true
        task.resume()
        
        while running && !failed {
            //print("waiting for auth 2 response...")
            //sleep(1)
        }
        
        // TODO: Get access token
        
        return (true, "Access token")
    }
    
    class func getAuthToken(username username: String, password: String) -> (success: Bool, tokenORerror: String) {
       
        let loginResponse = loginRequest(username, password: password)
        if !loginResponse.success {
            return (false, loginResponse.error)
        }
        
        let authResponse = authRequest()
        if !authResponse.success {
            return (false, authResponse.error)
        }
        
        let authPostResponse = authPostRequest()
        if !authPostResponse.success {
            return (false, authPostResponse.codeORerror)
        }
        
        let tokenResponse = getToken(authPostResponse.codeORerror)
        if !tokenResponse.success {
            return (false, tokenResponse.tokenORerror)
        }
        
        return (true, tokenResponse.tokenORerror)
    }

}
