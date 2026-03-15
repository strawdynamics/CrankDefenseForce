import PlaydateKit

class RemoteScoresDisplay {
	// MARK: Lifecycle

	init(_ config: Config) {
		self.rows = Self.buildRows(config)
		totalHeight = Self.positionRows(self.rows)

		let _ = Scoreboards.getScores(boardID: CdfScoreboard.toptimes.rawValue) { scoresList, errorMessage in
			if let errorMessage {
				print("getScores error: \(String(cString: errorMessage))")
				return
			}
			guard let scoresList else { return }
			let list = scoresList.pointee
			var entries: [ScoreEntry] = []
			if let scores = list.scores {
				for i in 0..<Int(list.count) {
					let score = scores[i]
					entries.append(ScoreEntry(
						rank: score.rank,
						player: String(cString: score.player),
						value: score.value
					))
				}
			}
			RemoteScoresDisplay.pendingScores = entries
			Scoreboards.freeScoresList(scoresList)
		}
	}

	// MARK: Internal

	struct Config {
		let entityStore: EntityStore
	}

	struct ScoreEntry {
		let rank: UInt32
		let player: String
		let value: UInt32
	}

	var totalHeight: Int

	func hide() {
		isVisible = false
		for row in rows { for cell in row { cell.hide() } }
	}

	func show() {
		isVisible = true
		for row in rows { for cell in row { cell.show() } }
	}

	func update() {
		guard let scores = Self.pendingScores else { return }
		Self.pendingScores = nil
		rows = Self.buildScoreRows(scores)
		totalHeight = Self.positionRows(rows)
		if isVisible {
			show()
		} else {
			hide()
		}
	}

	// MARK: Private

	private static nonisolated(unsafe) var pendingScores: [ScoreEntry]? = nil

	private var rows: [[Cell]]

	private var isVisible = false

	private static func buildRows(_ config: Config) -> [[Cell]] {
		var rows: [[Cell]] = []

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 50
				))
		])

		rows.append([
			TextCell(
				TextCell.Config(
					text: "Loading…",
					alignment: .center,
				))
		])

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 150
				))
		])

		return rows
	}

	private static func buildScoreRows(_ scores: [ScoreEntry]) -> [[Cell]] {
		var rows: [[Cell]] = []

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 50
				))
		])

		rows.append([
			TextCell(
				TextCell.Config(
					text: "Top Times",
					font: CdfFont.NicoClean16,
				))
		])

		rows.append([HrCell()])

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 8
				))
		])

		for entry in scores {
			rows.append([
				ScoreEntryCell(
					ScoreEntryCell.Config(
						entry: entry
					)),
			])
		}

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 16
				))
		])

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
