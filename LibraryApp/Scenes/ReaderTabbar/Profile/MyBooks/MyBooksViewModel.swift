//
//  MyBooksViewModel.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/19/25.
//

import Combine
import Foundation

final class MyBooksViewModel: ObservableObject {
	@Published var books: [Book] = []
	@Published var selectedBook: Book?
	@Published var showSuccessBanner = false
	var alertInfo: String {
		guard let selectedBook else { return "Ошибка" }
return """
Автор: \(selectedBook.author)
Заголовок: \(selectedBook.title)
ISBN: \(selectedBook.isbn)
"""
	}

	private let library = AppContainer.shared.library
	private let client: Client?

	init(client: Client?) {
		self.client = client
		self.books = AppContainer.shared.library.issuedBooksForClientId(client?.id.uuidString)
	}

	func tapToBook(_ book: Book) {
		selectedBook = book
	}

	func tapToReturnBook(_ book: Book) {
		library.returnBook(book)
		books = AppContainer.shared.library.issuedBooksForClientId(client?.id.uuidString)
	}

	func reloadBooks() {
		books = AppContainer.shared.library.issuedBooksForClientId(client?.id.uuidString)
	}
}
