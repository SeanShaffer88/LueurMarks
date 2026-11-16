local addonName, ns = ...
ns = ns or _G.LueurMarks

ns:RegisterModule("loot", function(unit)
  if not UnitExists(unit) or not UnitIsDead or not UnitIsDead(unit) then return end
  if not UnitIsPlayer(unit) and UnitIsLootable and UnitIsLootable(unit) then
    return { icon = "Interface/Buttons/Button-Backpack-Up", tooltip = "Lootable" }
  end
end, 20)
