-- libraries/config.lua
local config = {}

-- ==== 1. Konfiguration ====================================================
local CONFIG_FILE = "config.json"

-- Standard-Konfiguration
local defaultConfig = {
    modem = "top",
    channel = 420,
    rotors = {"front", "right", "back", "left"},
    level = "primar"
}

-- JSON Hilfsfunktionen
local function jsonEncode(data)
    return textutils.serialiseJSON(data)
end

local function jsonDecode(str)
    local ok, result = pcall(textutils.unserialiseJSON, str)
    if ok and type(result) == "table" then
        return result
    else
        return nil, "Ungültiges JSON"
    end
end

-- ==== 2. Config laden & validieren ========================================
function config.loadConfig()
    local cfg = {
        modem = defaultConfig.modem,
        channel = defaultConfig.channel,
        rotors = {}
    }

    -- 1. Existiert die Datei?
    if not fs.exists(CONFIG_FILE) then
        print("[INFO] " .. CONFIG_FILE .. " nicht gefunden → erstelle Default")
        local file = fs.open(CONFIG_FILE, "w")
        if not file then
            error("Kann " .. CONFIG_FILE .. " nicht erstellen!")
        end
        file.write(jsonEncode(defaultConfig))
        file.close()

        cfg.modem = defaultConfig.modem
        cfg.channel = defaultConfig.channel
        cfg.rotors = defaultConfig.rotors
        return cfg
    end

    -- 2. Datei lesen
    local file = fs.open(CONFIG_FILE, "r")
    if not file then
        error("Kann " .. CONFIG_FILE .. " nicht öffnen!")
    end
    local content = file.readAll()
    file.close()

    -- 3. JSON parsen
    local data, err = jsonDecode(content)
    if not data then
        error("Ungültiges JSON in " .. CONFIG_FILE .. ": " .. (err or "unbekannt"))
    end

    -- 4. Modem validieren
    if type(data.modem) == "string" and peripheral.getType(data.modem) == "modem" then
        cfg.modem = data.modem
    else
        print("[WARN] Ungültiges Modem '" .. tostring(data.modem) .. "' → nutze '" .. defaultConfig.modem .. "'")
        cfg.modem = defaultConfig.modem
    end

    -- 5. Channel validieren (0–65535)
    local channel = data.channel
    if type(channel) == "number" and channel >= 0 and channel <= 65535 and math.floor(channel) == channel then
        cfg.channel = channel
    else
        print("[WARN] Ungültiger Channel '" .. tostring(channel) .. "' → nutze " .. defaultConfig.channel)
        cfg.channel = defaultConfig.channel
    end

    -- 6. Rotoren validieren
    if type(data.rotors) == "table" then
        local validRotors = {}
        for _, name in ipairs(data.rotors) do table.insert(validRotors, name) end
        if #validRotors > 0 then cfg.rotors = validRotors
        else error("Keine gültigen Rotoren in config.json gefunden!") end
    else error("rotors fehlt oder ist kein Array in config.json!") end
    
    -- 7. Level validieren
    if type(data.level) == "table" then cfg.level = data.level end

    return cfg
end

return config

