local Block = {}
local sha256 = require(script.Parent:WaitForChild("sha256"))
Block.__index = Block

function Block.new()
    return setmetatable({}, Block)
end

function Block:startBlock(list: table)
    self.zero_requirments = math.random(0, 20)
    self.elements = list
end

function Block:hashElements()
    local str = ""
    for _, el in ipairs(self.elements) do
        str = str + "-" + el
    end
    self.hash = sha256.sha256(str)
    return self.hash
end

function Block:complete(proof_of_work: string)
    proof_of_work = proof_of_work:split("")
    local cn = 0
    for _, ch in ipairs(proof_of_work) do
        if ch == "0" then
            cn += 1
        end
    end
    if not cn == self.zero_requirments then
        error("Invalid proof of work given.")
        return "Proof of work invalid."
    end
    self.__newindex = function(table, key, value)
       error("Attempt to edit a completed token.")
    end
end

return Block