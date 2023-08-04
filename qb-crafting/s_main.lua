local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-crafting:Server:AddXP', function(xp, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("craftingrep", Player.PlayerData.metadata["craftingrep"]+(xp*amount))
end)


QBCore.Functions.CreateCallback('QBCore:HasCraftingItemsItem', function(source, cb, items, Price)
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
                        if Player.Functions.RemoveMoney('cash', tonumber(Price), 'Crafting') then 
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

RegisterNetEvent('qb-crafting:Server:Collectmelting', function(NeedItems, item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local canGive = true
    for k, v in pairs(NeedItems) do
        if Player.Functions.RemoveItem(k, v) then 
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[k], "remove", v)
            Wait(800)
        else
            canGive = false
            break 
        end
    end
    if canGive then 
        Player.Functions.AddItem(item, amount, false, nil, 'Collectmelting')
        -- QBCore.Functions.BoxShow(src, true, item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", amount)

        QBCore.Functions.CreateLog(
            "normalcrafting",
            "Crafting",
            "green",
            "**"..GetPlayerName(src) .. "** just crafted : **" .. QBCore.Shared.Items[item]["label"] .. "** with amount of : **"..amount.."**",
            false
        )
    end
end)

RegisterNetEvent('qb-crafting:Server:Collectcrime', function(NeedItems, item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local canGive = true
    for k, v in pairs(NeedItems) do
        if Player.Functions.RemoveItem(k, v) then 
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[k], "remove", v)
            Wait(800)
        else
            canGive = false
            break 
        end
    end
    if canGive then 
        Player.Functions.AddItem(item, amount, false, nil, 'Collectmelting')
        -- QBCore.Functions.BoxShow(src, true, item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", amount)
        QBCore.Functions.CreateLog(
            "normalcrafting",
            "Crafting",
            "green",
            "**"..GetPlayerName(src) .. "** just crafted : **" .. QBCore.Shared.Items[item]["label"] .. "** with amount of : **"..amount.."**",
            false
        )
    end
end)

-- CreateThread(function()
--     Wait(1000)
--     WeaponLoop()
-- end)