//
//  Rocket.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

import PlaydateKit

nonisolated(unsafe) let rocketBitmapTable = try! Graphics.BitmapTable(path: "rocket.png")

class Rocket: BaseEntity {
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
	}
	
	var sprite = RocketSprite()
	
	private(set) var thrust: Float = 0.0
	
	var angle: Float
	
	var sin: Float = 0.0
	
	var cos: Float = 0.0
	
	var lastImageIndex: Int = 0
	
	var position: Point {
		return sprite.position
	}
	
	init(_ config: Config) {
		let bitmap = rocketBitmapTable[0]!
		let (bitmapWidth, bitmapHeight, _) = bitmap.getData(mask: nil, data: nil)
		
		sprite.image = bitmap
		sprite.moveTo(config.position)
		sprite.collideRect = Rect.init(
			x: 0,
			y: 0,
			width: bitmapWidth,
			height: bitmapHeight
		)
		
		sprite.addToDisplayList()
		
		angle = config.angle
		thrust = config.thrust
		
		super.init(config.entityStore)
		
		sprite.rocketId = id
		
		setAngle(newAngle: config.angle)
		setImage()
	}
	
	override func update() {
		super.update()
		
		if thrust == 0.0 {
			// TODO: Hide exhaust
		} else {
			// TODO: Show exhaust
			
			let deltaX = thrust * Time.deltaTime * cos
			let deltaY = thrust * Time.deltaTime * sin
			
			sprite.moveBy(dx: deltaX, dy: deltaY)
			
			updateCollision()
		}
		
		setImage()
		
		updateOob()
	}
	
	func setImage() {
		let roundedAngle = Int(angle.roundToNearest(15.0))
		let newImageIndex = ((roundedAngle % 360) / 15 + 24) % 24
		
		if newImageIndex != lastImageIndex {
			let bitmap = rocketBitmapTable[newImageIndex]!
			sprite.image = bitmap
			lastImageIndex = newImageIndex
		}
	}
	
	func updateOob() {
		let pos = position
		if pos.x < -20 || pos.x > 420 || pos.y < -20 || pos.y > 260 {
			remove()
		}
	}
	
	func updateCollision() {
		let pos = position
		let colls = sprite.checkCollisions(goalX: pos.x, goalY: pos.y).collisions
		print("collcount \(colls.count)")
		
		for coll in colls {
			let overlappingSprite = coll.other
			
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
				print("NOALPHASKIP")
				continue
			}
			
			print("ALPHAHIT!!")
			
			// TODO: Explode instead of remove
			remove()
			
			if let overlappingRocketSprite = overlappingSprite as? RocketSprite {
				handleCollisionWith(rocketSprite: overlappingRocketSprite)
			} else if let overlappingBuildingSprite = overlappingSprite as? Building.BuildingSprite {
				handleCollisionWith(buildingSprite: overlappingBuildingSprite)
			} else {
				print("Collided with unknown object \(overlappingSprite.collisionsEnabled)")
			}
		}
	}
	
	func handleCollisionWith(rocketSprite: RocketSprite) {
		guard let otherRocket = entityStore?.get(rocketSprite.rocketId) else { return }
		
		print("HIT ANOTHER ROCKET!!!!! \(id), \(otherRocket.id)")
	}
	
	func handleCollisionWith(buildingSprite: Building.BuildingSprite) {
		guard let building = entityStore?.get(buildingSprite.buildingId) else { return }
		
		print("HIT A BUILDING! \(id) -> \(building.id)")
	}
	
	func remove() {
		sprite.removeFromDisplayList()

		Self.removeEmitter.emit(RemoveEventPayload(
			rocket: self,
		))

		// TODO: Remove exhaust
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
	}
}
