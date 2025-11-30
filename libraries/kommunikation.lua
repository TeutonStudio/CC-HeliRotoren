-- libraries/kommunikation.lua
local kommunikation = {}

local VR = require("libraries/vektor")
local RV = require("libraries/rotor")

local function keinModem(seite) return "[FEHLER] Kein Modem an '" .. seite .. "' gefunden!" end

-- Identifiziert ob das Modem an config.modem seite ist und schreibt das peripheral in die config
function kommunikation.identifiziereModem(config)
    print("[INFO] Starte Rotor-Steuerung auf Kanal: " .. config.channel)
    print("[INFO] Rotoren: " .. table.concat(config.rotoren, ", "))
    local modem = peripheral.wrap(config.modem)
    if not modem then error(keinModem(config.modem)) end
    if not modem.isOpen(config.channel) then
        modem.open(config.channel) end
    config.modem = modem
end

function kommunikation.interpretiereSteuerung(config,nachricht)
    if nachricht.sender == "steuerung" then
        print("Steuerungsbefehl empfangen")
        print(nachricht.pitch, nachricht.roll, nachricht.coll, nachricht.yaw)
        if config.rolle == "primar" then
            ship.applyInvariantForce(0,nachricht.coll * ship.getMass(),0)
            ship.applyRotDependentTorque(nachricht.pitch * ship.getMass(),0,nachricht.roll * ship.getMass())
        elseif config.rolle == "sekundar" then
            ship.applyInvariantForce(nachricht.yaw * ship.getMass(),0,0)
        end

        -- if nachricht.pitch == nil then
        --     steuer:definiere_pitch(nachricht.pitch) end
        -- if nachricht.roll == nil then 
        --     steuer:definiere_roll(nachricht.roll) end
        -- if nachricht.coll == nil then
        --     steuer:definiere_coll(nachricht.coll) end
        -- if nachricht.yaw == nil then
        --     steuer:definiere_yaw(nachricht.yaw) end
    end
end


-- Senden
local lastStatus = 0
function kommunikation.sendeKommunikation(config, delta)
    while true do
        if os.clock() - (lastStatus or 0) > delta then
            lastStatus = os.clock()
            config.modem.transmit(config.channel, config.channel, {
                sender = config.rolle.."-steuerung-info",
                position = ship.getWorldspacePosition(),
                linearGeschw = VR.lokaleLinearGeschwindigkeit(),
                winkelGeschw = VR.lokaleWinkelGeschwindigkeit()
            } ) end
        sleep(delta)
    end
end

local function verbindungsAusgabe(rolle,channel)
    local partner = ""
    if rolle == "primar" then partner = "Heckrotor" end
    if rolle == "sekundar" then partner = "Hauptrotor" end
    return "[VERBUNDEN] "..partner.." gefunden! (Kanal "..channel..")"
end

-- Empfangen
local verbindung = false
function kommunikation.empfangeKommunikation(config)
    while true do
        local event, seite, channel, replyChannel, nachricht, distanz = os.pullEvent("modem_message")
        if verbindung or nachricht.sender == config.rolle then
            -- TODO nix gibts
        else
            print(verbindungsAusgabe(config.rolle,config.channel))
            verbindung = true end
        if channel == config.channel and nachricht then
            -- kommunikation.interpretiereKommunikation(nachricht, config, status)
            kommunikation.interpretiereSteuerung(config,nachricht)
        end
    end
end

return kommunikation
