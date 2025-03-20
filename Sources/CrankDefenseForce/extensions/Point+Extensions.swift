import PlaydateKit

extension Point {
	var rounded: Self {
		return Self(x: x.rounded(), y: y.rounded())
	}
}
