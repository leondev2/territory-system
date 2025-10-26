local ZauzimanjeAktivno = false
local TrenutnaTeritorija = nil
local ZauzimanjeVrijeme = 0
local ZauzimanjeProgress = 0
local Blipovi = {}
local Pedovi = {}
local Territorije = {}

function KreirajBlipove()
    for i=1, #Config.Teritorije do
        local ter = Config.Teritorije[i]
        local blip = AddBlipForCoord(ter.pedCoord.x, ter.pedCoord.y, ter.pedCoord.z)
        SetBlipSprite(blip, ter.blipSprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, ter.blipBoja)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(ter.ime)
        EndTextCommandSetBlipName(blip)
        Blipovi[i] = blip
    end
end

function KreirajPedove()
    for i=1, #Config.Teritorije do
        local ter = Config.Teritorije[i]
        RequestModel(ter.pedModel)
        while not HasModelLoaded(ter.pedModel) do
            Citizen.Wait(1)
        end
        local ped = CreatePed(4, ter.pedModel, ter.pedCoord.x, ter.pedCoord.y, ter.pedCoord.z, ter.pedCoord.w, false, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        SetEntityAsMissionEntity(ped, true, true)

        exports.qtarget:AddEntityZone('teritorija_ped_'..i, ped, {
            name = 'teritorija_ped_'..i,
            debugPoly = false,
            useZ = true
        }, {
            options = {
                {
                    event = "leon:pokreniZauzimanje",
                    icon = "fas fa-flag",
                    label = "Preuzmi teritoriju",
                    num = i,
                    canInteract = function()
                        return not ZauzimanjeAktivno
                    end
                }
            },
            distance = 2.5
        })

        Pedovi[i] = ped
    end
end

function AzurirajUI()
    SendNUIMessage({
        action = 'azuriraj',
        teritorije = Territorije,
        zauzimanjeAktivno = ZauzimanjeAktivno,
        trenutnaTeritorija = TrenutnaTeritorija,
        preostaloVrijeme = ZauzimanjeVrijeme
    })
end

function FormatirajVrijeme(timestamp)
    if not timestamp then return "Nepoznato" end
    local date = os.date("*t", timestamp)
    return string.format("%02d/%02d/%04d, %02d:%02d", date.day, date.month, date.year, date.hour, date.min)
end

RegisterNetEvent('leon:zapocniZauzimanje')
AddEventHandler('leon:zapocniZauzimanje', function(teritorijaId, igracId, vrijeme)
    if GetPlayerServerId(PlayerId()) == igracId then
        ZauzimanjeAktivno = true
        TrenutnaTeritorija = teritorijaId
        ZauzimanjeVrijeme = vrijeme
        ZauzimanjeProgress = 0
        SendNUIMessage({ action = 'showProgress', teritorijaId = teritorijaId })

        Citizen.CreateThread(function()
            while ZauzimanjeAktivno do
                Citizen.Wait(100)
                local playerPed = PlayerPedId()
                if not IsPedOnFoot(playerPed) or IsPedRagdoll(playerPed) then
                    TriggerServerEvent('leon:prekiniZauzimanje')
                    break
                end
                local coords = GetEntityCoords(playerPed)
                local terCoord = Config.Teritorije[teritorijaId].pedCoord
                local distance = #(vector3(coords.x, coords.y, coords.z) - vector3(terCoord.x, terCoord.y, terCoord.z))
                if distance > 3.0 then
                    TriggerServerEvent('leon:prekiniZauzimanje')
                    break
                end
                ZauzimanjeProgress = ZauzimanjeProgress + (100 / (vrijeme * 10))
                if ZauzimanjeProgress > 100 then ZauzimanjeProgress = 100 end
                SendNUIMessage({ action = 'progress', progress = ZauzimanjeProgress })
            end
        end)
    end
    AzurirajUI()
end)

RegisterNetEvent('leon:updateZauzimanje')
AddEventHandler('leon:updateZauzimanje', function(vrijeme)
    ZauzimanjeVrijeme = vrijeme
    SendNUIMessage({ action = 'updateTime', time = vrijeme })
    AzurirajUI()
end)

RegisterNetEvent('leon:zavrsiZauzimanje')
AddEventHandler('leon:zavrsiZauzimanje', function()
    ZauzimanjeAktivno = false
    TrenutnaTeritorija = nil
    ZauzimanjeVrijeme = 0
    ZauzimanjeProgress = 0
    SendNUIMessage({ action = 'hideProgress' })
    AzurirajUI()
end)

RegisterNetEvent('leon:teritorijaZauzeta')
AddEventHandler('leon:teritorijaZauzeta', function(teritorijaId, org, zauzetaOd, igracId)
    if not Territorije[teritorijaId] then return end
    Territorije[teritorijaId].vlasnik = org
    Territorije[teritorijaId].zauzetaOd = zauzetaOd or math.floor(GetGameTimer()/1000)
    AzurirajUI()
    
    if GetPlayerServerId(PlayerId()) == igracId then
        ESX.ShowNotification('Uspjesno ste zauzeli teritoriju i dobili ste nagrade!')
    else
        ESX.ShowNotification('Teritorija je zauzeta od strane ' .. org)
    end
end)

RegisterNetEvent('leon:pokreniZauzimanje')
AddEventHandler('leon:pokreniZauzimanje', function(data)
    ESX.TriggerServerCallback('leon:pokusajZauzimanje', function(success)
        if not success then
            ESX.ShowNotification('Ne mozete zapoceti zauzimanje ove teritorije!')
        end
    end, data.num)
end)

Citizen.CreateThread(function()
    while not ESX do Citizen.Wait(100) end
    while not exports.qtarget do Citizen.Wait(100) end
    ESX.TriggerServerCallback('leon:dohvatiTeritorije', function(teritorije)
        Territorije = teritorije
        KreirajBlipove()
        KreirajPedove()
        AzurirajUI()
    end)
end)

Citizen.CreateThread(function()
    local showNUI = false
    while true do
        Citizen.Wait(0)
        if IsPauseMenuActive() then
            local waypointBlip = GetFirstBlipInfoId(8)
            if DoesBlipExist(waypointBlip) then
                local wpCoords = GetBlipInfoIdCoord(waypointBlip)
                local foundTeritorija = nil
                for i=1,#Config.Teritorije do
                    local ter = Config.Teritorije[i]
                    if math.abs(wpCoords.x - ter.pedCoord.x) < 0.1 and math.abs(wpCoords.y - ter.pedCoord.y) < 0.1 then
                        foundTeritorija = i
                        break
                    end
                end
                if foundTeritorija then
                    local ter = Config.Teritorije[foundTeritorija]
                    local teritorija = Territorije[foundTeritorija] or {}
                    SendNUIMessage({
                        action = 'showInfo',
                        config = { ime = ter.ime, novacPoSatu = ter.novacPoSatu },
                        teritorija = { 
                            vlasnik = teritorija.vlasnik or "Niko",
                            zauzetaOd = teritorija.zauzetaOd
                        }
                    })
                    showNUI = true
                elseif showNUI then
                    SendNUIMessage({ action = 'hideInfo' })
                    showNUI = false
                end
            elseif showNUI then
                SendNUIMessage({ action = 'hideInfo' })
                showNUI = false
            end
        elseif showNUI then
            SendNUIMessage({ action = 'hideInfo' })
            showNUI = false
        end
    end
end)

RegisterNUICallback('zatvori', function(data, cb)
    SendNUIMessage({ action = 'hideInfo' })
end)
