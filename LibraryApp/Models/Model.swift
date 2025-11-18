//
//  Model.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/15/25.
//

import Foundation

// MARK: - 1. Классы сущности
class Client {
	let fio: String
	let id: UUID
	let email: String
	let password: String
	let city: String
	init(fio: String, email: String, password: String, city: String, id: UUID? = UUID()) {
		self.fio = fio
		self.id = id ?? UUID()
		self.email = email
		self.password = password
		self.city = city
	}
}

class Shelf {
	var books: [String: Book] 
	let type: ShelfType

	init(type: ShelfType, books: [String: Book] = [:]) {
		self.books = books
		self.type = type
	}

	func addBook(_ book: Book) {
		books[book.isbn] = book
	}

	func removeBook(_ book: Book) {
		books[book.isbn] = nil
	}

	func changeStatus(for book: Book, status: Book.Status) {
		books[book.isbn]?.status = status
	}

	// MARK: СТРАТЕГИЯ
	/// Паттерн стратегия, тк идет разделение на типы поиска, но с использованием enum, а не отдельных объектов
	/// Позволяет легко добавлять новые критерии поиска и разделяет алгоритмы поиска от основной логики архива
	/// ✅
	func search(by type: SearchType, value: String) -> [String: Book] {
		books.filter { dict in
			switch type {
			case .author:
				return dict.value.author.lowercased().contains(value.lowercased())
			case .title:
				return dict.value.title.lowercased().contains(value.lowercased())
			}
		}
	}

	enum ShelfType: String, CaseIterable {
		case a, b, c, d, e, f, g
		var capitalized: String {
			rawValue.capitalized
		}
	}
}

class Book: Identifiable {
	var id: String { isbn }
	let author: String
	let title: String
	let isbn: String
	var status: Status
	init(title: String, author: String, isbn: String, status: Status) {
		self.title = title
		self.author = author
		self.isbn = isbn
		self.status = status
	}

	func changeStatus(to status: Status) {
		self.status = status
	}

	enum Status {
		case unavailable
		case archive
	}
}

// MARK: - 2. Управляющие классы
class Archive {
	private(set) var shelves: [Shelf]
	private(set) var issuedBooks: [String: Client]
	init(shelves: [Shelf], issuedBooks: [String: Client]) {
		self.shelves = shelves
		self.issuedBooks = issuedBooks
	}

	convenience init() {
		self.init(shelves: [Shelf(type: .a, books: [:])], issuedBooks: [:])
	}

	/// Сделать запрос на книгу(местонахождение) ✅
	func shelf(for searchBook: Book) -> Shelf? {
		for shelf in shelves {
			if shelf.books[searchBook.isbn] != nil {
				return shelf
			}
		}
		return nil
	}

	/// Создать полку
	func addShelf(_ shelf: Shelf) {
		shelves.append(shelf)
	}

	/// Удалить полку
	func removeShelf(_ shelf: Shelf) {
		guard let index = shelves.firstIndex(where: { $0.type == shelf.type }) else {
			return
		}
		shelves.remove(at: index)
	}

	/// Добавить книгу на полку(впервые)
	func addBook(_ book: Book, to shelf: Shelf) {
		shelf.addBook(book)
	}

	/// Удалить книгу с полки(читать как удалить с БД)
	func removeBook(_ book: Book, from shelf: Shelf) {
		shelf.removeBook(book)
	}

	/// Выдать книгу библиотекарю, если она доступна ✅
	func issueBook(_ searchBook: Book, for client: Client) -> Bool {
		for shelf in shelves {
			if let book = shelf.books[searchBook.isbn] {
				shelf.books[searchBook.isbn]?.status = .unavailable
				issuedBooks[book.isbn] = client
				return true
			}
		}
		return false
	}

	/// Вернуть книгу на полку ✅
	func returnBook(_ book: Book) {
		guard let shelf = shelf(for: book) else { return }
		shelf.changeStatus(for: book, status: .archive)
		issuedBooks[book.isbn] = nil
	}

	/// ✅
	func clientForBook(_ book: Book) -> Client? {
		issuedBooks[book.isbn]
	}

	/// ✅
	func search(by type: SearchType, value: String) -> [String: Book] {
		var result: [String: Book] = [:]
		for shelf in shelves {
			let books = shelf.search(by: type, value: value)
			for (isbn, book) in books {
				result[isbn] = book
			}
		}
		return result
	}

	func freeShelfType() -> Shelf.ShelfType {
		var types = Shelf.ShelfType.allCases
		for shelf in shelves {
			types.removeAll(where: { $0 == shelf.type })
		}
		return types.first ?? .g
	}

	/// ✅
	func allBooks() -> [Book] {
		var books: [Book] = []
		for shelf in shelves {
			for (_, book) in shelf.books {
				books.append(book)
			}
		}
		return books
	}
}

class Library {
	let archive: Archive
	var clients: [Client]
	init(archive: Archive, clients: [Client]) {
		self.archive = archive
		self.clients = clients
	}
}

/// Функционал для клиента
extension Library {
//	- Добавить клиента
//	- Удалить клиента
//	- Дать книгу
//	- Забрать книгу
//	- Запрос местонахождения книги
//	- Поиск книг по названию
//	- Поиск книг по автору

	/// Добавить клиента ✅
	func addClient(_ client: Client) {
		clients.append(client)
		AppContainer.shared.fileManager.save(self)
	}

	/// Удалить клиента
	func removeClient(_ client: Client) {
		guard let index = clients.firstIndex(where: { $0 === client }) else {
			return
		}
		clients.remove(at: index)
		AppContainer.shared.fileManager.save(self)
	}

	/// Выдача книги клиенту ✅
	func issueBook(_ book: Book, for client: Client) -> Bool {
		defer {
			AppContainer.shared.fileManager.save(self)
		}
		return archive.issueBook(book, for: client)
	}

	/// Возврат книги ✅
	func returnBook(_ book: Book) {
		archive.returnBook(book)
		AppContainer.shared.fileManager.save(self)
	}

	/// Местонахождение книги по просьбе клиента ✅
	func bookLocation(for book: Book) -> Shelf? {
		archive.shelf(for: book)
		// Местоположение, что делать с ним?
	}

	/// ✅
	func searchBook(by type: SearchType, value: String) -> [Book] {
		archive.search(by: type, value: value).reduce(into: []) { $0.append($1.value) }
	}

	/// Найти пользователя книги ✅
	func clientForBook(_ book: Book) -> Client? {
		archive.clientForBook(book)
	}

	func getClient(by id: String?) -> Client? {
		clients.first(where: { $0.id == UUID(uuidString: String(id ?? "")) })
	}
}

/// Функционал для архива
extension Library {
//	- Создать полку
//	- Удалить полку
//	- Добавить книгу на полку в первый раз
//	- Удалить книгу с полки навсегда
//	- Взять книгу с полки в пользование
//	- Отдать книгу с полки в пользование

	/// Создать полку
	func addShelf(_ shelf: Shelf) {
		archive.addShelf(shelf)
		AppContainer.shared.fileManager.save(self)
	}

	/// Удалить полку
	func removeShelf(_ shelf: Shelf) {
		archive.removeShelf(shelf)
		AppContainer.shared.fileManager.save(self)
	}

	/// Добавление книги в бд
	func addBook(_ book: Book) {
		defer {
			AppContainer.shared.fileManager.save(self)
		}
		guard let shelf = archive.shelf(for: book) else {
			let shelfType = archive.freeShelfType()
			archive.addBook(book, to: Shelf(type: shelfType))
			return
		}
		archive.addBook(book, to: shelf)
	}

	/// Удаление книги из бд
	func removeBook(_ book: Book) {
		guard let shelf = archive.shelf(for: book) else { return }
		archive.removeBook(book, from: shelf)
		AppContainer.shared.fileManager.save(self)
	}
}

/// Критерии поиска
enum SearchType: String, CaseIterable, Identifiable {
	case author, title
	var id: Self { self }
	var rawValue: String {
		switch self {
		case .author:
			"По автору"
		case .title:
			"По названию"
		}
	}
}
