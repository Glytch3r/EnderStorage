EnderVault = EnderVault or {}

function EnderVault.isStorageSpr(sprName)
    local tab = {
        ["location_business_bank_01_68"] = true, --east
        ["location_business_bank_01_69"] = true, --south
    }
    return tab[sprName] or false
end

--[[ local sprName = "location_business_bank_01_68"
local pl = getPlayer()
local cursor = ISBrushToolTileCursor:new(sprName, sprName, pl)
cursor.dragNilAfterPlace = true
getCell():setDrag(cursor, pl:getPlayerNum()) ]]

function EnderVault.getSprName(obj)
    if not obj then return nil end
    local spr = obj:getSprite()
    return spr and spr:getName() or nil
end

function EnderVault.doSledge(obj)
    if isClient() then
        sledgeDestroy(obj)
    else
        local sq = obj:getSquare()
        if sq then
            sq:RemoveTileObject(obj);
            sq:getSpecialObjects():remove(obj);
            sq:getObjects():remove(obj);
            sq:transmitRemoveItemFromSquare(obj)
        end
    end
end

function EnderVault.fin(obj)

    getPlayerInventory(0):refreshBackpacks()
    getPlayerLoot(0):refreshBackpacks()
    if obj then
        obj:getContainer():setDrawDirty(true);
        EnderVault.setHL(obj, false)
    end
    ISInventoryPage.dirtyUI();
end

function EnderVault.doConvert(obj, sprName)
    if not (obj or sprName) then return end
    local sq = obj:getSquare()
    local pl = getPlayer()
    if sq and EnderVault.isVault(obj) then
        local vault = nil
        local md = obj:getModData()
        if md and not md['isEnderVault']  then
            EnderVault.doSledge(obj)
            --EnderVault.addMark(sq)


            vault = IsoThumpable.new(getCell(), sq, sprName, false, ISWoodenContainer:new(sprName, nil))
            --vault = IsoThumpable.new(getCell(), sq, sprName, false, ISWoodenContainer:create( "location_business_bank_01_69", "location_business_bank_01_68"))
            vault:setSprite(sprName)

            --local x, y, z = round(sq:getX()),  round(sq:getY()),  sq:getZ(),
            vault:getSprite():setName(sprName)
            vault:setIsThumpable(true)
            vault:setIsContainer(true)
            vault:setCanPassThrough(false)
            vault:setIsDismantable(false)
            vault:setBlockAllTheSquare(true)
            local cont = vault:getContainer()
            cont:setType('EnderVault')

            vault:getModData()['isEnderVault'] = true
            sq:AddTileObject(vault)

            if isClient() then
                vault:transmitCompleteItemToServer()
                vault:transmitUpdatedSpriteToClients()
            end
            EnderVault.restoreData(cont)
            EnderVault.setHL(vault, true)
            EnderVault.fin(vault)

        end
        return vault
    end
end
-----------------------            ---------------------------
function EnderVault.getEnderVault(sq)
    if not sq then return nil end
    for i = 0, sq:getObjects():size() - 1 do
        local obj = sq:getObjects():get(i)
        if EnderVault.isEnderVault(obj) then
            return obj
        end
    end
    return nil
end
function EnderVault.isEnderVault(obj)
    local sprName = EnderVault.getSprName(obj)
    if not sprName then return false end
    if not EnderVault.isStorageSpr(sprName) then return false end
    return obj:getContainer() ~= nil and instanceof(obj, "IsoThumpable") and obj:getModData()['isEnderVault'] == true
end
-----------------------            ---------------------------
function EnderVault.getVault(sq)
    if not sq then return nil end
    for i = 0, sq:getObjects():size() - 1 do
        local obj = sq:getObjects():get(i)
        if EnderVault.isVault(obj) then
            return obj
        end
    end
    return nil
end
function EnderVault.isVault(obj)
    local sprName = EnderVault.getSprName(obj)
    if not sprName then return false end
    return  EnderVault.isStorageSpr(sprName)
end