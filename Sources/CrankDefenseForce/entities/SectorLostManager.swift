import PlaydateKit

class SectorLostManager: BaseEntity {
	// MARK: Lifecycle

	init(_ config: Config) {
		matchStatsTracker = config.matchStatsTracker
		sectorLostDisplay = SectorLostDisplay(
			SectorLostDisplay.Config(
				matchStatsTracker: config.matchStatsTracker,
				entityStore: config.entityStore,
			))
		vcrEffect = VcrEffect(config.entityStore)

		// Init after VcrEffect so lateUpdate runs after!
		sectorLostText = SectorLostText(config.entityStore)

		yAnimator = Animator(
			Animator.Config(
				duration: 2,
				startValue: 0,
				endValue: -Float(sectorLostDisplay.totalHeight),
				easingFn: EasingFn.basic(Ease.inOutQuad)
			))

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
		uptime += Time.deltaTime

		vcrEffect.offY = offY

		switch state {
		case .textEntering:
			updateTextEntering()
		case .scrollEntering:
			updateScrollEntering()
		case .running:
			updateRunning()
		}
	}

	override func lateUpdate() {
		if state == .running {
			// lateUpdate input to avoid SectorLostText position offset while scrolling
			updateInput()
		}
	}

	// MARK: Private

	private static let textEnteringDuration: Float = 1

	private enum State {
		case textEntering
		case scrollEntering
		case running
	}

	private var state: State = .textEntering

	private var offY = 0

	private var uptime: Float = 0

	private let yAnimator: Animator<Float>

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
		if uptime >= Self.textEnteringDuration {
			state = .scrollEntering
		}
	}

	private func updateScrollEntering() {
		yAnimator.update()
		offY = Int(yAnimator.currentValue)

		Graphics.setDrawOffset(dx: 0, dy: offY)

		if yAnimator.ended {
			state = .running
		}
	}

	private func updateRunning() {

	}
}
