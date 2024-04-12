--[[
	The algorithm is divided into 4 parts:
	1. miniterm selection
	2. miniterm mixing
	3. esential miniterm selection
	4. final equation build
]]

require("Quine-McCluskey.utils")
local miniterm = require("Quine-McCluskey.miniterm")
local BooleanExp = require("Boolean_exp.BoolExp")


-- First selection of miniterms
--
-- Miniterms are selected if the bit in the truth table is 1
-- n is the number of terms
-- bits is the length of the numbers in binary
function QMCSelectMiniterm(n, bits)
	-- Selected miniterms
	local m = {}

	if not bits and n then
		print("Insert 0 or 1 depending on the output of the truth table")
		io.write('\n')
	
		for i = 0, n-1, 1 do
			io.write(string.char(65+i))
		end
		io.write('\n')
		for i = 0, 2^n-1, 1 do
			local repr = toBinary(i, n)
	
			io.write(repr .. ": ")
	
			local input = io.read()
	
			while input ~= "0" and input ~= "1" do
				io.write("Insert a valid term: ")
				input = io.read()
			end
	
			-- Generate that miniterm if the input is "1"
			if input == "1" then
				table.insert(m, miniterm:new(repr, {i}))
			end
		end
		
		io.write('\n')
		
	elseif bits then
		for i = 1, #bits, 1 do
			if bits[i] == "1" then
				local repr = toBinary(i-1, n)
				table.insert(m, miniterm:new(repr, {i-1}))
			end
		end
	elseif not n then
		io.write("Insert the expression: ")
		local exp = io.read()
		local vars = GetVars(exp, Tokenize(exp))
		for _, v in pairs(vars) do
			io.write(v.symbol, " ")
		end
		local tokens = Tokenize(exp)
		io.write(" RES\n")
		for i = 0, 2^#vars-1, 1 do
			local bin = toBinary(i, #vars)
			local truth = {}
			local res = '0'
			for j = 1, #bin, 1 do
				table.insert(truth, string.sub(bin, j, j))
			end
			res = Parse(vars, Gen_AST(tokens), truth)
			for _, b in pairs(truth) do
				io.write(b, " ")
			end
			if res == '1' then
				table.insert(m, miniterm:new(bin, {i}))
			end
			io.write(" ", res, "\n")
		end
		io.read()
		return m, #vars, exp, tokens
	end

	return m, n
end


-- - **Step 1**: place each miniterm in a bucket, according to its assigned group
-- - **Step 2**: mix the miniterms
-- - **Step 3**: repeat until there are no more miniterms that can be mixed
-- - **Step 4**: inside each bucket, keep only one miniterm of each starting number
function QMCMixMiniterms(t, b)
	-- Escential miniterms
	local raw_e_miniterms = {}
	-- The generated miniterm groups
	table.sort(t, function (m1, m2) if m1.nums[1] < m2.nums[1] then return true else return false end end)
	local mix_time = 0
	local clean_time = 0
	local stage = 1
	while true do
		local buckets = {}

		-- Sort them, low to high, according to the group
		table.sort(t, function (m1, m2) if m1.group < m2.group then return true else return false end end)

		-- Put each miniterm in it's corresponding bucket according to it's group number

		-- The bucket that's been currently worked on
		local current_bucket = {}
		for i = 1, #t, 1 do
			-- If the next miniterm has a different group, then insert the current bucket in buckets and reset it
			if i > 1 and t[i].group ~= t[i-1].group then
				if #t[i].nums == 1 then
					table.sort(current_bucket, function (m1, m2)
						if m1.nums[1] <m2.nums[1] then
							return true
						else
							return false
						end
					end)
				end
				table.insert(buckets, current_bucket)
				current_bucket = {}
			end

			-- Insert the current miniterm in current_bucket
			table.insert(current_bucket, t[i])

			-- Sometimes, there can be a final term that belongs to a single bucket. This accounts for it
			if i == #t then
				table.sort(current_bucket, function (m1, m2)
					if m1.nums[1] < m2.nums[1] then
						return true
					else
						return false
					end
				end)
				table.insert(buckets, current_bucket)
			end
		end

		-- Mix the terms and put them all in a bucket list, like above

		-- This is the amount of times that miniterm got mixed up. If zero, it means that it couldn't be mixed
		local matches = 0
		-- Since we already stored all the miniterms in separated lists, there's no need to keep the original one
		t = {}

		-- Iterate over every bucket
		-- As a little optimization, there's no need to mix beyond the bucket immediately next to the current one
		-- because the number of different bits will be >=2, and that's not how the algorithm works

		mix_time = os.clock()
		for x = 1, #buckets-1, 1 do
			-- Current bucket
			local x_bucket = buckets[x]
			-- Next bucket
			local y_bucket = buckets[x+1]

			-- Iterate over all the miniterms of the current bucket
			for z = 1, #x_bucket, 1 do
				-- Current miniterm of the current bucket
				local m1 = x_bucket[z]

				-- With the current miniterm, iterate over the miniterms of the next bucket
				for w = 1, #y_bucket, 1 do
					-- Current miniterm of the next bucket
					local m2 = y_bucket[w]
					-- Attempt to mix both
					local result, mix = miniterm:combine(m1, m2, b)

					-- In case of a successful mix:
					-- 1. Increase the number of matches
					-- 2. Insert that mix into t
					-- 3. Set .mixes as true, because both were able to mix
					if result then
						matches = matches + 1
						table.insert(t, mix)
						m1.mixes = true
						m2.mixes = true
					end
				end
			end
		end

		mix_time = os.clock() - mix_time

		-- Add all the raw miniterms to the list of escential miniterms for further filtering
		for _, x in pairs(buckets) do
			for _, y in pairs(x) do
				if not y.mixes then
					table.insert(raw_e_miniterms, y)
				end
			end
		end

		print("Stage "..stage)
		stage = stage + 1
		for _, v in pairs(buckets) do
			for _, min in pairs(v) do
				print(min:tostring())
			end
		end

		-- Little "optimization" that removes miniterms with repeated binary representations
		-- This reduces the amount of mixes the program will have to make. Not perfect, but good enough
		print("\nMixed ("..mix_time.." s)")
		table.sort(t, function (a1, b1)
			if a1.group < b1.group then
				return true
			else
				return false
			end
		end)
		do

			clean_time = os.clock()
			local x = 1
			while x <= #t do
				local x_min = t[x]
				local y = x+1
				while y <= #t do
					local y_min = t[y]
					if y_min.group == x_min.group then
						if x_min.repr == y_min.repr then
							table.remove(t, y)
						else
							y = y + 1
						end
					else
						break
					end
				end

				x = x + 1
			end
			--[[local x = 1
			while x <= #t do
				local x_min = t[x]
				local y = x+1
				while y <= #t do
					local y_min = t[y]
					if x_min.repr == y_min.repr then
						table.remove(t, y)
					else
						y = y + 1
					end
				end
				x = x + 1
			end]]
			print("Cleaned ("..os.clock()-clean_time.." s)")
			print("---------------------------------------")
		end

		io.read()

		-- In case the number of mixes is zero, it means that no more terms can be mixed. Break the loop in that case
		if matches == 0 then
			break
		end
	end

	return raw_e_miniterms
end

--Filtering of the  miniterms
--
-- The filtering process is divided into two rounds
--
-- The first round filters miniterms that may cause problems in the second round
--
-- The second round filters miniterms based on the amount of repeated nums
function QMCFilterEMiniterms(raw_e_miniterms)
	-- This part filters problematic miniterms that may screw the next step
	local e_miniterms = {}
	do
		-- The iterator over all raw miniterms
		local i = 1
		-- All the matched numbers up to that miniterm
		local matched = {}
		while i <= #raw_e_miniterms do
			-- Current miniterm
			local m1 =raw_e_miniterms[i]
			-- The matches of its numbers vs matched
			local match = 0
			-- Iterate over all nums of m1
			for _, x in pairs(m1.nums) do
				-- If matched has no numbers, insert the first one
				if #matched == 0 then
					table.insert(matched, x)
				else
					-- This tells if the number is in the list
					local in_list = false

					-- Iterate over all matched numbers and check if the current num is not
					-- in the list
					for y = 1, #matched, 1 do
						if x == matched[y] then
							match = match + 1
							in_list = true
						end
					end

					-- If it's not in the list, add it
					if not in_list then
						table.insert(matched, x)
					end
				end
			end

			-- If the number of matches is equal to the number of nums, then all numbers
			-- were already covered and that miniterm must be removed. i is not increased
			-- because it leads to unexpected behaviour
			if match >= #m1.nums then
				table.remove(raw_e_miniterms, i)
			-- Otherwise, advance to the next miniterm
			else
				i = i + 1
			end
		end
	end
	
	return raw_e_miniterms, e_miniterms
end

function QMCGenSolution(e_miniterms, bit, vars)
	local solution  = ""
	if #e_miniterms == 0 then
		solution = "0"
		return solution
	end
	local dont_care = 0
	for m = 1, #e_miniterms, 1 do
		local bits = 65
		local v = e_miniterms[m]

		for i = 1, #v.repr, 1 do
			local char = string.sub(v.repr, i, i)
			if char == "1" then
				if not vars then
					solution = solution .. string.char(bits + i - 1)
				else
					solution = solution .. vars[i].symbol
				end
			elseif char == "0" then 
				if not vars then
					solution = solution .. string.char(bits + i - 1) .. "'"
					
				else

					solution = solution .. vars[i].symbol .. "'"
				end
			else
				dont_care = dont_care + 1
			end
		end
		if m < #e_miniterms then
			solution = solution .. "+"
		end
	end

	if dont_care == bit and #e_miniterms == 1 then
		solution = "1"
	end

	return solution
end

return {QMCSelectMiniterm, QMCMixMiniterms, QMCFilterEMiniterms, QMCGenSolution}