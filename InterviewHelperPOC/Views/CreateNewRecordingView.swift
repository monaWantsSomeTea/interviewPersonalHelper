//
//  CreateNewRecordingView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/15/23.
//

import SwiftUI

struct CreateNewRecordingView: View {
    @Binding var isPresentingPlayRecordView: Bool
    @Binding var isPresentingNewRecordingView: Bool
    @Binding var totalRecordTime: CGFloat
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer(minLength: 20)
            
            Text("New Recording")
                .font(.headline)
            
            Text("\(self.totalRecordTime)")
            
            Button {
                // Stop recording
                // Save recording to temporary file
                self.isPresentingNewRecordingView = false
                self.isPresentingPlayRecordView = true
            } label: {
                Image(systemName: "stop.circle.fill")
                    .resizable()
                    .foregroundColor(.red)
                    .frame(width: 44, height: 44)
            }
            .padding([.top])
        }
    }
}

struct CreateNewRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewRecordingView(isPresentingPlayRecordView: .constant(true), isPresentingNewRecordingView: .constant(true), totalRecordTime: .constant(10))
    }
}
