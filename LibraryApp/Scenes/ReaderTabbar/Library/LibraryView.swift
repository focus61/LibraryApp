//
//  LibraryView.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/17/25.
//

import SwiftUI

struct LibraryView: View {
	@StateObject private var viewModel = LibraryViewModel()

	var picker: some View {
		HStack {
			Text("Тип поиска").font(.headline).padding(.horizontal)
			Spacer()
			Picker("Тип поиска", selection: $viewModel.selectedType) {
				ForEach(SearchType.allCases) { type in
					Text(type.rawValue)
				}
			}
			.pickerStyle(.segmented)
			.padding(.vertical, 8)
			.padding(.horizontal)
			Spacer()
		}
	}

	var body: some View {
		NavigationStack {
			ZStack {
				Color(uiColor: AppColors.mainBackground.rawValue).ignoresSafeArea()
				VStack {
					SearchBarUIKit(text: $viewModel.query)
						.padding(.horizontal, 8)
						.onChange(of: viewModel.query) {
							viewModel.resetAndLoad()
						}

					picker
						.onChange(of: viewModel.selectedType) {
							viewModel.resetAndLoad()
						}
					ZStack {
						List {
							ForEach(viewModel.loadedBooks) { book in
								BookView(viewModel: viewModel, book: book)
									.onAppear {
										if book.isbn == viewModel.loadedBooks.last?.isbn {
											viewModel.loadMore()
										}
									}
							}
							if viewModel.loadedBooks.count < viewModel.filteredBooks.count {
								HStack {
									Spacer()
									ProgressView()
									Spacer()
								}
								.listRowSeparator(.hidden)
							}
						}
						if viewModel.loadedBooks.isEmpty {
							Text("Ничего не найдено")
						}
					}
				}

				// Баннер
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
			.animation(.easeInOut, value: viewModel.showSuccessBanner)
			.navigationTitle("Библиотека")
			.navigationBarTitleDisplayMode(.large)
			.onAppear {
				viewModel.resetAndLoad()
			}
		}
	}
}

struct SearchBarUIKit: UIViewRepresentable {
	@Binding var text: String
	var placeholder: String = "Поиск"

	class Coordinator: NSObject, UISearchBarDelegate {
		@Binding var text: String

		init(text: Binding<String>) {
			_text = text
		}

		func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
			text = searchText
		}

		func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
			searchBar.setShowsCancelButton(true, animated: true)
		}

		func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
			searchBar.endEditing(true)
		}

		func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
			searchBar.resignFirstResponder()
			searchBar.text = ""
			text = ""
			searchBar.setShowsCancelButton(false, animated: true)
		}
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(text: $text)
	}

	func makeUIView(context: Context) -> UISearchBar {
		let searchBar = UISearchBar(frame: .zero)
		searchBar.delegate = context.coordinator
		searchBar.placeholder = placeholder
		searchBar.autocapitalizationType = .none
		searchBar.backgroundColor = .clear
		searchBar.barTintColor = AppColors.mainBackground.rawValue

		if let textField = searchBar.value(forKey: "searchField") as? UITextField {
			textField.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)   // ← Фон поля
			textField.layer.cornerRadius = 10
			textField.layer.masksToBounds = true
			textField.clearButtonMode = .never
			textField.textColor = .label
			textField.tintColor = .white

			// placeholder цвет
			textField.attributedPlaceholder = NSAttributedString(
				string: placeholder,
				attributes: [.foregroundColor: UIColor.placeholderText]
			)
			if let iconView = textField.leftView as? UIImageView {
				iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
				iconView.tintColor = .white
			}
		}
		return searchBar
	}

	func updateUIView(_ uiView: UISearchBar, context: Context) {
		uiView.text = text
	}
}


#Preview {
	LibraryView()
}
