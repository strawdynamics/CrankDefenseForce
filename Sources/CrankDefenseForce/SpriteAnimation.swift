import PlaydateKit

class SpriteAnimation {
	struct Config {
		let sprite: Sprite.Sprite
		let bitmapTable: Graphics.BitmapTable
		let bitmapTableIndices: [Int]
		let frameDuration: Float
		let loopType: LoopType
	}
	
	enum LoopType {
		case stop
		case loop
	}
	
	private let sprite: Sprite.Sprite
	private let bitmapTable: Graphics.BitmapTable
	private let frameDuration: Float
	private let bitmapTableIndices: [Int]
	private let frameCount: Int
	private let loopType: LoopType
	private let totalDuration: Float
	
	private var isPlaying = false
	private var currentTime: Float = 0
	private var currentFrameIndex: Int = 0
	private(set) var isComplete = false
	
	init(_ config: Config) {
		sprite = config.sprite
		bitmapTable = config.bitmapTable
		frameDuration = config.frameDuration
		bitmapTableIndices = config.bitmapTableIndices
		frameCount = config.bitmapTableIndices.count
		totalDuration = frameDuration * Float(frameCount)
		loopType = config.loopType
	}
	
	func play() {
		isComplete = false
		isPlaying = true
	}
	
	func pause() {
		isPlaying = false
	}
	
	func stop() {
		isPlaying = false
		currentTime = 0
		currentFrameIndex = 0
	}
	
	func update() {
		if !isPlaying {
			return
		}
		
		currentTime += Time.deltaTime
		
		var newFrameIndex = Int(floorf(currentTime / frameDuration))
		
		if newFrameIndex >= frameCount {
			switch loopType {
			case .loop:
				newFrameIndex = 0
				currentTime -= totalDuration
			case .stop:
				stop()
				isComplete = true
				return
			}
		}
		
		if newFrameIndex != currentFrameIndex {
			currentFrameIndex = newFrameIndex
			
			let bitmapTableIndex = bitmapTableIndices[currentFrameIndex]
			sprite.image = bitmapTable[bitmapTableIndex]
		}
	}
}
