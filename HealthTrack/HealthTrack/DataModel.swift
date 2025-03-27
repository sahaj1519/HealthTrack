//
//  DataModel.swift
//  HealthTrack
//
//  Created by Ajay Sangwan on 24/03/25.
//

import SwiftData
import SwiftUI


@Model
class DataModel{
    var  id = UUID()
    var date: Date
    var step: Int?
    var weight: Double?
    var heartRate: Double?
    
    
    var stepComputed: Int{
       step ?? 0
    }
    var weightComputed: Double{
        weight ?? 0
    }
    var heartRateComputed: Double{
        heartRate ?? 0
    }
    
    
    init(date: Date, step: Int? = nil, weight: Double? = nil, heartRate: Double? = nil) {
        self.date = date
        self.step = step
        self.weight = weight
        self.heartRate = heartRate
    }
}
