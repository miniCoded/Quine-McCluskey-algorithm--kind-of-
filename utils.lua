-- Convert from base-10 to base-2
-- n is the number to convert
-- b is the amount of bits
function toBinary(n, b)
	local repr = ""
	if n > 0 then
		while n > 0 do
			if n == 0 then
				break
			end
			if n % 2 == 0 then
				repr = "0" .. repr
			else
				repr = "1" .. repr
			end

			n = n // 2
		end
	else
		repr = "0"
	end

	while #repr < b do
		repr = "0" .. repr
	end

	return repr
end
-- {1, 3, 5, 7, 9, 10}
function binarySearch(arr, n, comp)
	local i = #arr//2
	local L = 1
	local R = #arr

	while L ~= R do
		if comp(arr[i], n) then
			return i
		else
			if comp(arr[i], n) then
				R = i - 1
			else
				L = i + 1
			end
			i = (R + L)//2
			print(R, L, i)
		end
	end

	return i
end

return {toBinary, binarySearch}