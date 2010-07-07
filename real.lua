local mediaPath = "Interface\\AddOns\\oUF_Real\\media\\"
local texture = [=[Interface\ChatFrame\ChatFrameBackground]=]
local square = mediaPath.."Square"
local arrow = {
	[1] = mediaPath.."Arrow",
	[2] = mediaPath.."Arrow2",
	[3] = mediaPath.."Arrow3",
}
local font = {
	[1] = mediaPath.."myriad.ttf",
--	[2] = mediaPath.."CalibriBold.ttf",
	[3] = mediaPath.."Republika.ttf",
	[4] = mediaPath.."Expressway.ttf",
}
	
local height, width = 3, 275
local scale = 1.0

local siValue = function(val)
	if (val >= 1e6) then
		return ("%.1fm"):format(val / 1e6)
	elseif (val >= 1e3) then
		return ("%.1fk"):format(val / 1e3)
	else
		return ("%d"):format(val)
	end
end

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = -1, left = -1, bottom = -1, right = -1},
}

local backbackdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = -1.5, left = -1.5, bottom = -1.5, right = -1.5},
}

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("^%l", string.upper)

	if(cunit == 'Vehicle') then
		cunit = 'Pet'
	end

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

local xp = function(self)
	local unit = self.unit
	
	if UnitLevel('player') ~= MAX_PLAYER_LEVEL then
		local min, max = UnitXP(unit), UnitXPMax(unit)
		local per = math.floor(min/max*100+.5)
			
		self.xp:SetText(siValue(min).."/"..siValue(max).." - "..per.."%")
	else
		self.xp:SetText(nil)
	end
end

local fader = function(self)
	local unit = self.unit
	
	if(UnitAffectingCombat(unit)) or (UnitExists(unit..'target')) or (UnitHealth(unit) < UnitHealthMax(unit)) then
		self:SetAlpha(1)
	else
		self:SetAlpha(0.25)
	end
end

local fixStatusbar = function(bar)
	bar:GetStatusBarTexture():SetHorizTile(false)
	bar:GetStatusBarTexture():SetVertTile(false)
end

local updateHealth = function(health, unit, min, max)
	local per = math.floor(min/max*100+.5)
	
	health.hpper:SetText(per.."%")
	
	if per < 20 then
		health.arrow:SetVertexColor(1,0,0)
		health.hpper:SetTextColor(1,0,0)
	elseif per < 50 then
		health.arrow:SetVertexColor(1,.3,0)
		health.hpper:SetTextColor(1,.3,0)
	elseif per < 70 then
		health.arrow:SetVertexColor(1,.8,0)
		health.hpper:SetTextColor(1,.8,0)
	else
		health.arrow:SetVertexColor(1,1,1)
		health.hpper:SetTextColor(1,1,1)
	end
	
	if unit == "target" or unit == "focus" then
		health:SetValue(max - min)
		health.arrow:SetPoint("BOTTOM", health, "RIGHT", -(min / max * health:GetWidth()), -5)
	else
		health.arrow:SetPoint("BOTTOM", health, "LEFT", (min / max * health:GetWidth()), -5)
	end
end

local updatePower = function(power, unit, min, max)
	if UnitPower(unit) == 0 then
		power.val:SetText(nil) return
	end
	
	if unit == "target" or unit == "focus" then
		power:SetValue(max - min)
		power.arrow:SetPoint("TOP", power, "RIGHT", -(min / max * power:GetWidth()), -1)
	else
		power.arrow:SetPoint("TOP", power, "LEFT", (min / max * power:GetWidth()), -1)
	end
end

local fixTex = function(tex)
	local ULx,ULy,LLx,LLy,URx,URy,LRx,LRy = tex:GetTexCoord()
	tex:SetTexCoord(ULy,ULx,LLy,LLx,URy,URx,LRy,LRx)
end

local fixTex2 = function(tex)
	local ULx,ULy,LLx,LLy,URx,URy,LRx,LRy = tex:GetTexCoord()
	tex:SetTexCoord(LLx,LLy,ULx,ULy,LRx,LRy,URx,URy)
end

local function hex(r, g, b)
	if(type(r) == 'table') then
		if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

local colors = setmetatable({
	power = setmetatable({
		['MANA'] = {.31,.45,.63},
		['RAGE'] = {.69,.31,.31},
		['FOCUS'] = {.71,.43,.27},
		['ENERGY'] = {.65,.63,.35},
		['RUNIC_POWER'] = {0,.8,.9},
		["AMMOSLOT"] = {0.8,0.6,0},
		["FUEL"] = {0,0.55,0.5},
		["POWER_TYPE_STEAM"] = {0.55,0.57,0.61},
		["POWER_TYPE_PYRITE"] = {0.60,0.09,0.17},
		["POWER_TYPE_HEAT"] = {0.55,0.57,0.61},
		["POWER_TYPE_OOZE"] = {0.75686281919479,1,0},
		["POWER_TYPE_BLOOD_POWER"] = {0.73725494556129,0,1},
	}, {__index = oUF.colors.power}),
}, {__index = oUF.colors})

oUF.Tags['real:hp']  = function(u) 
	local min = UnitHealth(u)
	return siValue(min)
end
oUF.TagEvents['real:hp'] = 'UNIT_HEALTH'

oUF.Tags['real:pp'] = function(u)
	local _, str = UnitPowerType(u)
	if str then
		return hex(colors.power[str])..siValue(UnitPower(u))
	end
end
oUF.TagEvents['real:pp'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER'

oUF.Tags['real:color'] = function(u, r)
	local _, class = UnitClass(u)
	local reaction = UnitReaction(u, "player")
	
	if (UnitIsTapped(u) and not UnitIsTappedByPlayer(u)) then
		return hex(oUF.colors.tapped)
	elseif (u == "pet") and GetPetHappiness() then
		return hex(oUF.colors.happiness[GetPetHappiness()])
	elseif (UnitIsPlayer(u)) then
		return hex(oUF.colors.class[class])
	elseif reaction then
		return hex(oUF.colors.reaction[reaction])
	else
		return hex(1, 1, 1)
	end
end
oUF.TagEvents['real:color'] = 'UNIT_REACTION UNIT_HEALTH UNIT_HAPPINESS'

oUF.Tags['real:name'] = function(u, r)
	local name = UnitName(r or u) or "unknown"
	return name
end
oUF.TagEvents['real:name'] = 'UNIT_NAME_UPDATE'

oUF.Tags['real:lvl'] = function(u) 
	local level = UnitLevel(u)
	local typ = UnitClassification(u)
	local color = GetQuestDifficultyColor(level)
	
	if level <= 0 then
		level = "??" 
		color.r, color.g, color.b = 1, 0, 0
	end
	
	if typ=="rareelite" then
		return hex(color)..level..'r+'
	elseif typ=="elite" then
		return hex(color)..level..'+'
	elseif typ=="rare" then
		return hex(color)..level..'r'
	else
		return hex(color)..level
	end
end

local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		return format("%dm", floor(s/minute + 0.5)), s % minute
	end
	return floor(s + 0.5), (s * 100 - floor(s * 100))/100
end

local CreateAuraTimer = function(self,elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local atime = FormatTime(self.timeLeft)
				self.remaining:SetText(atime)
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

local auraIcon = function(auras, button)
	local count = button.count
	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT", 3, -3)
	count:SetFontObject(nil)
	count:SetFont(font[4], 12, "OUTLINE")
	
	auras.disableCooldown = true

	button.icon:SetTexCoord(.1, .9, .1, .9)
	
	button.bbg = CreateFrame("Frame", nil, button)
	button.bbg:SetAllPoints(button)
	button.bbg:SetFrameStrata("BACKGROUND")
	button.bbg:SetBackdrop(backbackdrop)
	button.bbg:SetBackdropColor(0, 0, 0)
	
	button.bg = CreateFrame("Frame", nil, button)
	button.bg:SetAllPoints(button)
	button.bg:SetFrameStrata("LOW")
	button.bg:SetBackdrop(backdrop)
	button.bg:SetBackdropColor(0, 0, 0)

	button.overlay:Hide()
	
	local remaining = button:CreateFontString(nil, "OVERLAY")
	remaining:SetPoint("TOPLEFT", -3, 2)
	remaining:SetFont(font[4], 12, "OUTLINE")
	remaining:SetTextColor(1, 1, 1)
	button.remaining = remaining
end

local debuffFilter = {
	[GetSpellInfo(7386)] = true, -- Sunder
}

local PostUpdateIcon
do
	local playerUnits = {
		player = true,
		pet = true,
		vehicle = true,
	}

	PostUpdateIcon = function(icons, unit, icon, index, offset)
		local name, _, _, _, dtype, duration, expirationTime, unitCaster = UnitAura(unit, index, icon.filter)
		
		local texture = icon.icon
		if playerUnits[icon.owner] or debuffFilter[name] or not UnitIsFriend('player', unit) and not icon.debuff or UnitIsFriend('player', unit) and icon.debuff then
			texture:SetDesaturated(false)
		else
			texture:SetDesaturated(true)
		end
		
		if duration and duration > 0 then
			icon.remaining:Show()
		else
			icon.remaining:Hide()
		end
		
		if icon.debuff then
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			icon.bbg:SetBackdropColor(color.r, color.g, color.b)
		else
			icon.bbg:SetBackdropColor(0, 0, 0)
		end
		
		icon.duration = duration
		icon.timeLeft = expirationTime
		icon.first = true
		icon:SetScript("OnUpdate", CreateAuraTimer)
	end
end

local UnitSpecific = {
	player = function(self)
		self.xp = self:CreateFontString(nil, "OVERLAY")
		self.xp:SetFont(font[4], 12)
		self.xp:SetShadowOffset(1.25, -1.25)
		self.xp:SetTextColor(0, .6, .9)
		self.xp:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -18)
		
		if UnitLevel('player') ~= MAX_PLAYER_LEVEL then
			self:RegisterEvent('PLAYER_XP_UPDATE', xp)
			self:RegisterEvent('PLAYER_LEVEL_UP', xp)
			xp(self)
		end
		
		local buffs = CreateFrame("Frame", nil, self)
		buffs:SetHeight(36)
		buffs:SetWidth(36*12)
		buffs.initialAnchor = "TOPRIGHT"
		buffs.spacing = 5
		buffs.num = 40
		buffs["growth-x"] = "LEFT"
		buffs["growth-y"] = "DOWN"
		buffs:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -20)
		buffs.size = 36
		
		buffs.PostCreateIcon = auraIcon
		buffs.PostUpdateIcon = PostUpdateIcon

		self.Buffs = buffs
		
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(48)
		debuffs:SetWidth(48*12)
		debuffs.initialAnchor = "TOPRIGHT"
		debuffs.spacing = 5
		debuffs.num = 6
		debuffs["growth-x"] = "LEFT"
		debuffs["growth-y"] = "DOWN"
		debuffs:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, -20)
		debuffs.size = 48
		
		debuffs.PostCreateIcon = auraIcon
		debuffs.PostUpdateIcon = PostUpdateIcon
		
		self.Debuffs = debuffs
		
		if self.Buffs then
			BuffFrame:Hide()
			TemporaryEnchantFrame:Hide()
		end
		
		self:RegisterEvent('PLAYER_REGEN_ENABLED', fader)
		self:RegisterEvent('PLAYER_REGEN_DISABLED', fader)
		self:RegisterEvent('UNIT_TARGET', fader)
		self:RegisterEvent('UNIT_HEALTH', fader)
		self:RegisterEvent('PLAYER_ENTERING_WORLD', fader)
		
		self:SetAttribute('initial-height', height+25)
		self:SetAttribute('initial-width', width)
		self:SetAttribute('initial-scale', scale)
	end,
		
	target = function(self)
	
		local auras = CreateFrame("Frame", nil, self)
		auras:SetHeight(28)
		auras:SetWidth(28*10)
		auras.initialAnchor = "TOPLEFT"
		auras.spacing = 5
		auras.gap = true
		auras.num = 40
		auras["growth-x"] = "RIGHT"
		auras["growth-y"] = "DOWN"
		auras:SetPoint("LEFT", self, "RIGHT", 12, 0)
		auras.size = 28
		
		auras.PostCreateIcon = auraIcon
		auras.PostUpdateIcon = PostUpdateIcon

		self.Auras = auras
		
		local cpoints = self:CreateFontString(nil, 'OVERLAY')
		cpoints:SetPoint('RIGHT', self, 'LEFT', -4, 0)
		cpoints:SetFont(font[3], 24, "OUTLINE")
		cpoints:SetTextColor(1, 0, 0)
		self:Tag(cpoints, '[cpoints]')
		
		self:SetAttribute('initial-height', height+25)
		self:SetAttribute('initial-width', width)
		self:SetAttribute('initial-scale', scale)
	end,

	targettarget = function(self)
		
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(28)
		debuffs:SetWidth(28*10)
		debuffs.initialAnchor = "TOPLEFT"
		debuffs.spacing = 5
		debuffs.num = 8
		debuffs["growth-x"] = "RIGHT"
		debuffs["growth-y"] = "DOWN"
		debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -10)
		debuffs.size = 28
		
		debuffs.PostCreateIcon = auraIcon
		debuffs.PostUpdateIcon = PostUpdateIcon
		
		self.Debuffs = debuffs
		
		local squ = self:CreateTexture(nil, "OVERLAY")
		squ:SetTexture(square)
		squ:SetPoint("LEFT", self)
		
		local name = self:CreateFontString(nil, "OVERLAY")
		name:SetFont(font[4], 18)
		name:SetSize(width-15, 18)
		name:SetShadowOffset(1.25, -1.25)
		name:SetTextColor(1, 1, 1)
		name:SetJustifyH"LEFT"
		name:SetPoint("LEFT", squ, "RIGHT", 0, 2)
		self:Tag(name, " [real:lvl] [real:color][real:name] - [perhp]% ")
	
		self:SetAttribute('initial-height', height+25)
		self:SetAttribute('initial-width', width)
		self:SetAttribute('initial-scale', scale)
	end,
	
	pet = function(self)
	
		self:RegisterEvent('PLAYER_REGEN_ENABLED', fader)
		self:RegisterEvent('PLAYER_REGEN_DISABLED', fader)
		self:RegisterEvent('UNIT_TARGET', fader)
		self:RegisterEvent('UNIT_HEALTH', fader)
		self:RegisterEvent('PLAYER_ENTERING_WORLD', fader)
	
		self:SetAttribute('initial-height', height+25)
		self:SetAttribute('initial-width', width-50)
		self:SetAttribute('initial-scale', scale-0.2)
	end,
	
	focus = function(self)
	
		self:SetAttribute('initial-height', height+25)
		self:SetAttribute('initial-width', width-50)
		self:SetAttribute('initial-scale', scale)
	end,
}

local func = function(self, unit)
	self.menu = menu
	
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")
	
	if unit == "targettarget" then return UnitSpecific[unit](self) end

	--Health
	local hp = CreateFrame"StatusBar"
	hp:SetParent(self)
	hp:SetPoint("TOP")
	hp:SetPoint("LEFT")
	hp:SetPoint("RIGHT")
	hp:SetHeight(height)
	hp:SetStatusBarTexture(texture)
	hp:SetBackdrop(backdrop)
	hp:SetBackdropColor(0, 0, 0)
	fixStatusbar(hp)
	hp:SetStatusBarColor(1,1,1,0)
	
	hp.arrow = hp:CreateTexture(nil, "OVERLAY")
	hp.arrow:SetTexture(arrow[3])
	fixTex(hp.arrow)
	
	hp.squ = hp:CreateTexture(nil, "OVERLAY")
	hp.squ:SetTexture(square)
	if unit == "target" or unit == "focus" then
		hp.squ:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
	else
		hp.squ:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
	end

	hp.frequentUpdates = true
	hp.PostUpdate = updateHealth

	local hpbg = hp:CreateTexture(nil, "BORDER")
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(texture)
	hpbg:SetVertexColor(1,1,1)
	
	local hpper = hp:CreateFontString(nil, "OVERLAY")
	hpper:SetFont(font[3], 18, "OUTLINE")
	hpper:SetTextColor(1, 1, 1)
	hpper:SetPoint("BOTTOM", hp.arrow, "TOP", 0, -5)
	
	hp.hpper = hpper
	
	local hpval = hp:CreateFontString(nil, "OVERLAY")
	hpval:SetFont(font[3], 20)
	hpval:SetShadowOffset(1.25, -1.25)
	hpval:SetTextColor(1, 1, 1)
	if unit == "target" or unit == "focus" then
		hpval:SetPoint("TOPLEFT", hp, "BOTTOMLEFT", 0, -10)
	else
		hpval:SetPoint("TOPRIGHT", hp, "BOTTOMRIGHT", 0, -10)
	end
	self:Tag(hpval, "[real:hp]")

	hp.bg = hpbg
	self.Health = hp
	
	--Power
	local pp = CreateFrame"StatusBar"
	pp:SetParent(self)
	pp:SetPoint("TOP")
	if unit == "target" or unit == "focus" then
		pp:SetPoint("RIGHT")
	else
		pp:SetPoint("LEFT")
	end
	pp:SetSize(width*0.8, height)
	pp:SetStatusBarTexture(texture)
	fixStatusbar(pp)
	pp:SetStatusBarColor(1,1,1,0)
	
	pp.frequentUpdates = true
	pp.PostUpdate = updatePower
	
	pp.arrow = hp:CreateTexture(nil, "OVERLAY")
	pp.arrow:SetTexture(arrow[2])
	fixTex2(pp.arrow)
	
	--Power value
	local ppval = hp:CreateFontString(nil, "OVERLAY")
	ppval:SetFont(font[3], 20)
	ppval:SetShadowOffset(1.25, -1.25)
	ppval:SetTextColor(1, 1, 1)
	if unit == "target" or unit == "focus" then
		ppval:SetPoint("TOPRIGHT", hp, "BOTTOMRIGHT", 0, -10)
	else
		ppval:SetPoint("TOPLEFT", hp, "BOTTOMLEFT", 0, -10)
	end
	self:Tag(ppval, "[real:pp]")
	
	pp.val = ppval
	
	self.Power = pp
	
	--Name
	local name = hp:CreateFontString(nil, "OVERLAY")
	name:SetFont(font[4], 18)
	if unit == "pet" or unit == "focus" then
		name:SetSize(width-65, 18)
	else
		name:SetSize(width-15, 18)
	end
	name:SetShadowOffset(1.25, -1.25)
	name:SetTextColor(1, 1, 1)
	if unit == "target" or unit == "focus" then
		name:SetJustifyH"LEFT"
		name:SetPoint("LEFT", hp.squ, "RIGHT", 0, 2)
	else
		name:SetJustifyH"RIGHT"
		name:SetPoint("RIGHT", hp.squ, "LEFT", 0, 2)
	end
	self:Tag(name, " [real:lvl] [real:color][real:name] ")
	
	--Info
	local info = hp:CreateFontString(nil, "OVERLAY")
	info:SetFont(font[4], 14)
	info:SetShadowOffset(1.25, -1.25)
	info:SetTextColor(1, 1, 1)
	info:SetPoint("TOP", hp, "BOTTOM", 0, -10)
	self:Tag(info, "[leader] [status] [pvp]")
	
	--Combat
	local Combat = hp:CreateTexture(nil, 'OVERLAY')
	Combat:SetSize(22, 22)
	Combat:SetPoint("RIGHT", self, "LEFT", -2, 0)
	self.Combat = Combat
	
	--RIcon
	local ricon = hp:CreateTexture(nil, 'OVERLAY')
	ricon:SetPoint("CENTER", hp)
	ricon:SetSize(24, 24)
	self.RaidIcon = ricon

	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

oUF:RegisterStyle("Real", func)

oUF:Factory(function(self)
	self:SetActiveStyle"Real"

	self:Spawn"player":SetPoint("CENTER", -300, -120)
	self:Spawn"target":SetPoint("CENTER", 300, -120)
	self:Spawn"targettarget":SetPoint("TOP", self.units.target, "BOTTOM", -8, -35)
	self:Spawn"focus":SetPoint("CENTER", 550, 0)
	self:Spawn"pet":SetPoint("TOP", self.units.player, "BOTTOM", -25, -85)
end)