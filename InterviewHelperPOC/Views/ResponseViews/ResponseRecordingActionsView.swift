//
//  ResponseRecordingActionsView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/15/23.
//

import SwiftUI

private let kPlayRecordingLabelVerticalViewPadding: CGFloat = 12
private let kNewRecordingLabelVerticalViewPadding: CGFloat = 12

struct ResponseRecordingActionsView: View {
    @Binding var isPresentingPlayRecordView: Bool
    @Binding var isPresentingNewRecordingView: Bool
    
    // TODO: Disable when no recording is saved
    @State var hasSavedRecording: Bool = true
    
    var body: some View {
        HStack {
            Button(action: self.playRecording) {
                Text("Play Recording")
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding([.horizontal])
                    .padding([.vertical], kPlayRecordingLabelVerticalViewPadding)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(Color.black)
                    }
            }
            .opacity(self.hasSavedRecording ? 1 : 0.3)
            .disabled(!self.hasSavedRecording)

            Spacer()

            Button(action: self.addNewRecording) {
                Text("New Recording")
                    .foregroundColor(.white)
                    .padding([.horizontal])
                    .padding([.vertical], kNewRecordingLabelVerticalViewPadding)
            }
            .background(.red)
            .clipShape(Capsule(style: .continuous))
        }
    }
}

extension ResponseRecordingActionsView {
    private func playRecording() {
        self.isPresentingPlayRecordView = true
    }
    
    private func addNewRecording() {
        self.isPresentingNewRecordingView = true
    }
}


struct ResponseRecordingActionsView_Previews: PreviewProvider {
    static var previews: some View {
        ResponseRecordingActionsView(isPresentingPlayRecordView: .constant(true), isPresentingNewRecordingView: .constant(true))
        
        PromptAndResponseView(question:
            Binding(
                get: { TopInterviewQuestions().questions[0] },
                set: { _ in }
            )
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
