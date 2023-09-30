//
//  UserResponse.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

struct UserResponse: View {
    // Data from local storage
    @State var response: String = "Add your answer, notes or bullet points"
    
    var body: some View {
        NavigationLink(destination: UserResponseEditor(response: self.$response)) {
            TextEditor(text: self.$response)
                .shadow(color: .brown, radius: 2)
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
                .multilineTextAlignment(.leading)
                .disabled(true)
        }
    }
}

struct ResponseSection: View {
    var body: some View {
        UserResponse()
            .padding()
    }
}

struct UserResponse_Previews: PreviewProvider {
    static var previews: some View {
        ResponseSection()
    }
}
