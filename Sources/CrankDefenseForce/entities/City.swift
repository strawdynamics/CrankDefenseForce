import PlaydateKit

class City: BaseEntity {
	private(set) var buildings: [Building] = []

	struct Config {
		let groundHeight: Float
		let entityStore: EntityStore
	}

	let groundHeight: Float

	init(_ config: Config) {
		groundHeight = config.groundHeight
		super.init(config.entityStore)

		let buildingY = Float(Display.height) - config.groundHeight

		let buildingTypes = [
			Building.BuildingType.one,
			.two,
			.three,
			.four,
			.five,
		]

		for (i, buildingType) in buildingTypes.enumerated() {
			buildings.append(Building(Building.Config(
				buildingType: buildingType,
				entityStore: config.entityStore,
				position: Point(x: 80.0 + (60.0 * Float(i)), y: buildingY)
			)))
		}
	}

	func repairBuilding() {
		buildings.filter { $0.destroyed }.randomElement()?.repair()
	}
}
