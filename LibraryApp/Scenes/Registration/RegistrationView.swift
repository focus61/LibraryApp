//
//  RegistrationView.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/14/25.
//

import SwiftUI

struct RegistrationView: View {

	@StateObject private var viewModel = RegistrationViewModel()
	@StateObject private var keyboard = KeyboardObserver()
	@FocusState private var focusedField: Field?

	enum Field {
		case email, city, fullName, password
	}

	var body: some View {
		ZStack {
			Color(uiColor: AppColors.mainBackground.rawValue)
				.ignoresSafeArea()
			ScrollViewReader { proxy in
				ScrollView {
					VStack(spacing: 20) {
						Spacer(minLength: 40)
						Image("Books")
							.resizable()
							.scaledToFit()
							.frame(maxHeight: 250)

						fields
						Spacer(minLength: 40)
					}
					.padding(.bottom, keyboard.height)
					.onChange(of: focusedField) { _, newValue in
						if let field = newValue {
							Task {
								try? await Task.sleep(nanoseconds: 10_000_000)
								withAnimation(.easeInOut) {
									proxy.scrollTo(field, anchor: .center)
								}
							}
						}
					}
				}
			}
			VStack {
				Spacer()
				Button {
					viewModel.registrationTapped()
				} label: {
					
					Text("Зарегистрироваться")
						.foregroundColor(.white)
						.padding()
						.frame(maxWidth: .infinity)
						.background(RoundedRectangle(cornerRadius: 12).fill(.blue))
						.padding(.horizontal)
				}
				.padding(.bottom, 20)
			}
		}
		.ignoresSafeArea(.keyboard, edges: .bottom)
		.navigationTitle("Регистрация")
		.alert(item: $viewModel.alertMessage) { error in
			Alert(title: Text("Ошибка"), message: Text(error.message), dismissButton: .default(Text("ОК")))
		}
	}


	// MARK: Поля

	private var fields: some View {
		VStack(spacing: 20) {
			buildField(textField: emailField, imageName: "envelope")
				.id(Field.email)
				.focused($focusedField, equals: .email)

			buildField(textField: cityField, imageName: "building")
				.id(Field.city)
				.focused($focusedField, equals: .city)

			buildField(textField: fullNameField, imageName: "person")
				.id(Field.fullName)
				.focused($focusedField, equals: .fullName)

			buildField(textField: passwordField, imageName: "lock")
				.id(Field.password)
				.focused($focusedField, equals: .password)
		}
		.padding(.top, 20)
	}

	private var emailField: some View {
		TextField(text: $viewModel.email) {
			Text("Введите email").foregroundStyle(.gray)
		}.keyboardType(.emailAddress).foregroundStyle(.gray)
	}

	private var fullNameField: some View {
		TextField(text: $viewModel.fullName) {
			Text("Введите ваше ФИО").foregroundStyle(.gray)
		}.foregroundStyle(.gray)
	}

	private var cityField: some View {
		TextField(text: $viewModel.city) {
			Text("Город обслуживания").foregroundStyle(.gray)
		}.foregroundStyle(.gray)
	}

	private var passwordField: some View {
		TextField(text: $viewModel.password) {
			Text("Введите пароль").foregroundStyle(.gray)
		}.keyboardType(.asciiCapable).foregroundStyle(.gray)
	}


	private func buildField(textField: some View, imageName: String) -> some View {
		VStack {
			HStack {
				textField
				Image(systemName: imageName)
					.foregroundStyle(.gray)
			}
			Divider().background(.gray)
		}
		.padding(.horizontal)
	}
}

#Preview {
    RegistrationView()
}
