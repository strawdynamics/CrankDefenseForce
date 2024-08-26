//
//  BasicBackground.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

class BasicBackground: BaseEntity {
	let sprite: Sprite.Sprite
	
	init(entityStore: EntityStore, color: Graphics.Color) {
		let sprite = Sprite.Sprite()
		sprite.setDrawMode(.copy)
		sprite.image = Graphics.Bitmap.init(width: 400, height: 240, bgColor: color)
		sprite.center = Point.zero
		sprite.moveTo(Point.zero)
		sprite.zIndex = -32768
		sprite.setIgnoresDrawOffset(true)
		sprite.updatesEnabled = false
		sprite.addToDisplayList()
		self.sprite = sprite
		
		super.init(entityStore)
	}
	
	override func update() {

	}
	
	override func destroy() {
		super.destroy()
	}
}
