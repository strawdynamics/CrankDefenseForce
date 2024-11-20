class FloatAnimator {
	var duration: Float
	
	var startValue: Float
	
	var endValue: Float
	
	var easingFn: EasingFn
	
	var currentTime: Float = 0
	
	public private(set) var currentValue: Float = 0
	
	public private(set) var ended: Bool = false
	
	init(
		duration: Float,
		startValue: Float,
		endValue: Float,
		easingFn: EasingFn,
	) {
		self.duration = duration
		self.startValue = startValue
		self.endValue = endValue
		self.easingFn = easingFn
	}
	
	func update() {
		if ended {
			return
		}
		
		currentTime += Time.deltaTime
		
		if currentTime >= duration {
			ended = true
		}
		
		if (ended) {
			currentValue = endValue
		} else {
			updateValue()
		}
	}
	
	func reset() {
		ended = false
		currentTime = 0
		updateValue()
	}
	
	private func updateValue() {
		currentValue = easingFn.ease(currentTime, startValue, endValue - startValue, duration)
	}
}
