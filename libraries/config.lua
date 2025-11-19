-- libraries/config.lua
local config = {}

-- ==== 1. Konfiguration ====================================================
local CONFIG_FILE = "config.json"

-- Standard-Konfiguration
local defaultConfig = {
    channel = 69,
    rolle = "primar"
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
        channel = defaultConfig.channel,
        rolle = defaultConfig.rolle,
        modem = "",
        rotoren = {}
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

        cfg.channel = defaultConfig.channel
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

    -- 4. Rolle validieren
    if type(data.rolle) == "string" then cfg.rolle = data.rolle end
    local isPrimar = data.rolle == "primar"

    -- 5. Modem validieren
    cfg.modem = isPrimar and "top" or "front"

    -- 6. Channel validieren (0–65535)
    local channel = data.channel
    if type(channel) == "number" and channel >= 0 and channel <= 65535 and math.floor(channel) == channel then
        cfg.channel = channel
    else
        print("[WARN] Ungültiger Channel '" .. tostring(channel) .. "' → nutze " .. defaultConfig.channel)
        cfg.channel = defaultConfig.channel
    end

    -- 7. Rotoren validieren
    cfg.rotoren = isPrimar and {"front", "right", "back", "left"} or {"top", "right", "bottom", "left"}
    
    return cfg
end

return config

