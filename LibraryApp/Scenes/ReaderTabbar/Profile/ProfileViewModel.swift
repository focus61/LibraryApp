//
//  ProfileViewModel.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/19/25.
//

import Combine
import SwiftUI

final class ProfileViewModel: ObservableObject {
	@AppStorage(AppConstants.storageName) private var logged: String?
	@Published var showShare = false
	@Published var showRandomBook = false
	@Published var randomBook: Book?
	@Published var showSuccessBanner = false
	@Published var client: Client?


	var alertInfo: String {
		guard let randomBook, let shelf = library.bookLocation(for: randomBook) else {
			return "Ошибка"
		}
		return """
Автор: \(randomBook.author)
Заголовок: \(randomBook.title)
ISBN: \(randomBook.isbn)
Книга на полке: \(shelf.type.capitalized)
"""
	}


	private let library = AppContainer.shared.library

	init() {
		loadClient()
	}

	func loadClient() {
		client = library.getClient(by: logged)
	}

	func reloadClient() {
		loadClient()
		objectWillChange.send()
	}

	func tapToIssueBook(_ book: Book) -> Bool {
		guard let client else { return false }
		return library.issueBook(book, for: client)
	}

	func randomBookTapped() {
		randomBook = library.randomBook()
		showRandomBook = true
	}

	func uploadTapped() {
		showShare = true
	}

	func logoutTapped() {
		logged = nil
	}
}
