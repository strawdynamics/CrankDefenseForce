import PlaydateKit

class Sparkler: BaseEntity {
	struct Config {
		let entityStore: EntityStore
	}
	
	struct Spark {
		
	}
	
	var sparks: [Spark] = []
	
	init(_ config: Config) {
		// TODO: Actually implement this once Sprite draw override doesn't leak
		super.init(config.entityStore)
	}
}
