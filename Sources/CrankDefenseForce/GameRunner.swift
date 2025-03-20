import PlaydateKit

nonisolated(unsafe) let groundBitmap = try! Graphics.Bitmap(path: "ground.png")

class GameRunner {
	let entityStore = EntityStore()
	
	let enemyCoordinator: EnemyCoordinator
		
	let playerController: PlayerController
	
	let siloB: RocketSilo
	
	let siloA: RocketSilo
	
	let city: City
	
	init() {
		playerController = PlayerController(entityStore)
		
		city = City(City.Config(
			groundHeight: 12.0,
			entityStore: entityStore
		))
		
		enemyCoordinator = EnemyCoordinator(EnemyCoordinator.Config(
			entityStore: entityStore,
			city: city
		))
		
		siloB = RocketSilo(RocketSilo.Config(
			siloType: .b,
			entityStore: entityStore
		))
		
		siloA = RocketSilo(RocketSilo.Config(
			siloType: .a,
			entityStore: entityStore
		))
		
		let _ = Rocket.removeEmitter.on(handleRocketRemove)
		
		let bg = ImageBackground(
			entityStore: entityStore,
			backgroundType: .city
		)
		if GameSettings.timeOfDay == .night {
			bg.setDrawMode(.inverted)
		}
		
		let ground = StaticCollider(StaticCollider.Config(
			bitmap: groundBitmap,
			entityStore: entityStore,
		))
		
		ground.sprite.center = Point(x: 0.0, y: 1.0)
		ground.sprite.moveTo(Point(x: 0.0, y: 240.0))
	}
	
	func handleRocketRemove(payload: Rocket.RemoveEventPayload) {
		entityStore.remove(payload.rocket)
	}
	
	func start() {
		enemyCoordinator.start()
	}
	
	func update() {
		entityStore.update()
		
		updateInputs()
		
		entityStore.lateUpdate()
		
		Graphics.drawText("somanyents \(entityStore.entityCount)", at: Point.zero)
	}
	
	func exit() {
		Rocket.removeEmitter.reset()
		RocketSilo.launchEmitter.reset()
	}

	func finish() {

	}
	
	private func updateInputs() {
		let inputs = playerController.inputs
		
		for input in inputs {
			switch input {
			case .launchSiloB:
				let _ = siloB.attemptLaunch()
			case .launchSiloA:
				let _ = siloA.attemptLaunch()
			case .selectNextRocket:
				playerController.selectNextRocket()
			case .selectPreviousRocket:
				playerController.selectPreviousRocket()
			case .turnRocket(let degrees):
				playerController.turn(degrees: degrees)
			}
		}
	}
}
