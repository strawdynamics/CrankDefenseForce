import PlaydateKit

protocol Lerpable {
	func lerp(toward: Self, percent: Float) -> Self
}

extension Float: Lerpable {
	func lerp(toward: Float, percent: Float) -> Float {
		self + (toward - self) * percent
	}
}

extension Point: Lerpable {
	func lerp(toward: Point, percent: Float) -> Point {
		Point(
			x: x.lerp(toward: toward.x, percent: percent),
			y: y.lerp(toward: toward.y, percent: percent)
		)
	}
}
