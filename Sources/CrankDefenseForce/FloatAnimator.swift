class FloatAnimator {
	var duration: Float
	
	var startValue: Float
	
	var endValue: Float
	
	var easingFn: EasingFn
	
	var currentTime: Float = 0
	
	public private(set) var currentValue: Float = 0
	
	public private(set) var ended: Bool = false
	
	public private(set) var loop: Bool
	
	public var currentPercent: Float {
		return currentTime / duration
	}
	
	struct Config {
		var duration: Float
		var startValue: Float
		var endValue: Float
		var easingFn: EasingFn
		var loop: Bool = false
	}
	
	init(_ config: Config) {
		self.duration = config.duration
		self.startValue = config.startValue
		self.endValue = config.endValue
		self.easingFn = config.easingFn
		self.loop = config.loop
	}
	
	func update() {
		if ended {
			return
		}
		
		currentTime += Time.deltaTime
		
		if currentTime >= duration {
			if loop {
				currentTime = currentTime.truncatingRemainder(dividingBy: duration)
			} else {
				ended = true
			}
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
