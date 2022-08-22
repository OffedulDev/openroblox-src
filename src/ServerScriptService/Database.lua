-- Database
-- Actual Studios
-- August 14, 2022

local Database = {}

function Database:GetDatastore()
    return game:GetService("DataStoreService"):GetDataStore("Database")
end


function Database:SyncKey(key: string, data: any)
    warn("Setting " .. key .. " to " .. tostring(data))
    local Datastore = self:GetDatastore()
    local Shallow = self:GetShallow()
    if Datastore:GetAsync(key) == nil then
        table.insert(Shallow, key)
    end

    Datastore:SetAsync("shallow_info", Shallow)
    Datastore:SetAsync(key, data)
    return true
end

function Database:GetShallow()
    local Datastore = self:GetDatastore()
    return Datastore:GetAsync("shallow_info") or {}
end

return Database