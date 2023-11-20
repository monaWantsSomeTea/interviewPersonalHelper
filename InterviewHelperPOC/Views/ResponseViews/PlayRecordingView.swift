//
//  PlayRecordingView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/15/23.
//

import SwiftUI

struct PlayRecordingView: View {
    @ObservedObject var audioBox: AudioBox
    @ObservedObject var progressAnimator: AudioProgressViewAnimator
    
    @Binding var isPresentingPlayRecordView: Bool
    @Binding var totalRecordTime: CGFloat
    
    
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
                            self.audioBox.play()
                            self.progressAnimator.startUpdateLoop()
                            break
                        case .recording:
                            // TODO: Add user is currently recording message
                            break
                  
                        }
                        
                    } label: {
                        Image(systemName: self.playOrPauseActionImageName)
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                    }
                    
                    Button {
                        
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
             
            } label: {
                Text("Save") // Or dismiss depending on state.
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
        return PlayRecordingView(audioBox: audioBox, progressAnimator: AudioProgressViewAnimator(audioBox: audioBox), isPresentingPlayRecordView: .constant(true), totalRecordTime: .constant(10))
    }
}
