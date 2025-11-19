//
//  EditProfileView.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/19/25.
//

import SwiftUI

struct EditProfileView: View {
	enum Field: CaseIterable, Identifiable {
		var id: Self { self }
		case email, city, fullName, password
		var stringValue: String {
			switch self {
			case .email: "E-mail"
			case .city: "Город"
			case .fullName: "ФИО"
			case .password: "Пароль"
			}
		}

		var stringChangeValue: String {
			if self == .fullName {
				return "Изменить" +  " " + stringValue
			}
			return "Изменить" +  " " + stringValue.lowercased()

		}
	}
	@StateObject var viewModel: EditProfileViewModel
	init(viewModel: EditProfileViewModel) {
		_viewModel = StateObject(wrappedValue: viewModel)
	}

	var body: some View {
		List(Field.allCases) { field in
			Button(field.stringChangeValue) {
				viewModel.showAlert = true
				viewModel.selected = field
			}.foregroundStyle(.white)
		}
		.navigationTitle("Редактировать")
		.navigationBarTitleDisplayMode(.large)
		.textFieldAlert(
			isPresented: $viewModel.showAlert,
			TextFieldAlert(
				title: viewModel.selected.stringChangeValue,
				placeholder: viewModel.selected.stringValue
			) { text in
				viewModel.tapToConfirmChange(text)
			}
		).id(viewModel.selected)
			.alert(
				viewModel.errorAlertInfo ?? "",
				isPresented: $viewModel.showErrorAlert,
				actions: {
					Button(role: .cancel) {
						viewModel.errorAlertInfo = nil
					} label: {
						Text("Понятно")
					}
			})
	}
}

#Preview {
	EditProfileView(viewModel: EditProfileViewModel(client: nil, dataChanged: { }))
}

struct TextFieldAlert {
	var title: String
	var placeholder: String = ""
	var action: (String) -> Void
}

struct TextFieldAlertWrapper<Presenting>: View where Presenting: View {
	@Binding var isPresented: Bool
	let presenting: () -> Presenting
	var alert: TextFieldAlert

	@State private var text = ""

	var body: some View {
		presenting()
			.alert(alert.title, isPresented: $isPresented) {
				TextField(alert.placeholder, text: $text)
				Button("Подтвердить", role: .cancel) {
					alert.action(text)
					text = ""
				}
				Button("Отмена") {}
			}
	}
}

extension View {
	func textFieldAlert(
		isPresented: Binding<Bool>,
		_ alert: TextFieldAlert
	) -> some View {
		TextFieldAlertWrapper(
			isPresented: isPresented,
			presenting: { self },
			alert: alert
		)
	}
}
