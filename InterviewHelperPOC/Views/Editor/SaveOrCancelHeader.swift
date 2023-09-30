//
//  SaveOrCancelHeader.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

struct SaveOrCancelHeader: View {
    @Binding var response: String
    @Binding var inputResponse: String
    
    var body: some View {
        HStack {
            Button(action: self.cancel) {
                Text("Cancel")
                    .foregroundColor(.black)
                    .padding([.horizontal])
                    .padding([.vertical], 4)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(Color.black)
                    }
            }

            Spacer()

            Button(action: self.save) {
                Text("Save")
                    .foregroundColor(.black)
                    .padding([.horizontal])
                    .padding([.vertical], 4)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(Color.black)
                    }
                
            }
        }
    }
}

extension SaveOrCancelHeader {
    func save() {
        // So how do I save this to local memory??? ahhh
        print(self.$inputResponse.wrappedValue)
    }
    
    func cancel() {
        self.inputResponse = self.response
    }
}

struct SaveOrCancelHeader_Previews: PreviewProvider {
    static var previews: some View {
        SaveOrCancelHeader(response: .constant("Hello"), inputResponse: .constant("Not Hello"))
    }
}
