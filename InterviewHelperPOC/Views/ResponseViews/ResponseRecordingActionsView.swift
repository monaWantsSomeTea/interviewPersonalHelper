//
//  ResponseRecordingActionsView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/15/23.
//

import AVFoundation
import SwiftUI

private let kPlayRecordingLabelVerticalViewPadding: CGFloat = 12
private let kNewRecordingLabelVerticalViewPadding: CGFloat = 12

struct ResponseRecordingActionsView: View {
    @ObservedObject var audioBox: AudioBox
    @ObservedObject var progressAnimator: AudioProgressViewAnimator
    @Binding var isPresentingPlayRecordView: Bool
    @Binding var isPresentingNewRecordingView: Bool
    
    @State var hasMicrophoneAccess: Bool = false
    @State var displayRequestForMicophoneAccess: Bool = false
    
    // TODO: Disable when no recording is saved
    @State var hasSavedRecording: Bool = true
    
    var body: some View {
        HStack {
            Button(action: self.playRecording) {
                Text("Play Recording")
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding([.horizontal])
                    .padding([.vertical], kPlayRecordingLabelVerticalViewPadding)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(Color.black)
                    }
            }
            .opacity(self.hasSavedRecording ? 1 : 0.3)
            .disabled(!self.hasSavedRecording)

            Spacer()

            Button(action: self.addNewRecording) {
                Text("New Recording")
                    .foregroundColor(.white)
                    .padding([.horizontal])
                    .padding([.vertical], kNewRecordingLabelVerticalViewPadding)
            }
            .background(.red)
            .clipShape(Capsule(style: .continuous))
        }
        .onAppear {
            self.audioBox.setupRecorder()
        }
        .alert(isPresented: self.$displayRequestForMicophoneAccess) {
            Alert(title: Text("Requires Microphone Access"), message: Text("Enable microphone access to record. \nGo to iPhone Settings to enable access."), dismissButton: .default(Text("Dismiss")))
        }
    }
}

extension ResponseRecordingActionsView {
    private func requestMicrophoneAccess() {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { granted in
            self.hasMicrophoneAccess = granted
            if granted {
                self.isPresentingNewRecordingView = true
                audioBox.record()
                self.progressAnimator.startUpdateLoop()
            } else {
                displayRequestForMicophoneAccess = true
            }
        }
    }
    
    private func playRecording() {
        if self.audioBox.status == .stopped {
            self.audioBox.play()
            self.progressAnimator.startUpdateLoop()
            self.isPresentingPlayRecordView = true
        }
    }
    
    private func addNewRecording() {
        guard self.audioBox.status == .stopped else {
            return
        }
        
        if self.hasMicrophoneAccess {
            self.isPresentingNewRecordingView = true
            self.audioBox.record()
            self.progressAnimator.startUpdateLoop()
        } else {
            self.requestMicrophoneAccess()
        }
    }
}


struct ResponseRecordingActionsView_Previews: PreviewProvider {
    static var previews: some View {
        let audioBox = AudioBox()
        ResponseRecordingActionsView(audioBox: audioBox, progressAnimator: AudioProgressViewAnimator(audioBox: audioBox), isPresentingPlayRecordView: .constant(true), isPresentingNewRecordingView: .constant(true))
        
        PromptAndResponseView(question:
            Binding(
                get: { TopInterviewQuestions().questions[0] },
                set: { _ in }
            )
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
