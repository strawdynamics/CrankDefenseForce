//
//  Time.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

final class Time: Sendable {
	nonisolated(unsafe) var previousElapsedTime: Float = 0.0
	
	nonisolated(unsafe) var _deltaTime: Float = 0.0
	
	public var deltaTime: Float {
		return self._deltaTime
	}
	
	public func updateDeltaTime() {
		let newElapsedTime = System.elapsedTime
		
		self._deltaTime = newElapsedTime - self.previousElapsedTime
		self.previousElapsedTime = newElapsedTime
	}
}
