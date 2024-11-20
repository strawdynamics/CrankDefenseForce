import PlaydateKit

class StaticCollider: BaseEntity {
	class StaticColliderSprite: Sprite.Sprite {
	}
	
	struct Config {
		var bitmap: Graphics.Bitmap
		var entityStore: EntityStore
	}
	
	var sprite: StaticColliderSprite
	
	init(_ config: Config) {
		let sprite = StaticColliderSprite()
		sprite.image = config.bitmap
		let (bitmapWidth, bitmapHeight, _) = config.bitmap.getData(mask: nil, data: nil)
		sprite.collideRect = Rect.init(x: 0, y: 0, width: bitmapWidth, height: bitmapHeight)
		sprite.addToDisplayList()
		self.sprite = sprite
		
		super.init(config.entityStore)
	}
}
