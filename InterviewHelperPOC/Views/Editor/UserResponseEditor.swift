//
//  UserResponseEditor.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

struct UserResponseEditor: View {
    @Binding var response: String
    @State var inputResponse: String
    
    var body: some View {
        VStack {
            Text("Questions for this is here and we want this to be compact.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            
        
            TextEditor(text: self.$inputResponse)
                .shadow(color: .brown, radius: 2)
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))
            Spacer(minLength: 20)
            SaveOrCancelHeader(response: self.$response, inputResponse: self.$inputResponse)
        }
        .padding()
        .navigationTitle("Edit Response")
    }
    
    init(response: Binding<String>) {
        self._response = response
        self.inputResponse = response.wrappedValue
    }
}

struct UserResponseEditor_Previews: PreviewProvider {
    static var previews: some View {
        UserResponseEditor(response: .constant("Add your answer, notes or bullet points"))
    }
}
