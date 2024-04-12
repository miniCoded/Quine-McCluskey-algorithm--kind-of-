local QMC = require("Quine-McCluskey.QMC")
local BooleanExp = require("Boolean_exp.BoolExp")

math.randomseed(os.time())

local bits = 3

local truth = {}

for _ = 1, 2^bits, 1 do
	local rand_bit = ""
	if math.random() <= 0.5 then
		rand_bit = "1"
	else
		rand_bit = "0"
	end
	table.insert(truth, rand_bit)
end

-- truth = {"1", "0", "1", "1", "1", "0", "0", "1"}
-- truth = {"1", "0", "1", "0", "1", "1", "1", "0"}
-- truth = {"0", "0", "0", "0", "1", "1", "1", "0"}
-- truth = {"1", "1", "0", "1", "1", "0", "1", "0"}
-- truth = {'1', '0', '1', '1', '0', '1', '0', '0'}

local m, bits, exp, tok = QMCSelectMiniterm()
local raw_e_miniterms = QMCMixMiniterms(m, bits)
local e_miniterms = QMCFilterEMiniterms(raw_e_miniterms)
local solution = QMCGenSolution(e_miniterms, bits , GetVars(exp, tok))

print("Essential miniterms: ")
for i = 1, #e_miniterms, 1 do
	print(e_miniterms[i]:tostring())
end
print("---------------------------------------")

io.write('\n')
print("Solution: ", solution)