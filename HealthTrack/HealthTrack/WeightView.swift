//
//  WeightView.swift
//  HealthTrack
//
//  Created by Ajay Sangwan on 25/03/25.
//


import SwiftUI

struct WeightView: View {
    var body: some View {
        NavigationStack{
          
                
                NavigationLink{
                    WeightDetail_View()
                }label:{
                    weightChart_Line_View()
                }.foregroundStyle(.primary.opacity(1.0))
                
                weightChart_Bar_View()
                
            
            
        }
    }
}

#Preview {
    WeightView()
}
