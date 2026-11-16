local addonName, ns = ...
ns = ns or {}
_G.LueurMarks = ns

local defaults = {
  enabled = true,
  iconSize = 18,
  offsetX = 4,
  offsetY = 0,
  showLabels = false,
}
local modules = {}
ns.modules = modules

local function mergeDefaults(target, source)
  for key, value in pairs(source) do
    if type(value) == "table" then
      if type(target[key]) ~= "table" then target[key] = {} end
      mergeDefaults(target[key], value)
    elseif target[key] == nil then
      target[key] = value
    end
  end
end

function ns:RegisterModule(name, callback, priority)
  modules[name] = { callback = callback, priority = priority or 100 }
end

function ns:GetSettings()
  return LueurMarksDB
end

local function createIcon()
  local frame = CreateFrame("Frame", "LueurMarksOverlay", UIParent)
  frame:SetFrameStrata("TOOLTIP")
  frame:SetSize(18, 18)
  frame:Hide()

  frame.texture = frame:CreateTexture(nil, "OVERLAY")
  frame.texture:SetAllPoints()
  frame.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

  frame.border = frame:CreateTexture(nil, "OVERLAY", nil, 1)
  frame.border:SetTexture("Interface/Buttons/UI-ActionButton-Border")
  frame.border:SetBlendMode("ADD")
  frame.border:SetPoint("CENTER")
  frame.border:SetSize(26, 26)
  frame.border:Hide()
  frame:EnableMouse(true)
  frame:SetScript("OnEnter", function(self)
    if self.tooltipText then
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(self.tooltipText, 1, 1, 1, true)
      GameTooltip:Show()
    end
  end)
  frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
  return frame
end

local overlay
local function findSoftTargetFrame()
  -- Lueur may expose its soft-target frame under a known global. Prefer that
  -- when present; Blizzard's own frame is the safe fallback.
  return _G.LueurSoftTargetFrame or _G.SoftTargetFrame or _G.SoftTargetFrameContainer
end

local function update()
  if not overlay then return end
  local settings = LueurMarksDB
  if not settings.enabled then overlay:Hide(); return end

  local targetFrame = findSoftTargetFrame()
  local unit = "softtarget"
  if not UnitExists(unit) then unit = "softtargetinteract" end
  if not targetFrame or not targetFrame:IsShown() or not UnitExists(unit) then
    overlay:Hide()
    return
  end

  local guid = UnitGUID(unit)
  local ordered = {}
  for name, module in pairs(modules) do
    ordered[#ordered + 1] = { name = name, module = module }
  end
  table.sort(ordered, function(a, b)
    if a.module.priority == b.module.priority then return a.name < b.name end
    return a.module.priority < b.module.priority
  end)

  local context
  for _, entry in ipairs(ordered) do
    local result = entry.module.callback(unit, guid)
    if result then
      context = result
      break
    end
  end
  if not context or not context.icon then overlay:Hide(); return end

  overlay:SetSize(settings.iconSize or defaults.iconSize, settings.iconSize or defaults.iconSize)
  overlay:ClearAllPoints()
  overlay:SetPoint("LEFT", targetFrame, "RIGHT", settings.offsetX or 4, settings.offsetY or 0)
  if context.atlas and overlay.texture.SetAtlas then
    overlay.texture:SetAtlas(context.atlas)
  else
    overlay.texture:SetTexture(context.icon)
  end
  overlay.tooltipText = context.tooltip
  overlay:SetParent(targetFrame)
  overlay:SetFrameStrata("TOOLTIP")
  overlay:Show()
end

local driver = CreateFrame("Frame")
driver:RegisterEvent("PLAYER_LOGIN")
driver:RegisterEvent("PLAYER_TARGET_CHANGED")
driver:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
driver:RegisterEvent("QUEST_LOG_UPDATE")
driver:RegisterEvent("GOSSIP_SHOW")
driver:RegisterEvent("MERCHANT_SHOW")
driver:RegisterEvent("BAG_UPDATE_DELAYED")
driver:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then
    LueurMarksDB = LueurMarksDB or {}
    mergeDefaults(LueurMarksDB, defaults)
    overlay = createIcon()
    if C_Timer and C_Timer.After then C_Timer.After(0, update) end
  else
    update()
  end
end)

driver:SetScript("OnUpdate", function(_, elapsed)
  driver.elapsed = (driver.elapsed or 0) + elapsed
  if driver.elapsed >= 0.12 then
    driver.elapsed = 0
    update()
  end
end)

SLASH_LUEURMARKS1 = "/lueurmarks"
SlashCmdList.LUEURMARKS = function(message)
  local cmd, value = (message or ""):match("^(%S*)%s*(.-)$")
  if cmd == "size" then
    local size = tonumber(value)
    if size then LueurMarksDB.iconSize = math.max(10, math.min(36, size)) end
  elseif cmd == "toggle" then
    LueurMarksDB.enabled = not LueurMarksDB.enabled
  elseif cmd == "offset" then
    local x, y = value:match("^(%-?%d+)%s+(%-?%d+)$")
    if x then LueurMarksDB.offsetX, LueurMarksDB.offsetY = tonumber(x), tonumber(y) end
  else
    print("LueurMarks: /lueurmarks toggle | size <10-36> | offset <x> <y>")
    print("LueurMarks currently " .. (LueurMarksDB.enabled and "enabled" or "disabled") .. ".")
  end
  update()
end
