task.wait(1)
-- Utils
local Bin = script.Parent

-- Functions
local function getVarPage()
	return script:GetAttribute("Page")
end
local function hidePages()
	for _, Value in ipairs(script.Parent:GetChildren()) do
		if Value:IsA("Frame") or Value:IsA("ScrollingFrame") then
			if Value.Name == "Topbar" then continue end
			Value.Visible = false
		end
	end
end
local function getPage(page: string)
	return Bin:FindFirstChild(page) or Instance.new("Frame")
end
local function getCurrentPage()
	for _, _Page in ipairs(Bin:GetChildren()) do
		if _Page:IsA("Frame") and not _Page.Name == "Topbar" then
			if _Page.Visible == true then
				return _Page
			end
		end
	end
	return Instance.new("Frame")
end
local function switchPage(page: string)
	local Page = getVarPage()
	local oldPage = getPage(Page)
	page = getPage(page)

	oldPage.Visible = false
	page.Visible = true

	script:SetAttribute("Page", page.Name)
end

-- Initialize
script:SetAttribute("Page", getCurrentPage().Name)

-- Connect Buttons Links
for _, Obj in ipairs(Bin:GetDescendants()) do
	if Obj:IsA("TextButton") and Obj:GetAttribute("Link") ~= nil then
		task.spawn(function()
			Obj.MouseButton1Click:Connect(function()
				switchPage(Obj:GetAttribute("Link"))
			end)
		end)
	end
end

--[[ task.spawn(function()
	Bin.Login.Visible = true
	Bin.Login.LoginOptions.RobloxCredit.Sensor.MouseButton1Click:Wait()
	Bin.Login.Visible = false
	Bin.Homepage.Visible = true
end)
 *]]


