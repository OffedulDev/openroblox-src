-- GuiModule
-- Actual Studios
-- August 14, 2022

local MarketplaceService = game:GetService("MarketplaceService")
local GuiModule = {}

function GuiModule:ShowNFT(Player, Class)
    local Gui = Player.PlayerGui:WaitForChild("Main")
    local Info = MarketplaceService:GetProductInfo(Class.Asset, Enum.InfoType.GamePass)
    local Price = Info.PriceInRobux
    Gui.Marketplace.Visible = false
	Gui.Asset.ConfirmFrame.Visible = false 
	Gui.Asset.PriceFrame.Visible = true 
	Gui.Asset.Visible = true
	Gui.Create.Visible = false
	Gui.ServerHandler:SetAttribute("Page", "Asset")
	Gui.Asset.Owner.Text = ("Owned by <font color='#0080ff'>%s</font>"):format(Class.Owner)
	Gui.Asset.Title.Text = Class.Title
	Gui.Asset.Collection.Text = "No collection"
	Gui.Asset.Image.Image = ("rbxthumb://type=Asset&id=%s&w=420&h=420"):format(Class.Image)
	Gui.Asset.PriceFrame.Price.Price.Text = Price
	Gui.Asset.DescriptionFrame.Description.Text.Text = Class.Description
	task.spawn(function()
		Gui.Asset.PriceFrame.Price.Buy.MouseButton1Click:Connect(function()
			Gui.Asset.PriceFrame.Visible = false
			Gui.Asset.ConfirmFrame.Visible = true
			Gui.Asset.ConfirmFrame.Price.Price.Text = Price
		end)
	end)
end

function GuiModule:BuildNFT(Player, Class)
    local Gui = Player.PlayerGui:WaitForChild("Main")
    local Info = MarketplaceService:GetProductInfo(Class.Asset, Enum.InfoType.GamePass)
    local Marketplace = Gui:WaitForChild("Marketplace")
    local Template = Marketplace.InnerFrame:WaitForChild("Case")
    local Price = Info.PriceInRobux

    local Clone = Template:Clone()
	Clone.Icon.Image = ("rbxthumb://type=Asset&id=%s&w=420&h=420"):format(Class.Image)
	Clone.Collection.Text = "No collection"
	Clone.Price.Text = Price
	Clone.Title.Text = Class.Title
	Clone.Name = Class.Title
	Clone.Parent = Marketplace.InnerFrame
	Clone.Visible = true
	task.spawn(function()
		Clone.View.MouseButton1Click:Connect(function()
			self:ShowNFT(Player, Class)
		end)
	end)    
end

function GuiModule:UpdateCase(Player, Class)
	local Gui = Player.PlayerGui:WaitForChild("Main")
    local Info = MarketplaceService:GetProductInfo(Class.Asset, Enum.InfoType.GamePass)
    local Marketplace = Gui:WaitForChild("Marketplace")
    local Template = Marketplace.InnerFrame:WaitForChild("Case")
    local Price = Info.PriceInRobux

	if Marketplace.InnerFrame:FindFirstChild(Class.Title) then
		Marketplace.InnerFrame[Class.Title]:Destroy()
	else
		return
	end

    local Clone = Template:Clone()
	Clone.Icon.Image = ("rbxthumb://type=Asset&id=%s&w=420&h=420"):format(Class.Image)
	Clone.Collection.Text = "No collection"
	Clone.Price.Text = Price
	Clone.Title.Text = Class.Title
	Clone.Name = Class.Title
	Clone.Parent = Marketplace.InnerFrame
	Clone.Visible = true
	task.spawn(function()
		Clone.View.MouseButton1Click:Connect(function()
			self:ShowNFT(Player, Class)
		end)
	end) 
end

return GuiModule