import PlaydateKit

protocol PowerUpDropper: AnyObject {
	static var powerUpDropTable: [PowerUpType: Float] { get }
}
