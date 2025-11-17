-- libraries/kommunikation.lua
local kommunikation = {}

local VR = require("libraries/vektor")

-- Identifiziert ob das Modem an config.modem seite ist und schreibt das peripheral in die config
function kommunikation.identifiziereModem(config)
    local modem = peripheral.wrap(config.modem)
    if not modem then 
        error("Kein Modem an '" .. config.modem .. "' gefunden!") end
    if not modem.isOpen(config.channel) then
        modem.open(config.channel) end
    config.modem = modem
end


local function verbindungsAusgabe(rolle,channel)
    local partner = ""
    if rolle == "primar" then partner = "Heckrotor" end
    if rolle == "sekundar" then partner = "Hauptrotor" end
    return "[VERBUNDEN] "..partner.." gefunden! (Kanal "..channel..")"
end

-- Empfang: Primär <-> Sekundär
function kommunikation.interpretiereKommunikation(nachricht, config, status)
    if not status.verbindung then
        print(verbindungsAusgabe(config.rolle,config.channel))
        status.verbindung = true end
    if config.rolle == "primar" and nachricht.sender == "sekundar" then
        status.qK = nachricht.quaternionHeck
        status.qH = quaternion.fromShip() end
    if config.rolle == "sekundar" and nachricht.sender == "primar" then
        status.qH = nachricht.quaternionHaupt
        status.qK = quaternion.fromShip() end
    
end

function kommunikation.interpretiereSteuerung(nachricht, eingabe)
    if nachricht.sender == "steuerung" then
        eingabe.p = nachricht.pitch or 0
        eingabe.r = nachricht.roll or 0
        eingabe.c = nachricht.coll or 0
        eingabe.y = nachricht.yaw or 0
    end
end

-- Nachrichten generieren
function kommunikation.erhalteNachricht(rolle)
    if rolle == "primar" then
        return { sender = "primar", quaternionHaupt = quaternion.fromShip() } end
    if rolle == "sekundar" then
        return { sender = "sekundar", quaternionHeck = quaternion.fromShip() } end
end

local lastStatus = 0
-- Senden
function kommunikation.sendeKommunikation(config, nachricht)
    if os.clock() - (lastStatus or 0) > .05 then
        lastStatus = os.clock()
        config.modem.transmit(config.channel, config.channel, {
            sender = config.rolle.."-steuerung-info",
            position = ship.getWorldspacePosition(),
            linearGeschw = VR.lokaleLinearGeschwindigkeit(),
            winkelGeschw = VR.lokaleWinkelGeschwindigkeit()
        } ) end
    local packet = nachricht or kommunikation.erhalteNachricht(config.rolle)
    config.modem.transmit(config.channel, config.channel, packet)
end

return kommunikation
