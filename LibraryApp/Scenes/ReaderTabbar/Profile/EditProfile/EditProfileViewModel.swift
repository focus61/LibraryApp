//
//  EditProfileViewModel.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/19/25.
//

import Combine
import SwiftUI

final class EditProfileViewModel: ObservableObject {

	@Published var showAlert = false
	@Published var selected: EditProfileView.Field = .fullName
	@Published var showErrorAlert = false
	var errorAlertInfo: String? {
		didSet {
			showErrorAlert = errorAlertInfo != nil
		}
	}
	private let client: Client?
	private let dataChanged: () -> Void

	init(client: Client?, dataChanged: @escaping () -> Void) {
		self.client = client
		self.dataChanged = dataChanged
	}

	func tapToConfirmChange(_ text: String) {
		var changedData: Client.Data
		var text = text
		switch selected {
		case .email:
			changedData = .email
			text = text.lowercased()
		case .city:
			changedData = .city
		case .fullName:
			changedData = .fio
		case .password:
			changedData = .password
			if text.count < 6 {
				errorAlertInfo = "Пароль должен состоять минимум из 6 символов"
				return
			}
		}
		AppContainer.shared.library.changeClientInfo(client, changedData: changedData, text: text)
		dataChanged()
	}
}
