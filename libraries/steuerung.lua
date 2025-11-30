-- libraries/steuerung.lua
local steuerung = {}

local VR = require("libraries/vektor")
local RV = require("libraries/rotor")

-- PID-Controller Klasse (bleibt unverändert)
function steuerung.new(Kp, Ki, Kd, integralLimit, outputLimit)
    local self = {
        Kp = Kp or 1,
        Ki = Ki or 0,
        Kd = Kd or 0,
        integralLimit = integralLimit or 50,     -- Anti-Windup
        outputLimit   = outputLimit or nil,      -- optional: max Ausgang
        integral = 0,
        lastError = 0,
        lastTime = os.clock()
    }
    return setmetatable(self, {__index = steuerung})
end

-- Aufruf: pid:calculate(soll, ist) → Ausgang
function steuerung:errechne(soll, ist)
    local now = os.clock()
    local dt = now - self.lastTime
    if dt <= 0 then return 0 end
    self.lastTime = now
    local error = soll - ist
    self.integral = self.integral + error * dt
    -- Anti-Windup
    if self.integralLimit then
        self.integral = math.max(-self.integralLimit, math.min(self.integralLimit, self.integral))
    end
    local derivative = (error - self.lastError) / dt
    self.lastError = error
    local output = self.Kp * error + self.Ki * self.integral + self.Kd * derivative
    if self.outputLimit then
        output = math.max(-self.outputLimit, math.min(self.outputLimit, output))
    end
    return output end

function steuerung:ursprung()
    self.integral = 0
    self.lastError = 0
    self.lastTime = os.clock()
end

return steuerung
