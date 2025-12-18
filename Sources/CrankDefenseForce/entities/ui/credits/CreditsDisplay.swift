import PlaydateKit

class CreditsDisplay {
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

	// MARK: Private

	private let rows: [[Cell]]

	private static func buildRows(_ config: Config) -> [[Cell]] {
		var rows: [[Cell]] = []

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 8
				))
		])

		rows.append([
			ImageCell(
				ImageCell.Config(
					path: "entities/ui/credits/CreditsDisplay/crankDefenseForce",
					paddingLeft: 86,
				))
		])

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 8
				))
		])

		rows.append([
			TextCell(
				TextCell.Config(
					text: "A game by Paul Straw. Thanks for playing!",
					alignment: .center,
				))
		])

		rows.append([
			TextCell(
				TextCell.Config(
					text: "Based on a prototype created for PlayJam 5.",
					alignment: .center,
				))
		])

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 16
				))
		])

		rows.append([
			TextCell(
				TextCell.Config(
					text: "CREDITS",
				))
		])

		rows.append([
			KeyValueCell(
				KeyValueCell.Config(
					key: "Xmenekai",
					value: "In-game art",
					rowCellCount: 2,
					keyFont: CdfFont.NicoClean16,
					valueFont: CdfFont.NicoPups16,
				)),
			KeyValueCell(
				KeyValueCell.Config(
					key: "Rae",
					value: "Concept & marketing art",
					rowCellCount: 2,
					keyFont: CdfFont.NicoClean16,
					valueFont: CdfFont.NicoPups16,
				)),
		])

		rows.append([
			TextCell(
				TextCell.Config(
					text:
						"Special thanks to Finn Voorhees for creating PlaydateKit; easy to use Swift bindings for the Playdate C API.",
					alignment: .left,
				))
		])

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 16
				))
		])

		rows.append([
			TextCell(
				TextCell.Config(
					text: "LICENSES",
				))
		])

		rows.append([
			KeyValueCell(
				KeyValueCell.Config(
					key: "PlaydateKit (CC0)",
					value: "https://github.com/finnvoor/PlaydateKit",
					rowCellCount: 1,
					keyFont: CdfFont.NicoClean16,
					valueFont: CdfFont.NicoPups16,
				))
		])
		rows.append([
			KeyValueCell(
				KeyValueCell.Config(
					key: "PDFXR (MIT)",
					value: "https://github.com/strawdynamics/PDKPdfxr",
					rowCellCount: 1,
					keyFont: CdfFont.NicoClean16,
					valueFont: CdfFont.NicoPups16,
				))
		])

		rows.append([
			KeyValueCell(
				KeyValueCell.Config(
					key: "MasterPlayer (MIT)",
					value: "https://github.com/strawdynamics/PDKMasterPlayer",
					rowCellCount: 1,
					keyFont: CdfFont.NicoClean16,
					valueFont: CdfFont.NicoPups16,
				))
		])

		rows.append([
			KeyValueCell(
				KeyValueCell.Config(
					key: "Nico fonts (OFL)",
					value: "https://emhuo.itch.io/nico-pixel-fonts-pack",
					rowCellCount: 1,
					keyFont: CdfFont.NicoClean16,
					valueFont: CdfFont.NicoPups16,
				))
		])

		rows.append([
			TextCell(
				TextCell.Config(
					text: "Ⓑ Done",
					alignment: .right
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
