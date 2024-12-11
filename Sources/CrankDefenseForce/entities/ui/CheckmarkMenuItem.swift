
import PlaydateKit

class CheckmarkMenuItem: ConfigMenuItem {
	static nonisolated(unsafe) let checkmarkBitmapTable = try! Graphics.BitmapTable(path: "configMenuItemCheckmark.png")
	
	struct Config {
		let title: String
		let offsetX: Float
		let entityStore: EntityStore
		let getChecked: () -> Bool
		let toggleHandler: () -> Void
	}
	
	class DisplaySprite: ConfigMenuItem.Sprite {
		let title: String
		
		let getChecked: () -> Bool
		
		init(title: String, getChecked: @escaping () -> Bool) {
			self.title = title
			self.getChecked = getChecked

			super.init()
			zIndex = 10
			setSize(width: ConfigMenuItem.SPRITE_WIDTH, height: ConfigMenuItem.SPRITE_HEIGHT)
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.setFont(CdfFont.NicoClean16)
			Graphics.drawMode = .fillWhite
			Graphics.drawText(
				title,
				at: bounds.origin + Point(x: 16, y: 16)
			)
			
			Graphics.drawBitmap(
				checkmarkBitmapTable[getChecked() ? 1 : 0]!,
				at: bounds.origin + Point(
					x: 155,
					y: bounds.height * 0.5 - 10
				)
			)
			
		}
	}
	
	let displaySprite: DisplaySprite
	
	let toggleHandler: () -> Void
	
	init(_ config: Config) {
		displaySprite = DisplaySprite(
			title: config.title,
			getChecked: config.getChecked
		)
		
		toggleHandler = config.toggleHandler
		
		super.init(ConfigMenuItem.Config(
			title: config.title,
			offsetX: config.offsetX,
			entityStore: config.entityStore,
		))
		
		displaySprite.addToDisplayList()
	}
	
	override func update() {
		super.update()
		
		updateInput()
	}
	
	func updateInput() {
		if isFocused {
			let pushed = System.buttonState.pushed
			
			if pushed.contains(.a) {
				toggle()
			}
		}
	}
	
	func toggle() {
		toggleHandler()
	}
	
	override func lateUpdate() {
		displaySprite.moveTo(sprite.position)
		super.lateUpdate()
	}
}
