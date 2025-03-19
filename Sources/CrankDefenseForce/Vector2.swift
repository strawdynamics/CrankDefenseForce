import PlaydateKit

struct Vector2 {
	var x: Float
	var y: Float
	
	func normalized() -> Vector2 {
		let length = sqrtf(x * x + y * y)
		return length == 0 ? Vector2(x: 0, y: 0) : Vector2(x: x / length, y: y / length)
	}
	
	func angle(with vector: Vector2) -> Float {
		let dot = x * vector.x + y * vector.y
		let cross = x * vector.y - y * vector.x
		return atan2f(cross, dot)
	}
}
