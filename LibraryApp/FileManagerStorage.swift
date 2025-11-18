//
//  FileManagerStorage.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/16/25.
//

import Foundation

// MARK: АДАПТЕР FileManagerAdapter
// Конкретное хранилище
class FileManagerStorage {
	private let fileURL: URL

	init(filename: String = "LibraryApp.json") {
		let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		self.fileURL = documents.appendingPathComponent(filename)

		// Создаём файл, если его нет
		createFileIfNeeded()
	}

	private func createFileIfNeeded() {
		// Если уже существует — ничего не делаем
		guard !FileManager.default.fileExists(atPath: fileURL.path) else {
			return
		}

		// Ищем DefaultData.json в бандле
		guard let defaultURL = Bundle.main.url(forResource: "DefaultData", withExtension: "json") else {
			print("⚠️ DefaultData.json не найден в Bundle.")
			return
		}

		do {
			// Копируем содержимое DefaultData.json
			let data = try Data(contentsOf: defaultURL)

			// Создаём файл в Documents
			FileManager.default.createFile(atPath: fileURL.path, contents: data)
			print("📄 LibraryApp.json создан из DefaultData.json")
		} catch {
			print("❌ Ошибка при создании LibraryApp.json: \(error)")
		}
	}


	func saveToFile(_ data: Data) throws {
		try data.write(to: fileURL)
	}

	func loadFromFile() throws -> Data {
		try Data(contentsOf: fileURL)
	}

	func removeAllData() {
		if FileManager.default.fileExists(atPath: fileURL.path) {
			do {
				try FileManager.default.removeItem(at: fileURL)
				print("Файл успешно удалён")
			} catch {
				print("Ошибка при удалении файла: \(error)")
			}
		}
	}

	func getFileURL() -> URL {
		fileURL
	}
}

class FileManagerAdapter {
	private let storage: FileManagerStorage

	init(storage: FileManagerStorage = FileManagerStorage()) {
		self.storage = storage
	}

	func load() -> (archive: Archive?, clients: [Client]) {
		var archive: Archive?
		guard let data = try? storage.loadFromFile() else {
			return (archive, [])
		}
		let decoder = JSONDecoder()
		guard let result = try? decoder.decode(LibraryDTO.self, from: data) else {
			return (archive, [])
		}

		archive = result.archive.toArchive()
		let clients = result.clients.map { $0.toClient() }
		return (archive, clients)
	}

	func save(archive: Archive, clients: [Client]) {
		let libraryDTO = LibraryDTO(archive: archive, clients: clients)
		let encoder = JSONEncoder()
		if let data = try? encoder.encode(libraryDTO) {
			try? storage.saveToFile(data)
		}
	}

	func save(_ library: Library) {
		let libraryDTO = LibraryDTO(archive: library.archive, clients: library.clients)
		let encoder = JSONEncoder()
		if let data = try? encoder.encode(libraryDTO) {
			try? storage.saveToFile(data)
		}
	}

	func removeCache() {
		storage.removeAllData()
	}

	func getFileURL() -> URL {
		storage.getFileURL()
	}
}
