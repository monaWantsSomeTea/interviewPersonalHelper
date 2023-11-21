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
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleInteruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
    
    var urlForTemporaryDirectoryPath: URL {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let filePath = "TemporaryMemory.caf"
        return tempDirectory.appendingPathComponent(filePath)
    }
    
    var totalDurationForPlayer: TimeInterval {
        self.audioPlayer?.duration ?? 0.0
    }
    
    var currentTimeForPlayer: TimeInterval {
        self.audioPlayer?.currentTime ?? 0.0
    }
    
    func setupRecorder() {
        let recordSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            // TODO: Delete the print statement
            //            print("TEMP URL PATH:", self.urlForTemporaryDirectoryPath.absoluteString)
            self.audioRecorder = try AVAudioRecorder(url: self.urlForTemporaryDirectoryPath,
                                                     settings: recordSettings)
            self.audioRecorder?.delegate = self
        } catch {
            print("Error creating Audio Recorder.")
        }
    }
    
    func record() {
        self.audioRecorder?.record()
        self.status = .recording
    }
    
    func stopRecording() {
        self.audioRecorder?.stop()
        self.status = .stopped
    }
    
    func play() {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: urlForTemporaryDirectoryPath)
        } catch {
            // TODO: Show an error handler if audio player fails be created
            print(error.localizedDescription)
        }
        
        guard let audioPlayer = self.audioPlayer else { return }
        audioPlayer.delegate = self
        if audioPlayer.duration > 0.0 {
            audioPlayer.play()
            self.status = .playing
        }
    }
    
    func rewind(by time: TimeInterval) {
        guard let audioPlayer = self.audioPlayer else {
            return
        }
        
        audioPlayer.currentTime = audioPlayer.currentTime - time
    }
    
    func fastForward(by time: TimeInterval) {
        guard let audioPlayer = self.audioPlayer else {
            return
        }
        
        audioPlayer.currentTime = audioPlayer.currentTime + time
    }
    
    func resumePlayback() {
        self.audioPlayer?.play()
        self.status = .playing
    }
    
    func pausePlayback() {
        self.audioPlayer?.pause()
        self.status = .paused
    }
    
    func stopPlayback() {
        self.audioPlayer?.stop()
        self.status = .stopped
    }
    
    static func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time/60) % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", arguments: [minutes, seconds])
    }
}

extension AudioBox: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.status = .stopped
        
        // TODO: Show an error message when recording failed
    }
}

extension AudioBox: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.status = .stopped
    }
}
