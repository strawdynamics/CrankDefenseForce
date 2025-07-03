import PlaydateKit

class GameRunner {
	nonisolated(unsafe) static let groundBitmap = try! Graphics.Bitmap(path: "ground")

	enum State {
		case active
		case sectorLost
	}

	let entityStore = EntityStore()

	let enemyCoordinator: EnemyCoordinator

	let playerController: PlayerController

	let siloB: RocketSilo

	let siloA: RocketSilo

	let city: City

	let matchStatsTracker: MatchStatsTracker

	var state: State = .active

	init() {
		playerController = PlayerController(entityStore)
		matchStatsTracker = MatchStatsTracker()

		city = City(City.Config(
			groundHeight: 12.0,
			entityStore: entityStore
		))

		enemyCoordinator = EnemyCoordinator(EnemyCoordinator.Config(
			entityStore: entityStore,
			city: city
		))

		_ = PowerUpCollectHandler(PowerUpCollectHandler.Config(
			entityStore: entityStore,
			city: city,
			enemyCoordinator: enemyCoordinator
		))

		siloB = RocketSilo(RocketSilo.Config(
			siloType: .b,
			entityStore: entityStore
		))

		siloA = RocketSilo(RocketSilo.Config(
			siloType: .a,
			entityStore: entityStore
		))

		let bg = ImageBackground(
			entityStore: entityStore,
			backgroundType: .city
		)
		if GameSettings.timeOfDay == .night {
			bg.setDrawMode(.inverted)
		}

		let ground = StaticCollider(StaticCollider.Config(
			bitmap: Self.groundBitmap,
			entityStore: entityStore,
			zIndex: 150
		))

		ground.sprite.center = Point(x: 0.0, y: 1.0)
		ground.sprite.moveTo(Point(x: 0.0, y: Float(Display.height)))
	}

	func start() {
		enemyCoordinator.start()
	}

	func update() {
		entityStore.update()

		switch state {
		case .active:
			updateActive()
		case .sectorLost:
			updateSectorLost()
		}

		entityStore.lateUpdate()
	}

	func exit() {
		Rocket.removeEmitter.reset()
		SmallUfo.removeEmitter.reset()
		RocketSilo.launchEmitter.reset()
		PowerUp.collectEmitter.reset()
		Rocket.statsEmitter.reset()
	}

	func finish() {

	}

	func updateActive() {
		let pushed = System.buttonState.pushed
//		if city.buildings.allSatisfy({ $0.destroyed }) {
		if pushed.contains(.b) {
			lose()
			return
		}

		updateActiveInputs()
	}

	func lose() {
		state = .sectorLost
		matchStatsTracker.stop()
		
		_ = SectorLostManager(SectorLostManager.Config(
			matchStatsTracker: matchStatsTracker,
			entityStore: entityStore,
		))
	}

	private func updateActiveInputs() {
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

	func updateSectorLost() {

	}
}
