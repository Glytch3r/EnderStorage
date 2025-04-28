EnderVault = EnderVault or {}
function EnderVault.storeData(cont, isTake)
    if not cont then return end
    local pl = getPlayer()
    if not pl then return end

    local obj = cont:getParent()
    local sq = nil
    local sprName = nil
    if obj then
        sq = obj:getSquare();
        sprName = EnderVault.getSprName(obj)
    end

    local modData = pl:getModData()
    modData.StoredItems = {}

    local function serializeItem(item)
        if not item then return nil end

        local itemData = {
            fullType = item:getFullType() or "",
            name = item:getName() or "",
            isRanged = instanceof(item, "HandWeapon") and (item.isRanged and item:isRanged() or false) or false,
            ammoCount = nil,
            roundChambered = nil,
            containsClip = nil,
            isContainer = (instanceof(item, "InventoryContainer") or (item.getCategory and item:getCategory() == "Container")),
            containedItems = {},
            bloodLevel = nil,
            dirtyness = nil,
            haveBeenRepaired = (item.getHaveBeenRepaired and item:getHaveBeenRepaired()) or false,
            isBroken = (item.isBroken and item:isBroken()) or false,
            modData = {}
        }

        if itemData.isRanged then
            if item.getCurrentAmmoCount then
                itemData.ammoCount = item:getCurrentAmmoCount()
            end
            if item.isRoundChambered then
                itemData.roundChambered = item:isRoundChambered()
            end
            if item.isContainsClip then
                itemData.containsClip = item:isContainsClip()
            end
        end

        if item.getClothingItem and item:getClothingItem() then
            if item.getBloodLevel then
                itemData.bloodLevel = item:getBloodLevel()
            end
            if item.getDirtyness then
                itemData.dirtyness = item:getDirtyness()
            end
        end

        if item.hasModData and item:hasModData() then
            local modDataTable = item:getModData()
            for k, v in pairs(modDataTable) do
                itemData.modData[k] = v
            end
        end

        if itemData.isContainer and item.getInventory then
            local cont = item:getInventory()
            if cont and cont.getItems then
                local contItems = cont:getItems()
                for i = 0, contItems:size() - 1 do
                    local contItem = contItems:get(i)
                    local serializedContItem = serializeItem(contItem)
                    if serializedContItem then
                        table.insert(itemData.containedItems, serializedContItem)
                    end
                end
            end
        end

        return itemData
    end

    local items = cont:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local serialized = serializeItem(item)
        if serialized then
            table.insert(modData.StoredItems, serialized)
        end
    end
    EnderVault.clearAllItemsInContainer(cont)
    EnderVault.doSledge(obj)
    if not isTake then
        local props = ISMoveableSpriteProps.new(IsoObject.new(sq, sprName):getSprite())
        props.rawWeight = 10
        props:placeMoveableInternal(sq, InventoryItemFactory.CreateItem("Base.Plank"), sprName)
        EnderVault.delMark()
        EnderVault.fin(nil)
    end
end

function EnderVault.restoreData(cont)
    local pl = getPlayer()
    if not pl then return end

    local modData = pl:getModData()
    local storedItems = modData.StoredItems

    local function restoreItem(itemData)
        local item = nil

        if itemData and itemData.fullType then
            item = InventoryItemFactory.CreateItem(itemData.fullType)
            if item then
                item:setName(itemData.name or "")

                if itemData.isRanged then
                    if item.setCurrentAmmoCount then
                        item:setCurrentAmmoCount(itemData.ammoCount or 0)
                    end
                    if item.setRoundChambered then
                        item:setRoundChambered(itemData.roundChambered or false)
                    end
                    if item.setContainsClip then
                        item:setContainsClip(itemData.containsClip or false)
                    end
                end

                if item.getClothingItem then
                    if itemData.bloodLevel then
                        item:setBloodLevel(itemData.bloodLevel)
                    end
                    if itemData.dirtyness then
                        item:setDirtyness(itemData.dirtyness)
                    end
                end

                if itemData.modData then
                    for k, v in pairs(itemData.modData) do
                        item:getModData()[k] = v
                    end
                end

                if itemData.isContainer and item.getInventory then
                    local contItems = item:getInventory():getItems()
                    for _, subItemData in ipairs(itemData.containedItems) do
                        local contItem = restoreItem(subItemData)
                        if contItem then
                            contItems:addItem(contItem)
                        end
                    end
                end
            end
        end

        if item then
            cont:addItem(item)
        end

        return item
    end

    for _, itemData in ipairs(storedItems) do
        restoreItem(itemData)
    end
    EnderVault.fin(nil)
end


function EnderVault.clearAllItemsInContainer(cont)
    if not cont then return end
    local pl = getPlayer()
    local plNum = pl:getPlayerNum()
    ISRemoveItemTool.removeItems(cont, plNum)
    print(cont:getItems())
    EnderVault.fin(nil)
end
--EnderVault.clearAllItemsInContainer(dbgIso:getContainer(), dbgIso)
--[[
    local items = cont:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            inv:Remove(item)
        end
    end ]]
--[[
print(dbgIso:getContainer():getInventory())
ISRemoveItemTool.removeItem(item, plNum)
ISRemoveItemTool.removeItems(items, plNum)
 ]]