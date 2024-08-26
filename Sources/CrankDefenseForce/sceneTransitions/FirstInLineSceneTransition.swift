//
//  FirstInLineSceneTransition.swift
//  
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

let FRAME_DURATION: Float = 0.07
let MAX_FRAME_INDEX = 22
nonisolated(unsafe) let CURTAINS_BITMAP_TABLE: Graphics.BitmapTable = try! Graphics.BitmapTable.init(path: "firstInLineCurtains.gif")

class FirstInLineSceneTransition: BaseSceneTransition {
	private var frame = 0
	private var currentFrameTime: Float = 0.0
	
	override init() {
		
	}

	
	override func begin() {
		//
	}
	
	override func updateExit() -> SceneTransitionExitResult {
		self.currentFrameTime += game.time.deltaTime
		
		Graphics.pushContext(nil)
		Graphics.drawMode = .copy
		let img = CURTAINS_BITMAP_TABLE[self.frame]!
		Graphics.drawBitmap(img)
		Graphics.popContext()
		
		if self.currentFrameTime >= FRAME_DURATION {
			self.frame += 1
			self.currentFrameTime -= FRAME_DURATION
			
			if self.frame == 12 {
				return .complete
			}
		}
		
		return .exiting
	}
	
	override func updateEnter() -> SceneTransitionEnterResult {
		self.currentFrameTime += game.time.deltaTime
		
		Graphics.pushContext(nil)
		Graphics.drawMode = .copy
		let img = CURTAINS_BITMAP_TABLE[self.frame]!
		Graphics.drawBitmap(img)
		
		if self.currentFrameTime >= FRAME_DURATION {
			self.frame += 1
			self.currentFrameTime -= FRAME_DURATION
			
			if self.frame >= MAX_FRAME_INDEX {
				return .complete
			}
		}
		
		return .entering
	}
}
