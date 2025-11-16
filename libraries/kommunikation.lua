local kommunikation = {}

-- Empfang: Primär <-> Sekundär
function kommunikation.interpretiereKommunikation(message, level, status)
    if level == "primar" and message.variant == "sekundar" then
        if not status.verbindung then
            print("[VERBUNDEN] Heckrotor gefunden! (Kanal " .. status.channel .. ")")
            status.verbindung = true
        end
        return message.quaternionHeck, ship.getQuaternion()  -- Heck, Haupt
    elseif level == "sekundar" and message.variant == "primar" then
        if not status.verbindung then
            print("[VERBUNDEN] Hauptrotor gefunden! (Kanal " .. status.channel .. ")")
            status.verbindung = true
        end
        return ship.getQuaternion(), message.quaternionHaupt  -- Haupt, Heck
    end
    return nil, nil
end

-- Steuerung mit Rückgabe
function kommunikation.interpretiereSteuerung(message, level, wert)
    if message.variant == "steurung" then
        if level == "primar" then
            return vector.new(message.pitch or 0, message.roll or 0, message.coll or 0)
        elseif level == "sekundar" then
            return vector.new(0, 0, message.yaw or 0)
        end
    end
    return nil
end

-- Nachrichten generieren
function kommunikation.erhalteNachricht(level)
    if level == "primar" then
        return { variant = "primar", quaternionHaupt = ship.getQuaternion() }
    elseif level == "sekundar" then
        return { variant = "sekundar", quaternionHeck = ship.getQuaternion() }
    end
end

-- Senden
function kommunikation.sendeKommunikation(modem, cfg, message)
    local msg = message or kommunikation.erhalteNachricht(cfg.level)
    modem.transmit(cfg.channel, cfg.channel, msg)
end

return kommunikation
