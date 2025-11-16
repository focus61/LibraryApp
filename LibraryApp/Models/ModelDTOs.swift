//
//  ModelDTOs.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/16/25.
//

import Foundation

class LibraryDTO: Codable {
	let archive: ArchiveDTO
	let clients: [ClientDTO]

	init(archive: Archive, clients: [Client]) {
		self.archive = ArchiveDTO(shelves: archive.shelves, issuedBooks: archive.issuedBooks)
		self.clients = clients.map { ClientDTO(client: $0) }
	}
}
class ArchiveDTO: Codable {
	let shelves: [ShelfDTO]
	let issuedBooks: [String: ClientDTO]
	init(shelves: [Shelf], issuedBooks: [String: Client]) {
		self.shelves = shelves.map { ShelfDTO(books: $0.books, type: $0.type.rawValue) }
		self.issuedBooks = issuedBooks.reduce(into: [:]) { partialResult, tuple in
			partialResult[tuple.key] = ClientDTO(client: tuple.value)
		}
	}

	func toArchive() -> Archive {
		let issuedBooks = issuedBooks.reduce(into: [:]) { partialResult, tuple in
			partialResult[tuple.key] = tuple.value.toClient()
		}
		return Archive(shelves: shelves.map { $0.toShelf() }, issuedBooks: issuedBooks)
	}
}
class ShelfDTO: Codable {
	var books: [String: BookDTO]
	let type: String

	init(books: [String : Book], type: String) {
		self.books = books.reduce(into: [:], { partialResult, tuple in
			partialResult[tuple.key] = BookDTO(book: tuple.value)
		})
		self.type = type
	}
	func toShelf() -> Shelf {
		let type = Shelf.ShelfType(rawValue: type) ?? .g
		let books = books.reduce(into: [:]) { partialResult, tuple in
			partialResult[tuple.key] = tuple.value.toBook()
		}
		return Shelf(type: type, books: books)
	}
}
// DTO для сериализации Book
class BookDTO: Codable {
	let title: String
	let author: String
	let isbn: String
	let status: String

	init(book: Book) {
		self.title = book.title
		self.author = book.author
		self.isbn = book.isbn
		switch book.status {
		case .archive: self.status = "archive"
		case .unavailable: self.status = "unavailable"
		}
	}

	func toBook() -> Book {
		let bookStatus: Book.Status
		switch status {
		case "archive": bookStatus = .archive
		default: bookStatus = .unavailable
		}
		return Book(title: title, author: author, isbn: isbn, status: bookStatus)
	}
}

class ClientDTO: Codable {
	let fio: String
	let id: String
	let email: String
	let password: String
	let city: String
	init(client: Client) {
		fio = client.fio
		id = client.id.uuidString
		email = client.email
		password = client.password
		city = client.city

	}
	func toClient() -> Client {
		Client(
			fio: fio,
			email: email,
			password: password,
			city: city,
			id: UUID(uuidString: id)
		)
	}
}
