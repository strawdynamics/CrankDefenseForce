import PlaydateKit

class Rocket: BaseEntity {
	nonisolated(unsafe) static let rocketBitmapTable = try! Graphics.BitmapTable(path: "rocket.png")
		
	struct RemoveEventPayload {
		var rocket: Rocket
	}
	struct RemoveEvent: EventProtocol {
		typealias Payload = RemoveEventPayload
	}
	nonisolated(unsafe) static var removeEmitter = EventEmitter<RemoveEvent>()
	
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
	}
	
	var sprite = RocketSprite()
	
	var exhaust: RocketExhaust?
	
	private(set) var thrust: Float = 0.0
	
	var angle: Float
	
	var roundedAngle: Float
	
	var sin: Float = 0.0
	
	var cos: Float = 0.0
	
	var roundedSin: Float = 0.0
	
	var roundedCos: Float = 0.0
	
	var lastImageIndex: Int = 0
	
	var position: Point {
		return sprite.position
	}
	
	let owner: Owner
	
	init(_ config: Config) {
		owner = config.owner
		
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
		
		super.init(config.entityStore)
		
		exhaust = RocketExhaust(RocketExhaust.Config(
			rocket: self,
			entityStore: config.entityStore
		))
		
		sprite.rocketId = id
		
		setAngle(newAngle: config.angle)
		setImage()
	}
	
	override func update() {
		super.update()
		
		if thrust == 0.0 {
			exhaust?.deactivate()
		} else {
			exhaust?.activate()
			
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
			
			// Not exactly sure what this is, but it will crash otherwise!
			if overlappingSprite.image == nil {
				continue
			}
			
			// TODO: Explosion check
			
			let alphaCollided = Graphics.checkMaskCollision(
				bitmap1: sprite.image!,
				point1: sprite.bounds.origin,
				flip1: sprite.imageFlip,
				bitmap2: overlappingSprite.image!,
				point2: overlappingSprite.bounds.origin,
				flip2: overlappingSprite.imageFlip,
				rect: Rect.init(origin: Point.zero, width: 400.0, height: 240.0)
			)
			
			if (!alphaCollided) {
//				print("NOALPHASKIP")
				continue
			}
			
//			print("ALPHAHIT!!")
						
			if let overlappingRocketSprite = overlappingSprite as? RocketSprite {
				handleCollisionWith(rocketSprite: overlappingRocketSprite)
			} else if let overlappingBuildingSprite = overlappingSprite as? Building.BuildingSprite {
				handleCollisionWith(buildingSprite: overlappingBuildingSprite)
			} else if let overlappingBigUfoSprite = overlappingSprite as? BigUfo.BigUfoSprite {
				handleCollisionWith(bigUfoSprite: overlappingBigUfoSprite)
			} else {
				explode()
			}
		}
	}
	
	func handleCollisionWith(rocketSprite: RocketSprite) {
		guard let otherRocket = entityStore.get(rocketSprite.rocketId) as? Rocket else { return }
	
		if owner == .cpu && otherRocket.owner == .cpu {
			// noop, CPU rockets don't collide with each other
		} else {
			explode()
			otherRocket.remove()
		}
	}
	
	func handleCollisionWith(buildingSprite: Building.BuildingSprite) {
		if owner == .player {
			// Player rockets don't collide with buildings
			return
		}
		guard let building = entityStore.get(buildingSprite.buildingId) as? Building else { return }
		
		explode()
		building.attemptDestroy()
	}
	
	func handleCollisionWith(bigUfoSprite: BigUfo.BigUfoSprite) {
		if owner == .cpu {
			// CPU rockets don't collide with BigUfos
			return
		}
		guard let bigUfo = entityStore.get(bigUfoSprite.bigUfoId) as? BigUfo else { return }
		
		explode()
		bigUfo.damage()
	}
	
	func remove() {
		sprite.removeFromDisplayList()
		exhaust?.deactivate()
		entityStore.remove(exhaust!)
		exhaust = nil

		Self.removeEmitter.emit(RemoveEventPayload(
			rocket: self,
		))
	}
	
	func explode() {
		let _ = Explosion(Explosion.Config(
			position: sprite.position,
			maxRadius: 30,
			entityStore: entityStore,
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
}
