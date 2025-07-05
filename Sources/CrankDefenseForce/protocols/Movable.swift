import PlaydateKit

protocol Movable: BaseEntity {
	func moveTo(position: Point)
}
