function formatSecondsForDisplay(seconds)
	return formatMsForDisplay(seconds * 1000)
end

function formatMsForDisplay(ms)
	local totalSeconds = ms / 1000
	local minutes = math.floor(totalSeconds / 60)
	local seconds = math.floor(totalSeconds % 60)
	-- Rounded tenths
	local tenths = math.floor((totalSeconds * 10) + 0.5) % 10

	-- Increment if rounding increases enough
	if tenths == 10 then
		tenths = 0
		seconds = seconds + 1
		if seconds == 60 then
			seconds = 0
			minutes = minutes + 1
		end
	end

	-- Format the output
	return string.format("%d:%02d.%d", minutes, seconds, tenths)
end
