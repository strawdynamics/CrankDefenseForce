import PlaydateKit

class Explosion: BaseEntity {
	static let STARTING_RADIUS: Float = 8

	struct Config {
		let position: Point
		let maxRadius: Float
		let owner: Owner
		let entityStore: EntityStore
		var duration: Float = 1.8
		var inPercentage: Float = 0.35
		var collides: Bool = true
		var silent: Bool = false
	}

	class ExplosionSprite: Sprite.Sprite {
		var radius: Float = 0
		var alpha: Float = 0

		let owner: Owner

		init(owner: Owner) {
			self.owner = owner
		}

		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.fillEllipse(
				in: Rect(
					x: position.x - radius,
					y: position.y - radius,
					width: radius * 2,
					height: radius * 2
				),
				startAngle: 0,
				endAngle: 360,
				color: Graphics.Color.getBayer4x4FadeColor(
					foreground: GameSettings.timeOfDay == .day ? 0 : 1,
					alpha: alpha
				),
			)
		}
	}

	enum State {
		case expanding
		case collapsing
	}

	let sprite: ExplosionSprite

	let maxRadius: Float

	let duration: Float

	var currentRadius: Float = Explosion.STARTING_RADIUS

	var sizeAnimator: Animator<Float>

	var alphaAnimator: Animator<Float>

	var state: State = .expanding

	let inPercentage: Float
	let outPercentage: Float

	init(_ config: Config) {
		maxRadius = config.maxRadius
		duration = config.duration

		inPercentage = config.inPercentage
		outPercentage = 1 - inPercentage

		sizeAnimator = Animator(
			Animator.Config(
				duration: duration * inPercentage,
				startValue: Explosion.STARTING_RADIUS,
				endValue: maxRadius,
				easingFn: EasingFn.basic(Ease.outQuad),
			))

		alphaAnimator = Animator(
			Animator.Config(
				duration: duration * inPercentage,
				startValue: 0.7,
				endValue: 0.4,
				easingFn: EasingFn.basic(Ease.inBounce),
			))

		sprite = ExplosionSprite(owner: config.owner)

		super.init(config.entityStore)

		let size = maxRadius * 2

		sprite.zIndex = 180
		sprite.position = config.position
		sprite.setSize(width: maxRadius * 2, height: size)
		if config.collides {
			sprite.collideRect = Rect(x: 0, y: 0, width: size, height: size)
		}
		sprite.addToDisplayList()

		if !config.silent {
			Sfx.instance.play(.explosion, offset: MIDINote.random(in: -2...2))
		}
	}

	override func update() {
		sizeAnimator.update()
		alphaAnimator.update()

		sprite.radius = sizeAnimator.currentValue
		sprite.alpha = alphaAnimator.currentValue

		if sizeAnimator.ended {
			if state == .expanding {
				state = .collapsing

				sizeAnimator = Animator(
					Animator.Config(
						duration: duration * outPercentage,
						startValue: maxRadius,
						endValue: 0,
						easingFn: EasingFn.basic(Ease.inQuad),
					))

				alphaAnimator = Animator(
					Animator.Config(
						duration: duration * outPercentage,
						startValue: 0.4,
						endValue: 0,
						easingFn: EasingFn.basic(Ease.inOutQuad),
					))
			} else {
				entityStore.remove(self)
			}
		}
	}
}
