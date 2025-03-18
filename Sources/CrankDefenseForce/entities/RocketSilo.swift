import PlaydateKit

nonisolated(unsafe) let siloBBitmap = try! Graphics.Bitmap(path: "siloB.png")

nonisolated(unsafe) let siloABitmap = try! Graphics.Bitmap(path: "siloA.png")

let DEFAULT_THRUST: Float = 42.0;

class RocketSilo: BaseEntity {
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
	static let SILO_SPAWN_Y: Float = 220;
	static let SILO_SPAWN_MOVEMENT: Float = 16;
	static let SILO_B_SPAWN_X: Float = 14;
	static let SILO_A_SPAWN_X: Float = 386;
	
	let sprite = Sprite.Sprite()
	
	let siloType: SiloType
	
	var readyForLaunch = true
	
	var rocket: Rocket?
	
	var rocketPrepAnimator: FloatAnimator?
	
	init(_ config: Config) {
		siloType = config.siloType
		
		super.init(config.entityStore)
		
		switch config.siloType {
		case .b:
			sprite.image = siloBBitmap
			sprite.center = Point(x: 0.0, y: 1.0)
			sprite.moveTo(Point(x: 0.0, y: 240.0))
		case .a:
			sprite.image = siloABitmap
			sprite.center = Point(x: 1.0, y: 1.0)
			sprite.moveTo(Point(x: 400.0, y: 240.0))
		}
		
		sprite.zIndex = 50
		
		sprite.addToDisplayList()
		
		self.spawnInitialRocket()
	}
	
	override func update() {
		if let animator = rocketPrepAnimator {
			animator.update()
			
			self.rocket!.moveTo(position: Point(
				x: self.rocket!.x,
				y: animator.currentValue
			))
			
			if animator.ended {
				rocketPrepAnimator = nil
				readyForLaunch = true
			}
		}
	}
	
	func attemptLaunch()-> Bool {
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
			rocket.sprite.zIndex = 30
			rocket.setThrust(newThrust: DEFAULT_THRUST)
			
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
		
		rocketPrepAnimator = FloatAnimator(FloatAnimator.Config(
			duration: RocketSilo.BASE_ROCKET_PREP_DURATION,
			startValue: RocketSilo.SILO_SPAWN_Y,
			endValue: RocketSilo.SILO_SPAWN_Y - RocketSilo.SILO_SPAWN_MOVEMENT,
			easingFn: EasingFn.overshoot(Ease.inBack)
		))
	}
	
	private func spawnInitialRocket() {
		spawnRocket(at: Point(
			x: spawnX,
			y: RocketSilo.SILO_SPAWN_Y - RocketSilo.SILO_SPAWN_MOVEMENT
		))
	}
	
	private func spawnRocket(at: Point) {
		self.rocket = Rocket(Rocket.Config(
			position: at,
			angle: 0.0,
			entityStore: self.entityStore
		))
		self.rocket?.sprite.collisionsEnabled = false
	}
}
