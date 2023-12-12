//
//  CreateNewRecordingView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/15/23.
//

import SwiftUI

struct CreateNewRecordingView: View {
    @ObservedObject var audioBox: AudioBox
    @ObservedObject var progressAnimator: AudioProgressViewAnimator
     
    @Binding var isPresentingPlayRecordView: Bool
    @Binding var isPresentingNewRecordingView: Bool
    /// Audio is stored temporarily and not saved permanently. 
    @Binding var hasStoredUnsavedAudio: Bool
    
    var totalRecordTime: String { AudioBox.format(time: self.audioBox.currentTimeForRecorder) }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer(minLength: 20)
            
            Text("New Recording")
                .font(.headline)
            
            Text(self.progressAnimator.currentTimeFormatted)
            
            Button {
                self.audioBox.stopRecording()
                self.progressAnimator.stopUpdateTimer()
                self.hasStoredUnsavedAudio = true
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
        .onDisappear {
            self.progressAnimator.stopUpdateTimer()
            self.audioBox.status = .stopped
        }
    }
}

struct CreateNewRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        let audioBox = AudioBox()
        CreateNewRecordingView(audioBox: audioBox,
                               progressAnimator: AudioProgressViewAnimator(audioBox: audioBox),
                               isPresentingPlayRecordView: .constant(true),
                               isPresentingNewRecordingView: .constant(true),
                               hasStoredUnsavedAudio: .constant(false))
    }
}
