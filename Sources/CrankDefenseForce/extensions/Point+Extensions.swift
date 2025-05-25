import PlaydateKit

extension Point {
	var rounded: Self {
		return Self(x: x.rounded(), y: y.rounded())
	}
	
	func distance(to other: Self) -> Float {
		let dx = other.x - x
		let dy = other.y - y
		return (dx * dx + dy * dy).squareRoot()
	}
}
