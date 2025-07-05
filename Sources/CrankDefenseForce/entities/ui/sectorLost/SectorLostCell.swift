import PlaydateKit

let SectorLostCellPadding = 6

protocol SectorLostCell: AnyObject {
	var height: Int { get }

	func moveTo(topLeft: Point)
}

// Duration, # fired
class KeyValueSectorLostCell: SectorLostCell {
	struct Config {
		let key: String
		let value: String
		let rowCellCount: Int
	}

	let sprite = Sprite.Sprite()

	init(_ config: Config) {
		let bitmap = Graphics.Bitmap(
			width: Display.width / config.rowCellCount,
			height: CdfFont.NicoPups16.height + CdfFont.NicoClean16.height + SectorLostCellPadding * 3,
		)

		Graphics.pushContext(bitmap)
		Graphics.drawMode = .fillWhite
		Graphics.setFont(CdfFont.NicoPups16)
		Graphics.drawText(config.key, at: Point(
			x: SectorLostCellPadding,
			y: SectorLostCellPadding,
		))

		Graphics.setFont(CdfFont.NicoClean16)
		Graphics.drawText(config.value, at: Point(
			x: SectorLostCellPadding,
			y: CdfFont.NicoClean16.height + SectorLostCellPadding * 2,
		))
		Graphics.popContext()

		sprite.image = bitmap
		sprite.center = Point.zero
		sprite.zIndex = 600
		sprite.addToDisplayList()
	}

	var height: Int {
		return Int(sprite.bounds.height)
	}

	func moveTo(topLeft: Point) {
		sprite.moveTo(topLeft)
	}
}

// Horizontal rule
class HrCell: SectorLostCell {
	init() {
		let bitmap = Graphics.Bitmap(
			// Assume only cell in row
			width: Display.width - SectorLostCellPadding * 2,
			height: 1,
			bgColor: .white,
		)

		sprite.image = bitmap
		sprite.center = Point.zero
		sprite.zIndex = 600
		sprite.addToDisplayList()
	}

	let sprite = Sprite.Sprite()

	var height: Int {
		return 1
	}

	func moveTo(topLeft: Point) {
		sprite.moveTo(topLeft + Point(
			x: SectorLostCellPadding,
			y: 0,
		))
	}
}


//// Headers (# enemies, power-ups)
class TextCell: SectorLostCell {
	struct Config {
		let text: String
	}

	let sprite = Sprite.Sprite()

	init(_ config: Config) {
		let bitmap = Graphics.Bitmap(
			// Assume only cell in row
			width: Display.width - SectorLostCellPadding * 2,
			height: CdfFont.NicoPups16.height,
		)

		Graphics.pushContext(bitmap)
		Graphics.drawMode = .fillWhite
		Graphics.setFont(CdfFont.NicoPups16)
		Graphics.drawText(config.text, at: Point.zero)
		Graphics.popContext()

		sprite.image = bitmap
		sprite.center = Point.zero
		sprite.zIndex = 600
		sprite.addToDisplayList()
	}

	var height: Int {
		return CdfFont.NicoPups16.height + SectorLostCellPadding * 2
	}

	func moveTo(topLeft: Point) {
		sprite.moveTo(topLeft + Point(
			x: SectorLostCellPadding,
			y: SectorLostCellPadding,
		))
	}
}
//
//// Everything else
class EntityCell: SectorLostCell {
	enum EntityType {
		case rocket
		case fastRocket
		case smallUfo
		case bigUfo
		case pauseEnemies
		case repairBuilding
		case destroyEnemies
	}

	struct Config {
		let text: String
		let entityType: EntityType
		let entityStore: EntityStore
	}

	static let contentWidth = 80

	let textSprite = Sprite.Sprite()

	init(_ config: Config) {
		let bitmap = Graphics.Bitmap(
			width: Self.contentWidth,
			height: CdfFont.NicoClean16.height,
		)

		Graphics.pushContext(bitmap)
		Graphics.drawMode = .fillWhite
		Graphics.setFont(CdfFont.NicoClean16)
		Graphics.drawTextInRect(config.text, in: Rect(
			x: 0,
			y: 0,
			width: Self.contentWidth,
			height: height
		), aligned: .right)
		Graphics.popContext()

		textSprite.image = bitmap
		textSprite.center = Point.zero
		textSprite.zIndex = 600
		textSprite.addToDisplayList()
	}

	var height: Int {
		return CdfFont.NicoClean16.height + SectorLostCellPadding * 2
	}

	func moveTo(topLeft: PlaydateKit.Point) {
		textSprite.moveTo(topLeft + Point(
			x: SectorLostCellPadding,
			y: (height - Int(textSprite.bounds.height)) / 2,
		))
	}
}
