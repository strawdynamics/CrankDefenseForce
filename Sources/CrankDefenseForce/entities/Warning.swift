import PlaydateKit

class Warning: BaseEntity {
	nonisolated(unsafe) static let warningBitmap = try! Graphics.Bitmap(
		path: "entities/Warning/warning")

	struct Config {
		let position: Point
		let entityStore: EntityStore
		var duration: Float = 1.8
		var inPercentage: Float = 0.2
		var outPercentage: Float = 0.2
	}

	let sprite = Sprite.Sprite()

	let duration: Float

	var lifetime: Float = 0

	var yAnimator: Animator<Float>?

	let inPercentage: Float
	let outPercentage: Float

	let position: Point

	init(_ config: Config) {
		duration = config.duration
		inPercentage = config.inPercentage
		outPercentage = config.outPercentage
		position = config.position

		yAnimator = Animator(
			Animator.Config(
				duration: duration * inPercentage,
				startValue: -20,
				endValue: 0,
				easingFn: EasingFn.basic(Ease.outBounce),
			))

		super.init(config.entityStore)

		let bitmap = Self.warningBitmap

		sprite.zIndex = 40
		sprite.image = bitmap
		sprite.moveTo(position + Point(x: 0, y: -20))
		sprite.addToDisplayList()
	}

	override func update() {
		lifetime += Time.deltaTime

		if let yAnimator = self.yAnimator {
			yAnimator.update()

			sprite.moveTo(position + Point(x: 0, y: yAnimator.currentValue))

			if yAnimator.ended {
				self.yAnimator = nil
			}
		}

		if lifetime / duration >= 1 - outPercentage && yAnimator == nil {
			yAnimator = Animator(
				Animator.Config(
					duration: duration * outPercentage,
					startValue: 0,
					endValue: -20,
					easingFn: EasingFn.overshoot(Ease.inBack),
				))
		}

		if lifetime >= duration {
			entityStore.remove(self)
		}
	}
}
