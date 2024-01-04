local dogBreeds = { 'Rottweiler', 'Husky', 'Retriever', 'Shepherd' }
local dogBHash = { 'a_c_rottweiler', 'a_c_husky', 'a_c_retriever', 'a_c_shepherd' }

local k9 = nil
local k9Name = nil

local blipk9 = nil

local isDogInVehicle = false

local selectedDogIndex = 1
local currentDogIndex = 1

local open = false
local main = RageUI.CreateMenu("K9 Manager", "Actions")
main.Closed = function()
    open = false
end

function openK9Menu()
    if open then
        open = false
        RageUI.Visible(main, false)
        return
    else
        open = true
        RageUI.Visible(main, true)
        Citizen.CreateThread(function()
            while open do
                RageUI.IsVisible(main, function()
                    if k9 == nil then
                        -- create a button to rename the dog
                        RageUI.Button("Dog's name", nil, { RightLabel = k9Name }, true, {
                            onSelected = function()
                                local result = KeyboardInput("Dog's name")
                                if result ~= nil then
                                    k9Name = result
                                end
                            end,
                        })
                        -- create a button to select the dog breed
                        RageUI.List("Dog breed", dogBreeds, selectedDogIndex, nil, {}, true, {
                            onListChange = function(Index)
                                selectedDogIndex = Index
                                currentDogIndex = Index
                            end,
                        })

                        RageUI.Button("Spawn the dog", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                if k9Name == nil then
                                    ShowNotification("You have to name your dog first!")
                                else
                                    -- Spawning
                                    local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)

                                    TriggerServerEvent('mth-k9:server:spawn', dogBHash[currentDogIndex], pos)
                                end
                            end,
                        })
                    else
                        RageUI.Button("Sit", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_Sit(k9)
                            end,
                        })

                        RageUI.Button("Follow / Call", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_Follow(k9)
                            end,
                        })

                        RageUI.Button("Don't move", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_Stay(k9)
                            end,
                        })

                        RageUI.Button("Bark", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_Bark(k9)
                            end,
                        })

                        RageUI.Button("Lay down", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_Lay(k9)
                            end,
                        })

                        RageUI.Button("Beg", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_beg(k9)
                            end,
                        })

                        RageUI.Button("Give paw", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_paw(k9)
                            end,
                        })

                        RageUI.Button("Attack", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                if isAttacking then
                                    isAttacking = false
                                    ClearPedTasksImmediately(k9)
                                else
                                    if Config.Select then
                                        select_and_attackK9(k9)
                                    else
                                        attackK9(k9)
                                    end
                                end
                            end,
                        })

                        RageUI.Button("Enter the car", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                EnterVehicle(k9)
                            end,
                        })

                        RageUI.Button("Exit the car", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                ExitVehicle(k9)
                            end,
                        })

                        RageUI.Button("Dismiss the dog", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                DismissDog(k9)
                            end,
                        })
                    end
                end)
                Wait(1)
            end
        end)
    end
end

RegisterNetEvent('mth-k9:openMenu')
AddEventHandler('mth-k9:openMenu', function()
    openK9Menu()
end)

RegisterNetEvent('mth-k9:client:spawn')
AddEventHandler('mth-k9:client:spawn', function(dog)
    -- get network control
    NetworkRequestControlOfNetworkId(dog)
    repeat
        Wait(1)
    until NetworkHasControlOfNetworkId(dog)

    k9 = NetToPed(dog)

    SetEntityAsMissionEntity(k9, true, true)
    GiveWeaponToPed(k9, GetHashKey('WEAPON_ANIMAL'), true, true)
    TaskSetBlockingOfNonTemporaryEvents(k9, true)
    SetPedFleeAttributes(k9, 0, false)
    SetPedCombatAttributes(k9, 3, true)
    SetPedCombatAttributes(k9, 5, true)
    SetPedCombatAttributes(k9, 46, true)
    -- make it not attack the owner in any condition
    SetPedAsGroupLeader(k9, GetPedGroupIndex(PlayerPedId()))
    SetPedAsGroupMember(k9, GetPedGroupIndex(PlayerPedId()))
    SetPedNeverLeavesGroup(k9, true)

    blipk9 = AddBlipForEntity(k9)
    SetBlipAsFriendly(blipk9, true)
    SetBlipDisplay(blipk9, 2)
    SetBlipShowCone(blipk9, true)
    SetBlipAsShortRange(blipk9, false)

    Command_Follow(k9)
    InitLoop()
end)


function InitLoop()
    Citizen.CreateThread(function()
        while k9 do
            if IsEntityDead(k9) then
                ShowNotification(k9Name .. " was killed!")
                k9 = nil
                k9Name = nil
                RemoveBlip(blipk9)
                blipk9 = nil
            elseif IsEntityDead(PlayerPedId()) then
                DeleteEntity(k9)
                k9 = nil
                k9Name = nil
                RemoveBlip(blipk9)
                blipk9 = nil
            end
            if not NetworkHasControlOfEntity(k9) then
                NetworkRequestControlOfEntity(k9)
            end
            Wait(1000)
        end
    end)
end

local isAttacking = false
function attackK9(ped)
    DetachEntity(ped)

    if IsPlayerFreeAiming(PlayerId()) then
        local _, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
        ClearPedTasks(ped)
        if IsEntityAPed(target) and target ~= PlayerPedId() then
            isAttacking = true
            TaskCombatPed(ped, target, 0, 16)
            CreateThread(function()
                while isAttacking and not IsPedDeadOrDying(target, true) do
                    SetPedMoveRateOverride(ped, 1.25)
                    Citizen.Wait(0)
                end
            end)
        end
    else
        local target = GetPedInFront()
        ClearPedTasks(ped)
        if IsEntityAPed(target) and target ~= PlayerPedId() then
            isAttacking = true
            TaskCombatPed(ped, target, 0, 16)

            CreateThread(function()
                while isAttacking and not IsPedDeadOrDying(target, true) do
                    SetPedMoveRateOverride(ped, 1.25)
                    Citizen.Wait(0)
                end
            end)
        end
    end
end

RegisterNetEvent('mth-k9:attack')
AddEventHandler('mth-k9:attack', function()
    attackK9(k9)
end)

function select_and_attackK9(ped)
    DetachEntity(ped)
    local target = nil

    local player = GetAllPlayersInArea(GetEntityCoords(ped), 5.0)
    for k, v in pairs(player) do
        if v == PlayerId() then
            table.remove(player, k)
        end
    end

    if player ~= nil then
        if next(player) then
            inChoice = true
            StartChoicePlayerK9(player)
            if selectedPlayer ~= nil then
                target = GetPlayerPed(selectedPlayer)
            end
        end
    else
        ShowNotification("No player nearby")
    end

    if target == nil then
        ShowNotification("No player selected")
        return
    end
    ClearPedTasks(ped)

    if IsEntityAPed(target) and target ~= PlayerPedId() then
        isAttacking = true
        TaskCombatPed(ped, target, 0, 16)

        CreateThread(function()
            while isAttacking and not IsPedDeadOrDying(target, true) do
                SetPedMoveRateOverride(ped, 1.25)
                Citizen.Wait(0)
            end
        end)
    end
end

function Command_Sit(ped)
    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@amb@world_dog_sitting@idle_a")
    while not HasAnimDictLoaded("creatures@rottweiler@amb@world_dog_sitting@idle_a") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@amb@world_dog_sitting@idle_a", "idle_b", 8.0, -4.0, -1, 1, 0.0)
end

RegisterNetEvent('mth-k9:sit')
AddEventHandler('mth-k9:sit', function()
    Command_Sit(k9)
end)

function Command_Stay(ped)
    ClearPedTasks(ped)

    RequestAnimDict("amb@lo_res_idles@")
    while not HasAnimDictLoaded("amb@lo_res_idles@") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "amb@lo_res_idles@", "creatures_world_rottweiler_standing_lo_res_base", 8.0, -4.0, -1, 1, 0.0)
end

RegisterNetEvent('mth-k9:stay')
AddEventHandler('mth-k9:stay', function()
    Command_Stay(k9)
end)

function Command_paw(ped)
    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@tricks@")
    while not HasAnimDictLoaded("creatures@rottweiler@tricks@") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@tricks@", "paw_right_loop", 8.0, -4.0, -1, 1, 0.0)
end

RegisterNetEvent('mth-k9:paw')
AddEventHandler('mth-k9:paw', function()
    Command_paw(k9)
end)

function Command_beg(ped)
    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@tricks@")
    while not HasAnimDictLoaded("creatures@rottweiler@tricks@") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@tricks@", "beg_loop", 8.0, -4.0, -1, 1, 0.0)
end

RegisterNetEvent('mth-k9:beg')
AddEventHandler('mth-k9:beg', function()
    Command_beg(k9)
end)

function Command_Follow(ped)
    ClearPedTasks(ped)
    DetachEntity(ped)

    TaskFollowToOffsetOfEntity(ped, GetPlayerPed(-1), 0.5, 0.0, 0.0, 7.0, -1, 0.2, true)
end

RegisterNetEvent('mth-k9:follow')
AddEventHandler('mth-k9:follow', function()
    Command_Follow(k9)
end)

function Command_Bark(ped)
    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@amb@world_dog_barking@idle_a")
    while not HasAnimDictLoaded("creatures@rottweiler@amb@world_dog_barking@idle_a") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@amb@world_dog_barking@idle_a", "idle_a", 8.0, -4.0, -1, 1, 0.0)
end

RegisterNetEvent('mth-k9:bark')
AddEventHandler('mth-k9:bark', function()
    Command_Bark(k9)
end)

function Command_Lay(ped)
    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@amb@sleep_in_kennel@")
    while not HasAnimDictLoaded("creatures@rottweiler@amb@sleep_in_kennel@") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@amb@sleep_in_kennel@", "sleep_in_kennel", 8.0, -4.0, -1, 1, 0.0)
end

RegisterNetEvent('mth-k9:lay')
AddEventHandler('mth-k9:lay', function()
    Command_Lay(k9)
end)

function Command_StartTrack(dog, player)
    local target = GetPlayerPed(GetPlayerFromServerId(tonumber(player)))

    TaskFollowToOffsetOfEntity(dog, target, 0.5, 0.0, 0.0, 6.0, -1, 0.2, true)
end

function EnterVehicle(ped)
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        ClearPedTasks(ped)

        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local vehHeading = GetEntityHeading(vehicle)

        TaskGoToEntity(ped, vehicle, -1, 0.5, 100, 1073741824, 0)
        TaskAchieveHeading(ped, vehHeading, -1)

        RequestAnimDict("creatures@rottweiler@in_vehicle@van")
        RequestAnimDict("creatures@rottweiler@amb@world_dog_sitting@base")

        while not HasAnimDictLoaded("creatures@rottweiler@in_vehicle@van") or
            not HasAnimDictLoaded("creatures@rottweiler@amb@world_dog_sitting@base") do
            Citizen.Wait(1)
        end

        TaskPlayAnim(ped, "creatures@rottweiler@in_vehicle@van", "get_in", 8.0, -4.0, -1, 2, 0.0)
        Citizen.Wait(700)
        ClearPedTasks(ped)
        AttachEntityToEntity(ped, vehicle, GetEntityBoneIndexByName(vehicle, "seat_pside_r"), 0.0, 0.0, 0.25)
        TaskPlayAnim(ped, "creatures@rottweiler@amb@world_dog_sitting@base", "base", 8.0, -4.0, -1, 2, 0.0)
    else
        ShowNotification("You have to be in a vehicle to do that!")
    end
end

RegisterNetEvent('mth-k9:enterVeh')
AddEventHandler('mth-k9:enterVeh', function()
    EnterVehicle(k9)
    isDogInVehicle = true
end)

function ExitVehicle(ped)
    local vehicle = GetEntityAttachedTo(ped)
    local vehPos = GetEntityCoords(vehicle)
    local forwardX = GetEntityForwardVector(vehicle).x * 3.7
    local forwardY = GetEntityForwardVector(vehicle).y * 3.7
    local _, groundZ = GetGroundZFor_3dCoord(vehPos.x, vehPos.y, vehPos.z, 0)

    ClearPedTasks(ped)
    DetachEntity(ped)

    SetEntityCoords(ped, vehPos.x - forwardX, vehPos.y - forwardY, groundZ)

    Command_Follow(ped)
end

RegisterNetEvent('mth-k9:exitVeh')
AddEventHandler('mth-k9:exitVeh', function()
    ExitVehicle(k9)
    isDogInVehicle = false
end)

function DismissDog(ped)
    ClearPedTasks(ped)

    DeletePed(ped)

    blipk9 = nil
    k9 = nil
    k9Name = nil
    RemoveBlip(blipk9)
end

RegisterNetEvent('mth-k9:dismiss')
AddEventHandler('mth-k9:dismiss', function()
    DismissDog(k9)
end)

function StartChoicePlayerK9(players)
    selectedPlayer = nil
    ShowNotification("Press ~g~E~s~ to confirm\nPress ~b~L~s~ to change target\nPress ~r~X~s~ to cancel")
    local timer = GetGameTimer() + 10000
    while inChoice do
        if next(players) then
            local mCoors = GetEntityCoords(GetPlayerPed(players[1]))
            DrawMarker(20, mCoors.x, mCoors.y, mCoors.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255,
                255, 120, 0, 1, 2, 0, nil, nil, 0)
            if GetGameTimer() > timer then
                ShowNotification("~r~Timeout was reached")
                inChoice = false
                return
            elseif IsControlJustPressed(0, 51) then -- E
                selectedPlayer = players[1]
                inChoice = false
                return
            elseif IsControlJustPressed(0, 182) then -- L
                table.remove(players, 1)
                if next(players) then
                    timer = GetGameTimer() + 10000
                end
            elseif IsControlJustPressed(0, 73) then -- X
                ShowNotification("~r~You canceled the choice")
                selectedPlayer = nil
                inChoice = false
                return
            end
        else
            ShowNotification("~r~No players found")
            selectedPlayer = nil
            inChoice = false
            return
        end
        Wait(0)
    end
end

if Config.UseKeybind then
    Keys.Register(Config.Keybinds.Menu, Config.Keybinds.Menu, 'K9 Menu', function()
        TriggerEvent('mth-k9:openMenu')
    end)
    Keys.Register(Config.Keybinds.Attack, Config.Keybinds.Attack, 'K9 Attack', function()
        TriggerEvent('mth-k9:attack')
    end)
    Keys.Register(Config.Keybinds.Sit, Config.Keybinds.Sit, 'K9 Sit', function()
        TriggerEvent('mth-k9:sit')
    end)
    Keys.Register(Config.Keybinds.Stay, Config.Keybinds.Stay, 'K9 Stay', function()
        TriggerEvent('mth-k9:stay')
    end)
    Keys.Register(Config.Keybinds.Follow, Config.Keybinds.Beg, 'K9 Beg', function()
        TriggerEvent('mth-k9:beg')
    end)
    Keys.Register(Config.Keybinds.Paw, Config.Keybinds.Paw, 'K9 Paw', function()
        TriggerEvent('mth-k9:paw')
    end)
    Keys.Register(Config.Keybinds.Follow, Config.Keybinds.Follow, 'K9 Follow', function()
        TriggerEvent('mth-k9:follow')
    end)
    Keys.Register(Config.Keybinds.Bark, Config.Keybinds.Bark, 'K9 Bark', function()
        TriggerEvent('mth-k9:bark')
    end)
    Keys.Register(Config.Keybinds.Lay, Config.Keybinds.Lay, 'K9 Lay', function()
        TriggerEvent('mth-k9:lay')
    end)
    Keys.Register(Config.Keybinds.EnterExitVehicle, Config.Keybinds.EnterExitVehicle, 'K9 Enter/Exit Vehicle', function()
        if isDogInVehicle == true then
            TriggerEvent('mth-k9:exitVeh')
        elseif isDogInVehicle == false then
            TriggerEvent('mth-k9:enterVeh')
        end
    end)
    Keys.Register(Config.Keybinds.Dismiss, Config.Keybinds.Dismiss, 'K9 Dismiss', function()
        TriggerEvent('mth-k9:dismiss')
    end)
end