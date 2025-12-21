import PlaydateKit

nonisolated(unsafe) private let SCREEN_CENTER = Point(x: 200.0, y: 120.0)

class PlayerController: BaseEntity {
	private static let CRANK_COEFFICIENT: Float = 0.3

	private static let DPAD_TURN_DEGREES_PER_SECOND: Float = 360.0

	enum PlayerInput {
		case launchSiloB
		case launchSiloA
		case selectPreviousRocket
		case selectNextRocket
		case turnRocket(Float)
	}

	private var cursor: PlayerCursor

	private(set) var currentRocket: Rocket?

	private var rockets: [Rocket] = []

	private(set) var inputs: [PlayerInput] = []

	private var currentRocketIndex: Int = -1

	override init(_ entityStore: EntityStore) {
		self.cursor = PlayerCursor(entityStore)
		super.init(entityStore)

		let _ = RocketSilo.launchEmitter.on(handleRocketLaunch)
		let _ = Rocket.removeEmitter.on(handleRocketRemove)
	}

	func handleRocketLaunch(payload: RocketSilo.LaunchEventPayload) {
		currentRocket = payload.rocket
		currentRocketIndex = rockets.count
		rockets.append(payload.rocket)
	}

	func handleRocketRemove(payload: Rocket.RemoveEventPayload) {
		let removedCurrentRocket = payload.rocket.id == self.currentRocket?.id
		if removedCurrentRocket {
			self.currentRocket = nil
		}

		rockets.removeAll { rocket in
			let shouldRemove = rocket.id == payload.rocket.id

			return shouldRemove
		}

		if removedCurrentRocket && rockets.count > 0 {
			currentRocketIndex = rockets.count - 1
			currentRocket = rockets[currentRocketIndex]
		}
	}

	func turn(degrees: Float) {
		currentRocket?.changeAngle(delta: degrees)
	}

	func selectNextRocket() {
		if rockets.count == 0 {
			currentRocketIndex = -1
			return
		}

		if currentRocketIndex >= self.rockets.count - 1 {
			currentRocketIndex = 0
		} else {
			currentRocketIndex += 1
		}

		currentRocket = rockets[currentRocketIndex]
	}

	func selectPreviousRocket() {
		if rockets.count == 0 {
			currentRocketIndex = -1
			return
		}

		if currentRocketIndex <= 0 {
			currentRocketIndex = rockets.count - 1
		} else {
			currentRocketIndex -= 1
		}

		currentRocket = rockets[currentRocketIndex]
	}

	override func update() {
		updateInputs()
	}

	override func lateUpdate() {
		updateCursor()
	}

	private func updateInputs() {
		inputs.removeAll()

		switch GameSettings.controlScheme {
		case .standard:
			updateStandardInputs()
		case .leftyLauncher:
			updateLeftyLauncherInputs()
		case .lrSwitch:
			updateLrSwitchInputs()
		}
	}

	private func updateStandardInputs() {
		let pushed = System.buttonState.pushed

		// Launch
		if pushed.contains(.b) {
			inputs.append(.launchSiloB)
		}

		if pushed.contains(.a) {
			inputs.append(.launchSiloA)
		}

		// Switch
		if pushed.contains(.down) {
			inputs.append(.selectPreviousRocket)
		} else if pushed.contains(.up) {
			inputs.append(.selectNextRocket)
		}

		// Turn
		let current = System.buttonState.current

		if current.contains(.left) {
			inputs.append(.turnRocket(Time.deltaTime * -Self.DPAD_TURN_DEGREES_PER_SECOND))
		} else if current.contains(.right) {
			inputs.append(.turnRocket(Time.deltaTime * Self.DPAD_TURN_DEGREES_PER_SECOND))
		}

		updateCrankInput()
	}

	private func updateLeftyLauncherInputs() {
		let pushed = System.buttonState.pushed

		// Launch
		if pushed.contains(.left) {
			inputs.append(.launchSiloB)
		}

		if pushed.contains(.right) {
			inputs.append(.launchSiloA)
		}

		// Switch
		if pushed.contains(.down) {
			inputs.append(.selectPreviousRocket)
		} else if pushed.contains(.up) {
			inputs.append(.selectNextRocket)
		}

		// Turn
		let current = System.buttonState.current

		if current.contains(.b) {
			inputs.append(.turnRocket(Time.deltaTime * -Self.DPAD_TURN_DEGREES_PER_SECOND))
		} else if current.contains(.a) {
			inputs.append(.turnRocket(Time.deltaTime * Self.DPAD_TURN_DEGREES_PER_SECOND))
		}

		updateCrankInput()
	}

	private func updateLrSwitchInputs() {
		let pushed = System.buttonState.pushed

		// Launch
		if pushed.contains(.b) {
			inputs.append(.launchSiloB)
		}

		if pushed.contains(.a) {
			inputs.append(.launchSiloA)
		}

		// Switch
		if pushed.contains(.left) {
			inputs.append(.selectPreviousRocket)
		} else if pushed.contains(.right) {
			inputs.append(.selectNextRocket)
		}

		updateCrankInput()
	}

	private func updateCrankInput() {
		let crankChange = System.crankChange

		if crankChange != 0.0 {
			inputs.append(.turnRocket(crankChange * Self.CRANK_COEFFICIENT))
		}
	}

	private func updateCursor() {
		if let rocket = currentRocket {
			cursor.moveToward(dest: rocket.position)
			cursor.show()
		} else {
			cursor.hide()
		}
	}
}
