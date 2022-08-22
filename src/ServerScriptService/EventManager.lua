local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local EventManager = {
    SubscribeEvents = {};
}

function EventManager:Run()
    for _, Player in ipairs(Players:GetPlayers()) do
        for _, Event in ipairs(self.SubscribeEvents) do
            Event.Event:FireClient(Player, Event.ClientKey)
            task.spawn(function()
                Event.Event.OnServerEvent:Connect(function(Player, Key, ...)
                    if Key == Event.ClientKey then
                        Event.Callback(Player, ...)
                    else
                        error("Wrong key issued.")
                    end
                end)
            end)
        end
    end
    Players.PlayerAdded:Connect(function(Player)
        for _, Event in ipairs(self.SubscribeEvents) do
            Event.Event:FireClient(Player, Event.ClientKey)
            task.spawn(function()
                Event.Event.OnServerEvent:Connect(function(Player, Key, ...)
                    if Key == Event.ClientKey then
                        Event.Callback(Player, ...)
                    else
                        error("Wrong key issued.")
                    end
                end)
            end)
        end
    end)
end

function EventManager:SubscribeEvent(event: RemoteEvent, callback: any)
    warn(("Subscribed %s"):format(event.Name))
    local EventClass = {
        Event = event,
        Callback = callback,
        ServerKey = math.random(999,9999),
        ClientKey = math.random(999,9999)
    }

    table.insert(self.SubscribeEvents, EventClass)
    return
end

return EventManager