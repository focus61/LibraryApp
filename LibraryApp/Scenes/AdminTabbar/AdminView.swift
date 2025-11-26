//
//  AdminTabbar.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/17/25.
//

import Combine
import SwiftUI

struct AdminView: View {
	@AppStorage(AppConstants.storageName) private var logged: String?
	func logoutTapped() {
		logged = nil
	}

	var body: some View {
		NavigationStack {
			List {
				Section {
					NavigationLink("Клиенты") {
						ClientsView()
					}
					NavigationLink("Полки и книги") {
						ShelfView()
					}
				}
				Section {
					Button("Выход", role: .destructive) {
						logoutTapped()
					}
				}
			}
			.navigationTitle("Меню")
		}
	}
}
