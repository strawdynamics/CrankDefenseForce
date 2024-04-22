local gfx <const> = playdate.graphics

fonts = {
	nicoPups16 = gfx.font.new("fonts/nico/nico-pups-16"),
	nicoClean16 = gfx.font.new("fonts/nico/nico-clean-16"),
	lexendDecaBold32 = gfx.font.new("fonts/lexend/lexend-deca-bold-32"),
}

local function strokeOffsets(radius)
	local offsets = {}
	for x = -radius, radius do
		for y = -radius, radius do
			if x * x + y * y <= radius * radius then
				table.insert(offsets, { x, y })
			end
		end
	end
	return offsets
end

function drawTextAlignedStroked(text, x, y, alignment, stroke, strokeColor)
	local offsets = strokeOffsets(stroke)

	if strokeColor == nil then
		strokeColor = gfx.kDrawModeFillWhite
	end

	gfx.pushContext()
	gfx.setImageDrawMode(strokeColor)
	for _, o in pairs(offsets) do
		gfx.drawTextAligned(text, x + o[1], y + o[2], alignment)
	end
	gfx.popContext()

	gfx.drawTextAligned(text, x, y, alignment)
end

function imageWithTextStroked(
	text,
	maxWidth,
	maxHeight,
	leadingAdjustment,
	truncationString,
	alignment,
	stroke,
	strokeColor
)
	if text == nil then
		text = 'nil'
	end

	if strokeColor == nil then
		strokeColor = gfx.kDrawModeFillWhite
	end

	local foregroundImage, textWasTruncated = gfx.imageWithText(
		text,
		maxWidth,
		maxHeight,
		gfx.kColorClear,
		leadingAdjustment,
		truncationString,
		alignment
	)

	gfx.pushContext()
	print('setstrok', strokeColor)
	gfx.setImageDrawMode(strokeColor)
	local strokeImage = gfx.imageWithText(
		text,
		maxWidth,
		maxHeight,
		gfx.kColorClear,
		leadingAdjustment,
		truncationString,
		alignment
	)
	gfx.popContext()

	local outImageWidth, outImageHeight = foregroundImage:getSize()
	outImageWidth += stroke * 2
	outImageHeight += stroke * 2
	local outImage = gfx.image.new(outImageWidth, outImageHeight)

	gfx.pushContext(outImage)
	local offsets = strokeOffsets(stroke)
	for _, o in pairs(offsets) do
		strokeImage:draw(stroke + o[1], stroke + o[2])
	end

	foregroundImage:draw(stroke, stroke)
	gfx.popContext()

	return outImage, textWasTruncated
end
