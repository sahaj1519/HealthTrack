//
//  ContentView.swift
//  HealthTrack
//
//  Created by Ajay Sangwan on 24/03/25.
//
import SwiftData
import SwiftUI
import Charts

struct ContentView: View {
    
    @Environment(\.modelContext) var modelContext
   
   
    @State private var selectedType: String = "Steps"
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                Picker("Choose What you want to see", selection: $selectedType){
                    Text("Steps").tag("Steps")
                    Text("Weight").tag("Weight")
                    
                }.pickerStyle(.segmented)
                ScrollView{
                    if selectedType == "Steps"{
                        StepView()
                    }else{
                        WeightView()
                    }
                }.scrollIndicators(.hidden)
            }
             
        }.padding()
        
     //   .preferredColorScheme(.dark)
       
        .onAppear{
            Task{
                do{
                    
                    HealthDataManager.clearAllHealthData(context: modelContext)
                     await HealthDataManager.requestHealthKitAccess()
                    let stepEntry   =  await HealthDataManager.fetchStepData()
                    let weightEntry = await HealthDataManager.fetchWeightData()
                    let heartEntry  = await HealthDataManager.fetchHeartData()
                    
                   
                    let existingEntries = try modelContext.fetch(FetchDescriptor<DataModel>())
                    
                    for (index, data) in stepEntry.enumerated(){
                        let date = data.date
                        let step = data.step
                        
                        let weight    = index < weightEntry.count ? weightEntry[index].weight : 0
                        let heartRate = index < heartEntry.count ? heartEntry[index].heartRate : 0
                        
                        let calendar = Calendar.current
                        if !existingEntries.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                            let entry = DataModel(date: date, step: step, weight: weight, heartRate: heartRate)
                            modelContext.insert(entry)
                        }

                    }
                    
                  
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
