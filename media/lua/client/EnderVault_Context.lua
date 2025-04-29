EnderVault = EnderVault or {}

function EnderVault.checkDist(pl, sq)
    pl = pl or getPlayer()
	local x, y = sq:getX(), sq:getY()
	local dist = pl:DistTo(x, y)
   return math.floor(dist) <= 3
end

function EnderVault.setSprite(sprName, vaultItem)
    if not sprName then return end
    local pl = getPlayer()
    local plNum = pl:getPlayerNum()
    local cursor = ISBrushToolTileCursor:new(sprName, sprName, pl)
    cursor.dragNilAfterPlace = true
    getCell():setDrag(cursor, plNum)

    local function OnObjectAdded(object)
        if vaultItem and pl:getInventory():contains(vaultItem) then
            ISRemoveItemTool.removeItem(vaultItem, plNum)
        end
        Events.OnObjectAdded.Remove(OnObjectAdded)
        Events.OnTick.Remove(OnTick)
    end
    Events.OnObjectAdded.Add(OnObjectAdded)

    local function OnTick()
        if getCell():getDrag(plNum) ~= cursor then
            Events.OnObjectAdded.Remove(OnObjectAdded)
            Events.OnTick.Remove(OnTick)
        end
    end
    Events.OnTick.Add(OnTick)
end

function EnderVault.addTip(option, sprName)
    local tooltip = ISToolTip:new();
    tooltip:initialise();
    --tooltip:setName(tostring(sprName));
    tooltip:setTexture(sprName);
    option.toolTip = tooltip
end

-----------------------   take*     convert*    ---------------------------
function EnderVault.context(player, context, worldobjects, test)
    local pl = getSpecificPlayer(player)
    local sq = clickedSquare
    if sq then
        local enderVault = EnderVault.getEnderVault(sq)
		local vault = EnderVault.getVault(sq)
		local enderVaultCont = nil
		if enderVault then
			--print("enderVault")
			enderVaultCont = enderVault:getContainer()
			if enderVaultCont then
				EnderVault.tempMark(sq)
				--print("enderVaultCont")
			end
		end

		if not vault then
			EnderVault.delMark()
			return
		end

		local Main = context:addOptionOnTop(getText("EnderVault"))
		Main.iconTexture = getTexture("media/ui/LootableMaps/EnderVault_Symbol.png")
		local opt = ISContextMenu:getNew(context)
		context:addSubMenu(Main, opt)

		if vault then
			--print("vault")

			local convOpt = opt:addOptionOnTop(getText("ContextMenu_EnderVault_ConvertVault"), worldobjects, function()
				if luautils.walkAdj(pl, sq) then
					ISTimedActionQueue.add(EnderVault.Action:new(pl, vault, false))
					getSoundManager():playUISound("EnderVault_Open")
					EnderVault.fin(nil)
				end
			end)
			local tip = ISWorldObjectContextMenu.addToolTip()
			convOpt.iconTexture = getTexture("media/ui/EnderVault_Off.png")
			tip.description = getText("ContextMenu_EnderVault_ConvertVault")
			convOpt.toolTip = tip
			if EnderVault.isEnderVault(vault) then
				convOpt.notAvailable = true
			end


			local sprName = EnderVault.getSprName(vault)
			local optTip = opt:addOptionOnTop(getText("ContextMenu_EnderVault_TakeVault"), worldobjects, function()
				if luautils.walkAdj(pl, sq) then

					ISTimedActionQueue.add(EnderVault.Action:new(pl, vault, true))
					ISInventoryPage.dirtyUI();
				end
				getSoundManager():playUISound("UIActivateMainMenuItem")
			end)

			local tip = ISWorldObjectContextMenu.addToolTip()
			optTip.iconTexture = getTexture("media/ui/LootableMaps/EnderVault_Symbol.png")
			tip.description = getText("ContextMenu_EnderVault_TakeVault")
			tip:setTexture(sprName)
			optTip.toolTip = tip



--[[ 			local optTip2 = opt:addOptionOnTop(getText("ContextMenu_EnderVault_Open"), worldobjects, function()
				EnderVault.restoreData(enderVaultCont)
				getSoundManager():playUISound("EnderVault_On")
				EnderVault.fin(nil)
			end)
			optTip2.iconTexture = getTexture("media/ui/EnderVault_On.png")
			if EnderVault.isEnderVault(vault) then
				convOpt.notAvailable = true
			end ]]
		end

		if enderVaultCont then
			local optTip = opt:addOptionOnTop(getText("ContextMenu_EnderVault_Close"), worldobjects, function()
				if luautils.walkAdj(pl, sq) then
					EnderVault.storeData(enderVaultCont, false)

					getSoundManager():playUISound("EnderVault_Close")
					EnderVault.fin(nil)
				end
			end)
			optTip.iconTexture = getTexture("media/ui/EnderVault_Off.png")
		end

	end
end


Events.OnFillWorldObjectContextMenu.Remove(EnderVault.context)
Events.OnFillWorldObjectContextMenu.Add(EnderVault.context)


-----------------------   inv*         ---------------------------

function EnderVault.invContext(plNum, context, items)
    local pl = getSpecificPlayer(plNum)
    local inv = pl:getInventory()
	local vaultItem = nil
    for _, item in ipairs(items) do
        local checkItem = type(item) == "table" and item.items[1] or (instanceof(item, "InventoryItem") and item or nil)
        if checkItem then
            local fType = checkItem:getFullType()
            if luautils.stringStarts(fType, "Base.EnderVault")  then
				print(fType)
				vaultItem = checkItem
				break
            end
        end
    end
	if vaultItem ~= nil then
		local mainMenu = getText("ContextMenu_EnderVault_PlaceVault")
		local Main = context:addOptionOnTop(mainMenu)
		Main.iconTexture = getTexture("media/ui/EnderVault_On.png")
		local opt = ISContextMenu:getNew(context)
		context:addSubMenu(Main, opt)

		local dir = "South"
		local sprNameToSet =  "location_business_bank_01_69"
		local optTip = opt:addOptionOnTop(dir, worldobjects, function()
			EnderVault.setSprite(sprNameToSet, vaultItem)
		end)
		local iconPath = "media/ui/LootableMaps/map_arrowsouth.png"
		optTip.iconTexture = getTexture(iconPath)
		EnderVault.addTip(optTip, sprNameToSet)

		local dir2 = "East"
		local sprNameToSet2 =  "location_business_bank_01_68"
		local optTip = opt:addOptionOnTop(dir2, worldobjects, function()
			EnderVault.setSprite(sprNameToSet2, vaultItem)
		end)
		local iconPath = "media/ui/LootableMaps/map_arroweast.png"
		optTip.iconTexture = getTexture(iconPath)
		EnderVault.addTip(optTip, sprNameToSet2)
	end
end

Events.OnFillInventoryObjectContextMenu.Remove(EnderVault.invContext)
Events.OnFillInventoryObjectContextMenu.Add(EnderVault.invContext)
