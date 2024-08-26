//
//  Rocket.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

import PlaydateKit

nonisolated(unsafe) let rocketBitmapTable = try! Graphics.BitmapTable(path: "rocket.png")

class Rocket: BaseEntity {
	public struct Config {
		public var position: Point
		public var angle: Float
		public var thrust: Float = 0.0
		public var entityStore: EntityStore
		public var tag: Tag = .none
	}

	public enum Tag: UInt8 {
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
			
			// TODO: Update collision
		}
		
		self.setImage()
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
	
	public func getPosition() -> Point {
		return self.sprite.position
	}
	
	public func setThrust(newThrust: Float) {
		self.thrust = newThrust
	}
	
	public func changeAngle(delta: Float) {
		self.setAngle(newAngle: self.angle + delta)
	}
	
	public func setAngle(newAngle: Float) {
		self.angle = newAngle.truncatingRemainder(dividingBy: 360.0)
		
		let radAngle = (self.angle - 90.0).toRadians()
		self.cos = cosf(radAngle)
		self.sin = sinf(radAngle)
	}
}
