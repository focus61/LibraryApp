//
//  MyBooksView.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/19/25.
//

import SwiftUI

struct MyBooksView: View {
	@StateObject var viewModel: MyBooksViewModel
	init(viewModel: MyBooksViewModel) {
		_viewModel = StateObject(wrappedValue: viewModel)
	}

	var body: some View {
		NavigationStack {
			ZStack {
				List(viewModel.books) {
					SimpleBookView(viewModel: viewModel, book: $0)
				}
				if viewModel.showSuccessBanner {
					VStack {
						Spacer()
						SuccessBanner(message: "Успешно!")
							.transition(.move(edge: .top).combined(with: .opacity))
							.padding(.bottom, 10)
					}
					.zIndex(1)
				}
			}
			.navigationTitle("Мои книги")
			.navigationBarTitleDisplayMode(.large)
		}
	}
}

struct SimpleBookView: View {
	@ObservedObject var viewModel: MyBooksViewModel
	let book: Book
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
			Image(systemName: "arrowshape.right.circle.fill")
				.resizable()
				.frame(width: 30, height: 30)
				.foregroundStyle(.gray)
		}
		.onTapGesture {
			viewModel.tapToBook(book)
		}
		.alert(item: $viewModel.selectedBook) { book in
			alert(book)
		}
	}

	func alert(_ book: Book) -> Alert {
		let alertButton = Alert.Button.default(Text("Вернуть книгу")) {
			viewModel.tapToReturnBook(book)
			Task {
				await showSuccessBanner()
			}
		}
		return Alert(
			title: Text(viewModel.alertInfo),
			primaryButton: alertButton ,
			secondaryButton: .destructive(Text("Выход"))
		)
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

#Preview {
	MyBooksView(viewModel: MyBooksViewModel(client: nil))
}
