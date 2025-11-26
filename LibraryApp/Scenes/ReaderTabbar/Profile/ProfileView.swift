//
//  ProfileView.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/17/25.
//

import SwiftUI

struct ProfileView: View {
	@StateObject var viewModel = ProfileViewModel()
	private var client: Client? { viewModel.client }
	var body: some View {
		ZStack {
			NavigationStack {
				VStack {
					Spacer(minLength: 15)
					List {
						Section {
							InfoView(viewModel: viewModel)
						}
						.listRowInsets(EdgeInsets())
						.listRowBackground(Color.clear)
						Section {
							HStack {
								Image(systemName: "repeat.1").foregroundStyle(.blue)
								Button {
									viewModel.randomBookTapped()
								} label: {
									Text("Случайная книга")
								}
							}
							HStack {
								Image(systemName: "square.and.arrow.up").foregroundStyle(.blue)
								Button {
									viewModel.uploadTapped()
								} label: {
									Text("Выгрузить БД")
								}
							}
						}
						Section {
							HStack {
								Image(systemName: "person.crop.circle.badge.clock.fill")

								NavigationLink {
									let viewModel =  EditProfileViewModel(client: client) {
										self.viewModel.reloadClient()
									}
									EditProfileView(viewModel: viewModel)
								} label: {
									Text("Редактировать данные")
								}
							}
							HStack {
								Image(systemName: "books.vertical.circle.fill")
								NavigationLink {
									MyBooksView(viewModel: MyBooksViewModel(client: client))
								} label: {
									Text("Мои книги")
								}
							}
						}
						Section {
							Button {
								viewModel.logoutTapped()
							} label: {
								Text("Выход").foregroundStyle(.red)
							}
						}
					}
				}
				.navigationTitle("Профиль")
				.navigationBarTitleDisplayMode(.large)
				.sheet(isPresented: $viewModel.showShare) {
					ShareSheet(items: [AppContainer.shared.fileManager.getFileURL()])
				}
				.alert(item: $viewModel.randomBook) { book in
					alert(book)
				}
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
	}

	func alert(_ book: Book) -> Alert {
		let alertButton = Alert.Button.default(Text("Взять книгу")) {
			if viewModel.tapToIssueBook(book) {
				Task {
					await showSuccessBanner()
				}
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
	ProfileView()
}

struct ShareSheet: UIViewControllerRepresentable {
	let items: [Any] // файлы, ссылки, текст

	func makeUIViewController(context: Context) -> UIActivityViewController {
		let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
		return controller
	}

	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct InfoView: View {
	@StateObject var viewModel: ProfileViewModel
	private var client: Client? { viewModel.client }

	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 20)
				.foregroundStyle(Color(uiColor: UIColor.secondarySystemGroupedBackground))
			HStack {
				Image(systemName: "person.crop.circle")
					.resizable()
					.frame(width: 50, height: 50)
					.padding(.leading)
					.foregroundStyle(Color(uiColor: .lightGray))
				VStack {
					HStack {
						Text(client?.fio ?? "Афонин Александр Романович").font(.title3)
						Spacer()
					}
					HStack {
						Text(client?.city ?? "Санкт-Петербург").font(.default).foregroundStyle(Color(uiColor: .lightGray))
						Spacer()
					}
				}.padding(.horizontal, 10)
				Spacer()
			}
		}
		.frame(height: 90)
	}
}
