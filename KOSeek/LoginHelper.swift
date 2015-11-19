//
//  LoginHelper.swift
//  KOSeek
//
//  Created by Alzhan on 26.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class LoginHelper {
        
    private static let baseURL = "https://auth.fit.cvut.cz/oauth/"
    private static let login = "login.do?"
    private static let authorize = "oauth/authorize"
    private static let token = "oauth/token"
    private static let redirectURI = "http://client.kosios.cz/auth/response"
    private static let appID = "659b7e1d-e8c2-4781-aefa-a8d6fff099db"
    private static let appSecret = "QZIGl69NMif1l5GTy1TuuBWm8UiBXNxz"
    static var accessToken = ""
    
    private init(){ }
    
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
        print("Login request = \(request)")
        
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
        
        var count = 0
        while running && !failed && count < MAX_WAIT_FOR_RESPONSE {
            print("waiting for login response...")
            sleep(1)
            count++
        }
        
        if failed || errorOcurredIn(task.response) || count >= MAX_WAIT_FOR_RESPONSE{
            return (false, "Log in failed. Please try again.")
        }
        
        return (true, "200 OK")
    }
    
    private class func authRequest() -> (success: Bool, codeORerror: String) {
        var running = false
        var failed = false
        var code: String = ""
        var codeObtained = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + authorize + "?response_type=code&client_id=" + appID + "&redirect_uri=" + redirectURI)!)
        request.HTTPMethod = "GET"
        
        print("Auth request = \(request)")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil && error?.code != -1003 {
                print("error=\(error)")
                failed = true
                return
            }
                
            else if error?.code == -1003 {
                //print("error=\(error)")
                var range = error?.description.rangeOfString("code=")
                range?.startIndex = (range?.startIndex.advancedBy(5))!
                range?.endIndex = (range?.startIndex.advancedBy(6))!
                code = (error?.description.substringWithRange(range!))!
                print("Code: \(code)")
                codeObtained = true
            }
            
            print("Auth response = \(response)")
            running = false
        }
        running = true
        task.resume()
        
        var count = 0
        while running && !failed && count < MAX_WAIT_FOR_RESPONSE {
            print("waiting for auth response...")
            sleep(1)
            count++
        }
        
        if !codeObtained {
            if failed || errorOcurredIn(task.response) || count >= MAX_WAIT_FOR_RESPONSE {
                return (false, "Log in failed. Please try again.")
            }
        }
        
        else {
            return (true, code)
        }
        
        return (true, "200 OK")
    }
    
    private class func codeRequest() -> (success: Bool, codeORerror: String) {
        var code: String = ""
        
        var running = false
        var failed = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + authorize + "?response_type=code&client_id=" + appID + "&redirect_uri=" + redirectURI)!)
        request.HTTPMethod = "POST"
        
        let postStr = "user_oauth_approval=true"
        
        request.HTTPBody = postStr.dataUsingEncoding(NSUTF8StringEncoding)
        
        print("Code request = \(request)")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil && error?.code != -1003 {
                print("error=\(error)")
                failed = true
                return
            }
            
            else if error?.code == -1003 {
                //print("error=\(error)")
                var range = error?.description.rangeOfString("code=")
                range?.startIndex = (range?.startIndex.advancedBy(5))!
                range?.endIndex = (range?.startIndex.advancedBy(6))!
                code = (error?.description.substringWithRange(range!))!
                print("Code: \(code)")
            }
            
            print("Response = \(response)")
            print("Change run")
            running = false
        }
        running = true
        task.resume()
        
        var count = 0
        while running && !failed && count < MAX_WAIT_FOR_RESPONSE {
            print("waiting for code response...")
            sleep(1)
            count++
        }
        
        if failed || errorOcurredIn(task.response) || count >= MAX_WAIT_FOR_RESPONSE{
            return (false, "Log in failed. Please try again.")
        }
    
        return (true, code)
    }
    
    private class func tokenRequest(code: String) -> (success: Bool, error: String) {
        var running = false
        var failed = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + token + "?code=" + code + "&grant_type=authorization_code&client_id=" + appID + "&client_secret=" + appSecret + "&redirect_uri=" + redirectURI)!)
        
        request.addValue("Basic NjU5YjdlMWQtZThjMi00NzgxLWFlZmEtYThkNmZmZjA5OWRiOlFaSUdsNjlOTWlmMWw1R1R5MVR1dUJXbThVaUJYTnh6", forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            
            print("Token response = \(response)")
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Token response string = \(responseString)")
            
            let json = JSON(data: data!)
            if let AT = json["access_token"].string {
                print("Access token: \(AT)")
                accessToken = AT
            }
            
            running = false
        }
        running = true
        task.resume()
        
        var count = 0
        while running && !failed && count < MAX_WAIT_FOR_RESPONSE {
            print("waiting for token response...")
            sleep(1)
            count++
        }
        
        if failed || errorOcurredIn(task.response) || count >= MAX_WAIT_FOR_RESPONSE{
            return (false, "Log in failed. Please try again.")
        }
        
        return (true, "200 OK")
    }
    
    class func getAuthToken(username username: String, password: String) -> (success: Bool, error: String) {

        let loginResponse = loginRequest(username, password: password)
        if !loginResponse.success {
            return (false, loginResponse.error)
        }
        
        let authResponse = authRequest()
        if !authResponse.success {
            return (false, authResponse.codeORerror)
        }
        
        var codeResponse: (success: Bool, codeORerror: String)
        if authResponse.codeORerror == "200 OK" {
            codeResponse = codeRequest()
            if !codeResponse.success {
                return (false, codeResponse.codeORerror)
            }
        }
        else {
            codeResponse = authResponse
        }
        
        let tokenResponse = tokenRequest(codeResponse.codeORerror)
        if !tokenResponse.success {
            return (false, tokenResponse.error)
        }

        return (true, "200 OK")
    }
}
