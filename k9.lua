local dogBreeds = { 'Rottweiler', 'Husky', 'Retriever', 'Shepherd', 'Berger', 'Berger 2', 'Berger Civil' }
local dogBHash = { 'a_c_rottweiler', 'a_c_husky', 'a_c_retriever', 'a_c_shepherd', 'a_c_berger', 'a_c_berger1',
    'a_c_bergerciv' }
local dogTypes = { 'Search', 'General Purpose' }

local k91 = nil
local k91Name = nil

local blipk91 = nil

local selectedDogIndex = 1
local currentDogIndex = 1
local currentTypeIndex = 1
local selectedTypeIndex = 1

local open = false
local main = RageUI.CreateMenu("", "Action Disponible", 0.0, 0.0, "vision", "menu_title_police")
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
                    if k91 == nil then

                        -- create a button to rename the dog
                        RageUI.Button("Nom du chien", nil, { RightLabel = k91Name }, true, {
                            onSelected = function()
                                local result = KeyboardImput("Nom du chien")
                                if result ~= nil then
                                    k91Name = result
                                end
                            end,
                        })

                        -- create a button to select the dog breed
                        RageUI.List("Race du chien", dogBreeds, selectedDogIndex, nil, {}, true, {
                            onListChange = function(Index, Item)
                                selectedDogIndex = Index
                                currentDogIndex = Index
                            end,
                        })

                        RageUI.Button("Spawn le chien", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                if k91Name == nil then
                                    ShowNotification("Vous devez donner un nom au chien!")
                                else
                                    -- Spawning
                                    RequestModel(GetHashKey(dogBHash[currentDogIndex]))
                                    while not HasModelLoaded(GetHashKey(dogBHash[currentDogIndex])) do
                                        Citizen.Wait(1)
                                    end

                                    local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)
                                    local heading = GetEntityHeading(GetPlayerPed(-1))
                                    local _, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, false);

                                    k91 = CreatePed(28, GetHashKey(dogBHash[currentDogIndex]), pos.x, pos.y, groundZ + 1
                                        , heading,
                                        true, true)

                                    -- Dog Behaviour
                                    GiveWeaponToPed(k91, GetHashKey('WEAPON_ANIMAL'), true, true)
                                    TaskSetBlockingOfNonTemporaryEvents(k91, true)
                                    SetPedFleeAttributes(k91, 0, false)
                                    SetPedCombatAttributes(k91, 3, true)
                                    SetPedCombatAttributes(k91, 5, true)
                                    SetPedCombatAttributes(k91, 46, true)

                                    -- Blip Stuff
                                    blipk91 = AddBlipForEntity(k91)
                                    SetBlipAsFriendly(blipk91, true)
                                    SetBlipDisplay(blipk91, 2)
                                    SetBlipShowCone(blipk91, true)
                                    SetBlipAsShortRange(blipk91, false)

                                    BeginTextCommandSetBlipName("STRING")
                                    AddTextComponentString(k91Name)
                                    EndTextCommandSetBlipName(blipk91)

                                    Command_Follow(k91)

                                end
                            end,
                        })

                    else
                        if IsPedDeadOrDying(k91, true) then
                            ShowNotification(k91Name .. " a été tué!")
                            k91 = nil
                            k91Name = nil
                            blipk91 = nil
                            RemoveBlip(blipk91)
                        end

                        RageUI.Button("Assis", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_Sit(k91)
                            end,
                        })

                        RageUI.Button("Suivre/Rappeler", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_Follow(k91)
                            end,
                        })

                        RageUI.Button("Pas bouger", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_Stay(k91)
                            end,
                        })

                        RageUI.Button("Aboyer", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_Bark(k91)
                            end,
                        })

                        RageUI.Button("Couché", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_Lay(k91)
                            end,
                        })

                        RageUI.Button("Réclamer", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_beg(k91)
                            end,
                        })

                        RageUI.Button("Donner la patte", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                Command_paw(k91)
                            end,
                        })

                        -- RageUI.Button("Traquer un joueur", nil, { RightLabel = "→" }, true, {
                        --     onSelected = function()
                        --         -- TODO
                        --         TrackPlayer(k91)
                        --     end,
                        -- })

                        RageUI.Button("Attaquer", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                if isAttacking then
                                    isAttacking = false
                                    ClearPedTasksImmediately(k91)
                                else
                                    attackK9(k91)
                                end
                            end,
                        })

                        RageUI.Button("Entrer dans le véhicule", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                EnterVehicle(k91)
                            end,
                        })

                        RageUI.Button("Sortir du véhicule", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                ExitVehicle(k91)
                            end,
                        })

                        RageUI.Button("Despawn le chien", nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                DismissDog(k91)
                            end,
                        })
                    end
                end)
                Wait(1)
            end
        end)
    end
end

Keys.Register('O', 'O', 'Menu K9', function()
    if p:getJob() == 'lspd' then
        openK9Menu()
    else
        blipk91 = nil
        k91 = nil
        k91Name = nil
        RemoveBlip(blipk91)
        ShowNotification("Vous n'êtes pas autorisé à utiliser ce menu!")
    end
end)

local isAttacking = false

function attackK9(ped)
    DetachEntity(ped)

    local player = GetAllPlayersInArea(p:pos(), 3.0)
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
                local target = GetPlayerPed(selectedPlayer)
            end
        end
    end
    ClearPedTasks(ped)

    if IsEntityAPed(target) then
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

--[[ Command Functions ]] --

-- function TrackPlayer(k91)

--     local player = GetAllPlayersInArea(p:pos(), 3.0)
--     for k, v in pairs(player) do
--         if v == PlayerId() then
--             table.remove(player, k)
--         end
--     end

--     if player ~= nil then
--         if next(player) then
--             inChoice = true
--             StartChoicePlayerK9(player)
--             if selectedPlayer ~= nil then
--                 Command_StartTrack(k91, selectedPlayer)
--             end
--         end
--     end
-- end

function Command_Sit(ped)

    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@amb@world_dog_sitting@idle_a")
    while not HasAnimDictLoaded("creatures@rottweiler@amb@world_dog_sitting@idle_a") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@amb@world_dog_sitting@idle_a", "idle_b", 8.0, -4.0, -1, 1, 0.0)

end

function Command_Stay(ped)

    ClearPedTasks(ped)

    RequestAnimDict("amb@lo_res_idles@")
    while not HasAnimDictLoaded("amb@lo_res_idles@") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "amb@lo_res_idles@", "creatures_world_rottweiler_standing_lo_res_base", 8.0, -4.0, -1, 1, 0.0)

end

function Command_paw(ped)

    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@tricks@")
    while not HasAnimDictLoaded("creatures@rottweiler@tricks@") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@tricks@", "paw_right_loop", 8.0, -4.0, -1, 1, 0.0)

end

function Command_beg(ped)

    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@tricks@")
    while not HasAnimDictLoaded("creatures@rottweiler@tricks@") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@tricks@", "beg_loop", 8.0, -4.0, -1, 1, 0.0)

end

function Command_Follow(ped)

    ClearPedTasks(ped)
    DetachEntity(ped)

    TaskFollowToOffsetOfEntity(ped, GetPlayerPed(-1), 0.5, 0.0, 0.0, 7.0, -1, 0.2, true)

end

function Command_Bark(ped)

    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@amb@world_dog_barking@idle_a")
    while not HasAnimDictLoaded("creatures@rottweiler@amb@world_dog_barking@idle_a") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@amb@world_dog_barking@idle_a", "idle_a", 8.0, -4.0, -1, 1, 0.0)

end

function Command_Lay(ped)
    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@amb@sleep_in_kennel@")
    while not HasAnimDictLoaded("creatures@rottweiler@amb@sleep_in_kennel@") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@amb@sleep_in_kennel@", "sleep_in_kennel", 8.0, -4.0, -1, 1, 0.0)

end

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
        ShowNotification("Vous devez être dans un véhicule")
    end

end

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

function DismissDog(ped)

    ClearPedTasks(ped)

    DeletePed(ped)

    blipk91 = nil
    k91 = nil
    k91Name = nil
    RemoveBlip(blipk91)

end

function GetPedInFront()
    local player = PlayerId()
    local plyPed = GetPlayerPed(player)
    local plyPos = GetEntityCoords(plyPed, false)
    local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 5.0, 0.0)
    local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12
        , plyPed, 7)
    local _, _, _, _, ped = GetShapeTestResult(rayHandle)
    return ped
end

function StartChoicePlayerK9(players)
    selectedPlayer = nil
    ShowNotification(
        "Appuyez sur ~g~E~s~ pour valider\nAppuyez sur ~b~L~s~ pour changer de cible\nAppuyez sur ~r~X~s~ pour annuler")
    local timer = GetGameTimer() + 10000
    while inChoice do
        if next(players) then
            local mCoors = GetEntityCoords(GetPlayerPed(players[1]))
            DrawMarker(20, mCoors.x, mCoors.y, mCoors.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255,
                255, 120, 0, 1, 2, 0, nil, nil, 0)
            if GetGameTimer() > timer then
                ShowNotification("~r~Le délai est dépassé")
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
                ShowNotification("~r~Vous avez annulé")
                selectedPlayer = nil
                inChoice = false
                return
            end
        else
            ShowNotification("~r~Il n'y a personne autour de vous")
            selectedPlayer = nil
            inChoice = false
            return
        end
        Wait(0)
    end
end
