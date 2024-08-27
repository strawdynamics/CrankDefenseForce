//
//  Rocket.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

import PlaydateKit

nonisolated(unsafe) let rocketBitmapTable = try! Graphics.BitmapTable(path: "rocket.png")


struct TestoEventPayload {
	var bob: Float
	var bobString: String
}

struct TestoEvent: EventProtocol {
	typealias Payload = TestoEventPayload
}

class Rocket: BaseEntity {
	struct RemoveEventPayload {
		var rocket: Rocket
	}
	struct RemoveEvent: EventProtocol {
		typealias Payload = RemoveEventPayload
	}
	nonisolated(unsafe) static var removeEmitter = EventEmitter<RemoveEvent>()
	
	struct Config {
		var position: Point
		var angle: Float
		var thrust: Float = 0.0
		var entityStore: EntityStore
		var tag: Tag = .none
	}

	enum Tag: UInt8 {
		case none = 0
		case player = 1
		case cpu = 2
	}
	
	var sprite: Sprite.Sprite
	
	var thrust: Float = 0.0
	
	var angle: Float
	
	var sin: Float = 0.0
	
	var cos: Float = 0.0
	
	var lastImageIndex: Int = 0
	
	var position: Point {
		return self.sprite.position
	}
	
	init(_ config: Config) {
		let sprite = Sprite.Sprite()
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
		sprite.tag = config.tag.rawValue
		
		self.sprite = sprite
		
		self.angle = config.angle
		self.thrust = config.thrust
		
		super.init(config.entityStore)
		
		self.setAngle(newAngle: config.angle)
		self.setImage()
	}
	
	override func update() {
		super.update()
		
		if self.thrust == 0.0 {
			// TODO: Hide exhaust
		} else {
			// TODO: Show exhaust
			
			let deltaX = self.thrust * Time.deltaTime * self.cos
			let deltaY = self.thrust * Time.deltaTime * self.sin
			
			self.sprite.moveBy(dx: deltaX, dy: deltaY)
			
			self.updateCollision()
		}
		
		self.setImage()
		
		self.updateOob()
	}
	
	func setImage() {
		let roundedAngle = Int(self.angle.roundToNearest(15.0))
		let newImageIndex = roundedAngle % 360 / 15 % 24
		
		if newImageIndex != self.lastImageIndex {
			let bitmap = rocketBitmapTable[newImageIndex]!
			self.sprite.image = bitmap
			self.lastImageIndex = newImageIndex
		}
	}
	
	func updateOob() {
		let pos = self.position
		if pos.x < -20 || pos.x > 420 || pos.y < -20 || pos.y > 260 {
			self.remove()
		}
	}
	
	func updateCollision() {
		let rawOverlappingSprites = self.sprite.overlappingSprites
		var overlappingSprites: [Sprite.Sprite] = []
		
		for case let spritePointer? in rawOverlappingSprites {
			let spritePointer = unsafeBitCast(spritePointer, to: UnsafeMutablePointer<Sprite.Sprite>.self)

			overlappingSprites.append(spritePointer.pointee)
		}
		
		
		for overlappingSprite in overlappingSprites {
			// TODO: https://github.com/finnvoor/PlaydateKit/issues/89
		}
		
		rawOverlappingSprites.deallocate()
	}
	
	func handleCollisionWith(otherRocket: Rocket) {
//
	}
	
	func remove() {
		self.sprite.removeFromDisplayList()

		Self.removeEmitter.emit(RemoveEventPayload(
			rocket: self,
		))

		// TODO: Remove exhaust
	}
	
	func setThrust(newThrust: Float) {
		self.thrust = newThrust
	}
	
	func changeAngle(delta: Float) {
		self.setAngle(newAngle: self.angle + delta)
	}
	
	func setAngle(newAngle: Float) {
		self.angle = newAngle.truncatingRemainder(dividingBy: 360.0)
		
		let radAngle = (self.angle - 90.0).toRadians()
		self.cos = cosf(radAngle)
		self.sin = sinf(radAngle)
	}
}
