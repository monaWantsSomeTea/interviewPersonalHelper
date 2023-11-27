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
    /// Audio has not been saved to CoreData.
    @Binding var hasUnsavedAudio: Bool
    
    @State var showFailedToSaveAudioErrorMessage: Bool = false
    @State var showFailedToDeleteAudioErrorMessage: Bool = false
    @State var showGenericErrorMessage: Bool = false
    
    var previousStatus: AudioStatus = .playing
    var playOrPauseActionImageName: String {
        switch self.audioBox.status {
        case .playing:
            return "pause.fill"
        case .paused, .stopped, .recording:
            return "play.fill"
        }
    }
    
    var totalDuration: String {
        let minutes = Int(self.audioBox.totalDurationForPlayer / 60) % 60
        let seconds = Int(self.audioBox.totalDurationForPlayer) % 60
        return String(format: "%02i:%02i", arguments: [minutes, seconds])
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
                        switch self.audioBox.status {
                        case .playing:
                            self.audioBox.pausePlayback()
                        case .paused:
                            self.audioBox.resumePlayback()
                        case .stopped:
                            do {
                                try self.audioBox.play(identifier: self.promptItemViewModel.identifier)
                                self.progressAnimator.startUpdateLoop()
                            } catch {
                                self.showGenericErrorMessage = true
                            }
                            break
                        case .recording:
                            fatalError("Recording is in session.")
                            break
                  
                        }
                        
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
                    self.audioBox.stopPlayback()
                    self.audioBox.status = .stopped
                    self.progressAnimator.stopUpdateTimer()
                    
                    self.deleteAudio()
                    
                    self.isPresentingPlayRecordView = false
                } label: {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
                .padding([.trailing])
            }
            
            Button {
                self.audioBox.stopPlayback()
                self.audioBox.status = .stopped
                self.progressAnimator.stopUpdateTimer()
                self.isPresentingPlayRecordView = false
                
                if self.hasUnsavedAudio {
                    self.saveRecording(for: self.promptItemViewModel)
                }
             
            } label: {
                Text(self.hasUnsavedAudio ? "Save" : "Dismiss")
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
        .alert(isPresented: self.$showFailedToSaveAudioErrorMessage) {
            Alert(title: Text("Something went wrong"),
                  message: Text("Audio was not saved. Please try again later."),
                  dismissButton: .default(Text("Dismiss")))
        }
        .alert(isPresented: self.$showFailedToDeleteAudioErrorMessage) {
            Alert(title: Text("Something went wrong"),
                  message: Text("Audio was not deleted. Please try again later."),
                  dismissButton: .default(Text("Dismiss")))
        }
        .alert(isPresented: self.$showGenericErrorMessage) {
            Alert(title: Text("Something went wrong"),
                  message: Text("Please try again later"),
                  dismissButton: .default(Text("Dismiss")))
        }
    }
}

extension PlayRecordingView {
    private func deleteAudio() {
        do {
            try self.audioBox.deleteAudio(identifier: self.promptItemViewModel.identifier,
                                          prompt: self.promptItemViewModel.prompt)
        } catch {
            self.showFailedToDeleteAudioErrorMessage = true
        }
    }
    
    private func saveRecording(for promptItem: PromptItemViewModel) {
        do {
            let audioDetails = try self.audioBox.writeAudioToDocumentsDirectory(for: promptItem)
            try self.saveToCoreData(for: promptItem, with: audioDetails)
            self.hasUnsavedAudio = false
        } catch {
            self.showFailedToSaveAudioErrorMessage = true
        }
    }

    /// Save the prompt item to core data when it does not contain the url to the audio file.
    private func saveToCoreData(for promptItem: PromptItemViewModel, with details: AudioBox.AudioDetails) throws {        
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
            newPromptItem.identifier = details.identifier
            newPromptItem.originialCategory = kTopInterviewQuestionCategory
            newPromptItem.originalId = String(topInterviewQuestion.id)
            newPromptItem.prompt = topInterviewQuestion.prompt
        default:
            fatalError("Unsupported type")
        }

        do {
            if let oldPromptItem {
                self.viewContext.delete(oldPromptItem)
            }
            
            try self.viewContext.save()
        } catch let error as NSError {
            self.viewContext.delete(newPromptItem)
            throw error
        }
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

//struct PlayRecordingView_Previews: PreviewProvider {
//    static var previews: some View {
//        let audioBox = AudioBox()
//        return PlayRecordingView(audioBox: audioBox, progressAnimator: AudioProgressViewAnimator(audioBox: audioBox), isPresentingPlayRecordView: .constant(true), totalRecordTime: .constant(10))
//    }
//}
