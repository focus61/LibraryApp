//
//  BookListView.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/17/25.
//

import SwiftUI

struct BookView: View {
	@ObservedObject var viewModel: LibraryViewModel
	let book: Book
	private enum BookStatus {
		case canReturn, available
		var color: Color {
			switch self {
			case .canReturn:
				.gray
			case .available:
				.green
			}
		}

		var imageName: String {
			switch self {
			case .canReturn:
				"arrowshape.right.circle.fill"
			case .available:
				"checkmark.circle.fill"
			}
		}

		init(canReturn: Bool) {
			self = canReturn ? .canReturn : .available
		}
	}

	var body: some View {
		HStack {
			VStack {
				HStack {
					Text(book.title).font(.headline)
					Spacer()
				}
				HStack {
					Text(book.author).foregroundStyle(.gray)
					Spacer()
				}
			}
			let bookStatus = BookStatus(
				canReturn: viewModel.canReturnBook(book)
			)
			Image(systemName: bookStatus.imageName)
				.resizable()
				.frame(width: 30, height: 30)
				.foregroundStyle(bookStatus.color)
		}
		.onTapGesture {
			viewModel.tapToBook(book)
		}
		.alert(item: $viewModel.selectedBook) { book in
			alert(book)
		}
	}
	func alert(_ book: Book) -> Alert {
		let canReturnBook = viewModel.canReturnBook(book)
		let text = Text(viewModel.alertInfo)
		let exitText = Text("Выход")
		var alertButton: Alert.Button?
		if canReturnBook {
			alertButton = Alert.Button.default(Text("Вернуть книгу")) {
				viewModel.tapToReturnBook(book)
				Task {
					await showSuccessBanner()
				}
			}
		} else {
			alertButton = Alert.Button.default(Text("Взять книгу")) {
				if viewModel.tapToIssueBook(book) {
					Task {
						await showSuccessBanner()
					}
				}
			}
		}
		if let alertButton {
			return Alert(title: text, primaryButton: alertButton, secondaryButton: .destructive(exitText))
		} else {
			let button = Alert.Button.cancel(exitText) {}
			return Alert(title: text, dismissButton: button)
		}
	}

	// Асинхронная функция показа баннера
	func showSuccessBanner() async {
		viewModel.showSuccessBanner = true
		try? await Task.sleep(nanoseconds: 3_000_000_000)
		viewModel.showSuccessBanner = false
	}
}

#Preview {
	BookView(viewModel: LibraryViewModel(), book: Book(title: "Название 12345", author: "Александр Петрович", isbn: "12345", status: .unavailable))
}
