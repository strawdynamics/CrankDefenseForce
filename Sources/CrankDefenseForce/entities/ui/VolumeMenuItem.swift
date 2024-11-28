import PlaydateKit

class VolumeMenuItem: ConfigMenuItem {
	static let max: Int = 10
	
	enum VolumeType {
		case music
		case sfx
	}
	
	struct Config {
		let title: String
		let offsetX: Float
		let volumeType: VolumeType
		let entityStore: EntityStore
	}
	
	class Sprite: ConfigMenuItem.Sprite {
		override init() {
			super.init()
			zIndex = 10
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.pushContext(nil)
			
			Graphics.drawMode = .fillWhite
			Graphics.drawText(
				"helloworld",
				at: bounds.origin
			)
			
			Graphics.popContext()
		}
	}
	
	let displaySprite = Sprite()
	
	let currentValue: Int
	
	let volumeType: VolumeType
	
	init(_ config: Config) {
		volumeType = config.volumeType
		
		currentValue = 5
		
		displaySprite.addToDisplayList()
		
		super.init(ConfigMenuItem.Config(
			title: config.title,
			offsetX: config.offsetX,
			entityStore: config.entityStore,
		))
	}
	
	override func lateUpdate() {
		displaySprite.moveTo(sprite.position)
		super.lateUpdate()
	}
}
