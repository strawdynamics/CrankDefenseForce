//
//  Time.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

final class Time: Sendable {
	nonisolated(unsafe) static var previousElapsedTime: Float = 0.0
	
	nonisolated(unsafe) static var _deltaTime: Float = 0.0
	
	public static var deltaTime: Float {
		return self._deltaTime
	}
	
	public static func updateDeltaTime() {
		let newElapsedTime = System.elapsedTime
		
		self._deltaTime = newElapsedTime - self.previousElapsedTime
		self.previousElapsedTime = newElapsedTime
	}
}
