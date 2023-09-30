//
//  CommonQuestionsHeader.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/19/23.
//

import SwiftUI

struct CommonQuestionsHeader: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Most common questions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding([.leading, .trailing, .top], 16)
            }
            Divider()
                .frame(height: 1)
                .overlay(Color(uiColor: .lightGray).opacity(0.5))
                .shadow(color: .init(uiColor: .lightGray), radius: 1, x: 0, y: -1)
        }
    }
}

struct CommonQuestionsHeader_Previews: PreviewProvider {
    static var previews: some View {
        CommonQuestionsHeader()
    }
}
