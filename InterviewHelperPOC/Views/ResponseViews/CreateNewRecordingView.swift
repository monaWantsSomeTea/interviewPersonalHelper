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
     
    @Binding var promptItemViewModel: PromptItemViewModel
    @Binding var isPresentingPlayRecordView: Bool
    @Binding var isPresentingNewRecordingView: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer(minLength: 20)
            
            Text("New Recording")
                .font(.headline)
            
            Text(self.progressAnimator.currentTimeFormatted)
            
            Button {
                self.audioBox.stopRecording()
                self.progressAnimator.stopUpdateTimer()
                self.isPresentingNewRecordingView = false
                
                do {
                    try self.audioBox.setupAudioPlayer(identifier: self.promptItemViewModel.identifier,
                                                       prompt: self.promptItemViewModel.prompt)
                    self.isPresentingPlayRecordView = true
                } catch {
                    assertionFailure("Audio player could not be setup.")
                }
            } label: {
                Image(systemName: "stop.circle.fill")
                    .resizable()
                    .foregroundColor(.red)
                    .frame(width: 44, height: 44)
            }
            .padding([.vertical])
        }
        .onDisappear {
            self.progressAnimator.stopUpdateTimer()
            self.audioBox.update(status: .stopped)
        }
    }
}

struct CreateNewRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        let audioBox = AudioBox()
        CreateNewRecordingView(audioBox: audioBox,
                               progressAnimator: AudioProgressViewAnimator(audioBox: audioBox),
                               promptItemViewModel: .constant(PromptItemViewModel(model: TopInterviewQuestions().questions[0] as! GenericPromptItem)),
                               isPresentingPlayRecordView: .constant(true),
                               isPresentingNewRecordingView: .constant(true))
    }
}
