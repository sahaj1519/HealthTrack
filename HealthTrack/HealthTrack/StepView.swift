//
//  StepView.swift
//  HealthTrack
//
//  Created by Ajay Sangwan on 25/03/25.
//

import SwiftUI


struct StepView: View {
    
    
    
    var body: some View {
        NavigationStack{
           
                
                NavigationLink{
                    StepDetail_View()
                    
                }label: {
                    
                    StepChart_Bar_View()
                    
                }.foregroundStyle(.primary.opacity(1.0))
                
                StepChart_Sector_view()
                
            
            
            
            
        }
        
    }
}

#Preview {
    StepView()
}
