//
//  AuthorizationView.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/14/25.
//

import SwiftUI

struct AuthorizationView: View {
	@StateObject private var viewModel = AuthorizationViewModel()

	var emailField: some View {
		TextField(text: $viewModel.email) {
			Text("Введите email").foregroundStyle(.gray)
		}.foregroundStyle(.gray)
	}

	var passwordField: some View {
		SecureField(text: $viewModel.password) {
			Text("Введите пароль").foregroundStyle(Color.gray)
		}.foregroundStyle(.gray)
	}

	var image: some View {
		Image("Books").resizable().scaledToFit()
	}

	var body: some View {
		NavigationStack {
			ZStack {
				Color(uiColor: AppColors.mainBackground.rawValue).ignoresSafeArea()
				VStack {
					Spacer()
					image
					VStack {
						buildField(textField: emailField, imageName: "envelope").padding(.top, 15)
						buildField(textField: passwordField, imageName: "lock").padding(.top, 15)
					}
					HStack {
						Spacer()
						Button {
							// TODO: - Сценарий "забыли пароль"
						} label: {
							Text("Забыли пароль?")
						}.padding(.horizontal)
					}.padding(.top, 10)
					Spacer()
					Button {
						viewModel.login()
					} label: {
						Text("Вход")
							.foregroundColor(.white)
							.padding()
							.frame(maxWidth: .infinity)
							.background(
								RoundedRectangle(cornerRadius: 12)
									.fill(Color.blue)
							)
					}
					.padding()
					.disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
					.opacity(viewModel.email.isEmpty || viewModel.password.isEmpty ? 0.5 : 1)
					NavigationLink {
						RegistrationView()
					} label: {
						Text("Регистрация")
					}
				}
			}
			.alert(item: $viewModel.alertMessage) { error in
				Alert(title: Text("Ошибка"), message: Text(error.message), dismissButton: .default(Text("ОК")))
			}
		}
	}

	private func buildField(textField: some View, imageName: String) -> some View {
		VStack {
			HStack {
				textField
				Image(systemName: imageName).foregroundStyle(Color.gray)
			}
			Divider().background(Color.white)
		}.padding(.horizontal)
	}
}

#Preview {
	AuthorizationView()
}
