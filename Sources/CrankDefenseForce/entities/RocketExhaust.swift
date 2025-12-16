import PlaydateKit

class RocketExhaust: BaseEntity {
	// ./bin/spriterot --rotations=24 --columns=1 --keep-size --output=4.png ~/Downloads/rot/4.png
	nonisolated(unsafe) static let normalExhaustBitmapTable = try! Graphics.BitmapTable(
		path: "entities/RocketExhaust/normalExhaust")

	nonisolated(unsafe) static let bigExhaustBitmapTable = try! Graphics.BitmapTable(
		path: "entities/RocketExhaust/bigExhaust")

	nonisolated(unsafe) static let engineSfx = RocketEngineSfx()

	enum ExhaustType {
		case normal
		case big
	}

	static let normalDistance: Float = 9

	static let bigDistance: Float = 22

	var sprite = Sprite.Sprite()

	var rocketPtr: Int
	var rocket: Rocket {
		return unsafeBitCast(rocketPtr, to: Rocket.self)
	}

	var frameAnimator: Animator<Float>

	var active = false

	let type: ExhaustType

	struct Config {
		var rocket: Rocket
		var entityStore: EntityStore
		var type: ExhaustType
	}

	init(_ config: Config) {
		rocketPtr = unsafeBitCast(config.rocket, to: Int.self)

		type = config.type

		frameAnimator = Animator(
			Animator.Config(
				duration: type == .normal ? 0.4 : 0.5,
				startValue: 0.0,
				endValue: 4.0,
				easingFn: EasingFn.basic(Ease.linear),
				loopMode: .loop,
			))

		super.init(config.entityStore)

		sprite.image =
			type == .normal ? Self.normalExhaustBitmapTable[0] : Self.bigExhaustBitmapTable[0]
		sprite.isVisible = false
		sprite.zIndex = 99
		sprite.addToDisplayList()
	}

	deinit {
		deactivate()
	}

	override func update() {
		super.update()

		updatePosition()

		updateAnimationFrame()
	}

	func updatePosition() {
		let rPos = rocket.position

		let dist = type == .normal ? Self.normalDistance : Self.bigDistance
		let x = rPos.x - (dist * rocket.roundedCos)
		let y = rPos.y - (dist * rocket.roundedSin)
		sprite.moveTo(Point(x: x, y: y).rounded)
	}

	func updateAnimationFrame() {
		let roundedAngle = Int(rocket.angle.roundToNearest(15.0))
		let rotFrame = (((roundedAngle % 360) / 15 + 24) % 24) * 4

		let animFrame = Int(frameAnimator.currentValue.rounded().truncatingRemainder(dividingBy: 4))
		let frameIndex = rotFrame + animFrame

		frameAnimator.update()
		sprite.image =
			type == .normal
			? Self.normalExhaustBitmapTable[frameIndex] : Self.bigExhaustBitmapTable[frameIndex]
	}

	func activate() {
		if active {
			return
		}
		active = true

		Self.engineSfx.incActiveRockets()

		sprite.isVisible = true
	}

	func deactivate() {
		if !active {
			return
		}
		active = false

		Self.engineSfx.decActiveRockets()

		sprite.isVisible = false
	}
}
