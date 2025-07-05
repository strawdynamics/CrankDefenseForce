import PlaydateKit

class SectorLostManager: BaseEntity {
	// MARK: Lifecycle

	init(_ config: Config) {
		matchStatsTracker = config.matchStatsTracker
		sectorLostDisplay = SectorLostDisplay(SectorLostDisplay.Config(
			matchStatsTracker: config.matchStatsTracker,
			entityStore: config.entityStore,
		))
		vcrEffect = VcrEffect(config.entityStore)

		// Init after VcrEffect so lateUpdate runs after!
		sectorLostText = SectorLostText(config.entityStore)

		super.init(config.entityStore)
	}

	// MARK: Internal

	struct Config {
		let matchStatsTracker: MatchStatsTracker
		let entityStore: EntityStore
	}

	let matchStatsTracker: MatchStatsTracker

	let vcrEffect: VcrEffect

	let sectorLostText: SectorLostText

	let sectorLostDisplay: SectorLostDisplay

	override func update() {
		vcrEffect.offY = offY

		switch state {
		case .textEntering:
			updateTextEntering()
		case .updateScrollEntering:
			updateScrollEntering()
		case .running:
			updateRunning()
		}
	}

	override func lateUpdate() {
		// lateUpdate input to avoid SectorLostText position offset while scrolling
		updateInput()
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
		let current = System.buttonState.current

		if current.contains(.up) {
			offY += 4
		} else if current.contains(.down) {
			offY -= 4
		}

		offY = max(min(offY - Int(System.crankChange), 0), -sectorLostDisplay.totalHeight)

		Graphics.setDrawOffset(dx: 0, dy: offY)
	}

	private func updateTextEntering() {

	}

	private func updateScrollEntering() {

	}

	private func updateRunning() {

	}
}
