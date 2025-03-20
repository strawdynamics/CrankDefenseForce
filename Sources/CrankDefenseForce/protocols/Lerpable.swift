import PlaydateKit

protocol Lerpable {
	static func lerp(from: Self, to: Self, percent: Float) -> Self
}

extension Float: Lerpable {
	static func lerp(from: Float, to: Float, percent: Float) -> Float {
		from + (to - from) * percent
	}
}

extension Point: Lerpable {
	static func lerp(from: Point, to: Point, percent: Float) -> Point {
		Point(
			x: Float.lerp(from: from.x, to: to.x, percent: percent),
			y: Float.lerp(from: from.y, to: to.y, percent: percent)
		)
	}
}
