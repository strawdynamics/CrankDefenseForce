//
//  Float+Extensions.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

extension Float {
	func roundToNearest(_ toNearest: Float) -> Self {
		return (self.rounded() / toNearest) * toNearest
	}
	
	func toRadians() -> Self {
		return self * Float.pi / 180.0
	}
}
