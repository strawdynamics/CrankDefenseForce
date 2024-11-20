import PlaydateKit

nonisolated(unsafe) let playerCursorBitmapTable = try! Graphics.BitmapTable(path: "playerCursor.png")

let CURSOR_SPEED: Float = 1000.0

let SHOW_DURATION: Float = 2.8
let HIDE_DURATION: Float = 0.2

class PlayerCursor: BaseEntity {
	var sprite: Sprite.Sprite
	
	private var isVisible = false
	
	private var isAnimating = false
	private var animTime: Float = 0
	private var animStartFrame: Float = 0
	private var animTargetFrame: Float = 0
	private var currentFrame: Int = 0
	private var animEasingFn: EasingFn = EasingFn.elastic(Ease.outElastic)
	private var animDuration: Float = 0
	
	override init(_ entityStore: EntityStore) {
		let sprite = Sprite.Sprite()
		sprite.image = playerCursorBitmapTable[0]
		sprite.moveTo(Point(x: 200.0, y: 120.0))
		sprite.addToDisplayList()
		sprite.zIndex = 80
		self.sprite = sprite
		
		super.init(entityStore)
	}
	
	override func update() {
		if isAnimating {
			animTime += Time.deltaTime
			
			let easedFrame = animEasingFn.ease(animTime, animStartFrame, animTargetFrame - animStartFrame, animDuration, 0.3, 0.7)
			
			currentFrame = Int(fmaxf(0, easedFrame).rounded())
			sprite.image = playerCursorBitmapTable[currentFrame]
			
			if animTime > animDuration {
				currentFrame = Int(animTargetFrame)
				isAnimating = false
			}
		}
	}
	
	func moveTo(point: Point) {
		self.sprite.moveTo(point)
	}
	
	func moveToward(dest: Point) {
		let cur = self.sprite.position
		
		let diffX = dest.x - cur.x
		let diffY = dest.y - cur.y
		
		let dist = (diffX * diffX + diffY * diffY).squareRoot()
		
		let dirX = diffX / dist
		let dirY = diffY / dist
		
		let speed = CURSOR_SPEED * Time.deltaTime
		
		if dist < speed {
			moveTo(point: dest)
		} else {
			moveTo(point: Point(
				x: cur.x + dirX * speed,
				y: cur.y + dirY * speed,
			))
		}
	}
	
	func show() {
		if isVisible {
			return
		}
		isVisible = true
		
		isAnimating = true
		animDuration = SHOW_DURATION
		animEasingFn = EasingFn.elastic(Ease.outElastic)
		animTime = 0
		animStartFrame = Float(currentFrame)
		animTargetFrame = 10
	}
	
	func hide() {
		if !isVisible {
			return
		}
		isVisible = false
		
		isAnimating = true
		animDuration = HIDE_DURATION
		animEasingFn = EasingFn.basic(Ease.inOutQuad)
		animTime = 0
		animStartFrame = Float(currentFrame)
		animTargetFrame = 0
	}
}
