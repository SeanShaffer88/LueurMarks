local addonName, ns = ...
ns = ns or _G.LueurMarks

-- APIs cannot reliably identify every service from an arbitrary soft target.
-- Use current merchant capability when the interaction window is open, and
-- allow data providers to add NPC IDs below as needed.
local repairNPCs = {}
local anvilNPCs = {}
ns.serviceNPCs = { repair = repairNPCs, anvil = anvilNPCs }

local function npcID(guid)
  if type(guid) ~= "string" then return nil end
  local _, _, _, _, _, id = strsplit("-", guid)
  return tonumber(id)
end

ns:RegisterModule("service", function(unit, guid)
  local id = npcID(guid)
  if id and repairNPCs[id] then
    return { icon = "Interface/Trade_BlackSmithing", tooltip = "Repair" }
  end
  if id and anvilNPCs[id] then
    return { icon = "Interface/Icons/INV_Misc_StoneTablet_05", tooltip = "Anvil" }
  end
  if UnitExists(unit) and UnitIsMerchant and UnitIsMerchant(unit) then
    return { icon = "Interface/Trade_BlackSmithing", tooltip = "Vendor" }
  end
end, 30)
