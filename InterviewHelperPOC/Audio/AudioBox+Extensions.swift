//
//  AudioBox+Extensions.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 12/11/23.
//

import AVFoundation
import Foundation

// - MARK: Helper functions

extension AudioBox {
    func update(status: AudioStatus) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.status = status
        }
    }
    
    private func update(hasTemporaryAudioFile: Bool) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.hasTemporaryAudio = hasTemporaryAudioFile
        }
    }
    
    func checkForTemporaryAudio(promptItem: PromptItemViewModel) {
        let temporaryAudioURL = self.getTemporaryURL(identifier: promptItem.identifier,
                                                     prompt: promptItem.prompt)
        
        if FileManager.default.fileExists(atPath: temporaryAudioURL.path()) {
            self.update(hasTemporaryAudioFile: true)
        } else {
            self.update(hasTemporaryAudioFile: false)
        }
    }
    
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
        } else if let savedFileURL, let data = fileManager.contents(atPath: savedFileURL.path()), !data.isEmpty {
            self.hasStoredAudio = true
        } else {
            self.hasStoredAudio = false
        }
    }
    
    func writeAudioToDocumentsDirectory(for promptItem: PromptItemViewModel) throws -> UUID {
        let urlForTemporaryDirectoryPath = self.getTemporaryURL(identifier: promptItem.identifier,
                                                                prompt: promptItem.prompt)
        
        let identifier: UUID = promptItem.identifier ?? UUID()
        let url = self.getURLWithinDocumentDirectory(with: identifier)
        
        if let url, let data = FileManager.default.contents(atPath: urlForTemporaryDirectoryPath.path()) {
            try data.write(to: url, options: [.atomic])
            try self.deleteTemporaryAudioFileURL(url: urlForTemporaryDirectoryPath)
        } else {
            fatalError("File url is not found in the temporary directory.")
        }
        
        return identifier
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
        } else if let savedFileURL, FileManager.default.fileExists(atPath: savedFileURL.path()) {
            try FileManager.default.removeItem(at: savedFileURL)
        }
        
        // No audio file stored on device.
        if let savedFileURL, !FileManager.default.fileExists(atPath: savedFileURL.path()) {
            self.hasStoredAudio = false
        }
    }
    
    private func deleteTemporaryAudioFileURL(url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}
    
// - MARK: Record helper functions
    
extension AudioBox {
    func record(promptItemIdentifier: UUID?, prompt: String) throws {
        try self.setupRecorder(promptItemIdentifier: promptItemIdentifier, prompt: prompt)
        self.update(status: .recording)
        guard let audioRecorder = self.audioRecorder else {
            fatalError("No recorder was found.")
        }
        
        audioRecorder.record()
    }
    
    func stopRecording() {
        self.update(status: .stopped)
        guard let audioRecorder = self.audioRecorder else {
            fatalError("No recorder was found.")
        }
        
        audioRecorder.stop()
        self.hasStoredAudio = true
    }
    
    func play(identifier: UUID?, prompt: String) throws {

        let temporaryURL = self.getTemporaryURL(identifier: identifier, prompt: prompt)
        let documentURL = self.getURLWithinDocumentDirectory(with: identifier)
        
        // Get temporary url path if it exists first
        if FileManager.default.fileExists(atPath: temporaryURL.path()) {
            self.audioPlayer = try AVAudioPlayer(contentsOf: temporaryURL)
        } else if let documentURL, FileManager.default.fileExists(atPath: documentURL.path()) {
            self.audioPlayer = try AVAudioPlayer(contentsOf: documentURL)
        } else {
            fatalError("Can not play. Url to file is not valid.")
        }
        
        guard let audioPlayer = self.audioPlayer else {
            fatalError("Audio player not found")
        }
        
        audioPlayer.delegate = self
        if audioPlayer.duration > 0.0 {
            audioPlayer.play()
            self.update(status: .playing)
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
        self.update(status: .playing)
    }
    
    func pausePlayback() {
        self.audioPlayer?.pause()
        self.update(status: .paused)
    }
    
    func stopPlayback() {
        self.audioPlayer?.stop()
        self.update(status: .stopped)
    }
}

// - MARK: Private helper functions

extension AudioBox {
    /// Returns the URL to the saved audio file within the document directory.
    ///
    /// - parameter identifier: The unique identifier for the prompt item.
    ///
    /// - return: The URL to the file containing the saved audio.
    private func getURLWithinDocumentDirectory(with identifier: UUID?) -> URL? {
        guard let identifier else {
            return nil
        }
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectoryURL = urls[0]
        return documentDirectoryURL.appendingPathComponent("\(identifier).caf")
    }
    
    /// Returns the URL to the audio file within the temporary directory.
    ///
    /// - parameter identifier: Optional. The unique identifier for the prompt item.
    /// - parameter prompt:    The prompt for the prompt item. Used if no identifier is set.
    ///
    /// - return: The URL to the file containing the temporarily saved audio.
    private func getTemporaryURL(identifier: UUID? = nil, prompt: String) -> URL {
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
        let filePath: String
        
        if let identifier {
            filePath = "TemporaryMemory\(identifier).caf"
        } else {
            let prompt = prompt
                .filter { $0.isLetter || $0.isWhitespace}
                .map { $0.isWhitespace ? "-" : $0 }
            filePath = "TemporaryMemory\(String(prompt)).caf"
        }
       
        return temporaryDirectory.appendingPathComponent(filePath)
    }

    /// Setup the audio recorder with the URL to the temporary directory.
    ///
    /// - parameter identifier: Optional. The unique identifier for the prompt item.
    /// - parameter prompt:    The prompt for the prompt item.
    ///
    private func setupRecorder(promptItemIdentifier: UUID?, prompt: String) throws {
        let url = self.getTemporaryURL(identifier: promptItemIdentifier, prompt: prompt)
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        self.audioRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
        self.audioRecorder?.delegate = self
    }
}
