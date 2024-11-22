class StepperConfigMenuItem: ConfigMenuItem {
	struct Config {
		let max: Int
		let offsetX: Float
		let entityStore: EntityStore
	}
	
	let max: Int
	
	let currentValue: Int
	
	init(_ config: Config) {
		self.max = config.max
		
		// TODO:
		currentValue = 5
		
		super.init(ConfigMenuItem.Config(
			offsetX: config.offsetX,
			entityStore: config.entityStore,
		))
	}
	
}
