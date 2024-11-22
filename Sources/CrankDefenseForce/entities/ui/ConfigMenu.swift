import PlaydateKit

class ConfigMenu: BaseEntity {
	static let ITEM_HEIGHT: Int = 50
	
	struct Config {
		let entityStore: EntityStore
	}
	
	let menuItems: [ConfigMenuItem]
	
	var selectedItemIndex = 0
	
	var yAnimator: FloatAnimator?
	
	init(_ config: Config) {
		menuItems = [
			ConfigMenuItem(ConfigMenuItem.Config(
				offsetX: 12,
				entityStore: config.entityStore
			)),
			ConfigMenuItem(ConfigMenuItem.Config(
				offsetX: 12,
				entityStore: config.entityStore
			)),
			ConfigMenuItem(ConfigMenuItem.Config(
				offsetX: 12,
				entityStore: config.entityStore
			)),
			ConfigMenuItem(ConfigMenuItem.Config(
				offsetX: 12,
				entityStore: config.entityStore
			)),
			ConfigMenuItem(ConfigMenuItem.Config(
				offsetX: 12,
				entityStore: config.entityStore
			)),
			ConfigMenuItem(ConfigMenuItem.Config(
				offsetX: 12,
				entityStore: config.entityStore
			)),
		]
		
		super.init(config.entityStore)
		
		menuItems[selectedItemIndex].select()
		positionMenuItems()
	}
	
	override func update() {
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
		menuItems[selectedItemIndex].deselect()
		
		selectedItemIndex += 1
		if selectedItemIndex >= menuItems.count {
			selectedItemIndex = 0
		}
		
		menuItems[selectedItemIndex].select()
		
		animateY(oldIndex: oldIndex, newIndex: selectedItemIndex)
	}
	
	func selectPrev() {
		let oldIndex = selectedItemIndex
		menuItems[selectedItemIndex].deselect()
		
		selectedItemIndex -= 1
		if selectedItemIndex < 0 {
			selectedItemIndex = menuItems.count - 1
		}
		
		menuItems[selectedItemIndex].select()
		
		animateY(oldIndex: oldIndex, newIndex: selectedItemIndex)
	}
	
	func animateY(oldIndex: Int, newIndex: Int) {
		self.yAnimator = FloatAnimator(
			duration: 0.3,
			startValue: Float(oldIndex),
			endValue: Float(newIndex),
			easingFn: EasingFn.basic(Ease.outQuad),
		)
	}
	
	func positionMenuItems() {
		// FIXME: Jank
		let offsetY: Float = (yAnimator == nil ? Float(selectedItemIndex) : yAnimator!.currentValue) * Float(ConfigMenu.ITEM_HEIGHT)
		
		menuItems.enumerated().forEach { (i, menuItem) in
			menuItem.moveTo(y: 12 + Float(i * ConfigMenu.ITEM_HEIGHT) - offsetY)
		}
	}
}
