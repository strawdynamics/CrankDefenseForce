import PlaydateKit

class Rocket: BaseEntity, PowerUpDropper, Movable, Toggleable {
	static let powerUpDropTable: [PowerUp.PowerUpType: Float] = [
		.none: 492,
		.pauseEnemies: 5,
		.repairBuilding: 1,
		.destroyEnemies: 2,
	]

	nonisolated(unsafe) static let rocketBitmapTable = try! Graphics.BitmapTable(
		path: "entities/Rocket/rocket")

	struct RemoveEventPayload {
		var rocket: Rocket
	}
	struct RemoveEvent: EventProtocol {
		typealias Payload = RemoveEventPayload
	}
	nonisolated(unsafe) static let removeEmitter = EventEmitter<RemoveEvent>()

	nonisolated(unsafe) static let statsEmitter = EventEmitter<StatsEvent>()

	class RocketSprite: Sprite.Sprite {
		var rocketId: Int = -1

		override func collisionResponse(other _: Sprite.Sprite) -> Sprite.CollisionResponseType {
			.overlap
		}
	}

	struct Config {
		var position: Point
		var angle: Float
		var thrust: Float = 0.0
		var entityStore: EntityStore
		var owner: Owner
		var exhaustType: RocketExhaust.ExhaustType = .normal
		var alwaysExhaust: Bool = false
	}

	let sprite = RocketSprite()

	var exhaust: RocketExhaust?

	let alwaysExhaust: Bool

	private(set) var thrust: Float = 0.0 {
		didSet {
			if !alwaysExhaust {
				if thrust == 0.0 {
					exhaust?.deactivate()
				} else {
					exhaust?.activate()
				}
			}
		}
	}

	var angle: Float

	var roundedAngle: Float

	var sin: Float = 0.0

	var cos: Float = 0.0

	var roundedSin: Float = 0.0

	var roundedCos: Float = 0.0

	var lastImageIndex: Int = 0

	let isFast: Bool

	var position: Point {
		return sprite.position
	}

	let owner: Owner

	init(_ config: Config) {
		owner = config.owner
		isFast = config.exhaustType == .big

		let bitmap = Self.rocketBitmapTable[0]!
		let (bitmapWidth, bitmapHeight, _) = bitmap.getData(mask: nil, data: nil)

		sprite.image = bitmap
		if GameSettings.timeOfDay == .night {
			sprite.setDrawMode(.inverted)
		}
		sprite.moveTo(config.position)
		sprite.collideRect = Rect.init(
			x: 0,
			y: 0,
			width: bitmapWidth,
			height: bitmapHeight
		)

		sprite.addToDisplayList()

		angle = config.angle
		roundedAngle = config.angle.roundToNearest(15.0)
		thrust = config.thrust
		alwaysExhaust = config.alwaysExhaust

		super.init(config.entityStore)

		exhaust = RocketExhaust(
			RocketExhaust.Config(
				rocket: self,
				entityStore: config.entityStore,
				type: config.exhaustType
			))

		if alwaysExhaust {
			exhaust?.sfxEnabled = false
		}

		if alwaysExhaust || thrust != 0.0 {
			exhaust?.activate()
			exhaust?.updatePosition()
		}

		sprite.rocketId = id
		sprite.zIndex = 100

		setAngle(newAngle: config.angle)
		setImage()
	}

	override func update() {
		super.update()

		if thrust != 0 {
			let deltaX = thrust * Time.deltaTime * cos
			let deltaY = thrust * Time.deltaTime * sin

			sprite.moveBy(dx: deltaX, dy: deltaY)

			updateCollision()
		}

		setImage()

		updateOob()
	}

	func moveTo(position: Point) {
		sprite.moveTo(position)
	}

	var x: Float {
		return sprite.position.x
	}

	var y: Float {
		return sprite.position.y
	}

	func setImage() {
		let newImageIndex = ((Int(roundedAngle) % 360) / 15 + 24) % 24

		if newImageIndex != lastImageIndex {
			let bitmap = Self.rocketBitmapTable[newImageIndex]!
			sprite.image = bitmap
			lastImageIndex = newImageIndex

			if GameSettings.timeOfDay == .night {
				sprite.setDrawMode(.inverted)
			}
		}
	}

	func updateOob() {
		if owner != .player {
			return
		}

		let pos = position
		if pos.x < -20 || pos.x > 420 || pos.y < -20 || pos.y > 260 {
			remove()
		}
	}

	func updateCollision() {
		let pos = position
		let colls = sprite.checkCollisions(goalX: pos.x, goalY: pos.y).collisions

		for coll in colls {
			let overlappingSprite = coll.other

			// Check for explosions first (nil image on overlappingSprite in this case)
			if let overlappingExplosionSprite = overlappingSprite as? Explosion.ExplosionSprite {
				// Reduce distance slightly to make explosions hit farther
				let dist = pos.distance(to: overlappingExplosionSprite.position) - 4

				if dist <= overlappingExplosionSprite.radius {
					explode(explosionOwner: overlappingExplosionSprite.owner)

					if owner == .cpu && overlappingExplosionSprite.owner == .player {
						Self.statsEmitter.emit(
							StatsEventPayload(
								eventType: isFast ? .cpuFastRocketDestroyed : .cpuRocketDestroyed
							))
					}
				}

				continue
			}

			let alphaCollided = Graphics.checkMaskCollision(
				bitmap1: sprite.image!,
				point1: sprite.bounds.origin,
				flip1: sprite.imageFlip,
				bitmap2: overlappingSprite.image!,
				point2: overlappingSprite.bounds.origin,
				flip2: overlappingSprite.imageFlip,
				rect: Rect.init(
					origin: Point.zero, width: Float(Display.width), height: Float(Display.height))
			)

			if !alphaCollided {
				continue
			}

			if let overlappingRocketSprite = overlappingSprite as? RocketSprite {
				handleCollisionWith(rocketSprite: overlappingRocketSprite)
			} else if let overlappingPowerUpSprite = overlappingSprite as? PowerUp.PowerUpSprite {
				handleCollisionWith(powerUpSprite: overlappingPowerUpSprite)
			} else if let overlappingBuildingSprite = overlappingSprite as? Building.BuildingSprite {
				handleCollisionWith(buildingSprite: overlappingBuildingSprite)
			} else if let overlappingBigUfoSprite = overlappingSprite as? BigUfo.BigUfoSprite {
				handleCollisionWith(bigUfoSprite: overlappingBigUfoSprite)
			} else if let overlappingSmallUfoSprite = overlappingSprite as? SmallUfo.SmallUfoSprite {
				handleCollisionWith(smallUfoSprite: overlappingSmallUfoSprite)
			} else {
				explode(explosionOwner: owner)
			}
		}
	}

	func handleCollisionWith(rocketSprite: RocketSprite) {
		guard let otherRocket = entityStore.get(rocketSprite.rocketId) as? Rocket else { return }

		if owner == .cpu && otherRocket.owner == .cpu {
			// CPU rockets don't collide with each other
			return
		}

		if owner == .cpu {
			dropPowerUp()

			Self.statsEmitter.emit(
				StatsEventPayload(
					eventType: isFast ? .cpuFastRocketDestroyed : .cpuRocketDestroyed
				))
		}

		if otherRocket.owner == .cpu {
			otherRocket.dropPowerUp()
			Self.statsEmitter.emit(
				StatsEventPayload(
					eventType: otherRocket.isFast ? .cpuFastRocketDestroyed : .cpuRocketDestroyed
				))
		}

		explode(
			explosionOwner: .player,
			at: position.lerp(toward: otherRocket.position, percent: 0.5)
		)
		otherRocket.remove()
	}

	func handleCollisionWith(powerUpSprite: PowerUp.PowerUpSprite) {
		if owner == .cpu {
			// CPU rockets don't collect power-ups
			return
		}

		powerUpSprite.collect()
	}

	func handleCollisionWith(buildingSprite: Building.BuildingSprite) {
		if owner == .player {
			// Player rockets don't collide with buildings
			return
		}
		guard let building = entityStore.get(buildingSprite.buildingId) as? Building else { return }

		explode(explosionOwner: .cpu)
		_ = building.attemptDestroy()
	}

	func handleCollisionWith(bigUfoSprite: BigUfo.BigUfoSprite) {
		if owner == .cpu {
			// CPU rockets don't collide with BigUfos
			return
		}
		guard let bigUfo = entityStore.get(bigUfoSprite.bigUfoId) as? BigUfo else { return }

		explode(explosionOwner: .player)
		let destroyed = bigUfo.damage()

		if destroyed {
			Self.statsEmitter.emit(
				StatsEventPayload(
					eventType: .cpuBigUfoDestroyed
				))

			bigUfo.dropPowerUp()
		}
	}

	func handleCollisionWith(smallUfoSprite: SmallUfo.SmallUfoSprite) {
		if owner == .cpu {
			// CPU rockets don't collide with SmallUfos
			return
		}
		guard let smallUfo = entityStore.get(smallUfoSprite.smallUfoId) as? SmallUfo else { return }

		explode(explosionOwner: .player)
		Self.statsEmitter.emit(
			StatsEventPayload(
				eventType: .cpuSmallUfoDestroyed
			))
		smallUfo.dropPowerUp()
		smallUfo.remove()
	}

	func remove() {
		if let e = exhaust {
			e.deactivate()
			entityStore.remove(e)
			exhaust = nil
		}

		Self.removeEmitter.emit(
			RemoveEventPayload(
				rocket: self,
			))

		entityStore.remove(self)
	}

	func explode(explosionOwner: Owner) {
		explode(explosionOwner: explosionOwner, at: position)
	}

	func explode(explosionOwner: Owner, at position: Point) {
		_ = Explosion(
			Explosion.Config(
				position: position,
				maxRadius: 32,
				owner: explosionOwner,
				entityStore: entityStore,
				duration: 2.2,
			))

		remove()
	}

	func setThrust(newThrust: Float) {
		thrust = newThrust
	}

	func changeAngle(delta: Float) {
		setAngle(newAngle: angle + delta)
	}

	func setAngle(newAngle: Float) {
		angle = fmodf(newAngle, 360.0)

		let radAngle = (angle - 90.0).toRadians()
		cos = cosf(radAngle)
		sin = sinf(radAngle)

		roundedAngle = angle.roundToNearest(15.0)
		let roundedRadAngle = (roundedAngle - 90.0).toRadians()
		roundedCos = cosf(roundedRadAngle)
		roundedSin = sinf(roundedRadAngle)
	}

	func show() {
		sprite.addToDisplayList()
		exhaust?.sprite.addToDisplayList()
	}

	func hide() {
		sprite.removeFromDisplayList()
		exhaust?.sprite.removeFromDisplayList()
	}
}
