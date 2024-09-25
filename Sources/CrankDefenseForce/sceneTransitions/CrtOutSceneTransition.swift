import PlaydateKit

class CrtOutSceneTransition: BaseSceneTransition {
	private var frame = CrtTransitionDetails.MAX_FRAME_INDEX
	private var currentFrameTime: Float = 0.0
	
	override func updateExit() -> SceneTransitionExitResult {
		self.currentFrameTime += Time.deltaTime
		
		Graphics.pushContext(nil)
		Graphics.drawMode = .copy
		let img = CrtTransitionDetails.CRT_ZOOM_BITMAP_TABLE[self.frame]!
		Graphics.drawBitmap(img)
		Graphics.popContext()
		
		if self.currentFrameTime >= CrtTransitionDetails.FRAME_DURATION {
			self.frame -= 1
			self.currentFrameTime -= CrtTransitionDetails.FRAME_DURATION
			
			if self.frame <= 0 {
				return .complete
			}
		}
		
		return .exiting
	}
	
	override func updateEnter() -> SceneTransitionEnterResult {
		return .complete
	}
}

