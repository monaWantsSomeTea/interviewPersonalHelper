//
//  AudioPlayerProgressViewAnimator.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/17/23.
//

import Foundation
import UIKit

class AudioProgressViewAnimator: ObservableObject {
    @Published var currentTimeFormatted: String = "00:00"
    @Published var currentTime: TimeInterval = 0.0
    
    let audioBox: AudioBox
    
    var updateTimer: CADisplayLink?
    var previousUpdateTimeForPlayer: CFTimeInterval = 0.0
    var previousUpdateTimeForRecorder: CFTimeInterval = 0.0
    
    init(audioBox: AudioBox) {
        self.audioBox = audioBox
    }
    
    func startUpdateLoop() {
        if let updateTimer = self.updateTimer {
            updateTimer.invalidate()
        }
        
        self.updateTimer = CADisplayLink(target: self, selector: #selector(updateLoop))
        self.updateTimer?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    /// Updates the current time progress.
    @objc func updateLoop() {
        // Allows the current time label  to update when the player is playing
        // or when rewinding or fastforwarding.
        if self.audioBox.status == .playing || self.audioBox.status == .paused {
            if CFAbsoluteTimeGetCurrent() - self.previousUpdateTimeForPlayer > 0.1 {
                self.previousUpdateTimeForPlayer = CFAbsoluteTimeGetCurrent()
                self.currentTimeFormatted = AudioBox.format(time: self.audioBox.currentTimeForPlayer)
                self.currentTime = self.audioBox.currentTimeForPlayer
            }
        } else if self.audioBox.status == .recording {
            if CFAbsoluteTimeGetCurrent() - self.previousUpdateTimeForRecorder > 0.1 {
                self.previousUpdateTimeForRecorder = CFAbsoluteTimeGetCurrent()
                self.currentTimeFormatted = AudioBox.format(time: self.audioBox.currentTimeForRecorder)
                self.currentTime = self.audioBox.currentTimeForRecorder
            }
        }
    }
    
    func updateAudioPlayerTimerImmediately() {
        Task(priority: .high) { [weak self] in
            guard let self else {
                fatalError("Class object does not exist.")
            }
            
            await MainActor.run {
                self.currentTimeFormatted = AudioBox.format(time: self.audioBox.currentTimeForPlayer)
                self.currentTime = self.audioBox.currentTimeForPlayer
            }
        }
    }
    
    func stopUpdateTimer() {
        self.updateTimer?.invalidate()
        self.updateTimer = nil
        self.currentTimeFormatted = "00:00"
        self.currentTime = 0.0
        
    }
}
