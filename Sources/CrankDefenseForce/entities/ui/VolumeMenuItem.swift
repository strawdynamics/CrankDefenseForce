import PlaydateKit

class VolumeMenuItem: StepperMenuItem {	
	enum VolumeType {
		case music
		case sfx
	}
	
	struct Config {
		let title: String
		let offsetX: Float
		let volumeType: VolumeType
		let entityStore: EntityStore
	}
	
	class Sprite: ConfigMenuItem.Sprite {
		let title: String
		
		let volumeType: VolumeType
		
		init(title: String, volumeType: VolumeType) {
			self.title = title
			self.volumeType = volumeType
			
			super.init()
			zIndex = 10
			setSize(width: ConfigMenuItem.SPRITE_WIDTH, height: ConfigMenuItem.SPRITE_HEIGHT)
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.setFont(CdfFont.NicoClean16)
			Graphics.drawMode = .fillWhite
			Graphics.drawText(
				title,
				at: bounds.origin + Point(x: 16, y: 16)
			)
			
			let currentVolume: Int
			switch volumeType {
			case .music:
				currentVolume = GameSettings.musicVolume
			case .sfx:
				currentVolume = GameSettings.sfxVolume
			}
			
			let width: Float = 4
			let gap: Float = 1
			let baseXOff: Float = 122
			let baseYOff: Float = 32
			
			for v in 1...GameSettings.MAX_VOLUME {
				let height = Float(v * 2)
				let xOff: Float = baseXOff + (width + gap) * Float(v) - 1
				
				let color: Graphics.Color
				if v <= currentVolume {
					color = .white
				} else {
					color = Graphics.Color.getBayer4x4FadeColor(foreground: 1, alpha: 0.5)
				}
				
				Graphics.fillRect(
					Rect(
						origin: bounds.origin + Point(
							x: Float(xOff),
							y: baseYOff - height
						),
						width: width,
						height: height
					),
					color: color
				)
			}
		}
	}
	
	override func prev() {
		super.prev()
		
		switch volumeType {
		case .music:
			GameSettings.decreaseMusicVolume()
		case .sfx:
			GameSettings.decreaseSfxVolume()
		}
	}
	
	override func next() {
		super.next()
		
		switch volumeType {
		case .music:
			GameSettings.increaseMusicVolume()
		case .sfx:
			GameSettings.increaseSfxVolume()
		}
	}
	
	let displaySprite: Sprite
	
	let currentValue: Int
	
	let volumeType: VolumeType
	
	init(_ config: Config) {
		displaySprite = Sprite(title: config.title, volumeType: config.volumeType)
		volumeType = config.volumeType
		
		currentValue = 5
		
		displaySprite.addToDisplayList()
		
		super.init(ConfigMenuItem.Config(
			title: config.title,
			offsetX: config.offsetX,
			entityStore: config.entityStore,
		))
	}
	
	override func lateUpdate() {
		displaySprite.moveTo(sprite.position)
		super.lateUpdate()
	}
}
