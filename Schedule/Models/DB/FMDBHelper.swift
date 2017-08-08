//
//  FMDBHelper.swift
//  Schedule
//
//  Created by Yuu Ogasa on 2017/08/08.
//  Copyright © 2017年 SundayCarpenter. All rights reserved.
//

import Foundation
import FMDB

protocol BaseDao {
    var baseDao: FMDBHelper { get }
}

final class FMDBHelper: NSObject {
    let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                     .userDomainMask,
                                                     true).last!.appendingPathComponent("schedule.db")
    
    var db: FMDatabase
    
    override init() {
        db = FMDatabase(path: dbPath)
    }
    
    func dbOpen() -> Bool {
        let isOpened = db.open()
        
        if !isOpened {
            fatalError("Failed to open database.")
        }
        return isOpened
    }
    
    func dbClose() -> Bool {
        let isClosed = db.close()
        
        if !isClosed {
            fatalError("Failed to close database.")
        }
        return isClosed
    }
    
    func beginTransaction() -> Bool {
        let beginTran = db.beginTransaction()
        
        if !beginTran {
            fatalError("Failed to begin transaction.")
        }
        return beginTran
    }
}
