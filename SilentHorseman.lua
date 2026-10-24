-- Silent Horseman: two independent options, mute the Horseman's voice lines and hide his chat yells.
-- /sh opens the options; /sh audio on|off and /sh chat on|off change them from chat.

local ADDON = ...
local DB

-- Voice files of the Headless Horseman (community listfile: sound/creature/headlesshorseman, headless horseman and
-- the_headless_horseman). Muting an ID the client does not have does nothing.
local SOUND_IDS = {
    551670, 551671, 551672, 551673, 551674, 551675,
    551676, 551677, 551678, 551679, 551680, 551681,
    551682, 551683, 551684, 551685, 551686, 551687,
    551688, 551689, 551690, 551691, 551692, 551693,
    551694, 551695, 551696, 551697, 551698, 551699,
    551700, 551701, 551702, 551703, 551704, 551705,
    551706, 768819, 768821, 768823, 768825, 768827,
    768829, 768831, 770235, 770237, 770239, 770241,
    770243, 770245,
}

-- Matches "Headless Horseman" and "Shade of the Horseman", the one that yells in the zone during Hallow's End.
local SPEAKER = "Horseman"
local CHAT_EVENTS = { "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_EMOTE" }

local function Print(msg)
    print("|cffff8000Silent Horseman:|r " .. msg)
end

---------------------------------------------------------------- Audio
local muted = false
local function ApplyAudio()
    local want = DB.audio and true or false
    if want == muted then
        return
    end
    for _, id in ipairs(SOUND_IDS) do
        if want then
            MuteSoundFile(id)
        else
            UnmuteSoundFile(id)
        end
    end
    muted = want
end

---------------------------------------------------------------- Chat
local function IsHorseman(sender)
    return type(sender) == "string" and sender:find(SPEAKER, 1, true) ~= nil
end

local function ChatFilter(_, _, _, sender)
    if DB and DB.chat and IsHorseman(sender) then
        return true
    end
end

for _, event in ipairs(CHAT_EVENTS) do
    ChatFrame_AddMessageEventFilter(event, ChatFilter)
end

-- /sh debug on: one line per NPC yell, say or emote (and boss emote) seen, so the real event name, the speaker's
-- name, whether the filter hid it and the gap since that speaker's last line can be read even with the text hidden.
local DEBUG_EVENTS = { "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_EMOTE",
    "CHAT_MSG_RAID_BOSS_EMOTE", "CHAT_MSG_RAID_BOSS_WHISPER" }
local lastSeen = {}
local debugFrame = CreateFrame("Frame")
debugFrame:SetScript("OnEvent", function(_, event, text, sender)
    if not (DB and DB.debug) then
        return
    end
    local now = GetTime()
    local who = tostring(sender)
    local gap = lastSeen[who] and ("%d s since the last"):format(now - lastSeen[who]) or "first seen"
    lastSeen[who] = now
    local hidden = DB.chat and IsHorseman(sender)
    Print(("%s from '%s' (%s, %s): %s"):format(event:gsub("^CHAT_MSG_", ""), who, hidden and "hidden" or "shown", gap,
        tostring(text):sub(1, 50)))
end)

---------------------------------------------------------------- Options
local panel = CreateFrame("Frame")
panel.name = "Silent Horseman"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Silent Horseman")

local function CheckBox(key, label, note, y)
    local box = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    box:SetPoint("TOPLEFT", 16, y)
    local text = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("LEFT", box, "RIGHT", 4, 0)
    text:SetText(label)
    local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 30, 2)
    sub:SetText(note)
    box:SetScript("OnClick", function(self)
        DB[key] = self:GetChecked() and true or false
        ApplyAudio()
    end)
    box.key = key
    return box
end

local audioBox = CheckBox("audio", "Mute his voice lines", "Silences every Headless Horseman voice file, including the boss fight.", -50)
local chatBox = CheckBox("chat", "Hide his chat text", "Hides his yells, says and emotes from every chat window.", -110)

panel:SetScript("OnShow", function()
    audioBox:SetChecked(DB.audio)
    chatBox:SetChecked(DB.chat)
end)

local category
if Settings and Settings.RegisterCanvasLayoutCategory then
    category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
end

local function OpenOptions()
    if category and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(category:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end

---------------------------------------------------------------- Slash command
local function Status()
    Print(("voice lines %s, chat text %s, debug %s. /sh audio on|off, /sh chat on|off, /sh debug on|off, /sh opens the options."):format(
        DB.audio and "muted" or "audible", DB.chat and "hidden" or "shown", DB.debug and "on" or "off"))
end

SLASH_SILENTHORSEMAN1, SLASH_SILENTHORSEMAN2 = "/sh", "/silenthorseman"
SlashCmdList.SILENTHORSEMAN = function(msg)
    local key, arg = strsplit(" ", strlower(strtrim(msg or "")))
    if (key == "audio" or key == "chat" or key == "debug") and (arg == "on" or arg == "off") then
        DB[key] = arg == "on"
        ApplyAudio()
        Status()
    elseif key == "status" then
        Status()
    else
        OpenOptions()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, _, name)
    if name ~= ADDON then
        return
    end
    SilentHorsemanDB = SilentHorsemanDB or { audio = true, chat = true }
    DB = SilentHorsemanDB
    ApplyAudio()
    for _, event in ipairs(DEBUG_EVENTS) do
        debugFrame:RegisterEvent(event)
    end
    self:UnregisterEvent("ADDON_LOADED")
end)
