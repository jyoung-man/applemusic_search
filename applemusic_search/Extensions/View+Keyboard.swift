//
//  View+Keyboard.swift
//  applemusic_search
//
//  Created by 박재영 on 12/28/25.
//

import SwiftUI

extension View {
    /// 키보드를 숨기는 헬퍼 메서드
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    /// 탭 제스처로 키보드를 숨기는 modifier
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
    
    /// 스크롤 시 키보드를 숨기는 modifier
    func dismissKeyboardOnScroll() -> some View {
        self.gesture(
            DragGesture()
                .onChanged { _ in
                    hideKeyboard()
                }
        )
    }
}
