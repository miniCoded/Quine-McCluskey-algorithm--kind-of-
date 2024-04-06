local miniterm = {}

-- repr is the binary number stored in the miniterm
--
-- - nums are the number of miniterms fused into it (if any)
-- - group is the bucket it belongs to
function miniterm:new(repr, nums, group)
	local o = {}
	for k, v in pairs(self) do
		o[k] = v
	end

	o.repr = repr
	o.nums = nums

	-- In case a group it's not provided, it will be assumed that this is a starter miniterm
	if not group then
		for i = 1, #repr, 1 do
			if string.sub(repr, i, i) == "1" then
				o.group = o.group + 1
			end
		end
	else
		o.group = group
	end

	return o
end

-- I this format:
--
-- m(nums): group = repr
function miniterm:tostring()
	local bins = "("

	for i = 1, #self.nums, 1 do
		if i < #self.nums then
			bins = bins .. self.nums[i] .. ", "
		else
			bins = bins .. self.nums[i] .. ")"
		end
	end

	return "m" .. bins .. ": " .. self.group .. " = " .. self.repr
end

-- Combines two miniterms.
-- Returns true if both could be combined. False otherwise
--
-- - m1 and m2 are miniterms
-- - group is the new group the combined miniterm will be assigned to
-- - bits is the amount of bits to work with
function miniterm:combine(m1, m2, bits, group)
	-- The new bit representation
	local nbit = ""
	-- The number of terms each miniterm has
	local nterms = {}
	-- To verify if there is more than one different bit
	local parity = true

	for i = 1, bits, 1 do
		-- Single bits of the two miniterms
		local b1, b2 = string.sub(m1.repr, i, i), string.sub(m2.repr, i, i)

		-- Ignore if both bits are the same
		if b1 == b2 then
			nbit = nbit .. b1
		else
			-- You cannot combine a normal bit with a don't-care bit
			if b1 == "-" or b2 == "-" then
				return false, nil
			else
				-- Only execute once if a bit is different. Replace that different bit with a "-"
				if parity then
					nbit = nbit .. "-"
					parity = false
				else
					-- If more than one different bit it's found, return false
					return false, nil
				end
			end
		end
	end

	-- Fuse both lists of terms together
	for k, v in pairs(m1.nums) do
		table.insert(nterms, v)
	end
	for k, v in pairs(m2.nums) do
		table.insert(nterms, v)
	end

	return true, miniterm:new(nbit, nterms, group)
end

miniterm.repr = ""
miniterm.group = 0
miniterm.nums = {}
miniterm.mixes = false

return miniterm