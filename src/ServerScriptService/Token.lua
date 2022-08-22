local Players = game:GetService("Players")
-- Token
-- Actual Studios
-- August 14, 2022

--[[
	
	obj = Token.new()
	
--]]

--[[
TODO:

Init generates one auth key and a seed, both have to be kept secret and when getting anything that seed will be 
used to decrypt it revealing the information, if the decryption has some type of error the token
gets destructed locally to prevent global harm.
--]]


local Token = {}
Token.__index = Token


function Token.new()
	
	local self = setmetatable({
		
	}, Token)
	
	return self
	
end

function Token:init(restart_init: boolean)

    self.history = {}
    self.token_details = {}
    self.authkey = self:encrypt("token64Hash" .. math.random(1, 550))
    return self.authkey
    
end

function Token:encrypt(text: string)
	local sea = require(script.Parent:WaitForChild("indirectaSEA"))
	local secret = sea.deriveSecret(tostring(text))
	secret = secret[3]
	
	return secret or 0
end

function Token:safeCompare(key: string, key1: string)
    warn(key, key1)
    if key == key1 then
        return true
    else
        return false
    end
end

function Token:verifyKey(inputKey: string)
    if self:safeCompare(self.authkey, inputKey) == true then
        return true
    else
        error("Unknown origin tried to access token properties.")
        return false
    end
end

function Token:register(action: string, auth_key: string)
	if not self:verifyKey(auth_key) then return false end
    

    action = {
        hash = self:encrypt(action);
        action = action;
    }
    table.insert(self.history, action)

    return true
end

function Token:set(index: string, value: string, authkey: number)
    if not self:register(("Set of %s to %s"):format(index, value), authkey) then return false end
    
    self.token_details[index] = value
    return true
end

function Token:save()
    local database = require(script.Parent:WaitForChild("Database"))
    local Class = self:class()
    database:SyncKey(Class.Title, Class)
end

function Token:class()
    local TokenClass = self.token_details
    TokenClass.History = game:GetService("HttpService"):JSONEncode(self.history)

    return TokenClass
end

return Token