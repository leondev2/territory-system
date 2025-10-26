
local json = require "json"  
local TERRITORIJE_FILE = "teritorija.json"
local Territorije = {}
local ZauzimanjeAktivno = false
local TrenutnaTeritorija = nil
local ZauzimajuciIgrac = nil
local ZauzimanjeVrijeme = 0

local function SpremiTerritorije()
    local jsonData = json.encode(Territorije, { indent = true })
    SaveResourceFile(GetCurrentResourceName(), TERRITORIJE_FILE, jsonData, -1)
end

local function UcitajTerritorije()
    local fileContent = LoadResourceFile(GetCurrentResourceName(), TERRITORIJE_FILE)
    if fileContent and fileContent ~= "" then
        local ok, data = pcall(json.decode, fileContent)
        if ok and type(data) == "table" then
            Territorije = data
        end
    else
        for i=1, #Config.Teritorije do
            Territorije[i] = {
                id = i,
                ime = Config.Teritorije[i].ime,
                vlasnik = nil,
                zauzetaOd = nil
            }
        end
        SpremiTerritorije()
    end
end

function DohvatiOrganizaciju(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    local job = xPlayer.getJob()
    if job and job.name ~= 'unemployed' then return job.name end
    return nil
end

function ProvjeriUdaljenost(source, teritorijaId)
    local coords = GetEntityCoords(GetPlayerPed(source))
    local terCoord = Config.Teritorije[teritorijaId].pedCoord
    local distance = #(vector3(coords.x, coords.y, coords.z) - vector3(terCoord.x, terCoord.y, terCoord.z))
    return distance <= 500.0
end

function DajItemeIgracu(source, teritorijaId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local teritorija = Config.Teritorije[teritorijaId]
    if not teritorija or not teritorija.itemi then return end
    
    for _, item in ipairs(teritorija.itemi) do
        xPlayer.addInventoryItem(item.name, item.count)
    end
end

function ZapocniZauzimanje(source, teritorijaId)
    if ZauzimanjeAktivno then return false end
    local org = DohvatiOrganizaciju(source)
    if not org then return false end
    if Territorije[teritorijaId].vlasnik == org then return false end

    ZauzimanjeAktivno = true
    TrenutnaTeritorija = teritorijaId
    ZauzimajuciIgrac = source
    ZauzimanjeVrijeme = Config.Teritorije[teritorijaId].vrijemeZauzimanja

    TriggerClientEvent('leon:zapocniZauzimanje', -1, teritorijaId, source, ZauzimanjeVrijeme)

    Citizen.CreateThread(function()
        while ZauzimanjeAktivno do
            Wait(1000)
            ZauzimanjeVrijeme = ZauzimanjeVrijeme - 1
            if ZauzimanjeVrijeme <= 0 then
                ZavrsiZauzimanje(true)
                break
            end
            TriggerClientEvent('leon:updateZauzimanje', -1, ZauzimanjeVrijeme)
        end
    end)

    return true
end

function ZavrsiZauzimanje(uspjesno)
    if not ZauzimanjeAktivno then return end
    if uspjesno then
        local org = DohvatiOrganizaciju(ZauzimajuciIgrac)
        if org then
            local timestamp = os.time()
            Territorije[TrenutnaTeritorija].vlasnik = org
            Territorije[TrenutnaTeritorija].zauzetaOd = timestamp
            SpremiTerritorije()
            
            DajItemeIgracu(ZauzimajuciIgrac, TrenutnaTeritorija)
            
            TriggerClientEvent('leon:teritorijaZauzeta', -1, TrenutnaTeritorija, org, timestamp, ZauzimajuciIgrac)
        end
    end
    ZauzimanjeAktivno = false
    TrenutnaTeritorija = nil
    ZauzimajuciIgrac = nil
    ZauzimanjeVrijeme = 0
    TriggerClientEvent('leon:zavrsiZauzimanje', -1)
end

ESX.RegisterServerCallback('leon:pokusajZauzimanje', function(source, cb, teritorijaId)
    if not ProvjeriUdaljenost(source, teritorijaId) then cb(false); return end
    local org = DohvatiOrganizaciju(source)
    if not org then cb(false); return end
    if Territorije[teritorijaId].vlasnik == org then cb(false); return end
    if ZauzimanjeAktivno then cb(false); return end
    local success = ZapocniZauzimanje(source, teritorijaId)
    cb(success)
end)

ESX.RegisterServerCallback('leon:prekiniZauzimanje', function(source, cb)
    if ZauzimanjeAktivno and ZauzimajuciIgrac == source then
        ZavrsiZauzimanje(false)
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('leon:dohvatiTeritorije', function(source, cb)
    cb(Territorije)
end)

function GenerirajNovac()
    for i=1, #Territorije do
        if Territorije[i].vlasnik then
            local vrijemeZauzimanja = os.time() - Territorije[i].zauzetaOd
            local sati = math.floor(vrijemeZauzimanja / 3600)
            local iznos = sati * Config.Teritorije[i].novacPoSatu
            if iznos > 0 then
                TriggerEvent('leon:isplatiNovac', Territorije[i].vlasnik, iznos)
                Territorije[i].zauzetaOd = os.time()
                SpremiTerritorije()
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.TimerNovaca)
        GenerirajNovac()
    end
end)

RegisterServerEvent('leon:isplatiNovac')
AddEventHandler('leon:isplatiNovac', function(org, iznos)
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer and xPlayer.getJob().name == org then
            xPlayer.addAccountMoney('black_money', iznos)
            TriggerClientEvent('esx:showNotification', xPlayers[i], 'Vasa organizacija je primila $' .. iznos .. ' od teritorija!')
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        UcitajTerritorije()
    end
end)

exports('DohvatiTeritorije', function()
    return Territorije
end)
