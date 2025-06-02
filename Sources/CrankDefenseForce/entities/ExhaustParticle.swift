import PlaydateKit

class ExhaustParticle: Explosion {
	struct Config {
		let position: Point
		let maxRadius: Float
		let entityStore: EntityStore
		var duration: Float = 1.8
		var inPercentage: Float = 0.35
		var velocity: Vector2 = Vector2.zero
	}

	var velocity: Vector2

	init(_ config: Config) {
		velocity = config.velocity

		super.init(Explosion.Config(
			position: config.position,
			maxRadius: config.maxRadius,
			entityStore: config.entityStore,
			duration: config.duration,
			inPercentage: config.inPercentage,
			collides: false,
		))

		sprite.zIndex = 50
	}

	override func update() {
		sprite.moveBy(dx: velocity.x * Time.deltaTime, dy: velocity.y * Time.deltaTime)
		super.update()
	}
}
