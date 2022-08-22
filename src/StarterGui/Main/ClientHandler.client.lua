task.wait(3)

local Bin = script.Parent

-- Pages
local Asset = Bin:WaitForChild("Asset")
local Create = Bin:WaitForChild("Create")

-- Events
local ChainRemotes = game:GetService("ReplicatedStorage"):WaitForChild("ChainRemote")
local CreateRequest = ChainRemotes:WaitForChild("CreateRequest")
local CompletePurchaseProcess = ChainRemotes:WaitForChild("CompletePurchaseProcess")

local CPPKey = 0
local CRKey = 0

CompletePurchaseProcess.OnClientEvent:Connect(function(Key)
	CPPKey = Key
end)
CreateRequest.OnClientEvent:Connect(function(Key)
	CRKey = Key
end)

task.spawn(function()
	Asset.ConfirmFrame.Price.Confirm.MouseButton1Click:Connect(function()
		local TextBox = Asset.ConfirmFrame.Bar.Asset
		CompletePurchaseProcess:FireServer(CPPKey, TextBox.Text)
		return
	end)
end)

Create.InnerFrame.Complete.MouseButton1Click:Connect(function()
	local NameField = Create.InnerFrame.NameField
	local DescriptionField = Create.InnerFrame.DescriptionField
	local AssetField = Create.InnerFrame.AssetField
	local Image = Create.InnerFrame.ImageFrame.ImageId
	
	if NameField.Text == "" then
		NameField.Close.Visible = true
		return
	end

	if DescriptionField.Text == "" then
		DescriptionField.Close.Visible = true
		return
	end

	if AssetField.Text == "" then
		AssetField.Close.Visible = true
		return
	end

	local Table = {
		Title = NameField.Text,
		Description = DescriptionField.Text,
		Asset = tonumber(AssetField.Text),
		Image = tonumber(Image.Text)
	}
		
	CreateRequest:FireServer(CRKey, Table)
	return
end)