//
//  ClientsView.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/20/25.
//

import SwiftUI

struct ClientsView: View {
	@StateObject var viewModel = ClientsViewModel()

	var body: some View {
		NavigationStack {
			List(viewModel.clients) { client in
				VStack {
					HStack {
						Text(client.fio).font(.headline)
						Spacer()
					}
					HStack {
						Text(client.city).foregroundStyle(Color(uiColor: .lightGray))
						Spacer()
					}
					HStack {
						Text(client.email).foregroundStyle(Color(uiColor: .lightGray))
						Spacer()
					}

				}
				.contentShape(Rectangle())
				.onTapGesture {
					viewModel.tapToClient(client)
				}
			}
			.sheet(item: $viewModel.selectedClient) { client in
				ClientBooksSheet(client: client, viewModel: viewModel)
			}
			.navigationTitle("Пользователи")
		}
	}

}

#Preview {
    ClientsView()
}

struct ClientBooksSheet: View {
	let client: Client
	@StateObject var viewModel: ClientsViewModel
	var body: some View {
		NavigationStack {
			List {
				Section {
					ForEach(viewModel.books) { book in
						VStack(alignment: .leading) {
							Text(book.title)
								.font(.headline)
							Text(book.author)
								.foregroundStyle(.secondary)
						}
					}
				} header: {
					Text("Книги").foregroundStyle(.white)
				}
				Section {
					Button("Удалить клиента", role: .destructive) {
						viewModel.removeClient()
					}
				}
			}
			.navigationTitle(client.fio)
			.navigationBarTitleDisplayMode(.inline)
			.onAppear {
				viewModel.onAppearSheet()
			}
			.alert(viewModel.alertInfo ?? "", isPresented: $viewModel.showAlert) {
				Button("Понятно", role: .cancel) { }
			}
		}
	}
}
