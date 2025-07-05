import PlaydateKit

class SectorLostDisplay {
	// MARK: Lifecycle

	init(_ config: Config) {
		self.rows = Self.buildRows(config)
		totalHeight = Self.positionRows(self.rows)

		bg.image = Graphics.Bitmap(
			width: Display.width,
			height: totalHeight,
			bgColor: .black,
		)
		bg.center = Point.zero
		bg.moveTo(Point(
			x: 0,
			y: Display.height,
		))
		bg.zIndex = 500
		bg.addToDisplayList()
	}

	// MARK: Internal

	struct Config {
		let matchStatsTracker: MatchStatsTracker
		let entityStore: EntityStore
	}

	let totalHeight: Int

	// MARK: Private

	private let rows: [[SectorLostCell]]

	private let bg = Sprite.Sprite()

	private static func buildRows(_ config: Config) -> [[SectorLostCell]] {
		var rows: [[SectorLostCell]] = []
		let tracker = config.matchStatsTracker

		// Duration, # fired
		let minutes = Int(tracker.finalUptime / 60)
		let seconds = Int(tracker.finalUptime.truncatingRemainder(dividingBy: 60))
		let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
		rows.append([
			KeyValueSectorLostCell(KeyValueSectorLostCell.Config(
				key: "Duration",
				value: "\(minutes):\(secondsString)",
				rowCellCount: 2
			)),
			KeyValueSectorLostCell(KeyValueSectorLostCell.Config(
				key: "Rockets launched",
				value: "\(tracker.rocketsLaunched)",
				rowCellCount: 2
			)),
		])

		// Enemies destroyed
		let totalEnemiesDestroyed = tracker.cpuRocketsDestroyed + tracker.cpuFastRocketsDestroyed + tracker.cpuSmallUfosDestroyed + tracker.cpuBigUfosDestroyed
		if (totalEnemiesDestroyed > 0) {
			// HR
			rows.append([
				HrCell(),
			])

			// Header
			let pluralizedEnemies = totalEnemiesDestroyed == 1 ? "enemy" : "enemies"

			rows.append([
				TextCell(TextCell.Config(
					text: "\(totalEnemiesDestroyed) \(pluralizedEnemies) destroyed",
				)),
			])

			// Destroyed enemy details
			var detailsRow: [SectorLostCell] = []

			if tracker.cpuRocketsDestroyed > 0 {
				detailsRow.append(EntityCell(EntityCell.Config(
					text: "\(tracker.cpuRocketsDestroyed)",
					entityType: .rocket,
					entityStore: config.entityStore,
				)))
			}

			if tracker.cpuFastRocketsDestroyed > 0 {
				detailsRow.append(EntityCell(EntityCell.Config(
					text: "\(tracker.cpuFastRocketsDestroyed)",
					entityType: .fastRocket,
					entityStore: config.entityStore,
				)))
			}

			if tracker.cpuSmallUfosDestroyed > 0 {
				detailsRow.append(EntityCell(EntityCell.Config(
					text: "\(tracker.cpuSmallUfosDestroyed)",
					entityType: .smallUfo,
					entityStore: config.entityStore,
				)))
			}

			if tracker.cpuBigUfosDestroyed > 0 {
				detailsRow.append(EntityCell(EntityCell.Config(
					text: "\(tracker.cpuBigUfosDestroyed)",
					entityType: .bigUfo,
					entityStore: config.entityStore,
				)))
			}

			rows.append(detailsRow)
		}

		// PowerUps collected
		let totalPowerUpsCollected = tracker.pauseEnemiesPowerUpsCollected + tracker.repairBuildingPowerUpsCollected + tracker.destroyEnemiesPowerUpsCollected
		if (totalPowerUpsCollected > 0) {
			// HR
			rows.append([
				HrCell(),
			])

			// Header
			let pluralizedPowerUps = totalPowerUpsCollected == 1 ? "power-up" : "power-ups"

			rows.append([
				TextCell(TextCell.Config(
					text: "\(totalPowerUpsCollected) \(pluralizedPowerUps) collected",
				)),
			])

			// Collected PowerUp details
			var powerUpsRow: [SectorLostCell] = []

			if tracker.pauseEnemiesPowerUpsCollected > 0 {
				powerUpsRow.append(EntityCell(EntityCell.Config(
					text: "\(tracker.pauseEnemiesPowerUpsCollected)",
					entityType: .pauseEnemies,
					entityStore: config.entityStore,
				)))
			}

			if tracker.repairBuildingPowerUpsCollected > 0 {
				powerUpsRow.append(EntityCell(EntityCell.Config(
					text: "\(tracker.repairBuildingPowerUpsCollected)",
					entityType: .repairBuilding,
					entityStore: config.entityStore,
				)))
			}

			if tracker.destroyEnemiesPowerUpsCollected > 0 {
				powerUpsRow.append(EntityCell(EntityCell.Config(
					text: "\(tracker.destroyEnemiesPowerUpsCollected)",
					entityType: .destroyEnemies,
					entityStore: config.entityStore,
				)))
			}

			rows.append(powerUpsRow)
		}


		return rows
	}

	private static func positionRows(_ rows: [[SectorLostCell]]) -> Int {
		let offY = Float(Display.height)
		var totalRowHeight = 0

		for row in rows {
			let cellCount = row.count
			let cellWidth = Display.width / cellCount

			for (cellIndex, cell) in row.enumerated() {
				cell.moveTo(topLeft: Point(
					x: Float(cellIndex * cellWidth),
					y: offY + Float(totalRowHeight),
				))
			}

			// All cells for a row must be the same height
			totalRowHeight += row[0].height
		}

		return totalRowHeight
	}
}
