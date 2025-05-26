import PlaydateKit

class PowerUp: BaseEntity {
	enum PowerUpType {
		case none
		case pauseEnemies
	}
	
	struct Config {
		let position: Point
		let type: PowerUpType
		let entityStore: EntityStore
	}
	
	class PowerUpSprite: Sprite.Sprite {
		let type: PowerUpType
		
		init(type: PowerUpType) {
			self.type = type
		}
	}
	
	let type: PowerUpType
	
	let sprite: PowerUpSprite
	
	init(_ config: Config) {
		type = config.type
		sprite = PowerUpSprite(type: type)
		
		super.init(config.entityStore)
		
		let size: Float = 16
		
		sprite.zIndex = 90
		sprite.position = config.position
		sprite.setSize(width: size, height: size)
		sprite.collideRect = Rect(x: 0, y: 0, width: size, height: size)
		// TODO: Set image based on type
		sprite.addToDisplayList()
	}
}
