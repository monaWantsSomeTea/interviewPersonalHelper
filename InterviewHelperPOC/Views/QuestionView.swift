//
//  QuestionView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 9/11/23.
//

import SwiftUI

struct QuestionView: View {
    let question: InterviewQuestion
    var body: some View {
        self.content
            .background(Color(red: 250/255, green: 240/255, blue: 230/255, opacity: 0.2)) //, ,
    }
    
    var content: some View {
        GeometryReader { proxy in
            VStack {
                QuestionCard(detail: self.question.details)
                    .padding()
                    .frame(height: proxy.size.height * 0.35)
                ResponseSection()
                
            }
            .padding([.vertical], 32)
        }
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView(question: InterviewQuestions().questions[0])
    }
}
