// https://stackoverflow.com/a/62044583/2690480
extension Comparable {
	func clamped(_ f: Self, _ t: Self) -> Self {
		var r = self
		if r < f { r = f }
		if r > t { r = t }
		return r
	}
}
