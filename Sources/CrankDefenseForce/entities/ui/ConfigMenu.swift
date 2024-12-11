import PlaydateKit

class ConfigMenu: BaseEntity {
	static let ITEM_HEIGHT: Int = 52
	
	static let OFFSET_TOP: Float = 60
	
	struct Config {
		let entityStore: EntityStore
	}
	
	let menuItems: [ConfigMenuItem]
	
	var selectedItemIndex = 0
	
	var yAnimator: FloatAnimator?
	
	init(_ config: Config) {
		let offsetX: Float = 10
		
		menuItems = [
			ControlsMenuItem(ControlsMenuItem.Config(
				title: "Controls",
				offsetX: offsetX,
				entityStore: config.entityStore
			)),
			VolumeMenuItem(VolumeMenuItem.Config(
				title: "Music",
				offsetX: offsetX,
				volumeType: VolumeMenuItem.VolumeType.music,
				entityStore: config.entityStore
			)),
			VolumeMenuItem(VolumeMenuItem.Config(
				title: "SFX",
				offsetX: offsetX,
				volumeType: VolumeMenuItem.VolumeType.sfx,
				entityStore: config.entityStore
			)),
			CheckmarkMenuItem(CheckmarkMenuItem.Config(
				title: "Show FPS",
				offsetX: offsetX,
				entityStore: config.entityStore,
				getChecked: { () -> Bool in
					return GameSettings.showFps
				},
				toggleHandler: {() -> Void in
					GameSettings.showFps = !GameSettings.showFps
				}
			)),
		]
		
		super.init(config.entityStore)
		
		menuItems[selectedItemIndex].focus()
		positionMenuItems()
	}
	
	override func update() {
		updateYAnimator()
	}
	
	private func updateYAnimator() {
		if let yAnimator = yAnimator {
			yAnimator.update()
			
			positionMenuItems()
			
			if yAnimator.ended {
				self.yAnimator = nil
			}
		}
	}
	
	func selectNext() {
		let oldIndex = selectedItemIndex
		menuItems[selectedItemIndex].blur()
		
		selectedItemIndex += 1
		if selectedItemIndex >= menuItems.count {
			selectedItemIndex = 0
		}
		
		menuItems[selectedItemIndex].focus()
		
		animateY(oldIndex: oldIndex, newIndex: selectedItemIndex)
	}
	
	func selectPrev() {
		let oldIndex = selectedItemIndex
		menuItems[selectedItemIndex].blur()
		
		selectedItemIndex -= 1
		if selectedItemIndex < 0 {
			selectedItemIndex = menuItems.count - 1
		}
		
		menuItems[selectedItemIndex].focus()
		
		animateY(oldIndex: oldIndex, newIndex: selectedItemIndex)
	}
	
	func animateY(oldIndex: Int, newIndex: Int) {
		self.yAnimator = FloatAnimator(
			duration: 0.3,
			startValue: (self.yAnimator == nil) ? Float(oldIndex) : self.yAnimator!.currentValue,
			endValue: Float(newIndex),
			easingFn: EasingFn.basic(Ease.outQuad),
		)
	}
	
	func positionMenuItems() {
		// FIXME: Jank
		let offsetY: Float = (yAnimator == nil ? Float(selectedItemIndex) : yAnimator!.currentValue) * Float(ConfigMenu.ITEM_HEIGHT)
		
		menuItems.enumerated().forEach { (i, menuItem) in
			menuItem.moveTo(y: ConfigMenu.OFFSET_TOP + Float(i * ConfigMenu.ITEM_HEIGHT) - offsetY)
		}
	}
}
