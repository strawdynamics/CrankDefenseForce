
import PlaydateKit

class TimeOfDayMenuItem: StepperMenuItem {
	struct Config {
		let title: String
		let offsetX: Float
		let entityStore: EntityStore
	}
	
	class TitleSprite: ConfigMenuItem.Sprite {
		override init() {
			super.init()
			zIndex = 10
			setSize(width: ConfigMenuItem.SPRITE_WIDTH, height: ConfigMenuItem.SPRITE_HEIGHT)
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.setFont(CdfFont.NicoClean16)
			Graphics.drawMode = .fillWhite
			Graphics.drawText(
				GameSettings.timeOfDay.title,
				at: bounds.origin + Point(x: 16, y: 16)
			)
		}
	}
	
	let titleSprite = TitleSprite()
		
	init(_ config: Config) {
		titleSprite.addToDisplayList()
		
		super.init(ConfigMenuItem.Config(
			title: config.title,
			offsetX: config.offsetX,
			entityStore: config.entityStore,
		))
	}
	
	override func lateUpdate() {
		titleSprite.moveTo(sprite.position)
		super.lateUpdate()
	}
	
	override func prev() {
		super.prev()
		GameSettings.timeOfDay = GameSettings.timeOfDay.prev
	}
	
	override func next() {
		super.next()
		GameSettings.timeOfDay = GameSettings.timeOfDay.next
	}
}
