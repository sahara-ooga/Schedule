//
//  ScheduleDaoTest.swift
//  Schedule
//
//  Created by yogasawara@stv on 2017/08/12.
//  Copyright © 2017年 SundayCarpenter. All rights reserved.
//

import XCTest
import FMDB

@testable import Schedule

class ScheduleDaoTest: XCTestCase {
    let dao = ScheduleDao()
    
    //データベースファイルごと消去して、新たに作成する
    override func setUp() {
        super.setUp()
        self.clean()
        let _ = dao.createTable()
    }
    
    override func tearDown() {
        self.clean()
        super.tearDown()
    }
    
    //MARK: Create
    func testCreateNomalTable() {
        let fileManager = FileManager.default
        let db_is_exist = fileManager.fileExists(atPath: dao.baseDao.dbPath)
        
        //dbファイルが存在する
        XCTAssertTrue(db_is_exist)
        
        //カラムが存在する
        XCTAssertTrue(dao.baseDao.dbOpen())
        XCTAssertTrue(dao.baseDao.db.columnExists("id", inTableWithName: "Schedule"))
        XCTAssertTrue(dao.baseDao.db.columnExists("title", inTableWithName: "Schedule"))
        XCTAssertTrue(dao.baseDao.db.columnExists("location", inTableWithName: "Schedule"))
        XCTAssertTrue(dao.baseDao.db.columnExists("startDate", inTableWithName: "Schedule"))
        XCTAssertTrue(dao.baseDao.db.columnExists("endDate", inTableWithName: "Schedule"))
        XCTAssertTrue(dao.baseDao.db.columnExists("detail", inTableWithName: "Schedule"))
        XCTAssertTrue(dao.baseDao.db.columnExists("deleteFlag", inTableWithName: "Schedule"))
        XCTAssertTrue(dao.baseDao.dbClose())
    }

    //MARK: Insert
    func testInsertSingleSchedule() {
        //サンプルを作る
        let schedule = ScheduleDto()
        schedule.title = "test"
        schedule.location = "東京"
        let startDate = Date()
        let endDate = Date(timeInterval: 60*60*24, since: Date())
        schedule.startDate = startDate
        schedule.endDate = endDate
        schedule.detail = "test record"
        schedule.deleteFlag = false
        
        //DBに挿入する
        XCTAssertTrue(dao.insert(scheduleDto: schedule))
        
        //アサート
        if let schedules = dao.selectAll() {
            print("schedules.count is \(schedules.count)")
            for schdl in schedules {
                if schdl.title == "test" {
                    XCTAssertEqual(schdl.location, "東京")
                    
                    //Date型の比較については、https://stackoverflow.com/questions/32009877/nsdate-compare-in-testsを参照のこと
                    XCTAssertEqualWithAccuracy(schdl.startDate.timeIntervalSinceReferenceDate,
                                               startDate.timeIntervalSinceReferenceDate, accuracy: 0.001, "")
                    XCTAssertEqualWithAccuracy(schdl.endDate.timeIntervalSinceReferenceDate,
                                               endDate.timeIntervalSinceReferenceDate, accuracy: 0.001, "")
                    
                    XCTAssertEqual(schdl.detail, "test record")
                    XCTAssertEqual(schdl.deleteFlag, false)
                }
            }
        }else{
            //もし一件も取得できなかったら失敗
            XCTFail("No record selected.")
        }
    }
    
    func testInsertMultipleSchedules() {
        //サンプルレコードを作る
        let startDate = Date()
        let endDate = Date(timeInterval: 60*60*24, since: Date())
        let startDate2 = Date(timeInterval: 60*60*24, since: Date())
        let endDate2 = Date(timeInterval: 60*60*24, since: startDate2)

        let scheduleDic1:[String:Any] = ["title":"title1","location":"富山",
                                         "startDate":startDate,"endDate":endDate,
                                         "detail":"detail1","deleteFlag":false]
        let scheduleDic2:[String:Any] = ["title":"title2","location":"青森",
                                         "startDate":startDate2,"endDate":endDate2,
                                         "detail":"detail2","deleteFlag":false]
        let scheduleDicArray = [scheduleDic1,scheduleDic2]
        
        var schedules = [ScheduleDto]()
        for dic in scheduleDicArray{
            let schedule = ScheduleDto()
            schedule.title = dic["title"] as! String
            schedule.location = dic["location"] as! String
            schedule.startDate = dic["startDate"] as! Date
            schedule.endDate = dic["endDate"] as! Date
            schedule.detail = dic["detail"] as! String
            schedule.deleteFlag = dic["deleteFlag"] as! Bool
            schedules.append(schedule)
        }
        
        //DBに挿入する
        XCTAssertTrue(dao.insert(scheduleDtos: schedules))
        
        //アサート
        if let schedules = dao.selectAll() {
            print("schedules.count is \(schedules.count)")
            for schdl in schedules {
                let dic = scheduleDicArray[schdl.id - 1]
                XCTAssertEqual(schdl.title,dic["title"] as! String)
                XCTAssertEqual(schdl.location,dic["location"] as! String)
                
                let sd = dic["startDate"] as! Date
                XCTAssertEqualWithAccuracy(schdl.startDate.timeIntervalSinceReferenceDate,
                                           sd.timeIntervalSinceReferenceDate, accuracy: 0.001, "")
                let ed = dic["endDate"] as! Date
                XCTAssertEqualWithAccuracy(schdl.endDate.timeIntervalSinceReferenceDate,
                                           ed.timeIntervalSinceReferenceDate, accuracy: 0.001, "")
                XCTAssertEqual(schdl.detail,dic["detail"] as! String)
                XCTAssertEqual(schdl.deleteFlag,dic["deleteFlag"] as! Bool)
            }
        }else{
            //もし一件も取得できなかったら失敗
            XCTFail("No record selected.")
        }
    }
    
    
    //MARK: Delete
}

// MARK: - ヘルパーメソッド
extension ScheduleDaoTest {
    /// データベースファイルを消去する
    func clean() {
        let manager = FileManager.default
        if manager.fileExists(atPath: dao.baseDao.dbPath) {
            do {
                try manager.removeItem(atPath: dao.baseDao.dbPath)
            } catch {
                print("Error: faild to remove database file.")
            }
        }
    }
}
