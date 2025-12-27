local QBCore = exports['qb-core']:GetCoreObject()
local dashcamActive = false

RegisterCommand("dashcam", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job and PlayerData.job.name == "police" then
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then
            local model = GetEntityModel(veh)
            if Config.PoliceCars[model] then
                dashcamActive = not dashcamActive
                SendNUIMessage({ action = "toggleDashcam", state = dashcamActive })
            else
                QBCore.Functions.Notify("Bu sadece polis araçlarında kullanılabilir!", "error")
            end
        else
            QBCore.Functions.Notify("Araçta olmanız gerekiyor!", "error")
        end
    else
        QBCore.Functions.Notify("Sadece polisler bu komutu kullanabilir!", "error")
    end
end)

CreateThread(function()
    while true do
        Wait(200)
        if dashcamActive then
            local ped = PlayerPedId()
            local myVeh = GetVehiclePedIsIn(ped, false)
            if myVeh == 0 then
                dashcamActive = false
                SendNUIMessage({ action = "toggleDashcam", state = false })
                SendNUIMessage({
                    action = "updateMirror",
                    plate = "",
                    model = "",
                    speed = ""
                })
            else
                local coordFrom = GetEntityCoords(ped)
                local coordTo = GetOffsetFromEntityInWorldCoords(ped, 0.0, 25.0, 0.0)
                local rayHandle = StartShapeTestRay(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, ped, 0)
                local _, hit, _, _, targetVeh = GetShapeTestResult(rayHandle)
                local plate, model, speed = "", "", ""
                if hit == 1 and DoesEntityExist(targetVeh) and IsEntityAVehicle(targetVeh) then
                    plate = GetVehicleNumberPlateText(targetVeh)
                    model = GetDisplayNameFromVehicleModel(GetEntityModel(targetVeh))
                    speed = math.floor(GetEntitySpeed(targetVeh) * 3.6) .. " KM/H"
                end
                SendNUIMessage({
                    action = "updateMirror",
                    plate = plate,
                    model = model,
                    speed = speed
                })
            end
        end
    end
end)
