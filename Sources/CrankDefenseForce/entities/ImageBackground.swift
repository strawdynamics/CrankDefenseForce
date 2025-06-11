import PlaydateKit

enum ImageBackgroundType {
	case city
	case configCity
	case crt
}

class ImageBackground: BaseEntity {
	static nonisolated(unsafe) let cityBackgroundBitmap = try! Graphics.Bitmap(path: "entities/ImageBackground/cityBackground")
	static nonisolated(unsafe) let configCityBitmap = try! Graphics.Bitmap(path: "entities/ImageBackground/configCity")
	static nonisolated(unsafe) let crtBackgroundBitmap = CrtTransitionDetails.CRT_ZOOM_BITMAP_TABLE[0]
	
	let sprite: Sprite.Sprite
	
	init(entityStore: EntityStore, backgroundType: ImageBackgroundType) {
		let sprite = Sprite.Sprite()
		sprite.setDrawMode(.copy)
		switch backgroundType {
		case .city:
			sprite.image = ImageBackground.cityBackgroundBitmap
		case .configCity:
			sprite.image = ImageBackground.configCityBitmap
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
	
	func setDrawMode(_ drawMode: Graphics.Bitmap.DrawMode) {
		sprite.setDrawMode(drawMode)
	}
}
