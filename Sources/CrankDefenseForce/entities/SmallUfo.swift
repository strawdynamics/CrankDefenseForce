import PlaydateKit

class SmallUfo: BaseEntity, PowerUpDropper {
	static let powerUpDropTable: [PowerUp.PowerUpType: Float] = [
		.none: 1
	]

	struct RemoveEventPayload {
		var smallUfo: SmallUfo
	}
	struct RemoveEvent: EventProtocol {
		typealias Payload = RemoveEventPayload
	}
	nonisolated(unsafe) static var removeEmitter = EventEmitter<RemoveEvent>()

	var position: Point {
		return sprite.position
	}

	nonisolated(unsafe) static let smallUfoBitmapTable = try! Graphics.BitmapTable(path: "entities/SmallUfo/smallUfo")


	class SmallUfoSprite: Sprite.Sprite {
		var smallUfoId: Int = -1
	}

	struct Config {
		var entityStore: EntityStore
		var position: Point
		var facingLeft: Bool
		var speed: Float
	}

	var sprite = SmallUfoSprite()

	private(set) var destroyed = false

	private var bobYAnimator: Animator<Float>?

	private let facingLeft: Bool

	private let speed: Float

	init(_ config: Config) {
		facingLeft = config.facingLeft
		speed = config.speed

		let bitmap = Self.smallUfoBitmapTable[facingLeft ? 0 : 1]!
		let (bitmapWidth, bitmapHeight, _) = bitmap.getData(mask: nil, data: nil)

		sprite.image = bitmap
		sprite.moveTo(config.position)
		sprite.collideRect = Rect.init(
			x: 0,
			y: 0,
			width: bitmapWidth,
			height: bitmapHeight
		)
		sprite.zIndex = 70

		sprite.addToDisplayList()

		bobYAnimator = Animator(Animator.Config(
			duration: 0.5,
			startValue: config.position.y,
			endValue: config.position.y + 1,
			easingFn: EasingFn.basic(Ease.inOutQuad),
			loopMode: .pingPong
		))

		super.init(config.entityStore)

		sprite.smallUfoId = id
	}

	override func update() {
		updateOob()
		sprite.moveBy(dx: Time.deltaTime * speed * (facingLeft ? -1 : 1), dy: 0)
		updateBob()
	}

	func updateOob() {
		let pos = position
		if pos.x < -40 || pos.x > 440 {
			destroy()
		}
	}

	func destroy() {
		Self.removeEmitter.emit(RemoveEventPayload(
			smallUfo: self,
		))
		entityStore.remove(self)
	}

	private func updateBob() {
		guard let yAnim = bobYAnimator else { return }
		yAnim.update()
		sprite.moveTo(Point(
			x: sprite.position.x.rounded(),
			y: yAnim.currentValue.rounded()
		))
	}
}
