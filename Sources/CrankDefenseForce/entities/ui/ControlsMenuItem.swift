
import PlaydateKit

class ControlsMenuItem: ConfigMenuItem {
	enum VolumeType {
		case music
		case sfx
	}
	
	struct Config {
		let title: String
		let offsetX: Float
		let entityStore: EntityStore
	}
	
	class Sprite: ConfigMenuItem.Sprite {
		override init() {
			super.init()
			zIndex = 10
			setSize(width: ConfigMenuItem.SPRITE_WIDTH, height: ConfigMenuItem.SPRITE_HEIGHT)
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.pushContext(nil)
			
			Graphics.setFont(CdfFont.NicoClean16)
			Graphics.drawMode = .fillWhite
			Graphics.drawText(
				GameSettings.controlScheme.title,
				at: bounds.origin + Point(x: 16, y: 16)
			)
			
			Graphics.popContext()
		}
	}
	
	let displaySprite = Sprite()
		
	init(_ config: Config) {
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
	
	override func prev() {
		super.prev()
		GameSettings.controlScheme = GameSettings.controlScheme.prev
	}
	
	override func next() {
		super.next()
		GameSettings.controlScheme = GameSettings.controlScheme.next
	}
}
