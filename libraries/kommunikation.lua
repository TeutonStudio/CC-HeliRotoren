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
    if not modem.isOpen(config.steuerung) then
        modem.open(config.steuerung) end
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
    if status.verbindung or nachricht.sender == config.rolle then
        -- TODO
    else
        print(verbindungsAusgabe(config.rolle,config.channel))
        status.verbindung = true end
    local p_s = config.rolle == "primar" and nachricht.sender == "sekundar"
    local s_p = config.rolle == "sekundar" and nachricht.sender == "primar"
    if p_s then
        status.qK = nachricht.quaternionHeck
        status.qH = quaternion.fromShip() end
    if s_p then
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
function kommunikation.sendeKommunikation(config, nachricht, delta)
    while true do
        if os.clock() - (lastStatus or 0) > delta then
            lastStatus = os.clock()
            config.modem.transmit(config.channel, config.channel, {
                sender = config.rolle.."-steuerung-info",
                position = ship.getWorldspacePosition(),
                linearGeschw = VR.lokaleLinearGeschwindigkeit(),
                winkelGeschw = VR.lokaleWinkelGeschwindigkeit()
            } ) end
        if config.rolle == "sekundar" then sleep(delta/2) end
        local packet = nachricht or kommunikation.erhalteNachricht(config.rolle)
        config.modem.transmit(config.channel, config.channel, packet)
        sleep(delta)
    end
end

function kommunikation.empfangeKommunikation(config, werte)
    while true do
        local event, seite, channel, replyChannel, nachricht, distanz = os.pullEvent("modem_message")
        if channel == config.channel and nachricht then
            kommunikation.interpretiereKommunikation(nachricht, config, werte) end
        if channel == config.steuerung and nachricht then
            kommunikation.interpretiereSteuerung(nachricht, werte) end
    end
end

return kommunikation
