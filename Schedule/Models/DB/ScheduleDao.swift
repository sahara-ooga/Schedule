//
//  ScheduleDao.swift
//  Schedule
//
//  Created by yogasawara@stv on 2017/08/10.
//  Copyright © 2017年 SundayCarpenter. All rights reserved.
//

import UIKit

final class ScheduleDao: NSObject {
    let baseDao = FMDBHelper()
    
    // MARK:- Create Table
    
    /// Scheduleテーブルが存在しなければ、作成する
    func createTable() -> Bool {
        //TODO: カラムの定義
        let createTableSql = "" +
            "CREATE TABLE IF NOT EXISTS Schedule (" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "title TEXT, " +
            "location TEXT, " +
            "startDate TEXT, " +
            "endDate TEXT, " +
            "detail TEXT, " +
            "deleteFlag Integer)"
        
        do {
            _ = baseDao.dbOpen()
            try baseDao.db.executeUpdate(createTableSql, values: nil)
            _ = baseDao.dbClose()
        
            return true
        }catch{
            print("update error.")
            return false
        }
    }
    
    // MARK:- INSERT
    
    /// Scheduleテーブルにレコードを追加する
    func insert(scheduleDto: ScheduleDto) -> Bool {
        let insertSql = "INSERT INTO Schedule(" +
                    "title, " +
                    "location, " +
                    "startDate, " +
                    "endDate, " +
                    "detail, " +
                    "deleteFlag) " +
                    "VALUES(?, ?, ?, ?, ?, ?)"
        
        let schedule: [Any] = [scheduleDto.title,
                               scheduleDto.location,
                               scheduleDto.startDate,
                               scheduleDto.endDate,
                               scheduleDto.detail,
                               scheduleDto.deleteFlag]
        
        _ = baseDao.dbOpen()
        let executeSQL = baseDao.db.executeUpdate(insertSql,
                                                  withArgumentsIn: schedule)
        _ = baseDao.dbClose()
        return executeSQL
    }
    
    /// トランザクションを使用してScheduleテーブルに複数件レコードを追加する
    func insert(scheduleDtos: [ScheduleDto]) -> Bool {
        let insertSql = "" +
            "INSERT INTO Schedule(" +
            "title, " +
            "location, " +
            "startDate, " +
            "endDate, " +
            "detail, " +
            "deleteFlag) " +
            "VALUES(?, ?, ?, ?, ?, ?)"
        
        var scheduleArray: Array<Any> = []
        
        scheduleDtos.forEach { (scheduleDto) in
            scheduleArray.append([scheduleDto.title,
                                  scheduleDto.location,
                                  scheduleDto.startDate,
                                  scheduleDto.endDate,
                                  scheduleDto.detail,
                                  scheduleDto.deleteFlag])
        }
        _ = baseDao.dbOpen()
        _ = baseDao.beginTransaction()
        
        var success = true
        for schedule in scheduleArray {
            
            success = baseDao.db.executeUpdate(insertSql,
                                               withArgumentsIn: schedule as! [Any])
            
            if !success {
                break
            }
        }
        
        if success {
            // 全てのINSERTが成功した場合はcommitする
            baseDao.db.commit()
        } else {
            baseDao.db.rollback()
        }
        _ = baseDao.dbClose()
        
        return success
    }
    
    // MARK:- SELECT
    
    /// Scheduleテーブルのレコードを全件取得する
    func selectAll() -> [ScheduleDto]? {
        let selectSql = "SELECT * FROM Schedule"
        
        var resultArray: [ScheduleDto] = []
        
        _ = baseDao.dbOpen()
        
        do {
        /*guard*/ let result = try baseDao.db.executeQuery(selectSql,
                                                           values: nil) //else {return nil}
        while result.next() {
            
            let scheduleDto = ScheduleDto()
            scheduleDto.id = Int(result.int(forColumn: "id"))
            scheduleDto.title = result.string(forColumn: "title")!
            scheduleDto.location = result.string(forColumn: "location")!
            scheduleDto.startDate = result.date(forColumn: "startDate")!
            scheduleDto.endDate = result.date(forColumn: "endDate")!
            scheduleDto.detail = result.string(forColumn: "detail")!
            scheduleDto.deleteFlag = result.bool(forColumn: "deleteFlag")
            resultArray.append(scheduleDto)
        }
            
        _ = baseDao.dbClose()
        return resultArray
        }catch{
            return nil
        }
    }
    
    // MARK:- UPDATE
    
    /// 指定idのレコードのプロパティのうち与えられたものだけを更新する
    func update(id: Int,
                title: String? = nil,
                location: String? = nil,
                startDate:Date? = nil,
                endDate:Date? = nil,
                detail:String? = nil,
                deleteFlag:Bool? = nil) -> Bool {

        //nilでないパラメタだけ、sqlとparamsに項目を追加する
        var updateSql = "UPDATE Schedule SET "
        var params:[String : Any] = ["ID":id]
        
        if let title = title {
            updateSql += "title = :TITLE, "
            params["TITLE"] = title
        }
        
        if let location = location {
            updateSql += "location = :LOCATION, "
            params["LOCATION"] = location
        }
        
        if let startDate = startDate {
            updateSql += "startDate = :STARTDATE, "
            params["STARTDATE"] = startDate
        }
        
        if let endDate = endDate {
            updateSql += "endDate = :ENDDATE, "
            params["ENDDATE"] = endDate
        }
        
        if let detail = detail {
            updateSql += "detail = :DETAIL, "
            params["DETAIL"] = detail
        }
        
        if let deleteFlag = deleteFlag {
            updateSql += "deleteFlag = :DELETEFLAG, "
            params["DELETEFLAG"] = deleteFlag
        }
        
        //sql文のアップデートしたいキーワードは、最後の一つ前までは","がついていないといけない。
        //なので、最後の", "を刈り取る
        if updateSql.hasSuffix(", "){
            let excludes = CharacterSet(charactersIn:", ")
            updateSql = updateSql.trimmingCharacters(in: excludes)
        }
        
        //updateSql中の最後のカンマを削除する
        updateSql += " WHERE id = :ID"
        
        //DBの処理
        _ = baseDao.dbOpen()
        let executeSQL = baseDao.db.executeUpdate(updateSql,
                                                  withParameterDictionary: params)
        _ = baseDao.dbClose()
        return executeSQL
    }
    
    // MARK:- DELETE
    
    /// 指定idのレコードを削除する
    func delete(id: Int) -> Bool {
        let sql = "DELETE FROM Schedule WHERE id = ?"
        
        _ = baseDao.dbOpen()
        let executeSQL = baseDao.db.executeUpdate(sql, withArgumentsIn: [id])
        _ = baseDao.dbClose()
        return executeSQL
    }
    
    func deleteAll() -> Bool {
        let sql = "DELETE FROM Schedule"
        
        _ = baseDao.dbOpen()
        let executeSQL = baseDao.db.executeStatements(sql)
        _ = baseDao.dbClose()
        
        return executeSQL
    }

}

// MARK:- BaseDao
extension ScheduleDao: BaseDao {}
