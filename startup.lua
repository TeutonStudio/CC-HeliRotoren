local CFGV = require("libraries/config")
-- local KV = require("libraries/kommunikation")
-- local RV = require("libraries/rotor")
-- local PID   = require("libraries/steuerung")
-- local SV = require("libraries/steuer")

local function identifiziereModem(config)
    print("[INFO] Starte Rotor-Steuerung auf Kanal: " .. config.channel)
    print("[INFO] Rotoren: " .. table.concat(config.rotoren, ", "))
    local modem = peripheral.wrap(config.modem)
    --if not modem then error(keinModem(config.modem)) end
    if not modem.isOpen(config.channel) then
        modem.open(config.channel) end
    config.modem = modem
end

local cfg = CFGV.loadConfig()
identifiziereModem(cfg)

local delta = .02
local steuerung = {
    pitch = 0,
    roll  = 0,
    coll  = 0,
    yaw   = 0

}

local function empfangeSteuerung()
    while true do
        local event, seite, channel, replyChannel, nachricht, distanz = os.pullEvent("modem_message")
        if channel == cfg.channel and nachricht.sender == "steuerung" then
            if cfg.rolle == "primar" then
                if nachricht.pitch then
                    steuerung.pitch = nachricht.pitch end
                if nachricht.roll then
                    steuerung.roll = nachricht.roll end
                if nachricht.coll then
                    steuerung.coll = nachricht.coll end
            elseif cfg.rolle == "sekundar" then
                if nachricht.yaw then
                    steuerung.yaw = nachricht.yaw end
            end
        end end
end

local function aktualisiere(_delta)
    while true do
        print(steuerung.pitch, steuerung.roll, steuerung.coll, steuerung.yaw)
        if cfg.rolle == "primar" then
            ship.applyRotDependentTorque(steuerung.pitch * ship.getMass(),0,steuerung.roll * ship.getMass())
            ship.applyInvariantForce(0,steuerung.coll * ship.getMass(),0) end
        if cfg.rolle == "sekundar" then
            ship.applyInvariantForce(steuerung.yaw * ship.getMass(),0,0) end
        sleep(_delta) end
end

parallel.waitForAny(
    function() empfangeSteuerung() end,
    function() aktualisiere(delta) end
)
