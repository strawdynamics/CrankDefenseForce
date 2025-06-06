import PlaydateKit

class PowerUpCollectedText: BaseEntity {
	static nonisolated(unsafe) let dayBitmaps: [PowerUp.PowerUpType: Graphics.Bitmap] = [
		.pauseEnemies: Graphics.Bitmap(strokedText: "ASSAULT\nPAUSED", strokeWidth: 1, textColor: .fillWhite, strokeColor: .fillBlack, align: .center, font: CdfFont.NicoPups16)
	]

	static nonisolated(unsafe) let nightBitmaps: [PowerUp.PowerUpType: Graphics.Bitmap] = [
		.pauseEnemies: Graphics.Bitmap(strokedText: "ASSAULT\nPAUSED", strokeWidth: 1, textColor: .fillBlack, strokeColor: .fillWhite, align: .center, font: CdfFont.NicoPups16)
	]


	private let powerUpType: PowerUp.PowerUpType

	private let position: Point

	private let sprite = Sprite.Sprite()

	private let duration: Float

	private var alphaAnimator: Animator<Float>?

	private var yAnimator: Animator<Float>

	private var entering = true
	private var exiting = false

	private var uptime: Float = 0

	struct Config {
		let entityStore: EntityStore
		let powerUpType: PowerUp.PowerUpType
		let position: Point
		let duration: Float = 3
	}

	@discardableResult init(_ config: Config) {
		position = config.position + Point(x: 0, y: -10)
		powerUpType = config.powerUpType
		duration = config.duration

		sprite.image = GameSettings.timeOfDay == .day ? Self.dayBitmaps[powerUpType]! : Self.nightBitmaps[powerUpType]!
		sprite.zIndex = 200
		sprite.moveTo(position)
		sprite.addToDisplayList()

		yAnimator = Animator(Animator.Config(
			duration: duration,
			startValue: position.y,
			endValue: position.y - 10,
			easingFn: EasingFn.basic(Ease.outQuad)
		))

		alphaAnimator = Animator(Animator.Config(
			duration: duration * 0.1,
			startValue: 0,
			endValue: 1,
			easingFn: EasingFn.basic(Ease.inQuad)
		))

		super.init(config.entityStore)

		setAlpha(0)
	}

	override func update() {
		uptime += Time.deltaTime

		if !exiting && uptime > duration * 0.7 {
			exiting = true

			alphaAnimator = Animator(Animator.Config(
				duration: duration * 0.3,
				startValue: 1,
				endValue: 0,
				easingFn: EasingFn.basic(Ease.inQuad)
			))
		}

		updateY()
		updateAlpha()
	}

	private func updateY() {
		yAnimator.update()
		sprite.moveTo(Point(x: position.x, y: yAnimator.currentValue))
	}

	private func updateAlpha() {
		guard let alphaAnimator = alphaAnimator else {
			return
		}

		alphaAnimator.update()
		setAlpha(alphaAnimator.currentValue)

		if alphaAnimator.ended {
			if entering {
				entering = false

				self.alphaAnimator = nil
			} else {
				self.alphaAnimator = nil
			}
		}
	}

	private func setAlpha(_ alpha: Float) {
		var overlayPattern = Graphics.Color.getBayer4x4FadePattern(foreground: 1, alpha: alpha)

		overlayPattern.0.withUnsafeMutableBufferPointer { ptr in
			sprite.setStencilPattern(ptr.baseAddress!)
		}
	}
}

