local QBCore = exports['qb-core']:GetCoreObject()
local OpenUI = false
local Block = false
local BlockTime = 0
local labels = {}
local images = {}
local Boxes = {}
local isCollecting = false
local PlayerData = {}

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for k, v in pairs(Boxes) do
        if DoesEntityExist(v.box) then
            DeleteEntity(v.box)
            exports['qb-target']:RemoveTargetEntity(v.box)
        end
    end
end)

CreateThread(function()
    for k, v in pairs(QBCore.Shared.Items) do
        labels[k] = v.label
        images[k] = v.image
    end
end)

CreateThread(function()
    exports['qb-target']:AddTargetModel(`prop_toolchest_05`, {
        options = {
            {
                event = "qb-pew:client:OpenMainCraft",
                icon = "fa-light fa-gun",
                label = "Weapons",
            },
        },
        distance = 2.5,
    })
end)

RegisterNetEvent('qb-pew:client:OpenMainCraft', function()
    if not OpenUI then
        OpenUI = true
        SendNUIMessage({
            action = "show",
            data = {
                items = Config.Crafting,
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

local function CreateBox(index, coords)
    local ExObj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, `ba_prop_battle_bag_01a`, false, false, false)
    if ExObj ~= 0 then 
        PlaceObjectOnGroundProperly(ExObj)
        FreezeEntityPosition(ExObj, true)
        Boxes[index] = {
            box = ExObj,
            name = 'BluePrint'..index,
        }
        exports['qb-target']:AddTargetEntity(Boxes[index].box, {
            options = {
                {
                    icon = "fas fa-box-circle-check",
                    label = 'Blue Print',
                    box = index,
                    action = function()
                        if Config.BluePrintLocations[index].isActive then
                            TriggerEvent('qb-pew:client:collectBox', index)
                            return true
                        end
                    end,
                }
            },
            distance = 1.5,
        })
    else
        local Boxe = CreateObject(`ba_prop_battle_bag_01a`, coords.x, coords.y, coords.z - 1.0, false, false, false)
        PlaceObjectOnGroundProperly(Boxe)
        FreezeEntityPosition(Boxe, true)
        SetEntityHeading(Boxe, coords.w)
        Boxes[index] = {
            box = Boxe,
            name = 'BluePrint'..index,
        }
        exports['qb-target']:AddTargetEntity(Boxes[index].box, {
            options = {
                {
                    icon = "fas fa-box-circle-check",
                    label = 'Blue Print',
                    box = index,
                    action = function()
                        if Config.BluePrintLocations[index].isActive and not isCollecting then
                            TriggerEvent('qb-pew:client:collectBox', index)
                            return true
                        end
                    end,
                }
            },
            distance = 1.5,
        })
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Wait(1000)
    QBCore.Functions.TriggerCallback('qb-pew:BluePrintLocations', function(result)
        if result then
            Config.BluePrintLocations = result
            for k, v in pairs(Config.BluePrintLocations) do
                if v.isActive then
                    Wait(100)
                    CreateBox(k, v.coords)
                end
            end
        end
    end)
end)

RegisterNetEvent('qb-pew:client:collectBox', function(box)
    if not box then return end
    if not Config.BluePrintLocations[box] then return end
    if not Config.BluePrintLocations[box].isActive then return end
    if isCollecting then return end
    isCollecting = true
    QBCore.Functions.Progressbar("blueprint", "Picking bag ... ", 15000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('qb-pew:server:collectBox', box)
        isCollecting = false
    end, function()
        isCollecting = false
        QBCore.Functions.Notify("Canceled", "error", 4000)
    end)
    Wait(1000)
    isCollecting = false
end)

RegisterNetEvent('qb-pew:server:BoxCollected', function(box)
    if not box then return end
    if not Config.BluePrintLocations[box] then return end
    if not Config.BluePrintLocations[box].isActive then return end
    Config.BluePrintLocations[box].isActive = false
    if Boxes[box] then
        if DoesEntityExist(Boxes[box].box) then
            DeleteEntity(Boxes[box].box)
            exports['qb-target']:RemoveTargetEntity(Boxes[box].box)
            Boxes[box] = nil
        end
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
        BlockTime = 0
    end)
end

RegisterNUICallback('CraftStarted', function(data, cb)
    if data.mat.isGun then 
        local BluePrints = QBCore.Functions.GetPlayerData().metadata.blueprint
        if BluePrints then 
            if BluePrints[data.mat.itemName] then 
            else
                QBCore.Functions.Notify("You do not have blueprint for this weapon", "error", 5000)
                return
            end
        else
            QBCore.Functions.Notify("Error", "error")
            return
        end
    else
        local BluePrints = QBCore.Functions.GetPlayerData().metadata.blueprint
        if BluePrints then 
            if BluePrints[data.mat.itemName] then 
            else
                QBCore.Functions.Notify("You do not have blueprint for this ammo", "error", 5000)
                return
            end
        else
            QBCore.Functions.Notify("Error", "error")
            return
        end
    end
    local ItemPrice = math.ceil(data.mat.price * data.amount)
    for k, v in pairs(data.mat.NeedItems) do
        data.mat.NeedItems[k] = data.mat.NeedItems[k] * data.amount
    end

    QBCore.Functions.TriggerCallback('qb-pew:HasCraftingItemsItem', function(result, hasPrice)
        if result then
            if hasPrice then
                CloseCrafting()
                OpenUI = true
                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                QBCore.Functions.Progressbar("crafting_new", "Crafting "..QBCore.Shared.Items[data.mat.itemName].label.." ...", data.mat.Timer * data.amount, false, true, {
                    disableMovement = true,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                }, {}, {}, {}, function()
                    OpenUI = false
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    QBCore.Functions.TriggerCallback('qb-pew:RemoveItems', function(result)
                        if result then
                            local info = {
                                quality = 100
                            }
                            if data.mat.isGun then 
                                TriggerServerEvent('qb-pew:server:collectGuns', data.amount, data.mat.itemName)
                            else
                                TriggerServerEvent('qb-pew:server:collectAmmo', data.amount, data.mat.itemName)
                            end
                        end
                    end, data.mat.NeedItems)
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


RegisterNUICallback('CloseCrafting', function(data, cb)
    CloseCrafting()
end)

RegisterNUICallback('SendAlertcraft', function(data, cb)
    QBCore.Functions.Notify(data.text, data.type)
end)