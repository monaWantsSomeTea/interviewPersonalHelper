//
//  PlayRecordingView.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 11/15/23.
//

import SwiftUI

struct PlayRecordingView: View {
    @Binding var isPresentingPlayRecordView: Bool
    @Binding var totalRecordTime: CGFloat
    
    @State var currentRecordTime: CGFloat = 0 {
        didSet {
            self.currentRecordTimeFormatted = "\(Int(self.currentRecordTime)):00"
        }
    }
    
    @State var currentRecordTimeFormatted: String = "00:00"
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Play Recording")
                .font(.headline)
                .padding([.top], 8)
            
            Slider(value: self.$currentRecordTime, in: 0...10.0, step: 1) {
                Text("Label")
            } minimumValueLabel: {
                Text(self.currentRecordTimeFormatted)
            } maximumValueLabel: {
                Text("10:00")
            } onEditingChanged: { isEditing in
                print("isEditing")
            }
            .padding()
            
            ZStack {
                HStack(spacing: 32) {
                    Spacer()
                
                    Button {
                        
                    } label: {
                        Image(systemName: "backward.circle")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                    }
                    
                    Button {
                        self.isPresentingPlayRecordView = false
                        
                    } label: {
                        Image(systemName: "play.fill")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "forward.circle")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                    }
                    
                    Spacer()
                }
                .padding([.top], 8)
            }
            .overlay(alignment: .bottomTrailing) {
                Button {

                } label: {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
                .padding([.trailing])
            }
            
            if true {
                Button {

                } label: {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding([.horizontal], 16)
                        .padding([.vertical], 6)
                        .font(.headline)
                }
                .frame(width: 250, height: 50, alignment: .center)
                .background(.blue)
                .clipShape(Capsule(style: .circular))
                .padding([.vertical])
            }
        }

    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

struct PlayRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        PlayRecordingView(isPresentingPlayRecordView: .constant(true), totalRecordTime: .constant(10))
    }
}
