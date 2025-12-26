import PlaydateKit

class RocketSilo: BaseEntity {
	static let DEFAULT_THRUST: Float = 42.0

	nonisolated(unsafe) static let siloBBitmap = try! Graphics.Bitmap(
		path: "entities/RocketSilo/siloB")

	nonisolated(unsafe) static let siloABitmap = try! Graphics.Bitmap(
		path: "entities/RocketSilo/siloA")

	nonisolated(unsafe) static let siloBNightBitmap = try! Graphics.Bitmap(
		path: "entities/RocketSilo/siloBNight")

	nonisolated(unsafe) static let siloANightBitmap = try! Graphics.Bitmap(
		path: "entities/RocketSilo/siloANight")

	nonisolated(unsafe) static let siloIconsBitmapTable = try! Graphics.BitmapTable(
		path: "entities/RocketSilo/siloIcons")

	struct LaunchEventPayload {
		var rocket: Rocket
	}
	struct LaunchEvent: EventProtocol {
		typealias Payload = LaunchEventPayload
	}
	nonisolated(unsafe) static var launchEmitter = EventEmitter<LaunchEvent>()

	enum SiloType {
		case b
		case a
	}

	struct Config {
		let siloType: SiloType
		let entityStore: EntityStore
	}

	static let BASE_ROCKET_PREP_DURATION: Float = 2.5
	static let SILO_SPAWN_Y: Float = 220
	static let SILO_SPAWN_MOVEMENT: Float = 16
	static let SILO_B_SPAWN_X: Float = 14
	static let SILO_A_SPAWN_X: Float = 386

	let sprite = Sprite.Sprite()

	let iconSprite = Sprite.Sprite()

	let siloType: SiloType

	var readyForLaunch = true

	var rocket: Rocket?

	var rocketPrepAnimator: Animator<Float>?

	var prepSfxAnimator: Animator<Float>?

	init(_ config: Config) {
		siloType = config.siloType

		super.init(config.entityStore)

		iconSprite.center = Point(x: 0.5, y: 1.0)

		switch config.siloType {
		case .b:
			sprite.image = GameSettings.timeOfDay == .day ? Self.siloBBitmap : Self.siloBNightBitmap
			sprite.center = Point(x: 0.0, y: 1.0)
			sprite.moveTo(Point(x: 0, y: Display.height - 11))

			iconSprite.image =
				GameSettings.controlScheme == .leftyLauncher
				? Self.siloIconsBitmapTable[2] : Self.siloIconsBitmapTable[0]
			iconSprite.moveTo(Point(x: 14, y: Display.height))
		case .a:
			sprite.image = GameSettings.timeOfDay == .day ? Self.siloABitmap : Self.siloANightBitmap
			sprite.center = Point(x: 1.0, y: 1.0)
			sprite.moveTo(Point(x: Display.width, y: Display.height - 11))

			iconSprite.image =
				GameSettings.controlScheme == .leftyLauncher
				? Self.siloIconsBitmapTable[3] : Self.siloIconsBitmapTable[1]
			iconSprite.moveTo(Point(x: Display.width - 14, y: Display.height))
		}

		sprite.zIndex = 110
		sprite.addToDisplayList()

		iconSprite.zIndex = 160
		iconSprite.addToDisplayList()

		self.spawnInitialRocket()
	}

	override func update() {
		if let animator = prepSfxAnimator {
			animator.update()

			if animator.ended {
				prepSfxAnimator = nil
				Sfx.instance.play(.siloPrep)
			}
		}

		if let animator = rocketPrepAnimator {
			animator.update()

			self.rocket!.moveTo(
				position: Point(
					x: self.rocket!.x,
					y: animator.currentValue
				))

			if animator.ended {
				rocketPrepAnimator = nil
				readyForLaunch = true
			}
		}
	}

	func attemptLaunch() -> Bool {
		if readyForLaunch {
			launch()
			return true
		} else {
			abortLaunch()
			return false
		}
	}

	private func launch() {
		if let rocket = self.rocket {
			readyForLaunch = false
			rocket.sprite.collisionsEnabled = true
			rocket.setThrust(newThrust: Self.DEFAULT_THRUST)

			Self.launchEmitter.emit(LaunchEventPayload(rocket: rocket))

			prepareNextRocket()
		}
	}

	private func abortLaunch() {
		// TODO: Anim/sfx
	}

	private var spawnX: Float {
		let x: Float
		switch self.siloType {
		case .b:
			x = RocketSilo.SILO_B_SPAWN_X
		case .a:
			x = RocketSilo.SILO_A_SPAWN_X
		}

		return x
	}

	private func prepareNextRocket() {
		spawnRocket(at: Point(x: spawnX, y: RocketSilo.SILO_SPAWN_Y))

		prepSfxAnimator = Animator(
			Animator.Config(
				duration: RocketSilo.BASE_ROCKET_PREP_DURATION - 0.55,
				startValue: 0,
				endValue: 1,
				easingFn: EasingFn.basic(Ease.linear)
			))

		rocketPrepAnimator = Animator(
			Animator.Config(
				duration: RocketSilo.BASE_ROCKET_PREP_DURATION,
				startValue: RocketSilo.SILO_SPAWN_Y,
				endValue: RocketSilo.SILO_SPAWN_Y - RocketSilo.SILO_SPAWN_MOVEMENT,
				easingFn: EasingFn.overshoot(Ease.inBack)
			))
	}

	private func spawnInitialRocket() {
		spawnRocket(
			at: Point(
				x: spawnX,
				y: RocketSilo.SILO_SPAWN_Y - RocketSilo.SILO_SPAWN_MOVEMENT
			))
	}

	private func spawnRocket(at: Point) {
		self.rocket = Rocket(
			Rocket.Config(
				position: at,
				angle: 0.0,
				entityStore: self.entityStore,
				owner: .player
			))
		self.rocket?.sprite.collisionsEnabled = false
	}
}
