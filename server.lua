if Config.UseCommand then
    RegisterCommand('k9', function(source, args, rawCommand)
        TriggerClientEvent('mth-k9:openMenu', source)
    end, Config.AcePermissions)
end

RegisterNetEvent('mth-k9:server:spawn')
AddEventHandler('mth-k9:server:spawn', function(model, pos)
    local source = source
    local ped = CreatePed(0, model, pos.x, pos.y, pos.z, 0.0, true, true)
    while not DoesEntityExist(ped) do
        Wait(50)
    end
    print(ped)
    print(NetworkGetNetworkIdFromEntity(ped))
    TriggerClientEvent('mth-k9:client:spawn', source, NetworkGetNetworkIdFromEntity(ped))
end)
