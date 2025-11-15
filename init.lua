-- update-all
local LIBS = {
    {file = "startup.lua",  save = "mylib"},
    {file = "libaries/config.lua",  save = "utils"},
    {file = "libaries/rotor.lua", save = "config"},
    {file = "libaries/vektor.lua", save = "config"},
}

local REPO = "al_xnd_r/cc-my-library"
local BRANCH = "main"

for _, lib in ipairs(LIBS) do
    local url = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/" .. lib.file
    print("Lade " .. lib.file .. "...")

    if fs.exists(lib.save) then fs.delete(lib.save) end

    local ok = pcall(shell.run, "wget", url, lib.save)
    if ok then
        print("  ✓ " .. lib.file)
    else
        print("  ✗ Fehler bei " .. lib.file)
    end
end

print("Alle Libraries aktualisiert!")
