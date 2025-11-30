-- libraries/steuer.lua
local PID = require("libraries/steuerung")
local VR = require("libraries/vektor")

-- Neue Erweiterung: Controller-Instanz für Schiffsteuerung erstellen
function erstelleSteuer(rolle)
    local steuer = {}
    if rolle == "primar" then 
        steuer.target = { pitch = 0, roll = 0, coll = 0, yaw = 0 }
        steuer.pids = {
            pitch = PID.new(),
            roll = PID.new(),
            coll = PID.new()
        }
        -- Methode: Nur Yaw setzen
        function steuer:definiere_yaw(y)
            self.target.yaw = y or 0 end
        -- Methode: Nur Collective setzen
        function steuer:definiere_coll(c)
            self.target.coll = c or 0 end
        -- Methode: Nur Roll setzen
        function steuer:definiere_roll(r)
            self.target.roll = r or 0 end
        function steuer:aktualisiere()
            local omega = VR.lokaleWinkelGeschwindigkeit()  -- Lokale Winkelgeschwindigkeit (ship.getOmega())
            local vel = VR.lokaleLinearGeschwindigkeit()    -- Lokale Lineargeschwindigkeit (ship.getVelocity())
            local mass = ship.getMass()                     -- Schiffmasse für Skalierung
            local scale = mass * 10                         -- Skalierungsfaktor (anpassen für realistisches Verhalten; *10 als Beispiel für Torque)
            local out_pitch = 0
            local out_roll = 0
            local out_coll = 0
            -- Primär: Pitch (Torque X), Roll (Torque Z), Collective (Force Y)
            out_pitch = self.pids.pitch:errechne(self.target.pitch, omega.x)
            out_roll  = self.pids.roll:errechne( self.target.roll, omega.z)
            out_coll  = self.pids.coll:errechne( self.target.coll, vel.y)
            -- Kräfte/Torques anwenden (rotationsabhängig für lokale Koordinaten)
            ship.applyRotDependentTorque(out_pitch * scale, 0, out_roll * scale)
            
            ship.applyInvariantForce(0, out_coll * mass, 0)  -- Force skaliert nur mit Masse (für Beschleunigung)
            -- Pseudo-Rotoren setzen (visuelle Anpassung basierend auf PID-Ausgaben)
            -- RV.steuern(out_pitch, out_roll, out_coll, out_yaw)
        end
    end
    if rolle == "sekundar" then 
        steuer.target = { yaw = 0 }
        steuer.pids = {
            yaw = PID.new()
        }
        -- Methode: Nur Pitch setzen (angenommen "p" steht für Pitch)
        function steuer:definiere_pitch(p)
            self.target.pitch = p or 0 end
            -- Update-Methode: Berechnet PID-Ausgaben, wendet Kräfte/Torques an und setzt Rotoren pseudo-mäßig
        function steuer:aktualisiere()
            local omega = VR.lokaleWinkelGeschwindigkeit()  -- Lokale Winkelgeschwindigkeit (ship.getOmega())
            local vel = VR.lokaleLinearGeschwindigkeit()    -- Lokale Lineargeschwindigkeit (ship.getVelocity())
            local mass = ship.getMass()                     -- Schiffmasse für Skalierung
            local scale = mass * 10
            local out_yaw = 0
            -- Sekundär: Yaw (Torque Y)
            out_yaw = self.pids.yaw:errechne(self.target.yaw, omega.y)
            -- Torque anwenden
            ship.applyInvariantForce(0,out_yaw * scale,0)
            -- ship.applyRotDependentTorque(vector.new(0, out_yaw * scale, 0))
            -- Für Pseudo-Rotoren: Collective als Yaw-Ausgabe behandeln
            out_coll = out_yaw
            -- Pseudo-Rotoren setzen (visuelle Anpassung basierend auf PID-Ausgaben)
            -- RV.steuern(out_pitch, out_roll, out_coll, out_yaw)
        end
    end
    return steuer
end

return {
    erstelleSteuer = erstelleSteuer
}
