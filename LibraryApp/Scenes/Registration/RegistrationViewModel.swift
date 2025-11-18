//
//  RegistrationViewModel.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/16/25.
//

import Combine
import SwiftUI

final class RegistrationViewModel: ObservableObject {

	@Published var email: String = ""
	@Published var fullName: String = ""
	@Published var city: String = ""
	@Published var password: String = ""
	@Published var alertMessage: AlertMessage?
	@AppStorage(AppConstants.storageName) private var loggedUser: String?

	func registrationTapped() {
		let library: Library = AppContainer.shared.library
		let clients = library.clients
		let email = email.lowercased()
		guard !clients.contains(where: { $0.email == email }) else {
			return alertMessage = AlertMessage(message: "Пользователь зарегистрирован")
		}
		if password.count < 6 {
			return alertMessage = AlertMessage(message: "Пароль должен состоять минимум из 6 символов")
		}

		let client = Client(fio: fullName, email: email, password: password, city: city)
		library.addClient(client)
		AppContainer.shared.fileManager.save(archive: library.archive, clients: library.clients)
		loggedUser = client.id.uuidString
	}
}
