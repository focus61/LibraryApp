//
//  LibraryApp.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/14/25.
//

import SwiftUI
import SwiftData
/*
 MVP
 Запуск приложения - Экран авторизации (Вход/Регистрация)

 */

@main
struct LibraryApp: App {
	@AppStorage(AppConstants.storageName) private var loggedUser: String?

	var body: some Scene {
		WindowGroup {
			Group {
				view.preferredColorScheme(.dark)
			}
		}
	}

	var view: some View {
		let authType = Auth(loggedUser)
		switch authType {
		case .admin:
			return AnyView(AdminTabbarView())
		case .reader:
			return  AnyView(ReaderTabBarView())
		case .nonAuthorized:
			return AnyView(AuthorizationView())
		}
	}
}

enum AppConstants {
	static let storageName = "loggedUser"
}

enum AppColors {
	case mainBackground
	var rawValue: UIColor {
		Helper.getColor(r: 13, g: 27, b: 42)
	}
}

final class AppContainer {
	static let shared = AppContainer()
	lazy var fileManager: FileManagerAdapter = FileManagerAdapter()
	lazy var library: Library = {
		let (archive, client) = fileManager.load()
		return Library(archive: archive ?? Archive(), clients: client)
	}() {
		didSet {
			
		}
	}
}

enum Auth: String {
	case admin, reader, nonAuthorized
	init(_ value: String?) {
		switch value {
		case .some("reader"): self = .reader
		case .some("admin"): self = .admin
		default: self = .nonAuthorized
		}
	}
}

