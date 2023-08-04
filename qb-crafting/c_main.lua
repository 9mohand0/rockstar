local QBCore = exports['qb-core']:GetCoreObject()
local OpenUI = false
local Block = false
local BlockTime = 0
local labels = {}
local images = {}


-- local function WeaponsLoop()
--     Wait(15 * (60 * 1000))
--     TriggerServerEvent("qb-crafting:server:WeaponsLoop")
--     WeaponsLoop()
-- end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
end)

CreateThread(function()
    for k, v in pairs(QBCore.Shared.Items) do
        labels[k] = v.label
        images[k] = v.image
    end
end)

local function CloseCrafting()
    TriggerScreenblurFadeOut(250.0)
    SendNUIMessage({
        action = "close",
    })
    SetNuiFocus(false, false)
    OpenUI = false
    Citizen.SetTimeout(BlockTime + 3000, function()
        Block = false
    end)
end

RegisterNetEvent('qb-crafting:client:OpenMainCraft', function(ItemsData)
    if not OpenUI then
        OpenUI = true
        SendNUIMessage({
            action = "show",
            data = {
                items = ItemsData,
                labels = labels,
                images = images,
                xp = QBCore.Functions.GetPlayerData().metadata.craftingrep,
            },
        })
        TriggerScreenblurFadeIn(250.0)
        SetNuiFocus(true, true)
    else
        QBCore.Functions.Notify("You are crafting", "error", 4000)
    end
end)

RegisterNetEvent('qb-crafting:client:OpenmeltingCraft', function()
    if not OpenUI then
        OpenUI = true
        SendNUIMessage({
            action = "show",
            data = {
                items = Config.Melting,
                labels = labels,
                images = images,
                xp = QBCore.Functions.GetPlayerData().metadata.craftingrep,
                craftType = 'melting'
            },
        })
        TriggerScreenblurFadeIn(250.0)
        SetNuiFocus(true, true)
    else
        QBCore.Functions.Notify("You are working on something", "error", 4000)
    end
end)

RegisterNetEvent('qb-crafting:client:OpenCrimeCraft', function()
    if not OpenUI then
        OpenUI = true
        SendNUIMessage({
            action = "show",
            data = {
                items = Config.Crime,
                labels = labels,
                images = images,
                xp = QBCore.Functions.GetPlayerData().metadata.craftingrep,
                craftType = 'crime'
            },
        })
        TriggerScreenblurFadeIn(250.0)
        SetNuiFocus(true, true)
    else
        QBCore.Functions.Notify("You are working on something", "error", 4000)
    end
end)

RegisterNUICallback('CloseCrafting', function(data, cb)
    CloseCrafting()
end)

RegisterNUICallback('CraftStarted', function(data, cb)
    local ItemPrice = math.ceil(data.mat.price * data.amount)
    for k, v in pairs(data.mat.NeedItems) do
        data.mat.NeedItems[k] = data.mat.NeedItems[k] * data.amount
    end

    QBCore.Functions.TriggerCallback('QBCore:HasCraftingItemsItem', function(result, hasPrice)
        if result then
            if hasPrice then 
                CloseCrafting()
                OpenUI = true
                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                QBCore.Functions.Progressbar("crafting_new", "Crafting ... ", data.mat.Timer * data.amount, false, true, {
                    disableMovement = true,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                }, {}, {}, {}, function()
                    OpenUI = false
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    for k, v in pairs(data.mat.NeedItems) do
                        TriggerServerEvent("QBCore:Server:RemoveItem", k, v)
                        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[k], "remove")
                        Wait(800)
                    end
                    local info = {
                        quality = 100
                    }
                    TriggerServerEvent("QBCore:Server:AddItem", data.mat.itemName, data.amount, false, info, 'crafting '..data.mat.itemName)
                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[data.mat.itemName], "add")
                    if data.mat.levelUp then
                        TriggerServerEvent("qb-crafting:Server:AddXP", data.mat.levelUp, data.amount)
                    end
                end, function()
                    OpenUI = false
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    QBCore.Functions.Notify("Canceled", "error", 4000)
                end)
            else
                QBCore.Functions.Notify("You do not have money to craft this item", "error")
            end
        else
            QBCore.Functions.Notify("You do not have the required items", "error")
        end
    end, data.mat.NeedItems, ItemPrice)
end)

RegisterNUICallback('craftTypeStarted', function(data, cb)
    local ItemPrice = math.ceil(data.mat.price * data.amount)
    for k, v in pairs(data.mat.NeedItems) do
        data.mat.NeedItems[k] = data.mat.NeedItems[k] * data.amount
    end

    if data.craftingType == 'melting' then 
        QBCore.Functions.TriggerCallback('QBCore:HasCraftingItemsItem', function(result, hasPrice)
            if result then
                if hasPrice then 
                    CloseCrafting()
                    OpenUI = true
                    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                    local ItemInfo = QBCore.Shared.Items[data.mat.itemName]
                    QBCore.Functions.Progressbar("crafting_new", "Crafting "..ItemInfo['label'].." ...", data.mat.Timer * data.amount, false, true, {
                        disableMovement = true,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = false,
                    }, {}, {}, {}, function()
                        OpenUI = false
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        TriggerServerEvent('qb-crafting:Server:Collectmelting', data.mat.NeedItems, data.mat.itemName, data.amount)
                    end, function()
                        OpenUI = false
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        QBCore.Functions.Notify("Canceled", "error", 4000)
                    end)
                else
                    QBCore.Functions.Notify("You do not have money to craft this item", "error")
                end
            else
                QBCore.Functions.Notify("You do not have the required items", "error")
            end
        end, data.mat.NeedItems, ItemPrice)
    elseif data.craftingType == 'crime' then 
        QBCore.Functions.TriggerCallback('QBCore:HasCraftingItemsItem', function(result, hasPrice)
            if result then
                if hasPrice then 
                    CloseCrafting()
                    OpenUI = true
                    -- TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                    local ItemInfo = QBCore.Shared.Items[data.mat.itemName]
                    QBCore.Functions.Progressbar("crafting_new", "Crafting "..ItemInfo['label'].." ...", data.mat.Timer * data.amount, false, true, {
                        disableMovement = true,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = false,
                    }, {}, {}, {}, function()
                        OpenUI = false
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        TriggerServerEvent('qb-crafting:Server:Collectcrime', data.mat.NeedItems, data.mat.itemName, data.amount, data.mat.levelUp)
                    end, function()
                        OpenUI = false
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        QBCore.Functions.Notify("Canceled", "error", 4000)
                    end)
                else
                    QBCore.Functions.Notify("You do not have money to craft this item", "error")
                end
            else
                QBCore.Functions.Notify("You do not have the required items", "error")
            end
        end, data.mat.NeedItems, ItemPrice)
    end
end)

RegisterNUICallback('SendAlertcraft', function(data, cb)
    QBCore.Functions.Notify(data.text, data.type)
end)