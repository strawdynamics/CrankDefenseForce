//
//  PlayerCursor.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

import PlaydateKit

nonisolated(unsafe) let playerCursorBitmapTable = try! Graphics.BitmapTable(path: "playerCursor.png")

let CURSOR_SPEED: Float = 1000.0

class PlayerCursor: BaseEntity {
	var sprite: Sprite.Sprite
	
	override init(_ entityStore: EntityStore) {
		let sprite = Sprite.Sprite()
		sprite.image = playerCursorBitmapTable[0]
		sprite.moveTo(Point(x: 200.0, y: 120.0))
		sprite.addToDisplayList()
		sprite.zIndex = 80
		self.sprite = sprite
		
		super.init(entityStore)
	}
	
	func moveTo(point: Point) {
		self.sprite.moveTo(point)
	}
	
	func moveToward(dest: Point) {
		let cur = self.sprite.position
		
		let diffX = dest.x - cur.x
		let diffY = dest.y - cur.y
		
		let dist = (diffX * diffX + diffY * diffY).squareRoot()
		
		let dirX = diffX / dist
		let dirY = diffY / dist
		
		let speed = CURSOR_SPEED * Time.deltaTime
		
		if dist < speed {
			self.moveTo(point: dest)
		} else {
			self.moveTo(point: Point(
				x: cur.x + dirX * speed,
				y: cur.y + dirY * speed,
			))
		}
	}
}
