import PlaydateKit

//final class TestGame: PlaydateGame {
//	let bitmap = Graphics.Bitmap(width: 120, height: 20)
//	
//	var outsideDrawMode: Graphics.Bitmap.DrawMode = .fillBlack
//	
//	func update() -> Bool {
//		Graphics.clear(color: .white)
//		
//		// Why does this control the text color
//		Graphics.drawMode = outsideDrawMode
//		
//		Graphics.pushContext(bitmap)
//		
//		// …and not this?
//		Graphics.drawMode = .fillBlack
//		
////		Graphics.drawText("Should be black", at: .zero)
//		Graphics.fillRect(Rect(x: 0, y: 0, width: 50, height: 50), color: .black)
//		Graphics.popContext()
//		
//		Graphics.drawBitmap(bitmap, at: .zero)
//		
//		let pushed = System.buttonState.pushed
//		if pushed.contains(.a) {
//			print("swap!")
//			outsideDrawMode = outsideDrawMode == .fillBlack ? .fillWhite : .fillBlack
//		}
//		
//		return true
//	}
//}

final class Game: PlaydateGame {
	var scenePresenter: ScenePresenter
	
	init() {
//		Graphics.drawMode = .fillWhite
		Display.refreshRate = 40.0
		Sprite.setAlwaysRedraw(true)
		self.scenePresenter = ScenePresenter(firstScene: MainMenuScene())
	}
	
	func update() -> Bool {
		Time.updateDeltaTime()
		
		Graphics.clear()
		Sprite.updateAndDrawDisplayListSprites()
		
		self.scenePresenter.update()
		
		System.drawFPS()
		
		return true
	}

	func gameWillPause() {
		print("Paused!")
	}
}

