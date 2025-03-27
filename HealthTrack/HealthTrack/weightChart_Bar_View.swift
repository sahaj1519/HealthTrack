//
//  weightChart_Bar_View.swift
//  HealthTrack
//
//  Created by Ajay Sangwan on 25/03/25.
//
import Charts
import SwiftData
import SwiftUI

struct weightChart_Bar_View: View {
    
    static var last7DaysPredicate: Predicate<DataModel> {
           let today = Calendar.current.startOfDay(for: Date())
           let cutOffDate = Calendar.current.date(byAdding: .day, value: -7, to: today)!
           return #Predicate<DataModel> { $0.date >= cutOffDate && $0.date <= today }
       }

       @Query(filter: last7DaysPredicate, sort: \DataModel.date) var data: [DataModel]
    
    var weightChangeAray: [(day: String, change: Double)] {
        guard sampleData.count > 1 else { return [] }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        let sortedData = sampleData.sorted { $0.date < $1.date }
        
        var changes: [String: Double] = [:]  // Store weight change for each day
        
        for i in 1..<sortedData.count {
            let prev = sortedData[i - 1]
            let current = sortedData[i]
            
            let day = formatter.string(from: current.date)
            let change = current.weightComputed - prev.weightComputed
            changes[day] = change
        }
        
        let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        return weekDays.map { day in
            (day, changes[day] ?? 0.0)  // Default to 0 if the day is missing
        }
    }
    
    var sampleData: [DataModel] = [
            DataModel(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, step: 8500, weight: 40.5, heartRate: 72.0),
            DataModel(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, step: 9200, weight: 70.8, heartRate: 74.0),
            DataModel(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, step: 10200, weight: 31.0, heartRate: 71.5),
            DataModel(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, step: 7500, weight: 120.4, heartRate: 70.0),
            DataModel(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, step: 11000, weight: 69.9, heartRate: 73.2),
            DataModel(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, step: 6600, weight: 60.2, heartRate: 72.5),
            DataModel(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, step: 8800, weight: 70.1, heartRate: 71.8),
            DataModel(date: Calendar.current.date(byAdding: .day, value: -8, to: Date())!, step: 9700, weight: 90.6, heartRate: 72.1),
            DataModel(date: Calendar.current.date(byAdding: .day, value: -9, to: Date())!, step: 10400, weight: 100.0, heartRate: 73.0),
            DataModel(date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, step: 7200, weight: 69.8, heartRate: 70.5),
        ]
    var highlightedDay: (day: String, value: Double)? {
        guard !weightChangeAray.isEmpty else { return nil } // Prevents crashes if no data
        guard let lastEntry = weightChangeAray.last else { return nil } // Ensures a valid last entry
        return (day: lastEntry.day, value: lastEntry.change) // Uses correct tuple field names
    }
    
    var body: some View {
        
        
        VStack(alignment: .leading, spacing: -3){
            
            HStack(alignment: .center){
                Image(systemName: "figure")
                    .font(.title2.bold())
                    .foregroundStyle(.indigo)
                
                
                Text("Average Weight Change")
                    .foregroundStyle(.indigo)
                    .font(.system(size: 23, weight: .bold))
                Spacer()
            }.padding(.top, 0)
            
            
            Text("Per Weekday (Last 7 Days)")
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.4))
                .padding(.bottom)
            
            if weightChangeAray.isEmpty {
                           // No Data Message
                           Text("No weight data available for the last 7 days")
                               .foregroundStyle(.secondary)
                               .frame(height: 200)
                               .frame(maxWidth: .infinity)
                               .background(.gray.opacity(0.1))
                               .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                
                ZStack(alignment: .topTrailing){
                    Chart{
                        
                        ForEach(weightChangeAray , id: \.day){item in
                            
                            BarMark(x: .value("Date", item.day),
                                    y: .value("Weight Change", item.change))
                            .foregroundStyle(
                                item.change > 0
                                ? LinearGradient(colors: [.indigo, .indigo.opacity(0.8)], startPoint: .bottom, endPoint: .top)
                                : LinearGradient(colors: [.teal, .teal.opacity(0.8)], startPoint: .bottom, endPoint: .top)
                            )
                            
                        }
                        if let highlighted = highlightedDay {
                            RuleMark(x: .value("Highlighted day", highlighted.day))
                                .foregroundStyle(.primary.opacity(0.2))
                        }
                        
                        
                    }.foregroundStyle(.indigo)
                        .frame(height: 200)
                        .chartXAxis{
                            AxisMarks{value in
                                AxisValueLabel()
                            }
                        }
                    if let highlighted = highlightedDay {
                        VStack {
                            Text(highlighted.day)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.primary.opacity(0.4))
                                .padding([.top, .horizontal], 10)
                                .padding(.horizontal, 20)
                            
                            Text("\(highlighted.value, specifier: "+%.2f")") // "+0.42" effect
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.indigo)
                                .padding(.bottom, 10)
                        }
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(.primary.opacity(0.1), lineWidth: 1)
                        )
                        .offset(y: -70)
                        
                    }
                    
                }
            }
            
            
        }.padding()
        .background(.gray.opacity(0.1))
        .clipShape(.rect(cornerRadius: 15))
        .padding(.top, 5)
    }
}

#Preview {
    weightChart_Bar_View()
}
