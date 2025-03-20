import PlaydateKit

class BigUfo: BaseEntity {
	nonisolated(unsafe) static let bigUfoBitmapTable = try! Graphics.BitmapTable(path: "bigUfo.png")
	
	static let MOVE_TO_BUILDING_FRAME: Int = 0
	
	static let CHARGE_LASER_FRAMES = 1...9
	
	static let DESTROYED_FRAME: Int = 10
	
	static let MOVE_TO_BUILDING_Y_PPS: Float = 30
	
	private enum Activity {
		case moveToBuilding
		case chargeLaser
		case fireLaser
		case leave
		case crashLand
	}
	
	struct Config {
		var city: City
		var entityStore: EntityStore
		var position: Point
	}
	
	var sprite = Sprite.Sprite()
	
	var city: City
	
	var targetBuilding: Building?
	
	private var _currentActivity = Activity.moveToBuilding
	
	private(set) var destroyed = false
	
	private var currentActivity: Activity {
		get {
			return _currentActivity
		}
		
		set(newActivity) {
			let oldActivity = _currentActivity
			
			if newActivity == .moveToBuilding {
				beginMovingToBuilding()
			}
			
			_currentActivity = newActivity
		}
	}
	
	private var moveToBuildingXAnimator: FloatAnimator?
	private var moveToBuildingYAnimator: FloatAnimator?
	
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
			break
		case .fireLaser:
			break
		case .leave:
			break
		case .crashLand:
			break
		}
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
	
	private func beginMovingToBuilding() {
		guard let target = targetBuilding else { return }
		let buildingPos = target.position
		
		let startX = sprite.position.x
		let endX = buildingPos.x + Float.random(in: -5..<5)
		let deltaX = fabsf(endX - startX)
		
		moveToBuildingXAnimator = FloatAnimator(FloatAnimator.Config(
			duration: deltaX / Self.MOVE_TO_BUILDING_Y_PPS,
			startValue: startX,
			endValue: endX,
			easingFn: EasingFn.basic(Ease.inOutQuad),
		))
		
		let startY = sprite.position.y
		let endY = startY + 2
		moveToBuildingYAnimator = FloatAnimator(FloatAnimator.Config(
			duration: 0.4,
			startValue: startY,
			endValue: endY,
			easingFn: EasingFn.basic(Ease.inOutQuad),
			loopMode: .pingPong,
		))
	}
	
	private func pickTargetBuilding() {
		targetBuilding = city.buildings.filter({
			!$0.destroyed
		}).randomElement()
		
		if targetBuilding == nil {
			currentActivity = .leave
		} else {
			currentActivity = .moveToBuilding
		}
	}
}
