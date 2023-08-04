local QBCore = exports['qb-core']:GetCoreObject()

local BluePrintLocations = {}

QBCore.Functions.CreateCallback('qb-pew:BluePrintLocations', function(source, cb)
    cb(Config.BluePrintLocations)
end)

local function GetBluePrintData()
    math.randomseed(GetGameTimer())
    local rnd = math.random(1, 1000)
    local reward = 'pistolammo_blueprint'
    for k, v in pairs(Config.Crafting) do 
        if rnd >= v.min and rnd <= v.max then 
            reward = v.blueprint
            break
        end
    end
    -- print(rnd)
    return reward
end

CreateThread(function()
    Wait(100)
    local isFinished = false
    math.randomseed(GetGameTimer())
    while not isFinished do 
        local checked = false
        for k, v in pairs(Config.BluePrint) do 
            if not checked then 
                local rnd = math.random(1, #Config.BluePrint)
                if Config.BluePrint[rnd] then 
                    if Config.BluePrint[rnd].isActive then 
                        if not Config.BluePrint[rnd].Spawned then 
                            Config.BluePrint[rnd].Spawned = true
                            BluePrintLocations[#BluePrintLocations + 1] = Config.BluePrint[rnd]
                            checked = true
                            if #BluePrintLocations >= 20 then 
                                isFinished = true 
                            end
                            -- print(rnd, #BluePrintLocations)
                        end
                    end
                end
            end
        end
        Wait(100)
    end
    if #BluePrintLocations > 0 then 
        -- print(#BluePrintLocations)
        Config.BluePrintLocations = BluePrintLocations
    end
end)

RegisterNetEvent('qb-pew:server:collectBox', function(box)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not box then DropPlayer(src, 'Are you stupid?') return end 
    if not Config.BluePrintLocations[box] then DropPlayer(src, 'Are you stupid?') return end 
    if not Config.BluePrintLocations[box].isActive then DropPlayer(src, 'Are you stupid?') return end 
    Wait(1000)
    if Player then 
        if Config.BluePrintLocations[box].isActive then 
            local info = {
                blueprint = GetBluePrintData()
            }
            Player.Functions.AddItem('blueprintbag', 1, false, info)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['blueprintbag'], 'add', 1)
            Config.BluePrintLocations[box].isActive = false
            TriggerClientEvent('qb-pew:server:BoxCollected', -1, box)
            QBCore.Functions.CreateLog(
                "weaponbagfound",
                "Bag Found",
                "green",
                "**"..GetPlayerName(src) .. "** Has Found A Bag ID "..box.."",
                false
            )
        end
    end
end)

RegisterNetEvent('qb-pew:server:collectAmmo', function(amount, itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not amount then return end
    if Player then 
        local amount = tonumber(amount)
        for i = 1, amount do 
            Player.Functions.AddItem(itemName, 1)
        end
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'add', amount)
        QBCore.Functions.CreateLog(
            "weaponcrafting",
            "Ammo Crafted",
            "green",
            "**"..GetPlayerName(src) .. "** Has Crafted Ammo "..QBCore.Shared.Items[itemName].label.." With Amount of  "..amount.."",
            false
        )
    end
end)

RegisterNetEvent('qb-pew:server:collectGuns', function(amount, itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not amount then return end
    if not itemName then 
        exports['qb-logs']:CreateLog('fuckers', 'Fuckers Founded', 'red', GetPlayerName(src) .. ' Have Been Marked As Cheater [ Trying to trigger collect weapon crafting event (no itemName)]', true)
        return
    end
    if Player then 
        local amount = tonumber(amount)
        for i = 1, amount do 
            Wait(100)
            Player.Functions.AddItem(itemName, 1)
        end
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'add', amount)
        exports['qb-logs']:CreateLog(
            "weaponcrafting",
            "Weapon Crafted",
            "green",
            "**"..GetPlayerName(src) .. "** Has Crafted Weapon "..QBCore.Shared.Items[itemName].label.." With Amount of  "..amount.."",
            false
        )
    end
end)

QBCore.Functions.CreateUseableItem("blueprintbag", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Items = Player.PlayerData.items
    if Items[item.slot].info and Items[item.slot].info.blueprint then 
        if Player.Functions.RemoveItem('blueprintbag', 1) then 
            Player.Functions.AddItem(Items[item.slot].info.blueprint, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Items[item.slot].info.blueprint], 'add', 1)
            QBCore.Functions.CreateLog(
                "openweaponbag",
                "Bag Opened",
                "green",
                "**"..GetPlayerName(src) .. "** Has Opened A Bag And Found "..QBCore.Shared.Items[Items[item.slot].info.blueprint].label.."",
                false
            )
        end
    end
end)

QBCore.Functions.CreateUseableItem("sns_blueprint", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Items = Player.PlayerData.items
    if Items[item.slot] then 
        if Player.Functions.RemoveItem('sns_blueprint', 1) then 
            local MyMeta = Player.PlayerData.metadata['blueprint']
            if MyMeta then 
                MyMeta["weapon_snspistol"] = true
                Player.Functions.SetMetaData('blueprint', MyMeta)
                local itemLable = QBCore.Shared.Items["weapon_snspistol"]['label']
                QBCore.Functions.Notify(src, ''..itemLable..' have been unlocked', 'success', 7500)
                QBCore.Functions.CreateLog(
                    "useweaponblueprint",
                    "BluePrint",
                    "green",
                    "**"..GetPlayerName(src) .. "** Has Readed A BluePrint "..itemLable.."",
                    false
                )
            end
        end
    end
end)

QBCore.Functions.CreateUseableItem("pistolammo_blueprint", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Items = Player.PlayerData.items
    if Items[item.slot] then 
        if Player.Functions.RemoveItem('pistolammo_blueprint', 1) then 
            local MyMeta = Player.PlayerData.metadata['blueprint']
            if MyMeta then 
                MyMeta["pistol_ammo"] = true
                Player.Functions.SetMetaData('blueprint', MyMeta)
                local itemLable = QBCore.Shared.Items["pistol_ammo"]['label']
                QBCore.Functions.Notify(src, ''..itemLable..' have been unlocked', 'success', 7500)
                QBCore.Functions.CreateLog(
                    "useweaponblueprint",
                    "BluePrint",
                    "green",
                    "**"..GetPlayerName(src) .. "** Has Readed A BluePrint "..itemLable.."",
                    false
                )
            end
        end
    end
end)

QBCore.Functions.CreateUseableItem("snsmk_blueprint", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Items = Player.PlayerData.items
    if Items[item.slot] then 
        if Player.Functions.RemoveItem('snsmk_blueprint', 1) then 
            local MyMeta = Player.PlayerData.metadata['blueprint']
            if MyMeta then 
                MyMeta["weapon_snspistol_mk2"] = true
                Player.Functions.SetMetaData('blueprint', MyMeta)
                local itemLable = QBCore.Shared.Items["weapon_snspistol_mk2"]['label']
                QBCore.Functions.Notify(src, ''..itemLable..' have been unlocked', 'success', 7500)
                QBCore.Functions.CreateLog(
                    "useweaponblueprint",
                    "BluePrint",
                    "green",
                    "**"..GetPlayerName(src) .. "** Has Readed A BluePrint "..itemLable.."",
                    false
                )
            end
        end
    end
end)

QBCore.Functions.CreateUseableItem("pistol_blueprint", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Items = Player.PlayerData.items
    if Items[item.slot] then 
        if Player.Functions.RemoveItem('pistol_blueprint', 1) then 
            local MyMeta = Player.PlayerData.metadata['blueprint']
            if MyMeta then 
                MyMeta["weapon_pistol"] = true
                Player.Functions.SetMetaData('blueprint', MyMeta)
                local itemLable = QBCore.Shared.Items["weapon_pistol"]['label']
                QBCore.Functions.Notify(src, ''..itemLable..' have been unlocked', 'success', 7500)
                QBCore.Functions.CreateLog(
                    "useweaponblueprint",
                    "BluePrint",
                    "green",
                    "**"..GetPlayerName(src) .. "** Has Readed A BluePrint "..itemLable.."",
                    false
                )
            end
        end
    end
end)

QBCore.Functions.CreateUseableItem("mk2_blueprint", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Items = Player.PlayerData.items
    if Items[item.slot] then 
        if Player.Functions.RemoveItem('mk2_blueprint', 1) then 
            local MyMeta = Player.PlayerData.metadata['blueprint']
            if MyMeta then 
                MyMeta["weapon_pistol_mk2"] = true
                Player.Functions.SetMetaData('blueprint', MyMeta)
                local itemLable = QBCore.Shared.Items["weapon_pistol_mk2"]['label']
                QBCore.Functions.Notify(src, ''..itemLable..' have been unlocked', 'success', 7500)
                QBCore.Functions.CreateLog(
                    "useweaponblueprint",
                    "BluePrint",
                    "green",
                    "**"..GetPlayerName(src) .. "** Has Readed A BluePrint "..itemLable.."",
                    false
                )
            end
        end
    end
end)

QBCore.Functions.CreateUseableItem("50_blueprint", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Items = Player.PlayerData.items
    if Items[item.slot] then 
        if Player.Functions.RemoveItem('50_blueprint', 1) then 
            local MyMeta = Player.PlayerData.metadata['blueprint']
            if MyMeta then 
                MyMeta["weapon_pistol50"] = true
                Player.Functions.SetMetaData('blueprint', MyMeta)
                local itemLable = QBCore.Shared.Items["weapon_pistol50"]['label']
                QBCore.Functions.Notify(src, ''..itemLable..' have been unlocked', 'success', 7500)
                QBCore.Functions.CreateLog(
                    "useweaponblueprint",
                    "BluePrint",
                    "green",
                    "**"..GetPlayerName(src) .. "** Has Readed A BluePrint "..itemLable.."",
                    false
                )
            end
        end
    end
end)

QBCore.Functions.CreateUseableItem("heavypistol_blueprint", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Items = Player.PlayerData.items
    if Items[item.slot] then 
        if Player.Functions.RemoveItem('heavypistol_blueprint', 1) then 
            local MyMeta = Player.PlayerData.metadata['blueprint']
            if MyMeta then 
                MyMeta["weapon_heavypistol"] = true
                Player.Functions.SetMetaData('blueprint', MyMeta)
                local itemLable = QBCore.Shared.Items["weapon_heavypistol"]['label']
                QBCore.Functions.Notify(src, ''..itemLable..' have been unlocked', 'success', 7500)
                QBCore.Functions.CreateLog(
                    "useweaponblueprint",
                    "BluePrint",
                    "green",
                    "**"..GetPlayerName(src) .. "** Has Readed A BluePrint "..itemLable.."",
                    false
                )
            end
        end
    end
end)

QBCore.Functions.CreateUseableItem("vintag_blueprint", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Items = Player.PlayerData.items
    if Items[item.slot] then 
        if Player.Functions.RemoveItem('vintag_blueprint', 1) then 
            local MyMeta = Player.PlayerData.metadata['blueprint']
            if MyMeta then 
                MyMeta["weapon_vintagepistol"] = true
                Player.Functions.SetMetaData('blueprint', MyMeta)
                local itemLable = QBCore.Shared.Items["weapon_vintagepistol"]['label']
                QBCore.Functions.Notify(src, ''..itemLable..' have been unlocked', 'success', 7500)
                QBCore.Functions.CreateLog(
                    "useweaponblueprint",
                    "BluePrint",
                    "green",
                    "**"..GetPlayerName(src) .. "** Has Readed A BluePrint "..itemLable.."",
                    false
                )
            end
        end
    end
end)

QBCore.Functions.CreateCallback('qb-pew:RemoveItems', function(source, cb, items)
    local src = source
    local retval = false
    local itemscount = 0
    local checkeditemscount = 0
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        if items then 
            for k, v in pairs(items) do
                itemscount += 1
                if Player.Functions.RemoveItem(k, v) then 
                    checkeditemscount += 1
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[k], "remove", v)
                    Wait(800)
                end
            end
            if itemscount == checkeditemscount then 
                retval = true
            else
                TriggerEvent('qb-log:server:CreateLog', 'fuckers', 'Fuckers Founded', 'red', GetPlayerName(src) .. ' Have Been Marked As Cheater [ Crafting weapon or ammo without having items]', true)
            end
        end
    end
    cb(retval)
end)

QBCore.Functions.CreateCallback('qb-pew:HasCraftingItemsItem', function(source, cb, items, Price)
    local src = source
    local retval = false
    local HasPrice = false
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        if type(items) == 'table' then
            local count = 0
            local finalcount = 0
            for k, v in pairs(items) do
                if type(k) == 'string' then
                    finalcount = 0
                    for i, _ in pairs(items) do
                        if i then
                            finalcount = finalcount + 1
                        end
                    end
                    local item = Player.Functions.GetItemByName(k)
                    if item then
                        if item.amount >= v then
                            count = count + 1
                            if count == finalcount then
                                retval = true
                            end
                        end
                    end
                else
                    finalcount = #items
                    local item = Player.Functions.GetItemByName(v)
                    if item then
                        if amount then
                            if item.amount >= amount then
                                count = count + 1
                                if count == finalcount then
                                    retval = true
                                end
                            end
                        else
                            count = count + 1
                            if count == finalcount then
                                retval = true
                            end
                        end
                    end
                end
            end
        else
            local item = Player.Functions.GetItemByName(items)
            if item then
                if amount then
                    if item.amount >= amount then
                        retval = true
                    end
                else
                    retval = true
                end
            end
        end
        if retval then 
            if Price and Price > 0 then 
                local Cash = Player.PlayerData.money.cash
                if Cash and Cash ~= 0 then 
                    if tonumber(Cash) >= tonumber(Price) then 
                        if Player.Functions.RemoveMoney('cash', tonumber(Price)) then 
                            HasPrice = true 
                        end
                    end
                end
            else
                HasPrice = true 
            end
        end
    end
    cb(retval, HasPrice)
end)
