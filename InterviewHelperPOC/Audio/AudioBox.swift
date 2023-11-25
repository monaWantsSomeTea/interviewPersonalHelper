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
    @Published var hasStoredAudio: Bool = false
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var urlForTemporaryDirectoryPath: URL?
    var urlForDocumentDirectoryPath: URL?
    
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
            filePath = "TemporaryMemory\(prompt).caf"
        }
       
        return tempDirectory.appendingPathComponent(filePath)
    }
    
    func setupRecorder(promptItemIdentifier: UUID?, prompt: String) {
        self.urlForTemporaryDirectoryPath = self.getTemporaryURL(identifier: promptItemIdentifier,
                                                                    prompt: prompt)
        guard let urlForTemporaryDirectoryPath = self.urlForTemporaryDirectoryPath else {
//            throw
            fatalError("Temporary url not found")
        }
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: urlForTemporaryDirectoryPath,
                                                     settings: recordSettings)
            self.audioRecorder?.delegate = self
            self.hasStoredAudio = true
        } catch {
            print("Error creating Audio Recorder.")
        }
    }
    
    /// - returns: Whether or not the file with this url is written in
    func setURLFromPromptItem(identifier: UUID?, prompt: String) {
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
        } else if let data = fileManager.contents(atPath: savedFileURL.path()), !data.isEmpty {
            self.hasStoredAudio = true
        } else {
            self.hasStoredAudio = false
        }
    }
    
    func writeAudioToDocumentsDirectory(for promptItem: PromptItemViewModel) throws -> AudioDetails {
        guard let urlForTemporaryDirectoryPath = self.urlForTemporaryDirectoryPath else {
//            throw
            fatalError("Temporary url not found")
        }

        do {
            let data = try Data(contentsOf: urlForTemporaryDirectoryPath)
            
            
            let identifier: UUID = promptItem.identifier ?? UUID()
            let url = self.getURLWithinDocumentDirectory(with: identifier)
            self.urlForDocumentDirectoryPath = url
            
            if FileManager.default.fileExists(atPath: urlForTemporaryDirectoryPath.path()) ||
                FileManager.default.fileExists(atPath: url.path())
            {
                do {
                    try data.write(to: url, options: [.atomic])
                    try self.deleteTemporaryAudioFileURL(url: urlForTemporaryDirectoryPath)
                }
                catch {
                    print("Can not move files")
                    fatalError("Can not move files")
                }
            } else {
                print("Temp file doesn't no exisit")
            }
            
            return AudioDetails(identifier: identifier, url: url)
        } catch {
            fatalError("Failed to save data from the temporary file to the new file path.")
        // TODO: Handle error
//            throw
        }
    }
    
    func record(promptItemIdentifier: UUID?, prompt: String) {
        self.setupRecorder(promptItemIdentifier: promptItemIdentifier, prompt: prompt)
        self.audioRecorder?.record()
        self.status = .recording
    }
    
    func stopRecording() {
        self.audioRecorder?.stop()
        self.status = .stopped
    }
    
    func play(identifier: UUID?) {
        let url: URL
        
        if let urlForTemporaryDirectoryPath = self.urlForTemporaryDirectoryPath {
            url = urlForTemporaryDirectoryPath
        } else if let identifier {
            url = self.getURLWithinDocumentDirectory(with: identifier)
        } else {
            fatalError("No url found")
        }
        
        if FileManager.default.fileExists(atPath: url.path()) {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            } catch {
                print(error.localizedDescription)
                print("ISurlNil?:", url)
            }
        } else {
            fatalError("Can not play. Url to file is not valid.")
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
    
    func deleteAudio() throws {
        if let url = self.urlForTemporaryDirectoryPath {
            try self.deleteTemporaryAudioFileURL(url: url)
        } else if let url = self.urlForDocumentDirectoryPath {
            print("THIS URL Was not suppose to be deleted")
            try FileManager.default.removeItem(at: url)
            self.urlForDocumentDirectoryPath = nil
        }
        
        // TODO: Check the actual path using the identifier to see if it is valid
        if self.urlForDocumentDirectoryPath == nil {
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
        
        // TODO: Show an error message when recording failed
    }
}

extension AudioBox: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.status = .stopped
    }
}
