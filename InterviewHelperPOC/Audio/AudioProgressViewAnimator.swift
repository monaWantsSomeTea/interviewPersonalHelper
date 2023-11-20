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
    
    @objc func updateLoop() {
        if self.audioBox.status == .playing {
            if CFAbsoluteTimeGetCurrent() - self.previousUpdateTimeForPlayer > 0.1 {
                self.previousUpdateTimeForPlayer = CFAbsoluteTimeGetCurrent()
                self.currentTimeFormatted = Self.formattedTime(self.audioBox.currentTimeForPlayer)
                self.currentTime = self.audioBox.currentTimeForPlayer
            }
        } else if self.audioBox.status == .recording {
            if CFAbsoluteTimeGetCurrent() - self.previousUpdateTimeForRecorder > 0.1 {
                self.previousUpdateTimeForRecorder = CFAbsoluteTimeGetCurrent()
                self.currentTimeFormatted = Self.formattedTime(self.audioBox.audioRecorder?.currentTime ?? 0)
                self.currentTime = self.audioBox.audioRecorder?.currentTime ?? 0
            }
        }
    }
    
    func stopUpdateTimer() {
        self.updateTimer?.invalidate()
        self.updateTimer = nil
        self.currentTimeFormatted = "00:00"
        self.currentTime = 0.0
        
    }
    
    static func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time/60) % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", arguments: [minutes, seconds])
    }
}
