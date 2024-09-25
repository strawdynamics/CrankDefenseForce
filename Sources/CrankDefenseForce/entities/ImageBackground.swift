//
//  ImageBackground.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

nonisolated(unsafe) let cityBackgroundBitmap = try! Graphics.Bitmap(path: "cityBackground.png")

enum ImageBackgroundType {
	case city
}

class ImageBackground: BaseEntity {
	let sprite: Sprite.Sprite
	
	init(entityStore: EntityStore, backgroundType: ImageBackgroundType) {
		let sprite = Sprite.Sprite()
		sprite.setDrawMode(.copy)
		switch backgroundType {
		case .city:
			sprite.image = cityBackgroundBitmap
		}
		sprite.center = Point.zero
		sprite.moveTo(Point.zero)
		sprite.zIndex = -32768
		sprite.setIgnoresDrawOffset(true)
		sprite.updatesEnabled = false
		sprite.addToDisplayList()
		self.sprite = sprite
		
		super.init(entityStore)
	}
}
