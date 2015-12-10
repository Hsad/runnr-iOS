//
//  User.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 11/2/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import Foundation


class User: NSObject{
    var userName : String!
    var runs : [Run]!
    
    override init(){
        super.init()
        userName = ""
        runs = [Run]()
    }
    func giveUserName(nameToSet: String!){
        userName = nameToSet
    }
    func getUserName()->String{
        return userName
    }
    func appendRun(runToAppend: Run!){
        runs.append(runToAppend)
    }
    func removeRun(runToRemove: Run!){
        var index = 0
        for run in runs{
            if run == runToRemove{
                break
            }
            index++
        }
        runs.removeAtIndex(index)
    }
}