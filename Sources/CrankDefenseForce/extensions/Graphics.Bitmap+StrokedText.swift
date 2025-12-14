import PlaydateKit

extension Graphics.Bitmap {
	public convenience init(
		strokedText: String,
		strokeWidth: Int,
		textColor: Graphics.Bitmap.DrawMode,
		strokeColor: Graphics.Bitmap.DrawMode,
		wrap: Graphics.TextWrap = .word,
		align: Graphics.TextAlignment = .left,
		font: Graphics.Font,
		tracking: Int = 0,
		extraLeading: Int = 0,
		bgColor: Graphics.Color = .clear,
	) {
		let textWidth = font.getTextWidth(for: strokedText, tracking: tracking)
		let textHeight = font.getTextHeightForMaxWidth(
			for: strokedText,
			maxWidth: textWidth,
			wrap: wrap,
			tracking: tracking,
			extraLeading: extraLeading
		)

		let bitmapWidth = textWidth + strokeWidth * 2
		let bitmapHeight = textHeight + strokeWidth * 2

		self.init(width: bitmapWidth, height: bitmapHeight, bgColor: bgColor)

		var offsets: [(Int, Int)] = []
		for x in -strokeWidth...strokeWidth {
			for y in -strokeWidth...strokeWidth {
				if x * x + y * y <= strokeWidth * strokeWidth {
					offsets.append((x, y))
				}
			}
		}

		Graphics.pushContext(self)
		Graphics.setFont(font)
		Graphics.setTextLeading(extraLeading)
		Graphics.textTracking = tracking

		offsets.forEach { x, y in
			Graphics.drawMode = strokeColor
			Graphics.drawTextInRect(
				strokedText,
				in: Rect(
					x: strokeWidth + x,
					y: strokeWidth + y,
					width: textWidth,
					height: textHeight
				), wrap: wrap, aligned: align)
		}

		Graphics.drawMode = textColor
		Graphics.drawTextInRect(
			strokedText,
			in: Rect(
				x: strokeWidth,
				y: strokeWidth,
				width: textWidth,
				height: textHeight
			), wrap: wrap, aligned: align)

		Graphics.popContext()
	}
}
