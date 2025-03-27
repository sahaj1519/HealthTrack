//
//  healthData_Fetch_Function.swift
//  HealthTrack
//
//  Created by Ajay Sangwan on 24/03/25.
//


import HealthKit
import SwiftData
import SwiftUI

struct HealthDataManager {
    static let healthStore = HKHealthStore()

    /// Requests HealthKit access for step count data.
    static func requestHealthKitAccess() async {
            do {
                guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
                      let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass),
                      let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
                    print("Failed to initialize HealthKit types")
                    return
                }

                let readTypes: Set = [stepType, weightType, heartRateType]
                try await healthStore.requestAuthorization(toShare: [], read: readTypes)
                print(" HealthKit Authorization Successful")
            } catch {
                print("HealthKit Authorization Failed: \(error.localizedDescription)")
            }
        }
        
    
    //Fetches step count data.
   static  func fetchStepData() async -> [DataModel]{
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        return await fetchHealthData(type: stepType, unit: .count(), key: "step")
    }
    
    //Fetches weight data.
    static func fetchWeightData() async -> [DataModel] {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        return await fetchHealthData(type: weightType, unit: .gramUnit(with: .kilo), key: "weight")
    }
    
    //fetch heartData
    
    static func fetchHeartData() async -> [DataModel]{
        let heartType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        return await fetchHealthData(type: heartType, unit: HKUnit.count().unitDivided(by: .minute()), key: "heartRate")
    }

    /// Fetches  data asynchronously using Swift 6 async/await.
    static func fetchHealthData(type: HKQuantityType, unit: HKUnit, key: String) async -> [DataModel] {
       
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        let statisticsOptions: HKStatisticsOptions = (key == "step") ? .cumulativeSum : .discreteAverage  //  Use correct option for each type
        return  await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: statisticsOptions,       //Handles heart rate & weight better
                anchorDate: startDate,
                intervalComponents: DateComponents(day: 1)
            )

            query.initialResultsHandler = { _, result, error in
                if let error = error {
                    print("HealthKit Query Error: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                  
                    return
                }

                var entries: [DataModel] = []
                if let statsCollection = result {
                    for stats in statsCollection.statistics() {
                        let value: Double
                        if key == "step" {
                          value = stats.sumQuantity()?.doubleValue(for: unit) ?? 0   //  Use sum for steps
                        } else {
                          value = stats.averageQuantity()?.doubleValue(for: unit) ?? 0  //  Use average for weight & heart rate
                        }

                        let entry = DataModel(date: Calendar.current.startOfDay(for: stats.startDate))

                        switch key{
                        case "step": entry.step = Int(value)
                        case "weight": entry.weight = value
                        case "heartRate": entry.heartRate = value
                        default: break
                        }
                        entries.append(entry)
                    }
                }
                print(" Fetched \(entries.count) \(key) entries")
                continuation.resume(returning: entries)
            }

            healthStore.execute(query)
        }
    }

    ///Inserts fetched HealthKit data into SwiftData on the main thread.
    @MainActor
    static func saveStepsData(context: ModelContext, entries: [DataModel]) {
        for entry in entries {
            context.insert(entry)
        }
    }
    
    
    @MainActor
    static func clearAllHealthData(context: ModelContext) {
        do {
            let allData = try context.fetch(FetchDescriptor<DataModel>())
            for entry in allData {
                context.delete(entry)
            }
            print(" All HealthKit data deleted.")
        } catch {
            print(" Error deleting data: \(error.localizedDescription)")
        }
    }
}
