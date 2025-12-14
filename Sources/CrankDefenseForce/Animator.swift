class Animator<T: Lerpable> {
	var duration: Float

	var startValue: T

	var endValue: T

	var easingFn: EasingFn

	var currentTime: Float = 0

	public private(set) var currentValue: T

	public private(set) var ended: Bool = false

	public private(set) var loopMode: LoopMode

	public var currentPercent: Float {
		return currentTime / duration
	}

	enum LoopMode {
		case none
		case loop
		case pingPong
	}

	struct Config {
		var duration: Float
		var startValue: T
		var endValue: T
		var easingFn: EasingFn
		var loopMode: LoopMode = .none
	}

	init(_ config: Config) {
		duration = config.duration
		startValue = config.startValue
		currentValue = config.startValue
		endValue = config.endValue
		easingFn = config.easingFn
		loopMode = config.loopMode
	}

	func update() {
		if ended {
			return
		}

		currentTime += Time.deltaTime

		if currentTime >= duration {
			switch loopMode {
			case .none:
				ended = true
			case .loop:
				currentTime = currentTime.truncatingRemainder(dividingBy: duration)
			case .pingPong:
				currentTime = currentTime.truncatingRemainder(dividingBy: duration)
				swap(&startValue, &endValue)
			}
		}

		if ended {
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
		let easedPercent = easingFn.ease(currentTime, 0, 1, duration)
		currentValue = T.lerp(from: startValue, to: endValue, percent: easedPercent)
	}
}
