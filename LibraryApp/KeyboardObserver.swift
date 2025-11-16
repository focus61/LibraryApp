//
//  KeyboardObserver.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/15/25.
//

import SwiftUI
import Combine

final class KeyboardObserver: ObservableObject {
	@Published var height: CGFloat = 0

	init() {
		NotificationCenter.default.addObserver(
			forName: UIResponder.keyboardWillChangeFrameNotification,
			object: nil,
			queue: .main
		) { notif in
			if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
				let screenHeight = UIScreen.main.bounds.height
				let keyboardTop = frame.origin.y
				let keyboardHeight = max(0, screenHeight - keyboardTop)
				self.height = keyboardHeight
			}
		}
	}
}

