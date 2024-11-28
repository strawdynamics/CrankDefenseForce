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
		let title: String
		
		let volumeType: VolumeType
		
		init(title: String, volumeType: VolumeType) {
			self.title = title
			self.volumeType = volumeType
			
			super.init()
			zIndex = 10
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.pushContext(nil)
			
			Graphics.setFont(CdfFont.NicoClean16)
			Graphics.drawMode = .fillWhite
			Graphics.drawText(
				title,
				at: bounds.origin + Point(x: 16, y: 16)
			)
			
			Graphics.popContext()
		}
	}
	
	let displaySprite: Sprite
	
	let currentValue: Int
	
	let volumeType: VolumeType
	
	init(_ config: Config) {
		displaySprite = Sprite(title: config.title, volumeType: config.volumeType)
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
