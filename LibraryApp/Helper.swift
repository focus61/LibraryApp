//
//  Helper.swift
//  LibraryApp
//
//  Created by Aleksandr on 11/17/25.
//

import UIKit

class Helper {
	static func getColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) -> UIColor {
		UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
	}
}
