class VolumeMenuItem: ConfigMenuItem {
	static let max: Int = 10
	
	enum VolumeType {
		case music
		case sfx
	}
	
	struct Config {
		let offsetX: Float
		let volumeType: VolumeType
		let entityStore: EntityStore
	}
	
	let currentValue: Int
	
	let volumeType: VolumeType
	
	init(_ config: Config) {
		volumeType = config.volumeType
		
		currentValue = 5
		
		super.init(ConfigMenuItem.Config(
			offsetX: config.offsetX,
			entityStore: config.entityStore,
		))
	}
	
}
