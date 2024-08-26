//
//  Float+Extensions.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

extension Float {
	public func roundToNearest(_ toNearest: Float) -> Self {
		return (self.rounded() / toNearest) * toNearest
	}
	
	public func toRadians() -> Self {
		return self * Float.pi / 180.0
	}
}
