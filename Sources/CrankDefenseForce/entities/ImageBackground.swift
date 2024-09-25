//
//  ImageBackground.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

enum ImageBackgroundType {
	case city
	case crt
}

class ImageBackground: BaseEntity {
	static nonisolated(unsafe) let cityBackgroundBitmap = try! Graphics.Bitmap(path: "cityBackground.png")
	static nonisolated(unsafe) let crtBackgroundBitmap = CrtTransitionDetails.CRT_ZOOM_BITMAP_TABLE[0]
	
	let sprite: Sprite.Sprite
	
	init(entityStore: EntityStore, backgroundType: ImageBackgroundType) {
		let sprite = Sprite.Sprite()
		sprite.setDrawMode(.copy)
		switch backgroundType {
		case .city:
			sprite.image = ImageBackground.cityBackgroundBitmap
		case .crt:
			sprite.image = ImageBackground.crtBackgroundBitmap
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
