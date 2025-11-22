//
//  Model.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/15/25.
//

import Foundation

// MARK: - 1. Классы сущности
class Client: Identifiable {
	enum Data {
		case email, city, fio, password
	}
	var fio: String
	let id: UUID
	var email: String
	var password: String
	var city: String
	init(fio: String, email: String, password: String, city: String, id: UUID? = UUID()) {
		self.fio = fio
		self.id = id ?? UUID()
		self.email = email
		self.password = password
		self.city = city
	}

	fileprivate func change(_ data: Client.Data, text: String) {
		switch data {
		case .email:
			email = text
		case .fio:
			fio = text
		case .password:
			password = text
		case .city:
			city = text
		}
	}
}

class Shelf: Identifiable {
	var books: [String: Book]
	let type: ShelfType
	var id: String {
		type.capitalized
	}
	init(type: ShelfType, books: [String: Book] = [:]) {
		self.books = books
		self.type = type
	}

	fileprivate func addBook(_ book: Book) {
		books[book.isbn] = book
	}

	fileprivate func removeBook(_ book: Book) {
		books[book.isbn] = nil
	}

	fileprivate func changeStatus(for book: Book, status: Book.Status) {
		books[book.isbn]?.status = status
	}

	/// ✅
	fileprivate func booksArray() -> [Book] {
		books.map { $0.value }
	}

	// MARK: СТРАТЕГИЯ
	/// Паттерн стратегия, тк идет разделение на типы поиска, но с использованием enum, а не отдельных объектов
	/// Позволяет легко добавлять новые критерии поиска и разделяет алгоритмы поиска от основной логики архива
	/// ✅
	fileprivate func search(by type: SearchType, value: String) -> [String: Book] {
		books.filter { dict in
			switch type {
			case .author:
				return dict.value.author.lowercased().contains(value.lowercased())
			case .title:
				return dict.value.title.lowercased().contains(value.lowercased())
			}
		}
	}

	enum ShelfType: String, CaseIterable, Identifiable, Comparable {
		static func < (lhs: Shelf.ShelfType, rhs: Shelf.ShelfType) -> Bool {
			lhs.rawValue < rhs.rawValue
		}

		case a, b, c, d, e, f, g, h, i, j, k, l
		var capitalized: String {
			rawValue.capitalized
		}
		var id: Self { self }
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

	fileprivate func changeStatus(to status: Status) {
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
	fileprivate func shelf(for searchBook: Book) -> Shelf? {
		for shelf in shelves {
			if shelf.books[searchBook.isbn] != nil {
				return shelf
			}
		}
		return nil
	}

	/// ✅
	fileprivate func shelf(for type: Shelf.ShelfType) -> Shelf {
		return shelves.first(where: { $0.type == type }) ?? Shelf(type: .a)
	}

	/// Создать полку
	fileprivate func addShelf(_ shelf: Shelf) {
		shelves.append(shelf)
		shelves = shelves.sorted { left, right in
			left.type.id < right.type.id
		}
	}

	/// Удалить полку
	fileprivate func removeShelf(_ shelf: Shelf) {
		guard let index = shelves.firstIndex(where: { $0.type == shelf.type }) else {
			return
		}
		shelves.remove(at: index)
	}

	/// Добавить книгу на полку(впервые) ✅
	fileprivate func addBook(_ book: Book, to shelf: Shelf) {
		shelf.addBook(book)
	}

	/// Удалить книгу с полки(читать как удалить с БД) ✅
	fileprivate func removeBook(_ book: Book, from shelf: Shelf) {
		shelf.removeBook(book)
	}

	/// Выдать книгу библиотекарю, если она доступна ✅
	fileprivate func issueBook(_ searchBook: Book, for client: Client) -> Bool {
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
	fileprivate func returnBook(_ book: Book) {
		guard let shelf = shelf(for: book) else { return }
		shelf.changeStatus(for: book, status: .archive)
		issuedBooks[book.isbn] = nil
	}

	/// ✅
	fileprivate func clientForBook(_ book: Book) -> Client? {
		issuedBooks[book.isbn]
	}

	/// ✅
	fileprivate func search(by type: SearchType, value: String) -> [String: Book] {
		var result: [String: Book] = [:]
		for shelf in shelves {
			let books = shelf.search(by: type, value: value)
			for (isbn, book) in books {
				result[isbn] = book
			}
		}
		return result
	}

	/// ✅
	fileprivate func allBooks() -> [Book] {
		var books: [Book] = []
		for shelf in shelves {
			for (_, book) in shelf.books {
				books.append(book)
			}
		}
		return books
	}

	/// ✅
	fileprivate func randomBook() -> Book? {
		var index = 0
		let all = allBooks()
		while (index < all.count - 1) {
			let book = all.randomElement()
			if book?.status == .archive {
				return book
			}
			index += 1
		}
		return nil
	}

	/// ✅
	fileprivate func issuedBooksForClient(_ client: Client) -> [Book] {
		var result = [Book]()
		for (isbn, value) in issuedBooks where value.id == client.id {
			for shelf in shelves {
				if let book = shelf.books[isbn] {
					result.append(book)
				}
			}
		}
		return result
	}

	fileprivate func containsBook(with isbn: String) -> Bool {
		shelves.contains(where: { $0.books[isbn] != nil})
	}
}

class Library {
	let archive: Archive
	private(set) var clients: [Client]
	init(archive: Archive, clients: [Client]) {
		self.archive = archive
		self.clients = clients
	}
}

/// Функционал для клиента
extension Library {

	/// Добавить клиента ✅
	func addClient(_ client: Client) {
		clients.append(client)
		AppContainer.shared.fileManager.save(self)
	}

	/// Удалить клиента ✅
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

	/// Поиск книг по введенному значению✅
	func searchBook(by type: SearchType, value: String) -> [Book] {
		archive.search(by: type, value: value).reduce(into: []) { $0.append($1.value) }
	}

	/// Найти пользователя книги ✅
	func clientForBook(_ book: Book) -> Client? {
		archive.clientForBook(book)
	}

	/// Получить клиента по id✅
	func getClient(by id: String?) -> Client? {
		clients.first(where: { $0.id == UUID(uuidString: String(id ?? "")) })
	}

	/// Получить случайную книгу✅
	func randomBook() -> Book? {
		archive.randomBook()
	}

	/// Получить список книг привязанных к клиенту✅
	func issuedBooksForClientId(_ clientId: String?) -> [Book] {
		guard
			let clientId,
			let client = getClient(by: clientId) else { return [] }
		return archive.issuedBooksForClient(client)
	}

	/// Изменить инфо о клиенте✅
	func changeClientInfo(_ client: Client?, changedData: Client.Data, text: String) {
		guard let client else { return }
		clients.first(where: { $0.id == client.id })?.change(changedData, text: text)
		for (_, value) in archive.issuedBooks where value.id == client.id {
			value.change(changedData, text: text)
		}
		AppContainer.shared.fileManager.save(self)
	}

	/// Получить свободную полку, которой нет в массиве shelves
	func checkFreeShelf() -> Shelf {
		// a b c d ... l (allCases)
		// a c d e (shelves)
		// должен вернуть b
		let type = Shelf.ShelfType.allCases.first { shelfType in
			!archive.shelves.contains { $0.type == shelfType }
		} ?? .a
		return Shelf(type: type)
	}

	/// Есть ли в базе книга с введенным isbn
	func containsBook(with isbn: String) -> Bool {
		archive.containsBook(with: isbn)
	}

	/// Получение всех книг
	func allBooks() -> [Book] {
		archive.allBooks()
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

	/// Добавление книги в бд ✅
	func addBook(_ book: Book, to shelfType: Shelf.ShelfType) {
		let shelf = archive.shelf(for: shelfType)
		archive.addBook(book, to: shelf)
		AppContainer.shared.fileManager.save(self)
	}

	/// Удаление книги из бд ✅
	func removeBook(_ book: Book) {
		guard let shelf = archive.shelf(for: book) else { return }
		archive.removeBook(book, from: shelf)
		AppContainer.shared.fileManager.save(self)
	}

	/// Получение списка книг содержащихся на полке
	func booksArray(for shelf: Shelf) -> [Book] {
		shelf.booksArray()
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
