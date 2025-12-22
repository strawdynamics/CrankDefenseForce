import PlaydateKit

class BigUfoBeam: BaseEntity {
	nonisolated(unsafe) static let bitmapTable = try! Graphics.BitmapTable(path: "entities/BigUfoBeam/beam")

	private var selfDestructTimer: TimedCallback?
	private var spriteAnimation: SpriteAnimation!

	struct Config {
		let entityStore: EntityStore
		let position: Point
		let duration: Float
	}

	class BigUfoBeamSprite: Sprite.Sprite {}

	let sprite = BigUfoBeamSprite()

	init(_ config: Config) {
		sprite.image = Self.bitmapTable[0]
		sprite.center = Point(x: 0.5, y: 0.0)
		sprite.moveTo(config.position)
		sprite.zIndex = 58

		sprite.addToDisplayList()

		super.init(config.entityStore)

		spriteAnimation = SpriteAnimation(SpriteAnimation.Config(
			sprite: sprite,
			bitmapTable: Self.bitmapTable,
			bitmapTableIndices: Array(0..<16),
			frameDuration: 0.05,
			loopType: .loop
		))
		spriteAnimation.play()

		selfDestructTimer = TimedCallback(duration: config.duration) {}
	}

	override func update() {
		spriteAnimation.update()

		let ended = selfDestructTimer?.update() ?? false
		if ended {
			entityStore.remove(self)
		}
	}
}
