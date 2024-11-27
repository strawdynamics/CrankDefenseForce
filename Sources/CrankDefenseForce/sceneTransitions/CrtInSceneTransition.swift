import PlaydateKit

class CrtInSceneTransition: BaseSceneTransition {
	private var frame = 0
	private var currentFrameTime: Float = 0.0
	
	private var fadeTime: Float = 0.0
	
	override func updateExit() -> SceneTransitionExitResult {
		self.currentFrameTime += Time.deltaTime
		
		Graphics.pushContext(nil)
		Graphics.drawMode = .copy
		let img = CrtTransitionDetails.CRT_ZOOM_BITMAP_TABLE[self.frame]!
		Graphics.drawBitmap(img)
		Graphics.popContext()
		
		if self.currentFrameTime >= CrtTransitionDetails.FRAME_DURATION {
			self.frame += 1
			self.currentFrameTime -= CrtTransitionDetails.FRAME_DURATION
			
			if self.frame >= CrtTransitionDetails.MAX_FRAME_INDEX {
				return .complete
			}
		}
		
		return .exiting
	}
	
	// Fade from black
	override func updateEnter() -> SceneTransitionEnterResult {
		fadeTime += Time.deltaTime
		let fadePct = 1 - fadeTime / CrtTransitionDetails.FADE_DURATION
	
		Graphics.pushContext(nil)
		
		Graphics.fillRect(
			Rect(x: 0, y: 0, width: 400, height: 240),
			color: Graphics.Color.getBayer4x4FadeColor(foreground: 0, alpha: fadePct)
		)
		Graphics.popContext()
		
		if self.fadeTime >= CrtTransitionDetails.FADE_DURATION {
			return .complete
		} else {
			return .entering
		}
	}
}
