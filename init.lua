-- update-all  (speichere als Datei "update-all")

local LIBS = {
    {file = "libraries/config", type = "lua"},   -- Ordner libraries → libraries
    {file = "libraries/rotor", type = "lua"},
    {file = "libraries/vektor", type = "lua"},
    {file = "startup", type = "lua"}
    -- falls du noch startup.lua oder andere willst, einfach hinzufügen
}

local REPO   = "TeutonStudio/CC-HeliRotoren"   -- korrekter Repo-Name
local BRANCH = "main"

for _, lib in ipairs(LIBS) do
    local url = ("https://raw.githubusercontent.com/%s/%s/%s.%s"):format(REPO, BRANCH, lib.file, lib.type)
    
    print("Lade " .. lib.file .. "...")

    -- Alte Datei löschen (falls vorhanden)
    if fs.exists(lib.file) then fs.delete(lib.file) end

    -- Pfad für Ordner anlegen, falls nicht vorhanden
    local dir = fs.getDir(lib.file)
    if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir)end

    -- Download
    local ok, err = pcall(shell.run, "wget", url, lib.file.."."..lib.type)

    if ok then
        print("  ✓ " .. lib.file .. " → " .. lib.file)
    else
        print("  ✗ Fehler bei " .. lib.file)
        print("    URL war: " .. url)
    end
end

print("\nFertig! Alle Dateien aktualisiert.")
