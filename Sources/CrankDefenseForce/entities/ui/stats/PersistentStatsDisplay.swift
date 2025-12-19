import PlaydateKit

class PersistentStatsDisplay {
	// MARK: Lifecycle

	init(_ config: Config) {
		self.rows = Self.buildRows(config)
		totalHeight = Self.positionRows(self.rows)
	}

	// MARK: Internal

	struct Config {
		let entityStore: EntityStore
	}

	let totalHeight: Int

	func hide() {
		for row in rows {
			for cell in row {
				cell.hide()
			}
		}
	}

	func show() {
		for row in rows {
			for cell in row {
				cell.show()
			}
		}
	}

	// MARK: Private

	private let rows: [[Cell]]

	private static func buildRows(_ config: Config) -> [[Cell]] {
		var rows: [[Cell]] = []

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 50
				))
		])

		let pStats = PersistentStats.instance

		// Duration, # fired
		let minutes = Int(pStats.timePlayed / 60)
		let seconds = Int(pStats.timePlayed.truncatingRemainder(dividingBy: 60))
		let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
		rows.append([
			KeyValueCell(
				KeyValueCell.Config(
					key: "Time played",
					value: "\(minutes):\(secondsString)",
					rowCellCount: 3
				)),
			KeyValueCell(
				KeyValueCell.Config(
					key: "Sectors lost",
					value: "\(pStats.sectorsLost)",
					rowCellCount: 3
				)),
			KeyValueCell(
				KeyValueCell.Config(
					key: "Rockets launched",
					value: "\(pStats.rocketsLaunched)",
					rowCellCount: 3
				)),
		])

		// Enemies destroyed
		let totalEnemiesDestroyed =
			pStats.cpuRocketsDestroyed + pStats.cpuFastRocketsDestroyed + pStats.cpuSmallUfosDestroyed
			+ pStats.cpuBigUfosDestroyed

		// HR
		rows.append([
			HrCell()
		])

		// Header
		let pluralizedEnemies = totalEnemiesDestroyed == 1 ? "enemy" : "enemies"

		rows.append([
			TextCell(
				TextCell.Config(
					text: "\(totalEnemiesDestroyed) \(pluralizedEnemies) destroyed",
				))
		])

		// Destroyed enemy details
		var detailsRow: [Cell] = []

		detailsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.cpuRocketsDestroyed)",
					entityType: .rocket,
					entityStore: config.entityStore,
				)))

		detailsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.cpuFastRocketsDestroyed)",
					entityType: .fastRocket,
					entityStore: config.entityStore,
				)))

		detailsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.cpuSmallUfosDestroyed)",
					entityType: .smallUfo,
					entityStore: config.entityStore,
				)))

		detailsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.cpuBigUfosDestroyed)",
					entityType: .bigUfo,
					entityStore: config.entityStore,
				)))

		rows.append(detailsRow)

		// PowerUps collected
		let totalPowerUpsCollected =
			pStats.pauseEnemiesPowerUpsCollected + pStats.repairBuildingPowerUpsCollected
			+ pStats.destroyEnemiesPowerUpsCollected
		// HR
		rows.append([
			HrCell()
		])

		// Header
		let pluralizedPowerUps = totalPowerUpsCollected == 1 ? "power-up" : "power-ups"

		rows.append([
			TextCell(
				TextCell.Config(
					text: "\(totalPowerUpsCollected) \(pluralizedPowerUps) collected",
				))
		])

		// Collected PowerUp details
		var powerUpsRow: [Cell] = []

		powerUpsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.pauseEnemiesPowerUpsCollected)",
					entityType: .pauseEnemies,
					entityStore: config.entityStore,
				)))

		powerUpsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.repairBuildingPowerUpsCollected)",
					entityType: .repairBuilding,
					entityStore: config.entityStore,
				)))

		powerUpsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.destroyEnemiesPowerUpsCollected)",
					entityType: .destroyEnemies,
					entityStore: config.entityStore,
				)))

		rows.append(powerUpsRow)

		return rows
	}

	private static func positionRows(_ rows: [[Cell]]) -> Int {
		let offY: Float = 0
		var positionedRowsHeight = 0

		for row in rows {
			let cellCount = row.count
			let cellWidth = Display.width / cellCount
			var positionedCellsWidth = 0

			for (cellIndex, cell) in row.enumerated() {
				cell.moveTo(
					topLeft: Point(
						x: Float(positionedCellsWidth),
						y: offY + Float(positionedRowsHeight),
					))

				positionedCellsWidth += cell.width
			}

			// All cells for a row must be the same height
			positionedRowsHeight += row[0].height
		}

		return positionedRowsHeight
	}
}
