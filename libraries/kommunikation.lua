-- libraries/kommunikation
local kommunikation = {}

local function primarKommunikation(message)
    if message.variant == "sekundar" then 
        return ship.getQuaternion(),message.quaternionHeck end
end

local function sekundarKommunikation(message)
    if message.variant == "primar" then 
        return message.quaternionHaupt,ship.getQuaternion() end
end

-- Interpretiert die Kommuniaktion zwischen haupt & Heck
function kommunikation.interpretiereKommunikation(message,level,status)
	if level == "primar" then 
        if not status.verbindung then
            print("[VERBUNDEN] Heckrotor gefunden! (Kanal " .. status.channel .. ")")
            status.verbindung = true end
        return sekundarKommunikation(message) end
	if level == "sekundar" then 
        if not status.verbindung then
            print("[VERBUNDEN] Hauptrotor gefunden! (Kanal " .. status.channel .. ")")
            status.verbindung = true end
        return primarKommunikation(message) end
end

-- Interpretiert die Steurungsnachricht
function kommunikation.interpretiereSteuerung(message,level,wert)
    if message.variant == "steurung" then
        if level == "primar" then
            wert.steurung = vector.new(message.pitch,message.roll,message.coll) end
    	if level == "sekundar" then 
            wert.steurung = vector.new(0,0,message.yaw) end
    end
end

local function erhaltePrimarNachricht()
    return {
        variant = "primar",
        quaternionHaupt = ship.getQuaternion()
    } end

local function erhalteSekundarNachricht()
    return {
        variant = "sekundar",
        quaternionHeck = ship.getQuaternion()
    } end
   
-- Gibt die Kommunikation für Haupt & Heck aus
function kommunikation.erhalteNachricht(level)
    if level == "primar" then return erhaltePrimarNachricht() end 
    if level == "sekundar" then return erhalteSekundarNachricht() end
end
 
-- Verschickt die entsprechende Nachricht
function kommunikation.sendeKommunikation(modem,cfg,message)
    if message then modem.transmit(cfg.channel,cfg.channel,message)
    else modem.transmit(cfg.channel,cfg.channel,kommunikation.erhalteNachricht(cfg.level)) end
end

return kommunikation
    
