//
//  restfullHelper.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 12/8/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import Foundation



class restHTTPhelper{
    
    init(){
    }
    
    func makeGetRequest(urlString: String, completion: (result: NSDictionary) -> Void){
        let url = NSURL(string: urlString) //change the url
        
        //create the session object
        let session = NSURLSession.sharedSession()
        
        //now create the NSMutableRequest object using the url object
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET" //set http method as POST
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in            
            if response != nil{
                
                if data != nil{
                    do{
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                        
                        // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                        // The JSONObjectWithData constructor didn't return an error. But, we should still
                        // check and make sure that json has a value using optional binding.
                        if let parseJSON = json {
                            completion(result: parseJSON)
                        }
                        else {
                            // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                            let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            
                            var tempStr = jsonStr!.componentsSeparatedByString("]},")
                            tempStr[0] = String(tempStr[0].characters.dropFirst())
                            
                            let answer = [ "answer" : jsonStr! ] as NSDictionary
                            completion(result: answer)
                        }
                    }catch let err as NSError{
                        print(err.localizedDescription)
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: '\(jsonStr)'")
                    }
                }
            }
            else {
            }
        })
        task.resume()
    }
    
    func makePostRequest(urlString: String){
        let url = NSURL(string: urlString) //change the url
        
        //create the session object
        let session = NSURLSession.sharedSession()
        
        //now create the NSMutableRequest object using the url object
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST" //set http method as POST
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            
            if response != nil{
                
                if data != nil{
                    do{
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                        
                        // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                        // The JSONObjectWithData constructor didn't return an error. But, we should still
                        // check and make sure that json has a value using optional binding.
                        if let parseJSON = json {
                            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                            let success = parseJSON["success"] as? Int
                            print("Success: \(success)")
                        }
                        else {
                            // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                            let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("Error could not parse JSON: \(jsonStr)")
                        }
                    }catch let err as NSError{
                        print(err.localizedDescription)
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: '\(jsonStr)'")
                    }
                }
            }
            else {
            }
        })
        task.resume()
    }
}