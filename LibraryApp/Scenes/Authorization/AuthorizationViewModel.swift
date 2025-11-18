//
//  AuthorizationViewModel.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/16/25.
//

import Combine
import SwiftUI

final class AuthorizationViewModel: ObservableObject {
	@Published var email: String = ""
	@Published var password: String = ""
	@Published var alertMessage: AlertMessage?

	@AppStorage(AppConstants.storageName) private var loggedUser: String?
	private var isAdmin: Bool {
		email == "admin"
	}
	private lazy var clients: [Client] = AppContainer.shared.library.clients

	func loginTapped() {
		guard !isAdmin else {
			return loggedUser = Auth.admin.rawValue
		}

		guard let client = clients.first(where: { $0.email == email }) else {
			return alertMessage = AlertMessage(message: "Пользователь не зарегистрирован")
		}
		guard client.password == password else {
			return alertMessage = AlertMessage(message: "Пароль неверный")
		}
		alertMessage = nil
		loggedUser = client.id.uuidString
	}
}

struct AlertMessage: Identifiable {
	let id = UUID()
	let message: String
}
