import PlaydateKit

final class Time: Sendable {
	nonisolated(unsafe) static var previousElapsedTime: Float = System.elapsedTime
	
	nonisolated(unsafe) static var _deltaTime: Float = 0.0
	
	static var deltaTime: Float {
		return self._deltaTime
	}
	
	static func updateDeltaTime() {
		let newElapsedTime = System.elapsedTime

		self._deltaTime = newElapsedTime - self.previousElapsedTime
		self.previousElapsedTime = newElapsedTime
	}
}
