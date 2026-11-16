local addonName, ns = ...
ns = ns or _G.LueurMarks

-- Quest state is detected from the Blizzard quest/gossip UI APIs. These APIs
-- deliberately run only while a soft-target unit is present.
ns:RegisterModule("quest", function(unit)
  if not UnitExists(unit) or not UnitIsQuestGiver or not UnitIsQuestGiver(unit) then return end

  local available, completable = false, false
  if C_GossipInfo and C_GossipInfo.GetAvailableQuests then
    local quests = C_GossipInfo.GetAvailableQuests() or {}
    available = #quests > 0
  end
  if C_GossipInfo and C_GossipInfo.GetActiveQuests then
    local quests = C_GossipInfo.GetActiveQuests() or {}
    for _, quest in ipairs(quests) do
      if quest.isComplete then completable = true; break end
    end
  end
  if available then
    return { icon = "Interface/GossipFrame/AvailableQuestIcon", tooltip = "Starts a quest" }
  elseif completable then
    return { icon = "Interface/GossipFrame/ActiveQuestIcon", tooltip = "Quest ready to turn in" }
  end
end, 10)
