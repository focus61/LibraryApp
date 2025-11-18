//
//  SuccessBanner.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/18/25.
//

import SwiftUI

struct SuccessBanner: View {
	let message: String

	var body: some View {
		HStack(spacing: 8) {
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(.white)
			Text(message)
				.foregroundColor(.white)
				.bold()
		}
		.padding(.horizontal, 20)
		.padding(.vertical, 12)
		.background(
			Capsule()
				.fill(Color(uiColor: AppColors.mainBackground.rawValue))
				.shadow(radius: 4)
		)
	}
}
