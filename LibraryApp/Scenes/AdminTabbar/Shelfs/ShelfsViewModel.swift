//
//  ShelfsViewModel.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/21/25.
//

import Combine
import SwiftUI

final class ShelfsViewModel: ObservableObject {
	@Published var shelves: [Shelf] = []
	@Published var selectedShelf: Shelf?
	@Published var selectedBook: Book?
	@Published var showAddBookSheet = false
	@Published var needShowSuccessBanner = false
	@Published var needShowErrorISBNAlert = false

	@Published var title = ""
	@Published var author = ""
	@Published var isbn = ""

	var alertInfo: String {
		guard let selectedBook else {
			return "Ошибка"
		}
		var additionalInfo: String?
		if let client = AppContainer.shared.library.clientForBook(selectedBook) {
			additionalInfo = "\nКнига у: \(client.fio)"
		}
		return """
Автор: \(selectedBook.author)
Заголовок: \(selectedBook.title)
ISBN: \(selectedBook.isbn)
""" + (additionalInfo ?? "")
	}

	init() {
		shelves = AppContainer.shared.library.archive.shelves
	}

	func booksArray(for shelf: Shelf) -> [Book] {
		AppContainer.shared.library.booksArray(for: shelf)
	}

	func tapToAddShelf() {
		Task {
			await showSuccessBanner()
		}
		let newShelf = AppContainer.shared.library.checkFreeShelf()
		AppContainer.shared.library.addShelf(newShelf)
		updateShelves()
	}

	func tapToRemoveShelf(_ shelf: Shelf) {
		Task {
			await showSuccessBanner()
		}
		AppContainer.shared.library.removeShelf(shelf)
		updateShelves()
	}

	/// Показываем алерт о книге
	func tapToBook(_ book: Book) {
		selectedBook = book
	}

	/// Нажатие на "Добавить книгу"
	func tapToAddBook(_ shelf: Shelf) {
		selectedShelf = shelf
		showAddBookSheet = true
	}

	/// Нажатие на "Подтвердить" в сценарии добавления книги
	func tapToConfirmAddBook() {
		guard !AppContainer.shared.library.containsBook(with: isbn) else {
			return needShowErrorISBNAlert = true
		}

		guard let selectedShelf else { return }
		Task {
			await showSuccessBanner()
		}
		let book = Book(title: title, author: author, isbn: isbn, status: .archive)
		AppContainer.shared.library.addBook(book, to: selectedShelf.type)
		showAddBookSheet = false
		title = ""
		author = ""
		isbn = ""
		updateShelves()
	}

	func tapToRemoveBook(_ book: Book) {
		Task {
			await showSuccessBanner()
		}
		AppContainer.shared.library.removeBook(book)
		updateShelves()
	}

	// Асинхронная функция показа баннера
	private func showSuccessBanner() async {
		needShowSuccessBanner = true
		try? await Task.sleep(nanoseconds: 3_000_000_000)
		needShowSuccessBanner = false
	}

	private func updateShelves() {
		shelves = AppContainer.shared.library.archive.shelves
	}
}
