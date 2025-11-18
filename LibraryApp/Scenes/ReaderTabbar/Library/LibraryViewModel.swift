//
//  LibraryViewModel.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/17/25.
//

import Combine
import SwiftUI

final class LibraryViewModel: ObservableObject {
	@AppStorage(AppConstants.storageName) var logged: String?
	@Published var query = ""
	@Published var selectedType: SearchType = .title
	@Published var selectedBook: Book?

	@Published var showSuccessBanner = false

	var filteredBooks: [Book] {
		guard !query.isEmpty else { return allBooks }
		return library.searchBook(by: selectedType, value: query)
	}

	var alertInfo: String {
		guard let selectedBook else {
			return "Ошибка"
		}
		var statusDescription: String
		if let shelf = library.bookLocation(for: selectedBook), isArchivedBook(selectedBook) {
			statusDescription = "Книга на полке: \(shelf.type.capitalized)"
		} else {
			statusDescription = "Книга отсутсвует в архиве"
		}
		return """
Автор: \(selectedBook.author)
Заголовок: \(selectedBook.title)
ISBN: \(selectedBook.isbn)
\(statusDescription)
"""
	}

	// MARK: Infinite Scroll
	@Published var loadedBooks: [Book] = []
	private let pageSize = 20
	private var currentIndex = 0

	private let library = AppContainer.shared.library
	private var allBooks: [Book] { AppContainer.shared.library.archive.allBooks() }

	func resetAndLoad() {
		loadedBooks.removeAll()
		currentIndex = 0
		loadMore()
	}

	func loadMore() {
		let filtered = filteredBooks
		guard currentIndex < filtered.count else { return }

		let nextIndex = min(currentIndex + pageSize, filtered.count)
		let nextSlice = filtered[currentIndex..<nextIndex]

		loadedBooks.append(contentsOf: nextSlice)
		currentIndex = nextIndex
	}

	func tapToBook(_ book: Book) {
		selectedBook = book
	}

	func tapToIssueBook(_ book: Book) -> Bool {
		guard let client = AppContainer.shared.library.getClient(by: logged) else { return false }
		return library.issueBook(book, for: client)
	}

	func canReturnBook(_ book: Book) -> Bool {
		guard let logged, let client = library.clientForBook(book) else { return false }
		return client.id.uuidString == logged
	}

	func tapToReturnBook(_ book: Book) {
		library.returnBook(book)
	}

	func isArchivedBook(_ book: Book) -> Bool {
		book.status == .archive
	}
}

