local Token = require(script.Parent:WaitForChild("Token"))
local GuiModule = require(script.Parent:WaitForChild("GuiModule"))
local EventManager = require(script.Parent:WaitForChild("EventManager"))
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Database = require(script.Parent:WaitForChild("Database"))
local Marketplace = require(script.Parent:WaitForChild("Marketplace"))
local Players = game:GetService("Players")
local HTTPService = game:GetService("HttpService")
warn("Waiting for Player...")
repeat task.wait() until #Players:GetPlayers() > 0

warn("Started Basic Runtime")
local Player = Players:GetPlayers()[1]
local Tokens = {}
local Keys = Database:GetShallow()
task.spawn(function()
    local Datastore = Database:GetDatastore()
    for _, Key in ipairs(Keys) do
        local Class = Datastore:GetAsync(Key)
        if not Class then break end

        local NoviceToken = Token.new()
        local AuthKey = NoviceToken:init()
        NoviceToken:set("Title", Class.Title, AuthKey)
        NoviceToken:set("Description", Class.Description, AuthKey)
        NoviceToken:set("Image", Class.Image, AuthKey)
        NoviceToken:set("Asset", Class.Asset, AuthKey)
        NoviceToken:set("Owner", Player.Name, AuthKey)
        GuiModule:BuildNFT(Player, NoviceToken:class())

        local TokenStoreClass = {
            Token = NoviceToken,
            Key = AuthKey
        }
        table.insert(Tokens, TokenStoreClass)
    end
end)

--[[

Complete Purchase Process

--]]

EventManager:SubscribeEvent(ReplicatedStorage.ChainRemote.CompletePurchaseProcess, function(Player, NewAssetId)
    if Marketplace:VerifyGamepass(tonumber(NewAssetId), Player) == false then warn("Asset is not owned by the player.") return end
    local CurrentNFT = nil
    local Idx = 0
    for Index, Value in pairs(Tokens) do
        if Value.Token:class().Title == Player.PlayerGui.Main.Asset.Title.Text then
            CurrentNFT = Value
            Idx = Index
            break
        else
            continue
        end
    end

    CurrentNFT.Token:set("FutureAsset", NewAssetId, CurrentNFT.Key)
    Tokens[Idx] = CurrentNFT

    Marketplace.MarketplaceService:PromptGamePassPurchase(Player, CurrentNFT.Token:class().Asset)
end)

--[[

Marketplace ProcessReceipt

--]]

task.spawn(function()
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, id, is)
        if is == false then warn("Blank transaction.") return Enum.ProductPurchaseDecision.NotProcessedYet end
        local NFT = nil
        local Idx = 0
        for Index, Value in pairs(Tokens) do
            if Value.Token:class().Asset == id then
                NFT = Value
                Idx = Index
                break
            else
                continue
            end
        end
        if NFT == nil then warn("Blank transaction.") return Enum.ProductPurchaseDecision.NotProcessedYet end

        local FutureAsset = NFT.Token:class().FutureAsset
        if FutureAsset == nil then warn("Blank transaction.") return Enum.ProductPurchaseDecision.NotProcessedYet end

        NFT.Token:set("Owner", Player.Name, NFT.Key)
        NFT.Token:set("Asset", FutureAsset, NFT.Key)
        NFT.Token:set("FutureAsset", "", NFT.Key)
        NFT.Token:save()
        Tokens[Idx] = NFT

        return Enum.ProductPurchaseDecision.PurchaseGranted
    end)
end)

--[[

Create Request

--]]

EventManager:SubscribeEvent(ReplicatedStorage.ChainRemote.CreateRequest, function(Player, Table)
    local Class = Table
    Class.Owner = Player.Name

    local NoviceToken = Token.new()
    local AuthKey = NoviceToken:init()
    NoviceToken:set("Title", Class.Title, AuthKey)
    NoviceToken:set("Description", Class.Description, AuthKey)
    NoviceToken:set("Image", Class.Image, AuthKey)
    NoviceToken:set("Asset", Class.Asset, AuthKey)
    NoviceToken:set("Owner", Class.Owner, AuthKey)
    GuiModule:BuildNFT(Player, NoviceToken:class())
    GuiModule:ShowNFT(Player, NoviceToken:class())

    local TokenStoreClass = {
        Token = NoviceToken,
        Key = AuthKey
    }
    table.insert(Tokens, TokenStoreClass)
    NoviceToken:save()
end)

EventManager:Run()