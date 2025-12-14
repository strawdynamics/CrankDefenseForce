import PlaydateKit

class BigUfoBeam: BaseEntity {
	nonisolated(unsafe) static let bitmap = try! Graphics.Bitmap(path: "entities/BigUfoBeam/beam")

	private var selfDestructTimer: TimedCallback?

	struct Config {
		let entityStore: EntityStore
		let position: Point
		let duration: Float
	}

	class BigUfoBeamSprite: Sprite.Sprite {}

	let sprite = BigUfoBeamSprite()

	init(_ config: Config) {
		sprite.image = Self.bitmap
		sprite.center = Point(x: 0.5, y: 0.0)
		sprite.moveTo(config.position)
		sprite.zIndex = 58

		sprite.addToDisplayList()

		super.init(config.entityStore)

		selfDestructTimer = TimedCallback(duration: config.duration) {}
	}

	override func update() {
		let ended = selfDestructTimer?.update() ?? false
		if ended {
			entityStore.remove(self)
		}
	}
}
