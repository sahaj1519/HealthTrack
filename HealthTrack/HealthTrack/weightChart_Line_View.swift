//
//  weightChart_Line_View.swift
//  HealthTrack
//
//  Created by Ajay Sangwan on 25/03/25.
//
import Charts
import SwiftData
import SwiftUI

struct weightChart_Line_View: View {
    
    @Query(sort: \DataModel.date) var data: [DataModel]
    
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
   
    
    var averageWeight: Double{
        let sum = sampleData.reduce(0.0) { $0 + $1.weightComputed}
        return sampleData.isEmpty ? 0.0 : sum / Double(sampleData.count)
    }
    var goal = 50
    
    var minWeightPoint: Double{
        let min = sampleData.map { $0.weightComputed}.min() ?? 50
        return min
    }
     var maxWeightPoint: Double{
         let max = sampleData.map { $0.weightComputed}.max() ?? 200
        return max
    }
    
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: -3){
            
            HStack(alignment: .center){
                Image(systemName: "figure")
                    .font(.title2.bold())
                    .foregroundStyle(.indigo)
                  
                
                Text("Weight")
                    .foregroundStyle(.indigo)
                    .font(.title.weight(.medium))
                   
                
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.primary.opacity(0.4))
                
            }.padding(.top, 0)
         
            
            Text("Avg: \(averageWeight , specifier: "%.2f") lbs")
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.4))
                .padding(.bottom)
         
            
            if sampleData.isEmpty {
                           // No Data Message
                           Text("No weight data available for the last 28 days")
                               .foregroundStyle(.secondary)
                               .frame(height: 200)
                               .frame(maxWidth: .infinity)
                               .background(.gray.opacity(0.1))
                               .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                Chart{
                    
                    
                    ForEach(sampleData){ item in
                        
                        LineMark(x: .value("Date", item.date, unit: .day),
                                 y: .value("Weight", item.weightComputed))
                        .interpolationMethod(.linear)
                        
                        
                        PointMark(x: .value("Date", item.date, unit: .day),
                                  y: .value("Weight", item.weightComputed))
                        .symbol{
                            Circle()
                                .stroke(Color.indigo, lineWidth: 2) // Outlined circle
                                .frame(width: 8, height: 8)
                                .background(Circle().fill(Color.white))
                        }
                        
                       
                        
                        
                        RuleMark(y: .value("Goal", goal))
                            .foregroundStyle(.green)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [10]))
                        
                        PointMark(x: .value("Date", sampleData.last!.date),
                                  y: .value("Goal", goal))
                        .foregroundStyle(.clear)
                        
                        .annotation(position: .bottomLeading){
                            Text("Goal")
                                .font(.caption.bold())
                                .foregroundStyle(.green)
                            
                            
                        }
                        let minWeight = sampleData.map { $0.weightComputed }.min() ?? 50
                        let maxWeight = sampleData.map { $0.weightComputed }.max() ?? 200
                        
                        AreaMark(x: .value("Date", item.date, unit: .day),
                                 yStart: .value("Weight", minWeight + (maxWeight - minWeight) * 0.1),
                                 yEnd: .value("Baseline", item.weightComputed ))
                        
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [Color.indigo.opacity(0.2), Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        
                        
                        
                    }
                    
                }.foregroundStyle(.indigo)
                    .frame(height: 200)
                    .chartYAxis{
                        AxisMarks{ value in
                            AxisValueLabel()
                            AxisGridLine()
                            
                        }
                    }
                    .chartXAxis{
                        AxisMarks{value in
                            AxisValueLabel()
                        }
                    }
            }
            
            
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(.rect(cornerRadius: 15))
        .padding(.top)
    }
}

#Preview {
    weightChart_Line_View()
}
