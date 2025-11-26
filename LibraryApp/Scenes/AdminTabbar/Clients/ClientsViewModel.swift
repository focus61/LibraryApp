//
//  ClientsViewModel.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/20/25.
//

import Combine
import SwiftUI

final class ClientsViewModel: ObservableObject {
	@Published var clients: [Client] = AppContainer.shared.library.clients
	@Published var selectedClient: Client? = nil
	@Published var books: [Book] = []
	@Published var showAlert: Bool = false
	var alertInfo: String? {
		didSet {
			showAlert = alertInfo != nil
		}
	}

	func tapToClient(_ client: Client) {
		selectedClient = client
	}

	func onAppearSheet() {
		guard let selectedClient else { return }
		books = AppContainer.shared.library.issuedBooksForClientId(selectedClient.id.uuidString)
	}

	func removeClient() {
		guard let selectedClient, books.isEmpty else {
			alertInfo = "Нельзя удалить клиента, у которого есть не сданные книги."
			return showAlert = true
		}
		AppContainer.shared.library.removeClient(selectedClient)
		self.selectedClient = nil
	}
}
