struct TimedCallback {
	private var animator: Animator<Float>
	private let callback: () -> Void
	private var triggered = false

	init(duration: Float, callback: @escaping () -> Void) {
		self.animator = Animator(Animator.Config(
			duration: duration,
			startValue: 0,
			endValue: 1,
			easingFn: EasingFn.basic(Ease.linear)
		))
		self.callback = callback
	}

	mutating func update() -> Bool {
		animator.update()
		if !triggered && animator.ended {
			triggered = true
			callback()
		}
		return animator.ended
	}
}
