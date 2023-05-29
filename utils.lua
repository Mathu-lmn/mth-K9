function KeyboardInput(text)
	local result = nil
	AddTextEntry("CUSTOM_AMOUNT", text)
	DisplayOnscreenKeyboard(1, "CUSTOM_AMOUNT", '', "", '', '', '', 255)
	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Wait(1)
	end
	if UpdateOnscreenKeyboard() ~= 2 then
		result = GetOnscreenKeyboardResult()
		Citizen.Wait(1)
	else
		Citizen.Wait(1)
	end
	return result
end

function ShowNotification(text)
	AddTextEntry('core:notif', text)
	BeginTextCommandThefeedPost('core:notif')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandThefeedPostTicker(true, true)
end

function GetAllPlayersInArea(coords, zone)
	local playersInArea = {}
	if zone == nil then
		zone = 150.0
	end
	for k, v in pairs(GetActivePlayers()) do
		local pPed = GetPlayerPed(v)
		local pCoords = GetEntityCoords(pPed)
		if GetDistanceBetweenCoords(pCoords, coords, false) <= zone then
			table.insert(playersInArea, v)
		end
	end
	return playersInArea
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