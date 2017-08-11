//
//  ScheduleDto.swift
//  Schedule
//
//  Created by yogasawara@stv on 2017/08/10.
//  Copyright © 2017年 SundayCarpenter. All rights reserved.
//

import Foundation

final class ScheduleDto: NSObject {
    var id = 0
    var title = ""
    var location = ""
    var startDate = Date()
    var endDate = Date()
    var detail = ""
    var deleteFlag = false
}
