import PlaydateKit

class RemoteScoresDisplay {
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

		rows.append([
			TextCell(
				TextCell.Config(
					text: "Coming soon!",
					alignment: .center,
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
