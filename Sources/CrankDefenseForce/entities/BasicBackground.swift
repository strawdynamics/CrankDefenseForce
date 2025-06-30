import PlaydateKit

class BasicBackground: BaseEntity {
	let sprite: Sprite.Sprite

	init(entityStore: EntityStore, color: Graphics.Color) {
		let sprite = Sprite.Sprite()
		sprite.setDrawMode(.copy)
		sprite.image = Graphics.Bitmap.init(width: Display.width, height: Display.height, bgColor: color)
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
}
