//
//  PlayRecordingView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/15/23.
//

import SwiftUI

private let kTopInterviewQuestionCategory: String = "top-interview-question"

struct PlayRecordingView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var audioBox: AudioBox
    @ObservedObject var progressAnimator: AudioProgressViewAnimator
    
    @Binding var isPresentingPlayRecordView: Bool
    @Binding var totalRecordTime: CGFloat
    @Binding var promptItemViewModel: PromptItemViewModel
    
    @State var audioError: AudioError = .none
    @State var hasAudioError: Bool = false

    private var playOrPauseActionImageName: String {
        switch self.audioBox.status {
        case .playing:
            return "pause.fill"
        case .paused, .stopped, .recording:
            return "play.fill"
        }
    }
    
    private var totalDuration: String {
        AudioBox.format(time: self.audioBox.totalDurationForPlayer)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Play Recording")
                .font(.headline)
                .padding([.top], 8)
             
            VStack {
                ProgressView(value: self.progressAnimator.currentTime,
                             total: self.audioBox.totalDurationForPlayer)
                HStack {
                    Text(self.progressAnimator.currentTimeFormatted)
                        .font(.subheadline)
                    Spacer()
                    Text(self.totalDuration)
                        .font(.subheadline)
                }
            }
            .padding([.horizontal], 8)
            .padding()
            
            ZStack {
                HStack(spacing: 32) {
                    Spacer()
                
                    Button {
                        self.audioBox.rewind(by: 5)
                    } label: {
                        Image(systemName: "backward.circle")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                    }
                    
                    Button {
                        self.audioControlAction()
                    } label: {
                        Image(systemName: self.playOrPauseActionImageName)
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                    }
                    
                    Button {
                        if self.audioBox.fastForward(by: 5) {
                            self.progressAnimator.updateAudioPlayerTimerImmediately()
                        }
                    } label: {
                        Image(systemName: "forward.circle")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                    }
                    
                    Spacer()
                }
                .padding([.top], 8)
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    self.deleteAndDismiss()
                } label: {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
                .padding([.trailing])
            }
            
            Button {
                self.dismissAndSaveIfNeeded()
            } label: {
                Text(self.audioBox.hasTemporaryAudio ? "Save" : "Dismiss")
                    .foregroundColor(.white)
                    .padding([.horizontal], 16)
                    .padding([.vertical], 6)
                    .font(.headline)
            }
            .frame(width: 250, height: 50, alignment: .center)
            .background(.blue)
            .clipShape(Capsule(style: .circular))
            .padding([.top])
        }
        .onAppear {
            self.audioBox.checkForTemporaryAudio(promptItem: self.promptItemViewModel)
        }
        .onChange(of: self.audioError, perform: { newValue in
            if newValue != .none {
                self.hasAudioError = true
            }
        })
        .alert(isPresented: self.$hasAudioError) {
            Alert(title: Text(self.audioError.title),
                  message: Text(self.audioError.message),
                  dismissButton: .default(Text("Dismiss"))
            {
                self.audioError = .none
            })
        }
    }
}

extension PlayRecordingView {
    private func audioControlAction() {
        switch self.audioBox.status {
        case .playing:
            self.audioBox.pausePlayback()
        case .paused:
            self.audioBox.resumePlayback()
        case .stopped:
            do {
                self.progressAnimator.stopUpdateTimer()
                try self.audioBox.setupAudioPlayer(identifier: self.promptItemViewModel.identifier,
                                                   prompt: self.promptItemViewModel.prompt)
                self.audioBox.play()
                self.progressAnimator.startUpdateLoop()
            } catch {
                if let error = error as? AudioError {
                    self.audioError = error
                } else {
                    self.audioError = .genericError
                }
            }
        case .recording:
            fatalError("Recording is in session.")
            break
        }
    }
    
    private func dismissAndSaveIfNeeded() {
        self.audioBox.stopPlayback()
        self.audioBox.update(status: .stopped)
        self.progressAnimator.stopUpdateTimer()
        self.isPresentingPlayRecordView = false
        
        if self.audioBox.hasTemporaryAudio {
            self.saveRecording(for: self.promptItemViewModel)
        }
    }
    
    private func deleteAndDismiss() {
        self.audioBox.stopPlayback()
        self.audioBox.update(status: .stopped)
        self.progressAnimator.stopUpdateTimer()
        
        self.deleteAudio()
        self.isPresentingPlayRecordView = false
    }

    private func deleteAudio() {
        do {
            try self.audioBox.deleteAudio(identifier: self.promptItemViewModel.identifier,
                                          prompt: self.promptItemViewModel.prompt)
        } catch {
            if let error = error as? AudioError {
                self.audioError = error
            } else {
                self.audioError = .failedToDelete
            }
        }
    }
    
    private func saveRecording(for promptItem: PromptItemViewModel) {
        do {
            let identifier = try self.audioBox.writeAudioToDocumentsDirectory(for: promptItem)
            try self.saveToCoreData(for: promptItem, with: identifier)
        } catch {
            if let error = error as? AudioError {
                self.audioError = error
            } else {
                self.audioError = .failedToSave
            }
        }
    }

    /// Save the prompt item to core data when it does not contain the url to the audio file.
    private func saveToCoreData(for promptItem: PromptItemViewModel, with identifier: UUID) throws {
        let newPromptItem = PromptItem(context: self.viewContext)
        var oldPromptItem: PromptItem?
        
        switch promptItem.model {
        case let promptItem as PromptItem:
            // The old prompt item properties are assigned to the new prompt item.
            // Then we delete the old prompt item.
            // This is so that the `onChange` will detect the changes of CoreData for the PromptItems.
            newPromptItem.identifier = promptItem.identifier
            newPromptItem.originialCategory = promptItem.originialCategory
            newPromptItem.originalId = promptItem.originalId
            newPromptItem.prompt = promptItem.prompt
            newPromptItem.response = promptItem.response
         
            oldPromptItem = promptItem
        case let topInterviewQuestion as TopInterviewQuestion:
            newPromptItem.identifier = identifier
            newPromptItem.originialCategory = kTopInterviewQuestionCategory
            newPromptItem.originalId = String(topInterviewQuestion.id)
            newPromptItem.prompt = topInterviewQuestion.prompt
        default:
            throw AudioError.failedToSave
        }

        do {
            if let oldPromptItem {
                self.viewContext.delete(oldPromptItem)
            }
            
            try self.viewContext.save()
        } catch {
            self.viewContext.delete(newPromptItem)
            throw AudioError.failedToSave
        }
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

struct PlayRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        let audioBox = AudioBox()
        PlayRecordingView(audioBox: audioBox,
                          progressAnimator: AudioProgressViewAnimator(audioBox: audioBox),
                          isPresentingPlayRecordView: .constant(true),
                          totalRecordTime: .constant(10),
                          promptItemViewModel: .constant(PromptItemViewModel(model: TopInterviewQuestions().questions[0] as! GenericPromptItem)))
    }
}
