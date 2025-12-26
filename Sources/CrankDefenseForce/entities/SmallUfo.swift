import PlaydateKit

class SmallUfo: BaseEntity, PowerUpDropper, Movable, Toggleable {
	static let powerUpDropTable: [PowerUp.PowerUpType: Float] = [
		.none: 40,
		.pauseEnemies: 30,
		.repairBuilding: 10,
		.destroyEnemies: 20,
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

	nonisolated(unsafe) static let smallUfoBitmapTable = try! Graphics.BitmapTable(
		path: "entities/SmallUfo/smallUfo")

	nonisolated(unsafe) static let sfx = SmallUfoSfx()

	class SmallUfoSprite: Sprite.Sprite {
		var smallUfoId: Int = -1
	}

	struct Config {
		var entityStore: EntityStore
		var position: Point
		var facingLeft: Bool
		var speed: Float
		var exhaustZIndex: Int16 = 50
		var silent: Bool = false
	}

	var sprite = SmallUfoSprite()

	private(set) var destroyed = false

	private var bobYAnimator: Animator<Float>?

	private let facingLeft: Bool

	private let speed: Float

	private var life: Float = 0

	private var nextExhaustTime: Float = 0

	private let exhaustZIndex: Int16

	private var isExhausting = true

	private var silent: Bool

	init(_ config: Config) {
		facingLeft = config.facingLeft
		speed = config.speed
		exhaustZIndex = config.exhaustZIndex
		silent = config.silent

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

		bobYAnimator = Animator(
			Animator.Config(
				duration: 0.5,
				startValue: config.position.y,
				endValue: config.position.y + 1,
				easingFn: EasingFn.basic(Ease.inOutQuad),
				loopMode: .pingPong
			))

		super.init(config.entityStore)

		if !silent {
			Self.sfx.incActiveUfos()
		}

		scheduleExhaust()

		sprite.smallUfoId = id
	}

	func moveTo(position: Point) {
		sprite.moveTo(position)
		bobYAnimator?.startValue = position.y
		bobYAnimator?.endValue = position.y + 1
	}

	override func update() {
		updateOob()
		sprite.moveBy(dx: Time.deltaTime * speed * (facingLeft ? -1 : 1), dy: 0)
		updateExhaust()
		updateBob()
	}

	override func beforeRemove() {
		if !silent {
			Self.sfx.decActiveUfos()
		}
	}

	func updateOob() {
		let pos = position
		if pos.x < -40 || pos.x > 440 {
			remove()
		}
	}

	private func scheduleExhaust() {
		nextExhaustTime += Float.random(in: 0.3..<0.7)
	}

	private func updateExhaust() {
		if !isExhausting {
			return
		}

		life += Time.deltaTime
		if life >= nextExhaustTime {
			spawnExhaust()
			scheduleExhaust()
		}
	}

	func explode() {
		_ = Explosion(
			Explosion.Config(
				position: position,
				maxRadius: 32,
				owner: .player,
				entityStore: entityStore,
				duration: 2,
			))

		remove()
	}

	func remove() {
		Self.removeEmitter.emit(
			RemoveEventPayload(
				smallUfo: self,
			))
		entityStore.remove(self)
	}

	private func updateBob() {
		guard let yAnim = bobYAnimator else { return }
		yAnim.update()
		sprite.moveTo(
			Point(
				x: sprite.position.x.rounded(),
				y: yAnim.currentValue.rounded()
			))
	}

	private func spawnExhaust() {
		_ = ExhaustParticle(
			ExhaustParticle.Config(
				position: position
					+ Point(
						x: facingLeft ? 8 : -8,
						y: 0
					),
				maxRadius: Float.random(in: 1.5..<3),
				owner: .cpu,
				entityStore: entityStore,
				duration: Float.random(in: 0.4..<0.9),
				inPercentage: 0.8,
				velocity: Vector2(
					x: Float.random(in: 2..<10) * (facingLeft ? 1 : -1),
					y: -4
				),
				zIndex: exhaustZIndex,
			))
	}

	func show() {
		sprite.addToDisplayList()
		isExhausting = true
	}

	func hide() {
		sprite.removeFromDisplayList()
		isExhausting = false
	}
}
