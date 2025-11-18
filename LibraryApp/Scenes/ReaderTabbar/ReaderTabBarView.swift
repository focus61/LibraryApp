//
//  ReaderTabBarView.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/16/25.
//

import SwiftUI


struct ReaderTabBarView: View {

	var body: some View {
		TabView {
			Tab("Библиотека", systemImage: "books.vertical") {
				ZStack {
					Color(uiColor: AppColors.mainBackground.rawValue).ignoresSafeArea()
					LibraryView()
				}
			}
			Tab("Профиль", systemImage: "person.crop.circle.fill") {
				ZStack {
					Color(uiColor: AppColors.mainBackground.rawValue).ignoresSafeArea()
					ProfileView()
				}
			}
		}
	}
}

#Preview {
	ReaderTabBarView()
}
