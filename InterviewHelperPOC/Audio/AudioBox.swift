//
//  AudioBox.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/17/23.
//

import Foundation
import AVFoundation

class AudioBox: NSObject, ObservableObject {
    @Published var status: AudioStatus = .stopped
    /// Audio has been stored in file in either the temporary or document directory.
    @Published var hasStoredAudio: Bool = true

    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?

    var totalDurationForPlayer: TimeInterval { self.audioPlayer?.duration ?? 0.0 }
    var currentTimeForPlayer: TimeInterval { self.audioPlayer?.currentTime ?? 0.0 }
    
    var currentTimeForRecorder: TimeInterval { self.audioRecorder?.currentTime ?? 0 }
    
    var urlForTemporaryDirectoryPath: URL?
    
    override init() {
        super.init()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleInteruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AudioBox {
    /// Formats the time from seconds to digital clock format of minutes and seconds.
    ///
    /// - parameter time: TimeInterval to convert.
    ///
    /// - returns: A string representing the time in minutes and seconds in digital format.
    static func format(time: TimeInterval) -> String {
        let minutes = Int(time/60) % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", arguments: [minutes, seconds])
    }
}

// - MARK: Handle route change and interruption methods

extension AudioBox {
    @objc func handleRouteChange(notification: Notification) {
        if let info = notification.userInfo,
           let rawValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt {
            let reason = AVAudioSession.RouteChangeReason(rawValue: rawValue)
            if reason == .oldDeviceUnavailable {
                guard let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription,
                      let previousOutput = previousRoute.outputs.first else {
                    return
                }
                
                if previousOutput.portType == .headphones {
                    if self.status == .playing {
                        self.pausePlayback()
                    } else if self.status == .recording {
                        self.stopRecording()
                    }
                }
            }
        }
    }
    
    @objc func handleInteruption(notification: Notification) {
        if let userInfo = notification.userInfo,
           let rawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt
        {
            let type = AVAudioSession.InterruptionType(rawValue: rawValue)
            if type == .began {
                if self.status == .playing {
                    self.pausePlayback()
                } else if self.status == .recording {
                    self.stopRecording()
                }
            } else {
                if let rawValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: rawValue)
                    if options == .shouldResume && self.status == .paused {
                        self.resumePlayback()
                    }
                }
            }
        }
    }
}

// - MARK: Audio Delegate methods

extension AudioBox: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.status = .stopped
        self.hasStoredAudio = flag
    }
}

extension AudioBox: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.status = .stopped
    }
}
