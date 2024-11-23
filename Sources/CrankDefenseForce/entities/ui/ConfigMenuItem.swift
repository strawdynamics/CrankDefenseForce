import PlaydateKit

class ConfigMenuItem: BaseEntity {
	static nonisolated(unsafe) let bgBitmapTable = try! Graphics.BitmapTable(path: "configMenuItemBg.png")
	
	static let SELECTED_OFFSET_X: Float = 24
	
	struct Config {
		let offsetX: Float
		let entityStore: EntityStore
	}
	
	class Sprite: PlaydateKit.Sprite.Sprite {
		var isSelected = false
		
		override init() {
			super.init()
			self.center = Point(x: 0, y: 0.5)
			self.setSize(width: 192, height: 44)
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.pushContext(nil)
			
			Graphics.drawBitmap(
				ConfigMenuItem.bgBitmapTable[isSelected ? 1 : 0]!,
				at: bounds.origin
			)
			
			Graphics.drawMode = .fillWhite
			
			Graphics.popContext()
		}
	}
	
	let offsetX: Float
	
	private var isSelected = false
	
	var sprite = Sprite()
	
	var xAnimator: FloatAnimator?
	
	init(_ config: Config) {
		offsetX = config.offsetX
		
		super.init(config.entityStore)
	
		sprite.moveTo(Point(x: config.offsetX, y: 0))
		sprite.addToDisplayList()
	}
	
	override func update() {
		if let xAnimator = xAnimator {
			xAnimator.update()
			
			sprite.moveTo(Point(x: xAnimator.currentValue, y: sprite.position.y))
			
			if xAnimator.ended {
				self.xAnimator = nil
			}
		}
	}
	
	func moveTo(y: Float) {
		sprite.moveTo(Point(x: sprite.position.x, y: y))
	}
	
	func select() {
		if isSelected {
			return
		}
		isSelected = true
		sprite.isSelected = true
		
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
		sprite.isSelected = false
		
		xAnimator = FloatAnimator(
			duration: 0.5,
			startValue: offsetX + ConfigMenuItem.SELECTED_OFFSET_X,
			endValue: offsetX,
			easingFn: EasingFn.basic(Ease.outQuad),
		)
	}
}

