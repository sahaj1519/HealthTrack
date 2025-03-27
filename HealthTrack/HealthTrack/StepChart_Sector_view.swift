import Charts
import SwiftData
import SwiftUI

struct StepChart_Sector_view: View {
    
    @Query(sort: \DataModel.date) private var allData: [DataModel]

    
    var filteredData: [DataModel] {
        let today = Calendar.current.startOfDay(for: Date())
        let cutOffDate = Calendar.current.date(byAdding: .day, value: -6, to: today)!

        return allData.filter { entry in
            let entryDate = Calendar.current.startOfDay(for: entry.date)
            return entryDate >= cutOffDate && entryDate <= today
        }
    }
    
    // Find the day with the highest steps
    var highestStepDay: DataModel? {
        filteredData.max(by: { $0.stepComputed < $1.stepComputed })
    }
    
    // Compute total steps in the last 7 days
    var sumOfSteps: Int {
        filteredData.reduce(0) { $0 + $1.stepComputed }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: -3) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.pink)
                
                Text("Averages")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.pink)
                
                Spacer()
            }
            .padding(.top, 0)
            
            Text("Last 7 Days")
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.4))
                .padding(.bottom)

            ZStack {
                if sumOfSteps > 0 {
                    Chart(filteredData) { item in
                        SectorMark(
                            angle: .value("Steps", Double(item.stepComputed) / Double(sumOfSteps) * 360),
                            innerRadius: .ratio(0.65),
                            outerRadius: item.id == highestStepDay?.id ? .ratio(1.0) : .ratio(0.9),
                            angularInset: 1
                        )
                        .foregroundStyle(item.id == highestStepDay?.id ? .pink : .pink.opacity(0.3))
                        .cornerRadius(7)
                    }
                    .chartLegend(position: .bottom)
                    .frame(height: 210)

                    // Display the highest step day inside the chart
                    if let highest = highestStepDay {
                        VStack {
                            Text("\(highest.date.formatted(.dateTime.weekday(.wide)))")
                                .font(.title2.weight(.semibold))

                            Text("\(highest.stepComputed) Steps")
                                .fontWeight(.bold)
                                .foregroundStyle(.gray.opacity(0.9))
                        }
                    }
                } else {
                    Text("No Data Available")
                        .font(.title3)
                        .foregroundStyle(.gray)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .background(.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            } // ZStack
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.top, 5)
    }
}

#Preview {
    StepChart_Sector_view()
}
