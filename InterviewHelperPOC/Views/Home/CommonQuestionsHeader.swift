//
//  CommonQuestionsHeader.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/19/23.
//

import SwiftUI

private let kHeaderLabelPadding: CGFloat = 16

struct CommonQuestionsHeader: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Top interview questions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding([.leading, .trailing, .top], kHeaderLabelPadding)
            }
        }
    }
}

struct CommonQuestionsHeader_Previews: PreviewProvider {
    static var previews: some View {
        CommonQuestionsHeader()
    }
}
