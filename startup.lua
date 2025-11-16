-- startup.lua
local CFGV = require("libraries/config") -- Konfigurationsverwalter
local KV = require("libraries/kommunikation") -- Kommunikationsverwalter
local VR = require("libraries/vektor") -- Vektorraum Rechnung
local RV = require("libraries/rotor") -- Rotorenverwalter

-- Config laden
local cfg = CFGV.loadConfig()
local modem = peripheral.wrap(cfg.modem)
if not modem then error("Kein Modem an '" .. cfg.modem .. "' gefunden! Überprüfe config.json und Peripherie.") end
local rotorSeiten = cfg.rotors

-- ==== Zustand für Verbindungserkennung ====
local verbindung = false
local steuer = vector.new()

print("[INFO] Starte Rotor-Steuerung mit Modem: " .. cfg.modem)
print("[INFO] Rotoren: " .. table.concat(rotorSeiten, ", "))
modem.open(cfg.channel)

while true do
    local quaternionHaupt,quaternionHeck
    local azimuth = 0
	
    KV.sendeKommunikation(modem,cfg,false)
    local event, side, channel, replyChannel, message, dist = os.pullEvent("modem_message")
	if channel == cfg.channel and channel == replyChannel then
        quaternionHaupt,quaternionHeck = KV.interpretiereKommunikation(message,modem,{verbindung = verbindung, channel = channel})
		steuer = KV.interpretiereSteuerung(message,cfg.level,{steurung = steurung}) end
    if quaternionHaupt and quaternionHeck then
    	azimuth = RV.azimuth(quaternionHaupt, quaternionHeck) end
    if steuer then for idx, seite in ipairs(rotorSeiten) do
        RV.setzeRotor(seite, azimuth, steuer) end end
    sleep(0.01)
end
