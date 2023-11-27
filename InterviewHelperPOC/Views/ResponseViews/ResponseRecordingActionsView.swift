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
    @Binding var promptItemViewModel: PromptItemViewModel
    
    @State var hasMicrophoneAccess: Bool = false
    @State var displayRequestForMicophoneAccess: Bool = false
    @State var showGenericErrorMessage: Bool = false
    
    var body: some View {
        HStack {
            Button(action: self.playAudio) {
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
            .opacity(self.audioBox.hasStoredAudio ? 1 : 0.3)
            .disabled(!self.audioBox.hasStoredAudio)

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
            self.audioBox.checkForStoredAudio(identifier: self.promptItemViewModel.identifier,
                                             prompt: self.promptItemViewModel.prompt)
        }
        .alert(isPresented: self.$displayRequestForMicophoneAccess) {
            Alert(title: Text("Requires Microphone Access"),
                  message: Text("Enable microphone access to record. \nGo to iPhone Settings to enable access."),
                  dismissButton: .default(Text("Dismiss")))
        }
        .alert(isPresented: self.$showGenericErrorMessage) {
            Alert(title: Text("Something went wrong"),
                  message: Text("Please try again later"),
                  dismissButton: .default(Text("Dismiss")))
        }
    }
}

extension ResponseRecordingActionsView {
    private func requestMicrophoneAccess() {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { granted in
            self.hasMicrophoneAccess = granted
            if granted {
                do {
                    self.isPresentingNewRecordingView = true
                    try self.audioBox.record(promptItemIdentifier: self.promptItemViewModel.identifier,
                                             prompt: self.promptItemViewModel.prompt)
                    self.progressAnimator.startUpdateLoop()
                } catch {
                    self.showGenericErrorMessage = true
                }
            } else {
                displayRequestForMicophoneAccess = true
            }
        }
    }
    
    private func playAudio() {
        if self.audioBox.status == .stopped {
            do {
                try self.audioBox.play(identifier: self.promptItemViewModel.identifier)
                self.progressAnimator.startUpdateLoop()
                self.isPresentingPlayRecordView = true
            } catch {
                self.showGenericErrorMessage = true
            }
        }
    }
    
    private func addNewRecording() {
        guard self.audioBox.status == .stopped else {
            return
        }
        
        if self.hasMicrophoneAccess {
            do {
                self.isPresentingNewRecordingView = true
                try self.audioBox.record(promptItemIdentifier: self.promptItemViewModel.identifier,
                                     prompt: self.promptItemViewModel.prompt)
                self.progressAnimator.startUpdateLoop()
            } catch {
                self.showGenericErrorMessage = true
            }
        } else {
            self.requestMicrophoneAccess()
        }
    }
}


//struct ResponseRecordingActionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        let audioBox = AudioBox()
//        ResponseRecordingActionsView(audioBox: audioBox,
//                                     progressAnimator: AudioProgressViewAnimator(audioBox: audioBox),
//                                     isPresentingPlayRecordView: .constant(true),
//                                     isPresentingNewRecordingView: .constant(true),
//                                     promptItemViewModel: .constant(PromptItemViewModel(model: TopInterviewQuestions().questions[0] as! GenericPromptItem)),
//                                     hasStoredAudio: .constant(false))
//        
//        PromptAndResponseView(question:
//            Binding(
//                get: { TopInterviewQuestions().questions[0] },
//                set: { _ in }
//            )
//        )
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
