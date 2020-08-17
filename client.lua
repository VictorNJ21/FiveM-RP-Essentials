-- Disable Emergency
Citizen.CreateThread(function()
    for i = 1, 12 do
        EnableDispatchService(i, false)
    end
end)

-- Disable Weapon Drops
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_CARBINERIFLE'))
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_PISTOL'))
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_PUMPSHOTGUN'))
	end
end)

-- Disable Vehicle Rewards (weapons from emergancy vehicles)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		DisablePlayerVehicleRewards(PlayerPedId())	
	end
end)

-- Hide Crosshair
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		HideHudComponentThisFrame(14)
	end
end)

-- Handsup
Citizen.CreateThread(function()
    local dict = 'missminuteman_1ig_2'
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(100)
	end
    local handsup = false
	while true do
		Citizen.Wait(0)
        if IsControlJustPressed(1, 323) then 
            if not handsup then
                TaskPlayAnim(PlayerPedId(), dict, 'handsup_enter', 8.0, 8.0, -1, 50, 0, false, false, false)
                handsup = true
            else
                handsup = false
                ClearPedTasks(PlayerPedId())
            end
        end
    end
end)

-- Crouch
local crouched = false

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)

        local ped = PlayerPedId()

        if (DoesEntityExist(ped) and not IsEntityDead(ped)) then 
            DisableControlAction(0, 36, true)  

            if (not IsPauseMenuActive()) then 
                if (IsDisabledControlJustPressed(0, 36)) then 
                    RequestAnimSet('move_ped_crouched')

                    while (not HasAnimSetLoaded('move_ped_crouched')) do 
                        Citizen.Wait(100)
                    end 

                    if (crouched == true) then 
                        ResetPedMovementClipset(ped, 0)
                        crouched = false 
                    elseif (crouched == false) then
                        SetPedMovementClipset(ped, 'move_ped_crouched', 0.25)
                        crouched = true 
                    end 
                end
            end 
        end 
    end
end)

-- Recude NPC's
Citizen.CreateThread(function()
	local DensityMultiplier = 0.5
	while true do
	    Citizen.Wait(0)
	    SetVehicleDensityMultiplierThisFrame(DensityMultiplier)
	    SetPedDensityMultiplierThisFrame(DensityMultiplier)
	    SetRandomVehicleDensityMultiplierThisFrame(DensityMultiplier)
	    SetParkedVehicleDensityMultiplierThisFrame(DensityMultiplier)
	    SetScenarioPedDensityMultiplierThisFrame(DensityMultiplier, DensityMultiplier)
	end
end)

-- Finger point
local mp_pointing = false
local keyPressed = false

local function startPointing()
    local ped = PlayerPedId()
    RequestAnimDict('anim@mp_point')
    while not HasAnimDictLoaded('anim@mp_point') do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, 'task_mp_pointing', 0.5, 0, 'anim@mp_point', 24)
    RemoveAnimDict('anim@mp_point')
end

local function stopPointing()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0xD01015C7316AE176, ped, 'Stop')
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local once = true
local oldval = false
local oldvalped = false

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if once then
            once = false
        end
        if not keyPressed then
            if IsControlPressed(0, 29) and not mp_pointing and IsPedOnFoot(PlayerPedId()) then
                Wait(200)
                if not IsControlPressed(0, 29) then
                    keyPressed = true
                    startPointing()
                    mp_pointing = true
                else
                    keyPressed = true
                    while IsControlPressed(0, 29) do
                        Wait(50)
                    end
                end
            elseif (IsControlPressed(0, 29) and mp_pointing) or (not IsPedOnFoot(PlayerPedId()) and mp_pointing) then
                keyPressed = true
                mp_pointing = false
                stopPointing()
            end
        end
        if keyPressed then
            if not IsControlPressed(0, 29) then
                keyPressed = false
            end
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) and not mp_pointing then
            stopPointing()
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) then
            if not IsPedOnFoot(PlayerPedId()) then
                stopPointing()
            else
                local ped = PlayerPedId()
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0
                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = Cos(camHeading)
                local sinCamHeading = Sin(camHeading)
                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0
                local blocked = 0
                local nn = 0
                local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
                nn,blocked,coords,coords = GetRaycastResult(ray)
                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, 'Pitch', camPitch)
                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, 'Heading', camHeading * -1.0 + 1.0)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, 'isBlocked', blocked)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, 'isFirstPerson', Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
            end
        end
    end
end)

-- Disable Vehicle Air Control
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if DoesEntityExist(veh) and not IsEntityDead(veh) then
            local model = GetEntityModel(veh)
            if not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model) and IsEntityInAir(veh) then
                DisableControlAction(0, 59) 
                DisableControlAction(0, 60) 
            end
        end
    end
end)

-- Disable Vehicle Roll
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
		local roll = GetEntityRoll(vehicle)
		if (roll > 75.0 or roll < -75.0) and GetEntitySpeed(vehicle) < 2 then
			DisableControlAction(2, 59, true)
			DisableControlAction(2, 60, true)
		end
	end
end)
