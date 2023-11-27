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
    var urlForTemporaryDirectoryPath: URL?
    
    var totalDurationForPlayer: TimeInterval {
        self.audioPlayer?.duration ?? 0.0
    }
    
    var currentTimeForPlayer: TimeInterval {
        self.audioPlayer?.currentTime ?? 0.0
    }
    
    func getURLWithinDocumentDirectory(with identifier: UUID) -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectoryURL = urls[0]
        return documentDirectoryURL.appendingPathComponent("\(identifier).caf")
    }
    
    func getTemporaryURL(identifier: UUID? = nil, prompt: String) -> URL {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let filePath: String
        
        if let identifier {
            filePath = "TemporaryMemory\(identifier).caf"
        } else {
            let prompt = prompt
                .filter { $0.isLetter || $0.isWhitespace}
                .map { $0.isWhitespace ? "-" : $0 }
            filePath = "TemporaryMemory\(String(prompt)).caf"
        }
       
        return tempDirectory.appendingPathComponent(filePath)
    }
    
    func setupRecorder(promptItemIdentifier: UUID?, prompt: String) throws {
        let url = self.getTemporaryURL(identifier: promptItemIdentifier, prompt: prompt)
        self.urlForTemporaryDirectoryPath = url
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        self.audioRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
        self.audioRecorder?.delegate = self
    }
    
    /// - returns: Whether or not the file with this url is written in
    func checkForStoredAudio(identifier: UUID?, prompt: String) {
        // Assign the permanent url when the prompt identifier exists
        // and Core data contains data for this Prompt item
        guard let identifier else {
            let url = self.getTemporaryURL(prompt: prompt)
            self.hasStoredAudio = FileManager.default.fileExists(atPath: url.path())
            return
        }
        
        let fileManager = FileManager.default
        let unsavedFileURL = self.getTemporaryURL(identifier: identifier, prompt: prompt)
        let savedFileURL = self.getURLWithinDocumentDirectory(with: identifier)
        
        if let data = fileManager.contents(atPath: unsavedFileURL.path()), !data.isEmpty {
            self.hasStoredAudio = true
            self.urlForTemporaryDirectoryPath = unsavedFileURL
        } else if let data = fileManager.contents(atPath: savedFileURL.path()), !data.isEmpty {
            self.hasStoredAudio = true
        } else {
            self.hasStoredAudio = false
        }
    }
    
    func writeAudioToDocumentsDirectory(for promptItem: PromptItemViewModel) throws -> AudioDetails {
        guard let urlForTemporaryDirectoryPath = self.urlForTemporaryDirectoryPath else {
            fatalError("Temporary url not found")
        }

        let data = try Data(contentsOf: urlForTemporaryDirectoryPath)
        
        
        let identifier: UUID = promptItem.identifier ?? UUID()
        let url = self.getURLWithinDocumentDirectory(with: identifier)
    
        if FileManager.default.fileExists(atPath: urlForTemporaryDirectoryPath.path()) {
            try data.write(to: url, options: [.atomic])
            try self.deleteTemporaryAudioFileURL(url: urlForTemporaryDirectoryPath)
        } else {
            fatalError("File url is not found in the temporary directory.")
        }
        
        return AudioDetails(identifier: identifier, url: url)
    }
    
    func record(promptItemIdentifier: UUID?, prompt: String) throws {
        try self.setupRecorder(promptItemIdentifier: promptItemIdentifier, prompt: prompt)
        self.status = .recording
        guard let audioRecorder = self.audioRecorder else {
            fatalError("No recorder was found.")
        }
        
        audioRecorder.record()
    }
    
    func stopRecording() {
        self.status = .stopped
        guard let audioRecorder = self.audioRecorder else {
            fatalError("No recorder was found.")
        }
        
        audioRecorder.stop()
        self.hasStoredAudio = true
    }
    
    func play(identifier: UUID?) throws {
        let url: URL
        
        if let urlForTemporaryDirectoryPath = self.urlForTemporaryDirectoryPath {
            url = urlForTemporaryDirectoryPath
        } else if let identifier {
            url = self.getURLWithinDocumentDirectory(with: identifier)
        } else {
            fatalError("No url found")
        }
        
        if FileManager.default.fileExists(atPath: url.path()) {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
        } else {
            fatalError("Can not play. Url to file is not valid.")
        }
        
        guard let audioPlayer = self.audioPlayer else {
            fatalError("Audio player not found")
        }
        
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
    
    /// Fast forward the current time by a set amount of time in seconds and
    /// stop the audio and audio progress animator when the expected time is at or over the total duration.
    ///
    /// - parameter time: The offset of time in seconds to fast forward.
    ///
    /// - returns: Whether update the animation for the timer.d
    func fastForward(by time: TimeInterval) -> Bool {
        guard let audioPlayer = self.audioPlayer else {
            fatalError("No audio player found")
        }
        
        let updatedCurrentTime = audioPlayer.currentTime + time
        if updatedCurrentTime < audioPlayer.duration {
            audioPlayer.currentTime = updatedCurrentTime
            return false
        } else {
            self.stopPlayback()
            audioPlayer.currentTime = audioPlayer.duration - 0.1
            return true
        }
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
    
    func deleteAudio(identifier: UUID?, prompt: String) throws {
        guard let identifier else {
            let url = self.getTemporaryURL(prompt: prompt)
            if FileManager.default.fileExists(atPath: url.path()) {
                try self.deleteTemporaryAudioFileURL(url: url)
            } else {
                self.hasStoredAudio = false
                fatalError("URL to file is not found in the temporary directory.")
            }
            
            // No audio is stored when the identifier for the prompt item does not exisit.
            self.hasStoredAudio = false
            return
        }
        
        let temporaryFileURL = self.getTemporaryURL(identifier: identifier, prompt: prompt)
        let savedFileURL = self.getURLWithinDocumentDirectory(with: identifier)
        
        if FileManager.default.fileExists(atPath: temporaryFileURL.path())  {
            try self.deleteTemporaryAudioFileURL(url: temporaryFileURL)
        } else if FileManager.default.fileExists(atPath: savedFileURL.path()) {
            try FileManager.default.removeItem(at: savedFileURL)
        }
        
        // No audio file stored on device.
        if !FileManager.default.fileExists(atPath: savedFileURL.path()) {
            self.hasStoredAudio = false
        }
    }
    
    func deleteTemporaryAudioFileURL(url: URL) throws {
        try FileManager.default.removeItem(at: url)
        self.urlForTemporaryDirectoryPath = nil
    }
    
    static func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time/60) % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", arguments: [minutes, seconds])
    }
    
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

extension AudioBox {
    struct AudioDetails {
        /// Unique identifer for the prompt item.
        let identifier: UUID
        /// URL to where the audio file is stored.
        let url: URL
    }
}

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
