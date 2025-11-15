-- startup.lua
local CFGV = require("libraries/config") -- Konfigurationsverwalter
local VR = require("libraries/vektor") -- Vektorraum Rechnung
local RV = require("libraries/rotor") -- Rotorenverwalter

-- Config laden
local cfg = CFGV.loadConfig()
local modem = peripheral.wrap(cfg.modem)
if not modem then error("Kein Modem an '" .. cfg.modem .. "' gefunden! Überprüfe config.json und Peripherie.") end
local rotorSeiten = cfg.rotors

-- ==== Zustand für Verbindungserkennung ====
local verbindungBestaetigt = false

-- ==== 2. Haupt-Loop ======================================================
local globalFWD = vector.new(0, 0, 1)
local pitch = 40
local roll = 0
local coll = 0
local yaw = 0

print("[INFO] Starte Rotor-Steuerung mit Modem: " .. cfg.modem)
print("[INFO] Rotoren: " .. table.concat(rotorSeiten, ", "))
modem.open(cfg.channel)

while true do
    local azimuth = 0
    local steuer = vector.new()

    if cfg.level == "primar" then
        local event, side, channel, replyChannel, quaternionHeck, dist = os.pullEvent("modem_message")
        if channel == cfg.channel then
            local quaternionLokal = ship.getQuaternion()
            modem.transmit(replyChannel, cfg.channel, quaternionLokal)
            azimuth = RV.azimuth(quaternionLokal, quaternionHeck)
            steuer = vector.new(pitch, roll, coll)

            -- Bestätigung: Primär hat Sekundär gefunden
            if not verbindungBestaetigt then
                print("[ERFOLG] PRIMÄR: Verbindung zum SEKUNDÄR hergestellt! (Kanal " .. cfg.channel .. ")")
                verbindungBestaetigt = true
            end

            print("Azimuth: " .. azimuth)
        end

    elseif cfg.level == "sekundar" then
        local quaternionHeck = ship.getQuaternion()
        modem.transmit(cfg.channel, cfg.channel, quaternionHeck)

        local event, side, channel, replyChannel, quaternion, dist = os.pullEvent("modem_message")
        if channel == cfg.channel then
            azimuth = RV.azimuth(quaternion, quaternionHeck)
            steuer = vector.new(0, 0, yaw)

            -- Bestätigung: Sekundär hat Primär gefunden
            if not verbindungBestaetigt then
                print("[ERFOLG] SEKUNDÄR: Verbindung zum PRIMÄR empfangen! (Kanal " .. cfg.channel .. ")")
                verbindungBestaetigt = true
            end
        end
    end

    for idx, seite in ipairs(rotorSeiten) do
        RV.setzeRotor(seite, azimuth, steuer)
    end
    sleep(0.01)
end
