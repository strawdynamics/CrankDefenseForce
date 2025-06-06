import PlaydateKit

class BigUfo: BaseEntity, PowerUpDropper {
	static let powerUpDropTable: [PowerUp.PowerUpType: Float] = [
		.none: 1
	]
	
	var position: Point {
		return sprite.position
	}
	
	nonisolated(unsafe) static let bigUfoBitmapTable = try! Graphics.BitmapTable(path: "entities/BigUfo/bigUfo")

	nonisolated(unsafe) static let laserBitmap = try! Graphics.Bitmap(path: "entities/BigUfo/laser")

	static let moveToBuildingFrame: Int = 0
	
	static let chargeLaserFrames = 1...9
	
	static let destroyedFrame: Int = 10
	
	static let moveToBuildingXPps: Float = 25
	
	private static let maxDestroyedLeavingZigZagCount = 5
	
	private static let maxDamagedTime: Float = 1.2
	
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
	private var destroyedLeavingScaleAnimator: Animator<Float>?
	private var destroyedLeavingRotationAnimator: Animator<Float>?
	private var destroyedLeavingCurrentAngle: Float = 0.0
	private var destroyedLeavingTargetAngle: Float = 0.0
	
	private var pendingExplosions: [TimedCallback] = []
	
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
			} else if newActivity == .fireLaser {
				enterFireLaser()
			}
			
			_currentActivity = newActivity
		}
	}
	
	private var moveToBuildingXAnimator: Animator<Float>?
	
	private var bobYAnimator: Animator<Float>?
	
	private var damagedAnimator: Animator<Float>?
	private var damagedTime: Float = 0
	
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
		sprite.zIndex = 60
		
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
		laserSprite.zIndex = 59
		
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
		updatePendingExplosions()
		updateDamaged()
	}

	func explode() {
		hitPoints = 1
		damage()
	}

	func damage() {
		damagedTime = 0
		damagedAnimator = Animator(Animator.Config(
			duration: 0.15,
			startValue: 0,
			endValue: 1,
			easingFn: EasingFn.basic(Ease.linear),
			loopMode: .pingPong
		))
		
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
		guard let scaleAnim = destroyedLeavingScaleAnimator else { return }
		guard let rotAnim = destroyedLeavingRotationAnimator else { return }
		posAnim.update()
		scaleAnim.update()
		rotAnim.update()
		
		let baseImg = Self.bigUfoBitmapTable[Self.destroyedFrame]!
		let s = scaleAnim.currentValue
		let r: Float = rotAnim.currentValue
		sprite.image = baseImg.rotated(by: r, xScale: s, yScale: s).bitmap
		sprite.moveTo(posAnim.currentValue)
		laserSprite.image = Self.laserBitmap.rotated(by: r, xScale: s, yScale: s).bitmap
		
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
	
	private func enterFireLaser() {
		let _ = BigUfoBeam(BigUfoBeam.Config(
			entityStore: entityStore,
			position: sprite.position + Point(x: 0, y: laserYOffset + 20),
			duration: 0.25,
		))
	}
	
	private func enterDestroyed() {
		destroyed = true
		
		sprite.collisionsEnabled = false
		laserSprite.collisionsEnabled = false
		
		sprite.image = Self.bigUfoBitmapTable[Self.destroyedFrame]
		
		scheduleDestroyedUfoExplosions()
	}
	
	private func scheduleDestroyedUfoExplosions() {
		let explosionCount = Int.random(in: 4...6)
		var delay: Float = 0
		
		for _ in 0..<explosionCount {
			delay += Float.random(in: 0.25...0.4)

			let callback = TimedCallback(duration: delay) {
				guard let scaleAnim = self.destroyedLeavingScaleAnimator else { return }
				let s = scaleAnim.currentValue

				let _ = Explosion(Explosion.Config(
					position: self.sprite.position + Point(
						x: Float.random(in: -65...65) * s,
						y: Float.random(in: -25...25) * s
					),
					maxRadius: Float.random(in: 20...35) * s,
					entityStore: self.entityStore,
					duration: Float.random(in: 1.5...2.2)
				))
			}

			pendingExplosions.append(callback)
		}
	}
	
	private func updatePendingExplosions() {
		for i in (0..<pendingExplosions.count).reversed() {
			if pendingExplosions[i].update() {
				pendingExplosions.remove(at: i)
			}
		}
	}
	
	private func enterDestroyedLeaving() {
		zigZagDestroyedLeaving()
	}
	
	private func zigZagDestroyedLeaving() {
		let stepDur = Float.random(in: 0.5...0.8)
		
		let direction: Float = destroyedLeavingMovingRight ? 1 : -1

		// Rotation
		destroyedLeavingCurrentAngle = destroyedLeavingTargetAngle
		destroyedLeavingTargetAngle = destroyedLeavingCurrentAngle == 0 ? direction * -8.0 : -destroyedLeavingCurrentAngle
		destroyedLeavingRotationAnimator = Animator(Animator.Config(
			duration: stepDur,
			startValue: destroyedLeavingCurrentAngle,
			endValue: destroyedLeavingTargetAngle,
			easingFn: EasingFn.basic(Ease.inOutQuad)
		))
		
		// Position
		destroyedLeavingPosAnimator = Animator(Animator.Config(
			duration: stepDur,
			startValue: sprite.position,
			endValue: sprite.position - Point(
				x: direction * Float.random(in: 35...60),
				y: Float.random(in: 8...16)
			),
			easingFn: EasingFn.basic(Ease.inOutQuad),
		))
		
		// Scale
		let startScale = 1 - (Float(destroyedLeavingZigZagCount) * 0.2)
		destroyedLeavingScaleAnimator = Animator(Animator.Config(
			duration: stepDur,
			startValue: startScale,
			endValue: startScale - 0.2,
			easingFn: EasingFn.basic(Ease.inOutQuad),
		))
		
		destroyedLeavingMovingRight = !destroyedLeavingMovingRight
		destroyedLeavingZigZagCount += 1
		if destroyedLeavingZigZagCount > Self.maxDestroyedLeavingZigZagCount {
			entityStore.remove(self)
		}
	}
	
	private func updateBob() {
		guard currentActivity != .destroyedLeaving else { return }
		guard let yAnim = bobYAnimator else { return }
		yAnim.update()
		sprite.moveTo(Point(
			x: sprite.position.x.rounded(),
			y: yAnim.currentValue.rounded()
		))
	}
	
	private func updateLaser() {
		var scale: Float = 1
		if let scaleAnim = destroyedLeavingScaleAnimator {
			scale = scaleAnim.currentValue
		}
		
		var offset = Point(x: 0, y: laserYOffset * scale)

		if currentActivity == .destroyedLeaving, let rotation = destroyedLeavingRotationAnimator?.currentValue {
				let radians = rotation * .pi / 180
				let sinA = sinf(radians)
				let cosA = cosf(radians)

				offset = Point(
					x: offset.x * cosA - offset.y * sinA,
					y: offset.x * sinA + offset.y * cosA
				)
			}
		
		laserSprite.moveTo(sprite.position + offset)
	}
	
	private func updateDamaged() {
		guard let damAnim = damagedAnimator else { return }
		damAnim.update()
		damagedTime += Time.deltaTime
		
		if damagedTime > Self.maxDamagedTime {
			damagedAnimator = nil
			sprite.setDrawMode(.copy)
			laserSprite.setDrawMode(.copy)
		} else {
			let dm: LCDBitmapDrawMode = damAnim.currentValue.rounded() == 1 ? .inverted : .copy
			sprite.setDrawMode(dm)
			laserSprite.setDrawMode(dm)
		}
	}
	
	private func destroyBuilding(_ building: Building) {
		let destroyed = building.attemptDestroy()
		
		if destroyed {
			scheduleDestroyedBuildingExplosions(building)
		}
	}
	
	private func scheduleDestroyedBuildingExplosions(_ building: Building) {
		let bPos = building.position
		let explosionCount = Int.random(in: 3...4)
		var delay: Float = 0
		
		for _ in 0..<explosionCount {
			let callback = TimedCallback(duration: delay) {
				let _ = Explosion(Explosion.Config(
					position: bPos + Point(
						x: Float.random(in: -20...20),
						y: Float.random(in: -30...0),
					),
					maxRadius: Float.random(in: 20...35),
					entityStore: self.entityStore,
					duration: Float.random(in: 1.5...2.2),
				))
			}

			pendingExplosions.append(callback)
			
			delay += Float.random(in: 0.05...0.2)
		}
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
