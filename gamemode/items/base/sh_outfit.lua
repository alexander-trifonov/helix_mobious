
ITEM.name = "Outfit"
ITEM.description = "A Outfit Base."
ITEM.category = "Outfit"
ITEM.model = "models/Gibs/HGIBS.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "model"
ITEM.pacData = {}

--[[
-- This will change a player's skin after changing the model. Keep in mind it starts at 0.
ITEM.newSkin = 1
-- This will change a certain part of the model.
ITEM.replacements = {"group01", "group02"}
-- This will change the player's model completely.
ITEM.replacements = "models/manhack.mdl"
-- This will have multiple replacements.
ITEM.replacements = {
	{"male", "female"},
	{"group01", "group02"}
}

-- This will apply body groups.
ITEM.bodyGroups = {
	["blade"] = 1,
	["bladeblur"] = 1
}
]]--

-- Inventory drawing
if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end

	function ITEM:PopulateTooltip(tooltip)
		if (self.popularBy) then
			local popularBy = tooltip:AddRow("popularBy")
			local text = self.popularBy
			popularBy:SetColor(Color(150, 150, 150))
			popularBy:SetText(text)
			popularBy:SizeToContents()
		end
		if (self:GetData("durability", self.durability)) then
            local durability = tooltip:AddRow("durability")
            local text = ((self.durabilityDesc) or ("Осталось прочности: "))..(self:GetData("durability") or self.durability)
            durability:SetColor(Color(60, 150, 60))
            durability:SetText(text or "")
            durability:SizeToContents()
        end
	end
end

function ITEM:OnInstanced(index, x, y, item)
    self:SetData("durability", self:GetData("durability") or self.durability or 100)
	self:SetData("outfitCategory", self:GetData("outfitCategory") or self.outfitCategory or "other")
	if (self.PostInstanced) then
		self:PostInstanced()
	end
end

function ITEM:AddOutfit(client)
	local character = client:GetCharacter()

	self:SetData("equip", true)
	
	if istable(self.replacements) then
		for k, v in pairs(self.replacements) do
			character:SetModel(self.player:GetModel():gsub(v[1], v[2]))
		end

		if (self.bodyGroups == nil) then
			-- Load actual bodygroups
			client:ResetBodygroups()
			local bodyGroups = character:GetData("groups", {})
			for k, v in pairs(bodyGroups) do
				local index = client:FindBodygroupByName(k)
				
				if (index > -1) then
					client:SetBodygroup(index, v)
				end
			end	
		end
	end
	
	if (istable(self.bodyGroups)) then

		local bodyGroups = table.Copy(character:GetData("bodyGroups"..self.outfitCategory, {}))
		local bodyGroupsOld = table.Copy(bodyGroups)
		if (table.IsEmpty(bodyGroupsOld)) then
			for k, v in pairs(self.bodyGroups) do
				bodyGroupsOld[k] = 0 -- a value, player start with. Should add setbodygroup support or something
			end
		end
		character:SetData("bodyGroupsOld"..self.outfitCategory, bodyGroupsOld)
		
		for k, v in pairs(self.bodyGroups) do
			local index = client:FindBodygroupByName(k)
			
			if (index > -1) then
				client:SetBodygroup(index, v)
				bodyGroups[k] = v
			end
		end
		character:SetData("bodyGroups"..self.outfitCategory, bodyGroups)
		local actualData = character:GetData("groups", {})
		for k, v in pairs(bodyGroups) do
			actualData[k] = v
		end
		character:SetData("groups", actualData)
	end
	


	-- local groups = character:GetData("groups", {})

	-- -- remove original bodygroups
	-- if (!table.IsEmpty(groups)) then
	-- 	character:SetData("oldGroups" .. self.outfitCategory, groups)
	-- 	character:SetData("groups", {})

	-- 	client:ResetBodygroups()
	-- end

	-- if (isfunction(self.OnGetReplacement)) then
	-- 	character:SetData("oldModel" .. self.outfitCategory,
	-- 		character:GetData("oldModel" .. self.outfitCategory, self.player:GetModel()))
	-- 	character:SetModel(self:OnGetReplacement())
	-- elseif (self.replacement or self.replacements) then
	-- 	character:SetData("oldModel" .. self.outfitCategory,
	-- 		character:GetData("oldModel" .. self.outfitCategory, self.player:GetModel()))

	-- 	if (istable(self.replacements)) then
	-- 		if (#self.replacements == 2 and isstring(self.replacements[1])) then
	-- 			character:SetModel(self.player:GetModel():gsub(self.replacements[1], self.replacements[2]))
	-- 		else
	-- 			for _, v in ipairs(self.replacements) do
	-- 				character:SetModel(self.player:GetModel():gsub(v[1], v[2]))
	-- 			end
	-- 		end
	-- 	else
	-- 		character:SetModel(self.replacement or self.replacements)
	-- 	end
	-- end

	-- if (self.newSkin) then
	-- 	character:SetData("oldSkin" .. self.outfitCategory, self.player:GetSkin())
	-- 	self.player:SetSkin(self.newSkin)
	-- end

	-- -- get outfit saved bodygroups
	-- groups = self:GetData("groups", {})

	-- -- restore bodygroups saved to the item
	-- if (!table.IsEmpty(groups) and self:ShouldRestoreBodygroups()) then
	-- 	for k, v in pairs(groups) do
	-- 		client:SetBodygroup(k, v)
	-- 	end
	-- -- apply default item bodygroups if none are saved
	-- elseif (istable(self.bodyGroups)) then
	-- 	for k, v in pairs(self.bodyGroups) do
	-- 		local index = client:FindBodygroupByName(k)

	-- 		if (index > -1) then
	-- 			client:SetBodygroup(index, v)
	-- 		end
	-- 	end
	-- end

	-- local materials  = self:GetData("submaterial", {})

	-- if (!table.IsEmpty(materials) and self:ShouldRestoreSubMaterials()) then
	-- 	for k, v in pairs(materials) do
	-- 		if (!isnumber(k) or !isstring(v)) then
	-- 			continue
	-- 		end

	-- 		client:SetSubMaterial(k - 1, v)
	-- 	end
	-- end

	-- if (istable(self.attribBoosts)) then
	-- 	for k, v in pairs(self.attribBoosts) do
	-- 		character:AddBoost(self.uniqueID, k, v)
	-- 	end
	-- end

	self:OnEquipped()
end

local function ResetSubMaterials(client)
	for k, _ in ipairs(client:GetMaterials()) do
		if (client:GetSubMaterial(k - 1) != "") then
			client:SetSubMaterial(k - 1)
		end
	end
end

function ITEM:RemoveOutfit(client)
	local character = client:GetCharacter()

	self:SetData("equip", false)
	
	
	if (istable(self.replacements)) then
		character:SetModel(character:GetData("modelOriginal"))

		-- Return to monkey and restore actual bodygroups
		client:ResetBodygroups()
		local bodyGroups = character:GetData("groups", {})
		for k, v in pairs(bodyGroups) do
			local index = client:FindBodygroupByName(k)
			
			if (index > -1) then
				client:SetBodygroup(index, v)
			end
		end	
	end

	-- Change this category bodygroups back to monkey
	local bodyGroupsOld = table.Copy(character:GetData("bodyGroupsOld"..self.outfitCategory))
	--local bodyGroups = character:GetData("bodyGroupsOld"..self.outfitCategory)
	for k, v in pairs(bodyGroupsOld) do
		local index = client:FindBodygroupByName(k)
		
		if (index > -1) then
			client:SetBodygroup(index, v) -- 0 is default for now. Need /charsetbodygroup suppors here
			--bodyGroupsOld[k] = v
		end
	end
	character:SetData("bodyGroups"..self.outfitCategory, bodyGroupsOld)

	local bodyGroups = table.Copy(character:GetData("bodyGroups"..self.outfitCategory))
	-- Save changes
	local actualData = character:GetData("groups")
	for k, v in pairs(bodyGroups) do
		actualData[k] = v
	end
	character:SetData("groups", actualData)


	-- local materials = {}

	-- for k, _ in ipairs(client:GetMaterials()) do
	-- 	if (client:GetSubMaterial(k - 1) != "") then
	-- 		materials[k] = client:GetSubMaterial(k - 1)
	-- 	end
	-- end

	-- -- save outfit submaterials
	-- if (!table.IsEmpty(materials)) then
	-- 	self:SetData("submaterial", materials)
	-- end

	-- -- remove outfit submaterials
	-- ResetSubMaterials(client)

	-- local groups = {}

	-- for i = 0, (client:GetNumBodyGroups() - 1) do
	-- 	local bodygroup = client:GetBodygroup(i)

	-- 	if (bodygroup > 0) then
	-- 		groups[i] = bodygroup
	-- 	end
	-- end

	-- -- save outfit bodygroups
	-- if (!table.IsEmpty(groups)) then
	-- 	self:SetData("groups", groups)
	-- end

	-- -- remove outfit bodygroups
	-- client:ResetBodygroups()

	-- -- restore the original player model
	-- if (character:GetData("oldModel" .. self.outfitCategory)) then
	-- 	character:SetModel(character:GetData("oldModel" .. self.outfitCategory))
	-- 	character:SetData("oldModel" .. self.outfitCategory, nil)
	-- end

	-- -- restore the original player model skin
	-- if (self.newSkin) then
	-- 	if (character:GetData("oldSkin" .. self.outfitCategory)) then
	-- 		client:SetSkin(character:GetData("oldSkin" .. self.outfitCategory))
	-- 		character:SetData("oldSkin" .. self.outfitCategory, nil)
	-- 	else
	-- 		client:SetSkin(0)
	-- 	end
	-- end

	-- -- get character original bodygroups
	-- groups = character:GetData("oldGroups" .. self.outfitCategory, {})

	-- -- restore original bodygroups
	-- if (!table.IsEmpty(groups)) then
	-- 	for k, v in pairs(groups) do
	-- 		client:SetBodygroup(k, v)
	-- 	end

	-- 	character:SetData("groups", character:GetData("oldGroups" .. self.outfitCategory, {}))
	-- 	character:SetData("oldGroups" .. self.outfitCategory, nil)
	-- end

	-- if (istable(self.attribBoosts)) then
	-- 	for k, _ in pairs(self.attribBoosts) do
	-- 		character:RemoveBoost(self.uniqueID, k)
	-- 	end
	-- end

	-- for k, _ in pairs(self:GetData("outfitAttachments", {})) do
	-- 	self:RemoveAttachment(k, client)
	-- end

	self:OnUnequipped()
end

-- makes another outfit depend on this outfit in terms of requiring this item to be equipped in order to equip the attachment
-- also unequips the attachment if this item is dropped
function ITEM:AddAttachment(id)
	local attachments = self:GetData("outfitAttachments", {})
	attachments[id] = true

	self:SetData("outfitAttachments", attachments)
end

function ITEM:RemoveAttachment(id, client)
	local item = ix.item.instances[id]
	local attachments = self:GetData("outfitAttachments", {})

	if (item and attachments[id]) then
		item:OnDetached(client)
	end

	attachments[id] = nil
	self:SetData("outfitAttachments", attachments)
end

ITEM:Hook("drop", function(item)
	if (item:GetData("equip")) then
		local character = ix.char.loaded[item.owner]
		local client = character and character:GetPlayer() or item:GetOwner()

		item.player = client
		item:RemoveOutfit(item:GetOwner())
	end
end)

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	OnRun = function(item)
		item:RemoveOutfit(item.player)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
			hook.Run("CanPlayerUnequipItem", client, item) != false
	end
}

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	OnRun = function(item)
		local client = item.player
		local char = client:GetCharacter()
		local items = char:GetInventory():GetItems()

		for _, v in pairs(items) do
			if (v.id != item.id) then
				local itemTable = ix.item.instances[v.id]

				if (itemTable.pacData and v.outfitCategory == item.outfitCategory and itemTable:GetData("equip")) then
					client:NotifyLocalized(item.equippedNotify or "outfitAlreadyEquipped")
					return false
				end
			end
		end

		item:AddOutfit(item.player)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and item:CanEquipOutfit() and
			hook.Run("CanPlayerEquipItem", client, item) != false
	end
}

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		return false
	end

	return true
end

function ITEM:OnRemoved()
	if (self.invID != 0 and self:GetData("equip")) then
		self.player = self:GetOwner()
			self:RemoveOutfit(self.player)
		self.player = nil
	end
end

function ITEM:OnEquipped()
end

function ITEM:OnUnequipped()
end

function ITEM:CanEquipOutfit()
	return true
end

function ITEM:ShouldRestoreBodygroups()
	return true
end

function ITEM:ShouldRestoreSubMaterials()
	return true
end
