//
//  AudioStatus.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/17/23.
//

import Foundation

enum AudioStatus: Int, CustomStringConvertible {
    case stopped
    case playing
    case paused
    case recording
    
    var audioName: String {
        let audioName = ["Audio:Stopped", "Audio:Playing", "Audio:Paused", "Audio:Recording"]
        return audioName[rawValue]
    }
    
    var description: String {
        return audioName
    }
}
