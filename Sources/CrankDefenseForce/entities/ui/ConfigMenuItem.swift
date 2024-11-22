import PlaydateKit

class ConfigMenuItem: BaseEntity {
	static nonisolated(unsafe) let bgBitmapTable = try! Graphics.BitmapTable(path: "configMenuItemBg.png")
	
	static let SELECTED_OFFSET_X: Float = 24
	
	struct Config {
		let offsetX: Float
		let entityStore: EntityStore
	}
	
	class Sprite: PlaydateKit.Sprite.Sprite {
		override init() {
			super.init()
			self.center = .zero
		}
	}
	
	let offsetX: Float
	
	private var isSelected = false
	
	var bgSprite = Sprite()
	
	var xAnimator: FloatAnimator?
	
	init(_ config: Config) {
		offsetX = config.offsetX
		
		super.init(config.entityStore)
	
		bgSprite.image = ConfigMenuItem.bgBitmapTable[0]!
		bgSprite.moveTo(Point(x: config.offsetX, y: 0))
		bgSprite.addToDisplayList()
	}
	
	override func update() {
		if let xAnimator = xAnimator {
			xAnimator.update()
			
			bgSprite.moveTo(Point(x: xAnimator.currentValue, y: bgSprite.position.y))
			
			if xAnimator.ended {
				self.xAnimator = nil
			}
		}
	}
	
	func moveTo(y: Float) {
		bgSprite.moveTo(Point(x: bgSprite.position.x, y: y))
	}
	
	func select() {
		if isSelected {
			return
		}
		isSelected = true
		
		bgSprite.image = ConfigMenuItem.bgBitmapTable[1]!
		
		xAnimator = FloatAnimator(
			duration: 0.5,
			startValue: offsetX,
			endValue: offsetX + ConfigMenuItem.SELECTED_OFFSET_X,
			easingFn: EasingFn.basic(Ease.outQuad),
		)
	}
	
	func deselect() {
		if !isSelected {
			return
		}
		isSelected = false
		
		bgSprite.image = ConfigMenuItem.bgBitmapTable[0]!
		
		xAnimator = FloatAnimator(
			duration: 0.5,
			startValue: offsetX + ConfigMenuItem.SELECTED_OFFSET_X,
			endValue: offsetX,
			easingFn: EasingFn.basic(Ease.outQuad),
		)
	}
}

