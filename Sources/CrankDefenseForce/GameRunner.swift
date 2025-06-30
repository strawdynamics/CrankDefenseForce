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

	var state: State = .active

	var offY = 0

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

	var goSprite: Sprite.Sprite?

	func lose() {
		state = .sectorLost

//		let spr = Sprite.Sprite()
//		spr.image = Graphics.Bitmap(width: 300, height: 300, bgColor: .white)
//		Graphics.pushContext(spr.image)
//		Graphics.drawRect(Rect(x: 5, y: 5, width: 290, height: 290), color: .black)
//		Graphics.popContext()
//
//		spr.moveTo(Point(x: 0, y: 0))
//
//		spr.addToDisplayList()
//		goSprite = spr
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
		updateSectorLostInputs()
	}

	private func updateSectorLostInputs() {
		offY = min(offY - Int(System.crankChange), 0)
//		offY -= Int(System.crankChange)

		Graphics.setDrawOffset(dx: 0, dy: offY)

//		let current = System.buttonState.current
//
//		if current.contains(.up) {
//			offY += 8
//		} else if current.contains(.down) {
//			offY -= 8
//		}
//
//		if current.contains(.left) {
//			offX += 8
//		} else if current.contains(.right) {
//			offX -= 8
//		}
//
//		Graphics.setDrawOffset(dx: offX, dy: offY)
	}
}
