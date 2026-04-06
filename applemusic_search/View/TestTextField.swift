//
//  TestTextField.swift
//  applemusic_search
//
//  Created by Test on Test Date.
//

import SwiftUI

struct TestTextField: View {
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            TextField("테스트 입력", text: $text)
                .focused($isFocused)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Text("입력된 텍스트: \(text)")
            
            Button("포커스 토글") {
                isFocused.toggle()
            }
        }
        .padding()
    }
}

#Preview {
    TestTextField()
}