//
//  ShelfView.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/21/25.
//

import SwiftUI

struct ShelfView: View {
	@StateObject var viewModel: ShelfsViewModel = ShelfsViewModel()

	var body: some View {
		NavigationStack {
			ZStack {
				VStack {
					List {
						ForEach(viewModel.shelves) { shelf in
							let books = viewModel.booksArray(for: shelf)
							Section {
								if !books.isEmpty {
									ForEach(books) { book in
										ShelfBookView(
											viewModel: viewModel,
											book: book
										)
									}
								}
								Button {
									viewModel.tapToAddBook(shelf)
								} label: {
									HStack {
										Text("Добавить книгу")
										Spacer()
										Image(systemName: "plus")
									}
								}
							} header: {
								HStack {
									Text("Полка: " + shelf.id)
									Spacer()
									if books.isEmpty {
										Button {
											viewModel.tapToRemoveShelf(shelf)
										} label: {
											Image(systemName: "trash").foregroundStyle(.red)
										}
									}
								}
							}
						}
					}
				}
				if viewModel.shelves.count < Shelf.ShelfType.allCases.count {
					VStack {
						Spacer()
						Button {
							viewModel.tapToAddShelf()
						} label: {
							Text("Добавить полку")
								.font(.callout)
								.padding(.horizontal, 25)
								.padding(.vertical, 12)
								.background(
									RoundedRectangle(cornerRadius: 20)
										.fill(Color.blue)
								)
								.opacity(0.9)
								.foregroundColor(.white)
						}
					}
				}
				// Баннер
				if viewModel.needShowSuccessBanner {
					VStack {
						Spacer()
						SuccessBanner(message: "Успешно!")
							.transition(.move(edge: .top).combined(with: .opacity))
							.padding(.bottom, 10)
					}
					.zIndex(1)
				}
			}
			.navigationTitle("Полки с книгами")
			.sheet(isPresented: $viewModel.showAddBookSheet) {
				AddBookView(viewModel: viewModel).presentationDragIndicator(.visible)

			}
			.alert("Данный ISBN уже добавлен", isPresented: $viewModel.needShowErrorISBNAlert) {
				Button("Понятно", role: .cancel) {}
			}
		}
	}
}

#Preview {
	ShelfView()
}

struct ShelfBookView: View {
	@ObservedObject var viewModel: ShelfsViewModel
	let book: Book
	private enum BookStatus {
		case available, unavailable
		var color: Color {
			switch self {
			case .available:
					.green
			case .unavailable:
					.red
			}
		}

		var imageName: String {
			switch self {
			case .available:
				"checkmark.circle.fill"
			case .unavailable:
				"xmark.circle.fill"
			}
		}

		init(bookStatus: Book.Status) {
			self = bookStatus == .archive ? .available : .unavailable
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
				bookStatus: book.status
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
		let button = Alert.Button.cancel(Text("Выход")) {}
		let alertInfo = Text(viewModel.alertInfo)
		guard book.status == .archive else {
			return Alert(title: alertInfo, dismissButton: button)
		}
		let deleteButton = Alert.Button.destructive(Text("Удалить книгу")) {
			viewModel.tapToRemoveBook(book)
		}
		return Alert(
			title: alertInfo,
			primaryButton: deleteButton,
			secondaryButton: button
		)
	}
}

struct AddBookView: View {

	@StateObject var viewModel: ShelfsViewModel

	enum Field {
		case title, author, isbn
	}

	var body: some View {
		NavigationStack {
			VStack {
				HStack {
					Text("Добавить книгу").font(.largeTitle).bold().padding(.leading).padding(.top, 20)
					Spacer()
				}
				Spacer()
				VStack {
					field("Введите название", value: $viewModel.title)
					field("Введите автора", value: $viewModel.author)
					field("Введите ISBN", value: $viewModel.isbn).keyboardType(.numberPad)
				}
				.padding(.vertical, 10)
				.padding(.horizontal, 10)
				Spacer()
				Button {
					viewModel.tapToConfirmAddBook()
				} label: {
					Text("Подтвердить")
						.foregroundColor(.white)
						.padding()
						.frame(maxWidth: .infinity)
						.background(RoundedRectangle(cornerRadius: 12).fill(.blue))
						.padding(.horizontal)
				}
			}
		}
	}

	private func field(_ placeholder: String, value: Binding<String>) -> some View {
		TextField("", text: value, prompt: Text(placeholder).foregroundStyle(.white))
			.padding(.vertical, 15)
			.padding(.horizontal, 5)
			.background(Color(uiColor: .systemGray4))
			.cornerRadius(10)
	}
}
