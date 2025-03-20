import PlaydateKit

class BigUfo: BaseEntity {
	nonisolated(unsafe) static let bigUfoBitmapTable = try! Graphics.BitmapTable(path: "bigUfo.png")
	
	nonisolated(unsafe) static let laserBitmap = try! Graphics.Bitmap(path: "bigUfoLaser.png")
	
	static let MOVE_TO_BUILDING_FRAME: Int = 0
	
	static let CHARGE_LASER_FRAMES = 1...9
	
	static let DESTROYED_FRAME: Int = 10
	
	static let MOVE_TO_BUILDING_Y_PPS: Float = 30
	
	class BigUfoSprite: Sprite.Sprite {
		var bigUfoId: Int = -1
	}
	
	private enum Activity {
		case moveToBuilding
		case chargeLaser
		case fireLaser
		case leavingDestroyed
		case idle
	}
	
	struct Config {
		var city: City
		var entityStore: EntityStore
		var position: Point
	}
	
	var sprite = BigUfoSprite()
	
	var laserSprite = BigUfoSprite()
	
	var city: City
	
	var targetBuilding: Building?
	
	private var _currentActivity = Activity.moveToBuilding
	
	private(set) var destroyed = false
	
	private var laserYOffset: Float = 0
	
	private var laserYOffsetAnimator: Animator<Float>?
	
	private var currentActivity: Activity {
		get {
			return _currentActivity
		}
		
		set(newActivity) {
			let oldActivity = _currentActivity
			
			if newActivity == .moveToBuilding {
				enterMoveToBuilding()
			} else if newActivity == .chargeLaser {
				enterChargeLaser()
			}
			
			_currentActivity = newActivity
		}
	}
	
	private var moveToBuildingXAnimator: Animator<Float>?
	private var moveToBuildingYAnimator: Animator<Float>?
	
	private var chargeLaserYAnimator: Animator<Float>?
	
	init(_ config: Config) {
		let bitmap = Self.bigUfoBitmapTable[0]!
		let (bitmapWidth, bitmapHeight, _) = bitmap.getData(mask: nil, data: nil)
		
		sprite.image = bitmap
		sprite.moveTo(config.position)
		sprite.collideRect = Rect.init(
			x: 0,
			y: 0,
			width: bitmapWidth,
			height: bitmapHeight
		)
		
		let laserBitmap = Self.laserBitmap
		let (laserBitmapWidth, laserBitmapHeight, _) = laserBitmap.getData(mask: nil, data: nil)
		laserSprite.image = laserBitmap
		laserSprite.center = Point(x: 0.5, y: 0.0)
		laserSprite.moveTo(config.position)
		laserSprite.collideRect = Rect.init(
			x: 0,
			y: 0,
			width: laserBitmapWidth,
			height: laserBitmapHeight
		)
		
		laserSprite.addToDisplayList()
		sprite.addToDisplayList()
		
		city = config.city
		
		super.init(config.entityStore)
		
		pickTargetBuilding()
	}
	
	override func update() {
		switch currentActivity {
		case .moveToBuilding:
			updateMoveToBuilding()
		case .chargeLaser:
			updateChargeLaser()
		case .fireLaser:
			break
		case .leavingDestroyed:
			break
		case .idle:
			break
		}
		
		updateLaser()
	}
	
	private func updateMoveToBuilding() {
		guard let target = targetBuilding else {
			pickTargetBuilding()
			return
		}
		
		if target.destroyed {
			pickTargetBuilding()
			return
		}
		
		guard let xAnim = moveToBuildingXAnimator else { return }
		guard let yAnim = moveToBuildingYAnimator else { return }
		xAnim.update()
		yAnim.update()
		
		sprite.moveTo(Point(
			x: xAnim.currentValue,
			y: yAnim.currentValue
		))
		
		if xAnim.ended {
			currentActivity = .chargeLaser
		}
	}
	
	private func updateChargeLaser() {
		guard let target = targetBuilding else {
			pickTargetBuilding()
			return
		}
		
		if target.destroyed {
			pickTargetBuilding()
			return
		}
		
		guard let yAnim = chargeLaserYAnimator else { return }
		yAnim.update()
		sprite.moveTo(Point(
			x: sprite.position.x,
			y: yAnim.currentValue.rounded()
		))
		
		if let laserYAnim = laserYOffsetAnimator {
			laserYAnim.update()
			
			laserYOffset = laserYAnim.currentValue
			
			if laserYAnim.ended {
				laserYOffsetAnimator = nil
			}
		}
	}
	
	private func enterMoveToBuilding() {
		guard let target = targetBuilding else { return }
		let buildingPos = target.position
		
		let startX = sprite.position.x
		let endX = buildingPos.x + Float.random(in: -5..<5)
		let deltaX = fabsf(endX - startX)
		
		moveToBuildingXAnimator = Animator(Animator.Config(
			duration: deltaX / Self.MOVE_TO_BUILDING_Y_PPS,
			startValue: startX,
			endValue: endX,
			easingFn: EasingFn.basic(Ease.inOutQuad),
		))
		
		let startY = sprite.position.y
		let endY = startY + 2
		moveToBuildingYAnimator = Animator(Animator.Config(
			duration: 0.5,
			startValue: startY,
			endValue: endY,
			easingFn: EasingFn.basic(Ease.inOutQuad),
			loopMode: .pingPong,
		))
	}
	
	private func enterChargeLaser() {
		laserYOffsetAnimator = Animator(Animator.Config(
			duration: 2.0,
			startValue: 0,
			endValue: 24,
			easingFn: EasingFn.basic(Ease.outQuad),
		))

		chargeLaserYAnimator = Animator(Animator.Config(
			duration: 0.5,
			startValue: sprite.position.y,
			endValue: sprite.position.y + 2,
			easingFn: EasingFn.basic(Ease.inOutQuad),
			loopMode: .pingPong
		))
	}
	
	private func updateLaser() {
		laserSprite.moveTo(sprite.position + Point(x: 0, y: laserYOffset))
	}
	
	private func pickTargetBuilding() {
		targetBuilding = city.buildings.filter({
			!$0.destroyed
		}).randomElement()
		
		if targetBuilding == nil {
			currentActivity = .idle
		} else {
			currentActivity = .moveToBuilding
		}
	}
}
