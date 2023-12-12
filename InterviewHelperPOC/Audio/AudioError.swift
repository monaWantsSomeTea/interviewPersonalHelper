//
//  AudioError.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 12/11/23.
//

import Foundation

enum AudioError {
    case none
    case failedToSave
    case failedToDelete
    case genericError

    var title: String {
        return "Something went wrong"
    }
        
    var message: String {
        switch self {
        case .failedToSave:
            return "Audio was not saved. Please try again later."
        case .failedToDelete:
            return "Audio was not deleted. Please try again later."
        case .genericError:
            return "Please try again later"
        case .none:
            return ""
        }
    }
}
