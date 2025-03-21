import PlaydateKit

class BigUfo: BaseEntity {
	nonisolated(unsafe) static let bigUfoBitmapTable = try! Graphics.BitmapTable(path: "bigUfo.png")
	
	nonisolated(unsafe) static let laserBitmap = try! Graphics.Bitmap(path: "bigUfoLaser.png")
	
	static let moveToBuildingFrame: Int = 0
	
	static let chargeLaserFrames = 1...9
	
	static let destroyedFrame: Int = 10
	
	static let moveToBuildingXPps: Float = 25
	
	private static let maxDestroyedLeavingZigZagCount = 5
	
	class BigUfoSprite: Sprite.Sprite {
		var bigUfoId: Int = -1
	}
	
	private enum Activity {
		case moveToBuilding
		case chargeLaser
		case fireLaser
		case destroyed
		case destroyedLeaving
		case idle
	}
	
	struct Config {
		var city: City
		var entityStore: EntityStore
		var position: Point
		var hitPoints: Int
	}
	
	var sprite = BigUfoSprite()
	
	var laserSprite = BigUfoSprite()
	
	var city: City
	
	var targetBuilding: Building?
	
	private var hitPoints: Int
	
	private var _currentActivity = Activity.moveToBuilding
	
	private(set) var destroyed = false
	
	private var laserYOffset: Float = 0
	
	private var laserYOffsetAnimator: Animator<Float>?
	private var laserChargeAnimator: Animator<Float>?
	
	private var destroyedLeavingZigZagCount: Int = 0
	private var destroyedLeavingPosAnimator: Animator<Point>?
	private var destroyedLeavingMovingRight = Float.random(in: 0..<1) < 0.5
	
	private var currentActivity: Activity {
		get {
			return _currentActivity
		}
		
		set(newActivity) {
			if newActivity == .moveToBuilding {
				enterMoveToBuilding()
			} else if newActivity == .chargeLaser {
				enterChargeLaser()
			} else if newActivity == .destroyed {
				enterDestroyed()
			} else if newActivity == .destroyedLeaving {
				enterDestroyedLeaving()
			}
			
			_currentActivity = newActivity
		}
	}
	
	private var moveToBuildingXAnimator: Animator<Float>?
	
	private var bobYAnimator: Animator<Float>?
	
	init(_ config: Config) {
		let bitmap = Self.bigUfoBitmapTable[0]!
		let (bitmapWidth, bitmapHeight, _) = bitmap.getData(mask: nil, data: nil)
		
		hitPoints = config.hitPoints
		
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
		
		bobYAnimator = Animator(Animator.Config(
			duration: 0.5,
			startValue: config.position.y,
			endValue: config.position.y + 2,
			easingFn: EasingFn.basic(Ease.inOutQuad),
			loopMode: .pingPong
		))
		
		city = config.city
		
		super.init(config.entityStore)
		
		sprite.bigUfoId = id
		laserSprite.bigUfoId = id
		
		pickTargetBuilding()
	}
	
	override func update() {
		switch currentActivity {
		case .moveToBuilding:
			updateMoveToBuilding()
		case .chargeLaser:
			updateChargeLaser()
		case .fireLaser:
			updateFireLaser()
		case .destroyed:
			updateDestroyed()
		case .destroyedLeaving:
			updateDestroyedLeaving()
		case .idle:
			break
		}
		
		updateBob()
		updateLaser()
	}
	
	func damage() {
		hitPoints -= 1
		
		if hitPoints <= 0 {
			currentActivity = .destroyed
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
		xAnim.update()
		
		sprite.moveTo(Point(
			x: xAnim.currentValue,
			y: sprite.position.y
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
		
		if let laserYAnim = laserYOffsetAnimator {
			laserYAnim.update()
			
			laserYOffset = laserYAnim.currentValue
			
			if laserYAnim.ended {
				laserYOffsetAnimator = nil
			}
		}
		
		if let laserChargeAnim = laserChargeAnimator {
			laserChargeAnim.update()
			
			sprite.image = Self.bigUfoBitmapTable[Int(laserChargeAnim.currentValue)]
			
			if laserChargeAnim.ended {
				laserChargeAnimator = nil
				
				currentActivity = .fireLaser
			}
		}
	}
	
	private func updateFireLaser() {
		guard let tb = targetBuilding else {
			pickTargetBuilding()
			return
		}
		
		destroyBuilding(tb)
		pickTargetBuilding()
	}
	
	private func updateDestroyed() {
		currentActivity = .destroyedLeaving
	}
	
	private func updateDestroyedLeaving() {
		guard let posAnim = destroyedLeavingPosAnimator else { return }
		posAnim.update()
		
		sprite.moveTo(posAnim.currentValue)
//		laserSprite.moveTo(posAnim.currentValue + Point(x: 0, y: laserYOffset))
		
		if posAnim.ended {
			zigZagDestroyedLeaving()
		}
	}
	
	private func enterMoveToBuilding() {
		guard let target = targetBuilding else { return }
		let buildingPos = target.position
		
		sprite.image = Self.bigUfoBitmapTable[Self.moveToBuildingFrame]
		
		let startX = sprite.position.x
		let endX = buildingPos.x + Float.random(in: -5..<5)
		let deltaX = fabsf(endX - startX)
		
		moveToBuildingXAnimator = Animator(Animator.Config(
			duration: deltaX / Self.moveToBuildingXPps,
			startValue: startX,
			endValue: endX,
			easingFn: EasingFn.basic(Ease.inOutQuad),
		))
	}
	
	private func enterChargeLaser() {
		laserYOffsetAnimator = Animator(Animator.Config(
			duration: 2.0,
			startValue: laserYOffset,
			endValue: 24,
			easingFn: EasingFn.basic(Ease.outQuad),
		))
		
		laserChargeAnimator = Animator(Animator.Config(
			duration: 5.0,
			startValue: Float(Self.chargeLaserFrames.lowerBound),
			endValue: Float(Self.chargeLaserFrames.upperBound) + 0.999,
			easingFn: EasingFn.basic(Ease.linear),
		))
	}
	
	private func enterDestroyed() {
		destroyed = true
		
		sprite.collisionsEnabled = false
		laserSprite.collisionsEnabled = false
		
		sprite.image = Self.bigUfoBitmapTable[Self.destroyedFrame]
		
		let explosionCount = Int.random(in: 3...5)
		
		for _ in 0..<explosionCount {
			let _ = Explosion(Explosion.Config(
				position: sprite.position + Point(
					x: Float.random(in: -60...60),
					y: Float.random(in: -40...40),
				),
				maxRadius: Float.random(in: 20...35),
				entityStore: entityStore,
				duration: Float.random(in: 1.5...2.2),
			))
		}
	}
	
	private func enterDestroyedLeaving() {
		zigZagDestroyedLeaving()
	}
	
	private func zigZagDestroyedLeaving() {
		destroyedLeavingPosAnimator = Animator(Animator.Config(
			duration: Float.random(in: 0.2...0.4),
			startValue: sprite.position,
			endValue: sprite.position - Point(
				x: (destroyedLeavingMovingRight ? 1 : -1) * Float.random(in: 0...40),
				y: Float.random(in: 10...25)
			),
			easingFn: EasingFn.basic(Ease.inOutQuad),
		))
		
		destroyedLeavingMovingRight = !destroyedLeavingMovingRight
		destroyedLeavingZigZagCount += 1
		if destroyedLeavingZigZagCount > Self.maxDestroyedLeavingZigZagCount {
			entityStore.remove(self)
		}
	}
	
	private func updateBob() {
		guard let yAnim = bobYAnimator else { return }
		yAnim.update()
		sprite.moveTo(Point(
			x: sprite.position.x.rounded(),
			y: yAnim.currentValue.rounded()
		))
	}
	
	private func updateLaser() {
		laserSprite.moveTo(sprite.position + Point(x: 0, y: laserYOffset))
	}
	
	private func destroyBuilding(_ building: Building) {
		let bPos = building.position
		let explosionCount = Int.random(in: 2...3)
		
		for _ in 0..<explosionCount {
			let _ = Explosion(Explosion.Config(
				position: bPos + Point(
					x: Float.random(in: -20...20),
					y: Float.random(in: -30...0),
				),
				maxRadius: Float.random(in: 20...35),
				entityStore: entityStore,
				duration: Float.random(in: 1.5...2.2),
			))
		}
		
		building.attemptDestroy()
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
