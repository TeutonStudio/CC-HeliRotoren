-- update-all
local LIBS = {
    {file = "startup.lua",  save = "mylib"},
    {file = "libaries/config.lua",  save = "utils"},
    {file = "libaries/rotor.lua", save = "config"},
    {file = "libaries/vektor.lua", save = "config"}
}

local REPO = "al_xnd_r/cc-my-library"
local BRANCH = "main"

for idx, lib in ipairs(LIBS) do
    local url = "https://github.com/TeutonStudio/CC-HeliRotoren/blob/main/" .. lib
    print("Lade " .. lib.file .. "...")

    if fs.exists(lib.file) then fs.delete(lib.file) end

    if pcall(shell.run, "wget", url, lib.file) then print("  ✓ " .. lib.file)
    else print("  ✗ Fehler bei " .. lib.file) end
end

print("Alle Libraries aktualisiert!")
