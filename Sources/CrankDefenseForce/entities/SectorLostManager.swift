import PlaydateKit

class SectorLostManager: BaseEntity {
	// MARK: Lifecycle

	init(_ config: Config) {
		matchStatsTracker = config.matchStatsTracker
		vhsEffect = VhsEffect(config.entityStore)
		
		// Init after VhsEffect so lateUpdate runs after!
		sectorLostText = SectorLostText(config.entityStore)

		super.init(config.entityStore)
	}

	// MARK: Internal

	struct Config {
		let matchStatsTracker: MatchStatsTracker
		let entityStore: EntityStore
	}

	let matchStatsTracker: MatchStatsTracker

	let vhsEffect: VhsEffect

	let sectorLostText: SectorLostText

	override func update() {
		vhsEffect.offY = offY

		updateInput()

		switch state {
		case .textEntering:
			updateTextEntering()
		case .updateScrollEntering:
			updateScrollEntering()
		case .running:
			updateRunning()
		}
	}

	// MARK: Private

	private enum State {
		case textEntering
		case updateScrollEntering
		case running
	}

	private var state: State = .textEntering

	private var offY = 0

	private func updateInput() {
		offY = min(offY - Int(System.crankChange), 0)

		let current = System.buttonState.current

		if current.contains(.up) {
			offY += 4
		} else if current.contains(.down) {
			offY -= 4
		}

		Graphics.setDrawOffset(dx: 0, dy: offY)
	}

	private func updateTextEntering() {

	}

	private func updateScrollEntering() {

	}

	private func updateRunning() {

	}
}
