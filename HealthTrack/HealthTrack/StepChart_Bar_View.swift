//
//  StepChart_Bar_View.swift
//  HealthTrack
//
//  Created by Ajay Sangwan on 25/03/25.
//
import Charts
import SwiftData
import SwiftUI

struct StepChart_Bar_View: View {
    @Query(sort: \DataModel.date) private var data: [DataModel]  // Fetch all data, filter later

    
    // Average Steps Calculation
    var averageSteps: Int {
        let totalSteps = data.reduce(0) { $0 + $1.stepComputed }
        return data.isEmpty ? 0 : totalSteps / data.count
    }

    // Maximum Steps for Scaling
    var maxCount: Int {
        data.map { $0.stepComputed }.max() ?? 10000
    }

    var body: some View {
        VStack(alignment: .leading, spacing: -3) {
            HStack {
                Image(systemName: "figure.walk")
                    .font(.title2.bold())
                    .foregroundStyle(.pink)
                
                Text("Steps")
                    .foregroundStyle(.pink)
                    .font(.title.weight(.medium))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.primary.opacity(0.4))
            }
            .padding(.top, 0)
            
            Text("Avg: \(averageSteps) steps")
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.4))
                .padding(.bottom)

            if data.isEmpty {
                // No Data Message
                Text("No step data available for the last 28 days")
                    .foregroundStyle(.pink.opacity(0.6))
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                Chart {
                    ForEach(data, id: \.date) { item in
                        BarMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Steps", item.stepComputed)
                        )
                    }

                    // Add a RuleMark to indicate the average steps
                    RuleMark(y: .value("Avg steps", averageSteps))
                        .foregroundStyle(.gray.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [10], dashPhase: 0))
                }
                .foregroundStyle(.pink)
                .frame(height: 190)
                .chartYScale(domain: 0...(maxCount + 5000))
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let stepValue = value.as(Int.self) {
                                Text("\(stepValue / 1000)K") // Convert steps to thousands
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks() { value in
                        AxisValueLabel {
                            if let dateValue = value.as(Date.self) {
                                Text(dateValue, format: .dateTime.day(.twoDigits).month(.abbreviated))
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.top)
    }
}

#Preview {
    StepChart_Bar_View()
}
