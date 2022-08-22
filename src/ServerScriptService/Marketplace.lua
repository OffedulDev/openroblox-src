local MarketplaceService = game:GetService("MarketplaceService")
local Module = {
    MarketplaceService = game:GetService("MarketplaceService");
}

function Module:VerifyGamepass(asset: number, player: Player)
    local ProductInfo = self.MarketplaceService:GetProductInfo(asset, Enum.InfoType.GamePass)
    warn("Veryfing " .. ProductInfo.Name)

    if not (ProductInfo.Creator.Id == player.UserId) then error("This asset is not owned by the player."); return end
    if ProductInfo.IsPublicDomain == true then error("This is a free asset.") return false end
    if ProductInfo.IsForSale == false then error("This item is not for sale.") return false end
    if ProductInfo.PriceInRobux < 10 then error("This item price is lower then 10R$") return false end
    return true
end

return Module