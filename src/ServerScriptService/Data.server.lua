
local DataStore = game:GetService("DataStoreService"):GetDataStore("Server")
local MessagingService = game:GetService("MessagingService")
task.wait(3)

local Players = game:GetService("Players")

-- Initial Load
local Key = DataStore:GetAsync("Blockchain") or {}
local Player = Players:GetChildren()[1]
local Gui = Player:WaitForChild("PlayerGui")
local Screen = Gui:WaitForChild("Main")
local Marketplace = Screen:WaitForChild("Marketplace")
local Template = Marketplace:WaitForChild("InnerFrame"):WaitForChild("Case")
local Asset = Screen:WaitForChild("Asset")
local function showNFT(Value)
	Marketplace.Visible = false
	Asset.ConfirmFrame.Visible = false 
	Asset.PriceFrame.Visible = true 
	Asset.Visible = true
	Asset.Owner.Text = "Owned by <font color='#0080ff'>" .. Value.Owner .. "</font>"
	Asset.Title.Text = Value.Name
	Asset.Collection.Text = Value.Collection or "No collection"
	Asset.Image.Image = "rbxthumb://type=Asset&id=" .. Value.Image .. "&w=420&h=420"
	Asset.PriceFrame.Price.Price.Text = Value.Price
	Asset.DescriptionFrame.Description.Text.Text = Value.Description or "From " .. Value.Owner
	task.spawn(function()
		Asset.PriceFrame.Price.Buy.MouseButton1Click:Connect(function()
			Asset.PriceFrame.Visible = false
			Asset.ConfirmFrame.Visible = true
			Asset.ConfirmFrame.Price.Price.Text = Value.Price
		end)
	end)
end

local function updateNFTUi(value)
	local _Tem = Marketplace.InnerFrame:FindFirstChild(value.Name)
	local Tem = _Tem:Clone()
	_Tem:Destroy()
	Tem.Parent = Marketplace.InnerFrame
	Tem.Price.Text = value.Price
	task.spawn(function()
		Tem.View.MouseButton1Click:Connect(function()
			showNFT(value)
		end)
	end)
end

local function buildNFTUi(Value)
	local _Tem = Template:Clone()
	_Tem.Icon.Image = "rbxthumb://type=Asset&id=" .. Value.Image .. "&w=420&h=420"
	_Tem.Collection.Text = Value.Collection or "No collection"
	_Tem.Price.Text = Value.Price
	_Tem.Title.Text = Value.Name
	_Tem.Name = Value.Name
	_Tem.Parent = Marketplace.InnerFrame
	_Tem.Visible = true
	task.spawn(function()
		_Tem.View.MouseButton1Click:Connect(function()
			showNFT(Value)
		end)
	end)
end

task.spawn(function()

	for _, Value in ipairs(Key) do
		buildNFTUi(Value)
	end
	
end)

task.spawn(function()
	MessagingService:SubscribeAsync("NewCreation", function(Value) 
		buildNFTUi(game:GetService("HttpService"):JSONDecode(Value.Data))
	end)
end)

-- Events
local MarketplaceService = game:GetService("MarketplaceService")
local Events = game:GetService("ReplicatedStorage"):WaitForChild("ChainRemote")
local CreateRequest = Events:WaitForChild("CreateRequest")
local CompletePurchaseProcess = Events:WaitForChild("CompletePurchaseProcess")
local Fee = 1298439104
local SavedFields = ""
local StoreID = 0

warn("Subscribed Event")
task.spawn(function()
	CreateRequest.OnServerEvent:Connect(function(Player, Fields)
		warn(game:GetService("HttpService"):JSONEncode(Fields))
		local ImageInfo = MarketplaceService:GetProductInfo(Fields.Image, Enum.InfoType.Asset)
		local GamepassInfo = MarketplaceService:GetProductInfo(Fields.Asset, Enum.InfoType.GamePass)
		if GamepassInfo.Creator.Id ~= Player.UserId then warn("Gamepass not owned by the player.") return end
		if ImageInfo.Creator.Id ~= Player.UserId then warn("Image not owned by the player.") return end
		
		SavedFields = game:GetService("HttpService"):JSONEncode(Fields)
		MarketplaceService:PromptProductPurchase(Player, Fee)
	end)
end)

task.spawn(function()
	MessagingService:SubscribeAsync("OwnershipTransfer", function(data)
		updateNFTUi(game:GetService("HttpService"):JSONDecode(data.Data))
	end)
end)

task.spawn(function()
	CompletePurchaseProcess.OnServerEvent:Connect(function(Player, Id)
		Id = tonumber(Id)
		local GamepassInfo = MarketplaceService:GetProductInfo(Id, Enum.InfoType.GamePass)
		if GamepassInfo.Creator.Id ~= Player.UserId then warn("Gamepass not owned by the player."); Asset.ConfirmFrame.Visible = false; return end
		
		local Class =  nil
		for _, Value in ipairs(DataStore:GetAsync("Blockchain")) do
			if Value.Name == Asset.Title.Text then
				Class = Value
				break
			end
		end
		if Class == nil then warn("Class is nil"); return end
		StoreID = Id
		MarketplaceService:PromptGamePassPurchase(Player, Class.Asset)
	end)
end)

task.spawn(function()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, id, was)
		if was == true then
			
			local Class =  nil
			local Idx = 0
			for Index, Value in pairs(DataStore:GetAsync("Blockchain")) do
				if Value.Name == Asset.Title.Text then
					Class = Value
					Idx = Index
					break
				end
			end
			if Class == nil then warn("Class is nil") return end
			
			local GamepassInfo = MarketplaceService:GetProductInfo(StoreID, Enum.InfoType.GamePass)
			Class.Owner = plr.Name
			Class.Price = GamepassInfo.PriceInRobux
			Class.Asset = StoreID
			
			local Chain = DataStore:GetAsync("Blockchain")
			Chain[Idx] = Class
			
			DataStore:SetAsync("Blockchain", Chain)
			StoreID = 0
			
			MessagingService:PublishAsync("OwnershipTransfer", game:GetService("HttpService"):JSONEncode(Class))
		end
	end)
end)

local functions = {}
functions[Fee] = function(recipt, Player)
	warn(game:GetService("HttpService"):JSONEncode(recipt))
	local Fields = game:GetService("HttpService"):JSONDecode(SavedFields)
	local GamepassInfo = MarketplaceService:GetProductInfo(Fields.Asset, Enum.InfoType.GamePass)

	print("Price: " .. GamepassInfo.PriceInRobux)
	local NFTClass = {
		Name = Fields.Name,
		Description = Fields.Description,
		Collection = nil,
		Owner = Player.Name,
		Price = tostring(GamepassInfo.PriceInRobux),
		Image = Fields.Image,
		Asset = Fields.Asset
	}

	local CurrentChain = DataStore:GetAsync("Blockchain") or {}
	table.insert(CurrentChain, NFTClass)

	DataStore:SetAsync("Blockchain", CurrentChain)
	MessagingService:PublishAsync("NewCreation", game:GetService("HttpService"):JSONEncode(NFTClass))
	
	showNFT(NFTClass)
end

MarketplaceService.ProcessReceipt = function(reciptInfo)
	
	local handler = functions[reciptInfo.ProductId]
	local Player = Players:GetPlayerByUserId(reciptInfo.PlayerId)
	local success, result = pcall(handler, reciptInfo, Player)

	if not success then
		warn("Purchase handler didn't process.")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else	
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end
