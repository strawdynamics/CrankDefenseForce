extension Float {
	func roundToNearest(_ toNearest: Float) -> Self {
		return (self / toNearest).rounded() * toNearest
	}

	func toRadians() -> Self {
		return self * Float.pi / 180.0
	}

	func toDegrees() -> Self {
		return self * 180.0 / Float.pi
	}
}
