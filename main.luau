local VapeLibrary = {
	Internal = {
		DownKeys = {},
		ToggleKeybind = Enum.KeyCode["RightShift"],
		BlurType = (setthreadidentity and "CoreGui" or getthreadidentity and getthreadidentity() > 6 and "CoreGui" or "Blur"),
		Tabs = {},
		Pallet = {
			Main = Color3.fromRGB(26, 25, 26),
			Module = Color3.fromRGB(31, 29, 31),
			ModuleLight = Color3.fromRGB(37, 35, 37),
			Text = Color3.fromRGB(200, 200, 200),
			Font = Font.fromEnum(Enum.Font.Arial),
			Tween = TweenInfo.new(0.16, Enum.EasingStyle.Linear),
			GUIColor = {
				Hue = 0.46,
				Sat = 0.96,
				Value = 0.52
			}
		},
		ScreenGui = nil,
		ClickGui = nil,
		MainFrame = nil,
		MainChildren = nil,
		NotificationFrame = nil,
		Tooltip = nil,
		Blur = nil,
		Modules = {},
		Categories = {},
	}
}

local cloneref = cloneref or function(...) return ... end
local getgenv = getgenv or function() return _G end

local TweenService = cloneref(game:GetService('TweenService'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local TextService = cloneref(game:GetService('TextService'))
local GuiService = cloneref(game:GetService('GuiService'))
local RunService = cloneref(game:GetService('RunService'))

local Assets = {
	['arrowmodule.png'] = 'rbxassetid://14473354880',
	['Blur.png'] = 'rbxassetid://14898786664',
	['Blurnotif.png'] = 'rbxassetid://16738720137',
	['close.png'] = 'rbxassetid://14368309446',
	['closemini.png'] = 'rbxassetid://14368310467',
	['colorpreview.png'] = 'rbxassetid://14368311578',
	['combaticon.png'] = 'rbxassetid://14368312652',
	['dots.png'] = 'rbxassetid://14368314459',
	['edit.png'] = 'rbxassetid://14368315443',
	['expandicon.png'] = 'rbxassetid://14368353032',
	['expandright.png'] = 'rbxassetid://14368316544',
	['expandup.png'] = 'rbxassetid://14368317595',
	['guisettings.png'] = 'rbxassetid://14368318994',
	['guiv4.png'] = 'rbxassetid://14368322199',
	['guivape.png'] = 'rbxassetid://14657521312',
	['inventoryicon.png'] = 'rbxassetid://14928011633',
	['miniicon.png'] = 'rbxassetid://14368326029',
	['minigamesicon.png'] = 'rbxassetid://14368327000',
	['othericon.png'] = 'rbxassetid://14368328000',
	['rendericon.png'] = 'rbxassetid://14368350193',
	['utilityicon.png'] = 'rbxassetid://14368359107',
	['worldicon.png'] = 'rbxassetid://14368362492',
	['friendsicon.png'] = 'rbxassetid://14397462778',
	['profilesicon.png'] = 'rbxassetid://14397465323',
	['macrosicon.png'] = 'rbxassetid://14368340000',
	['bind.png'] = 'rbxassetid://14368304734',
	['vape.png'] = 'rbxassetid://14373395239',
	["warning.png"] = "rbxassetid://14368361552",
	["info.png"] = "rbxassetid://14368324807",
	["pin.png"] = "rbxassetid://14368342301"
}

local function Make(ClassName, Properties, Children)
	local a = Instance.new(ClassName)
	for i,v in pairs(Properties or {}) do
		a[i] = v
	end
	for _, v in pairs(Children or {}) do
		v.Parent = a
	end
	return a
end

local function GetTextSize(Text, font, MaxWidth, FontSize)
	if not (Text and font and MaxWidth and FontSize) then return Vector2.new(0,0) end 
	local TB = Make("GetTextBoundsParams", {
		Parent = nil,
		Width = MaxWidth or math.huge,
		Size = FontSize or 16,
		Text = Text,
		Font = font
	})
	return TextService:GetTextBoundsAsync(TB)
end

local function GetAsset(IconName : string | number)
	if type(IconName) == "number" then
		return "rbxassetid://" .. IconName
	elseif type(IconName) == "string" and string.sub(IconName, 1, 12) == "rbxassetid://" then
		return IconName
	end
	return Assets[IconName] or ""
end

local function ColorDark(col, num)
	local h, s, v = col:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(select(3, VapeLibrary.Internal.Pallet.Main:ToHSV()) > 0.5 and v + num or v - num, 0, 1))
end

local function ColorLight(col, num)
	local h, s, v = col:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(select(3, VapeLibrary.Internal.Pallet.Main:ToHSV()) > 0.5 and v - num or v + num, 0, 1))
end

local function Tween(obj, tweeninfo, goal)
	if obj.Parent and obj.Visible then
		local t = TweenService:Create(obj, tweeninfo or VapeLibrary.Internal.Pallet.Tween, goal)
		t:Play()
		return t
	else
		for i, v in goal do
			obj[i] = v
		end
	end
end

local PX_PER_SECOND = 1000

local function TweenSize(obj, new_size)
	local old_size = obj.Size
	local dy = math.abs(new_size.Y.Offset - old_size.Y.Offset)
	local dx = math.abs(new_size.X.Offset - old_size.X.Offset)
	local dist = math.max(dx, dy)
	local time = math.max(dist / PX_PER_SECOND, 0.04)
	local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	return Tween(obj, info, {Size = new_size})
end

local function MakeBlur(parent, notif)
	return Make('ImageLabel', {
		Name = 'Blur',
		Size = UDim2.new(1, 89, 1, 52),
		Position = UDim2.fromOffset(-48, -31),
		BackgroundTransparency = 1,
		Image = GetAsset((notif and 'Blurnotif' or 'Blur')..'.png'),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(52, 31, 261, 502),
		Parent = parent or nil
	})
end

local function MakeCorner(parent, radius)
	return Make('UICorner', {
		CornerRadius = radius or UDim.new(0, 5),
		Parent = parent
	})
end

local function MakeOutline(parent, MakeBright)
	return Make("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border, -- incase of text
		Color = MakeBright and Color3.fromRGB(190,190,190) or Color3.fromRGB(131,131,131),
		Transparency = MakeBright and 0.75 or 0,
		Parent = parent
	})
end

local function MakeDraggable(gui, window)
	gui.InputBegan:Connect(function(inputObj)
		if window and not window.Visible then return end
		if inputObj.UserInputType == Enum.UserInputType.MouseButton1
			and (inputObj.Position.Y - gui.AbsolutePosition.Y < 40 or window)
		then
			local dragPosition = Vector2.new(
				gui.AbsolutePosition.X - inputObj.Position.X,
				gui.AbsolutePosition.Y - inputObj.Position.Y + GuiService:GetGuiInset().Y
			)

			local changed = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local position = input.Position
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						dragPosition = (dragPosition // 3) * 3
						position = (position // 3) * 3
					end
					gui.Position = UDim2.fromOffset(position.X + dragPosition.X, position.Y + dragPosition.Y)
				end
			end)

			local ended
			ended = inputObj.Changed:Connect(function()
				if inputObj.UserInputState == Enum.UserInputState.End then
					if changed then changed:Disconnect() end
					if ended then ended:Disconnect() end
				end
			end)
		end
	end)
end

local function AddTooltip(BoundingFrame, Text, HoverTimeNeeded, MovesWithMouse)
	if not Text then return end

	MovesWithMouse = MovesWithMouse or true
	local IsInFrame = false
	local IsShown = false
	local Tooltip = VapeLibrary.Internal.Tooltip

	BoundingFrame.MouseEnter:Connect(function()
		if not Tooltip then return end 
		Tooltip.Text = Text

		local Size = GetTextSize(Text, VapeLibrary.Internal.Pallet.Font, 250, 14) + Vector2.new(22, 12)

		IsInFrame = true


		task.delay(HoverTimeNeeded or 0.5, function() 
			if not IsInFrame then return end
			IsShown = true
			Tooltip.Visible = true
			Tween(Tooltip, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0,Size.X,0,Size.Y)})

			task.delay(0.075, function() Tooltip.TextTransparency = 0 end)
			local Mouse = UserInputService:GetMouseLocation()
			Tooltip.Position = UDim2.fromOffset(Mouse.X + 16, Mouse.Y + 16)
		end)

	end)
	BoundingFrame.MouseLeave:Connect(function()
		if not Tooltip then return end 
		IsInFrame = false

		if IsShown then
			IsShown = false
			Tween(Tooltip, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0)})
			Tooltip.Text = ""
			task.delay(0.075, function() Tooltip.TextTransparency = 1 end)
			task.delay(0.15, function() Tooltip.Visible = false end)
		end
	end)
	BoundingFrame.MouseMoved:Connect(function()
		if (not IsShown) and MovesWithMouse then return end
		local Mouse = UserInputService:GetMouseLocation()
		Tooltip.Position = UDim2.fromOffset(Mouse.X + 16, Mouse.Y + 16)
	end)
end

local function RandomString(Length)
	local array = {}
	for i = 1, Length or 10 do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

local function getTableSize(tab)
	local ind = 0
	for _ in tab do ind += 1 end
	return ind
end

local function addMaid(object)
	object.Connections = {}
	function object:Clean(callback)
		if typeof(callback) == 'Instance' then
			table.insert(self.Connections, {
				Disconnect = function()
					callback:ClearAllChildren()
					callback:Destroy()
				end
			})
		elseif type(callback) == 'function' then
			table.insert(self.Connections, {
				Disconnect = callback
			})
		else
			table.insert(self.Connections, callback)
		end
	end
end

-- Component: Toggle
local function CreateToggle(optionsettings, children, api)
	local Pallet = VapeLibrary.Internal.Pallet
	local optionapi = {
		Type = 'Toggle',
		Enabled = optionsettings.Default or false,
		Index = getTableSize(api.Options)
	}

	local hovered = false
	local toggle = Make('TextButton', {
		Name = (optionsettings.Title or 'Default Name')..'Toggle',
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = optionsettings.Visible == nil or optionsettings.Visible,
		Text = '   '..(optionsettings.Title or 'Default Name'),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 14,
		FontFace = Pallet.Font,
		Parent = children
	})
	local knobholder = Make('Frame', {
		Name = 'Knob',
		Size = UDim2.fromOffset(22, 12),
		Position = UDim2.new(1, -30, 0, 9),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.14),
		Parent = toggle
	})
	MakeCorner(knobholder, UDim.new(1, 0))
	local knob = knobholder:Clone()
	knob.Size = UDim2.fromOffset(8, 8)
	knob.Position = UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = Pallet.Main
	knob.Parent = knobholder

	local function _Toggle()
		optionapi.Enabled = not optionapi.Enabled
		Tween(knobholder, Pallet.Tween, {
			BackgroundColor3 = optionapi.Enabled and Color3.fromHSV(VapeLibrary.Internal.Pallet.GUIColor.Hue, VapeLibrary.Internal.Pallet.GUIColor.Sat, VapeLibrary.Internal.Pallet.GUIColor.Value) or (hovered and ColorLight(Pallet.Main, 0.37) or ColorLight(Pallet.Main, 0.14))
		})
		Tween(knob, Pallet.Tween, {
			Position = UDim2.fromOffset(optionapi.Enabled and 12 or 2, 2)
		})

	end

	function optionapi:Toggle()
		_Toggle()
		if optionsettings.Function then
			optionsettings.Function(optionapi.Enabled)
		end
	end

	toggle.MouseEnter:Connect(function()
		hovered = true
		if not optionapi.Enabled then
			Tween(knobholder, Pallet.Tween, {
				BackgroundColor3 = ColorLight(Pallet.Main, 0.37)
			})
		end
	end)
	toggle.MouseLeave:Connect(function()
		hovered = false
		if not optionapi.Enabled then
			Tween(knobholder, Pallet.Tween, {
				BackgroundColor3 = ColorLight(Pallet.Main, 0.14)
			})
		end
	end)
	toggle.MouseButton1Click:Connect(function()
		optionapi:Toggle()
	end)

	if optionsettings.Default then
		_Toggle()
	end
	optionapi.Object = toggle
	api.Options[optionsettings.Title or 'Default Name'] = optionapi
	return optionapi
end

-- Component: Button
local function CreateButton(optionsettings, children, api)
	local Pallet = VapeLibrary.Internal.Pallet
	local button = Make('TextButton', {
		Name = (optionsettings.Title or 'Default Name')..'Button',
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundColor3 = Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = optionsettings.Visible == nil or optionsettings.Visible,
		Text = '',
		Parent = children
	})
	local bkg = Make('Frame', {
		Size = UDim2.fromOffset(200, 27),
		Position = UDim2.fromOffset(10, 2),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.05),
		Parent = button
	})
	MakeCorner(bkg)
	local label = Make('TextLabel', {
		Size = UDim2.new(1, -4, 1, -4),
		Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Pallet.Main,
		Text = optionsettings.Title or 'Default Name',
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 14,
		FontFace = Pallet.Font,
		Parent = bkg
	})
	MakeCorner(label, UDim.new(0, 4))

	button.MouseEnter:Connect(function()
		Tween(bkg, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.0875)
		})
	end)
	button.MouseLeave:Connect(function()
		Tween(bkg, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.05)
		})
	end)
	button.MouseButton1Click:Connect(function()
		if optionsettings.Function then
			optionsettings.Function()
		end
	end)

	return button
end

-- Component: Slider
local function CreateSlider(optionsettings, children, api)
	local Pallet = VapeLibrary.Internal.Pallet
	local optionapi = {
		Type = 'Slider',
		Value = optionsettings.Default or optionsettings.Min or 0,
		Max = optionsettings.Max or 10,
		Index = getTableSize(api.Options)
	}

	local slider = Make('TextButton', {
		Name = (optionsettings.Title or 'Default Name')..'Slider',
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = optionsettings.Visible == nil or optionsettings.Visible,
		Text = '',
		Parent = children
	})
	local title = Make('TextLabel', {
		Name = 'Title',
		Size = UDim2.fromOffset(60, 30),
		Position = UDim2.fromOffset(10, 2),
		BackgroundTransparency = 1,
		Text = optionsettings.Title or 'Default Name',
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 11,
		FontFace = Pallet.Font,
		Parent = slider
	})
	local valuebutton = Make('TextButton', {
		Name = 'Value',
		Size = UDim2.fromOffset(60, 15),
		Position = UDim2.new(1, -69, 0, 9),
		BackgroundTransparency = 1,
		Text = (optionsettings.Prefix or '')..optionapi.Value..(optionsettings.Suffix and ' '..(type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(optionapi.Value) or optionsettings.Suffix) or ''),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 11,
		FontFace = Pallet.Font,
		Parent = slider
	})
	local valuebox = Make('TextBox', {
		Name = 'Box',
		Size = valuebutton.Size,
		Position = valuebutton.Position,
		BackgroundTransparency = 1,
		Visible = false,
		Text = optionapi.Value,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 11,
		FontFace = Pallet.Font,
		ClearTextOnFocus = false,
		Parent = slider
	})
	local bkg = Make('Frame', {
		Name = 'Slider',
		Size = UDim2.new(1, -20, 0, 2),
		Position = UDim2.fromOffset(10, 37),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.034),
		BorderSizePixel = 0,
		Parent = slider
	})
	local fill = bkg:Clone()
	fill.Name = 'Fill'
	fill.Size = UDim2.fromScale(math.clamp((optionapi.Value - (optionsettings.Min or 0)) / (optionsettings.Max or 10), 0.04, 0.96), 1)
	fill.Position = UDim2.new()
	fill.BackgroundColor3 = Color3.fromHSV(VapeLibrary.Internal.Pallet.GUIColor.Hue, VapeLibrary.Internal.Pallet.GUIColor.Sat, VapeLibrary.Internal.Pallet.GUIColor.Value)
	fill.Parent = bkg
	local knobholder = Make('Frame', {
		Name = 'Knob',
		Size = UDim2.fromOffset(24, 4),
		Position = UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = slider.BackgroundColor3,
		BorderSizePixel = 0,
		Parent = fill
	})
	local knob = Make('Frame', {
		Name = 'Knob',
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHSV(VapeLibrary.Internal.Pallet.GUIColor.Hue, VapeLibrary.Internal.Pallet.GUIColor.Sat, VapeLibrary.Internal.Pallet.GUIColor.Value),
		Parent = knobholder
	})
	MakeCorner(knob, UDim.new(1, 0))
	optionsettings.Increment = optionsettings.Increment or 1
	optionsettings.Min = optionsettings.Min or 0
	optionsettings.Max = optionsettings.Max or 10

	local incrementValue = optionsettings.Increment
	if incrementValue ~= 0 then
		incrementValue = 1 / incrementValue
	else
		incrementValue = 1
	end

	function optionapi:SetValue(value, pos, final)
		if tonumber(value) == math.huge or value ~= value then return end
		local check = self.Value ~= value
		self.Value = value
		Tween(fill, Pallet.Tween, {
			Size = UDim2.fromScale(math.clamp(pos or math.clamp((value - optionsettings.Min) / (optionsettings.Max - optionsettings.Min), 0, 1), 0.04, 0.96), 1)
		})
		valuebutton.Text = (optionsettings.Prefix or '')..self.Value..(optionsettings.Suffix and ' '..(type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(self.Value) or optionsettings.Suffix) or '')
		if (check or final) and optionsettings.Function then
			optionsettings.Function(value, final)
		end
	end

	slider.InputBegan:Connect(function(inputObj)
		if
			(inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
			and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * 1)
		then
			local newPosition = math.clamp((inputObj.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
			optionapi:SetValue(math.floor((optionsettings.Min + (optionsettings.Max - optionsettings.Min) * newPosition) * incrementValue) / incrementValue, newPosition)
			local lastValue = optionapi.Value
			local lastPosition = newPosition

			local changed = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local newPosition = math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
					optionapi:SetValue(math.floor((optionsettings.Min + (optionsettings.Max - optionsettings.Min) * newPosition) * incrementValue) / incrementValue, newPosition)
					lastValue = optionapi.Value
					lastPosition = newPosition
				end
			end)

			local ended
			ended = inputObj.Changed:Connect(function()
				if inputObj.UserInputState == Enum.UserInputState.End then
					if changed then changed:Disconnect() end
					if ended then ended:Disconnect() end
					optionapi:SetValue(lastValue, lastPosition, true)
				end
			end)
		end
	end)
	slider.MouseEnter:Connect(function()
		Tween(knob, Pallet.Tween, {
			Size = UDim2.fromOffset(16, 16)
		})
	end)
	slider.MouseLeave:Connect(function()
		Tween(knob, Pallet.Tween, {
			Size = UDim2.fromOffset(14, 14)
		})
	end)
	valuebutton.MouseButton1Click:Connect(function()
		valuebutton.Visible = false
		valuebox.Visible = true
		valuebox.Text = optionapi.Value
		valuebox:CaptureFocus()
	end)
	valuebox.FocusLost:Connect(function(enter)
		valuebutton.Visible = true
		valuebox.Visible = false
		if enter and tonumber(valuebox.Text) then
			optionapi:SetValue(tonumber(valuebox.Text), nil, true)
		end
	end)

	optionapi.Object = slider
	api.Options[optionsettings.Title or 'Default Name'] = optionapi
	return optionapi
end

-- Component: Dropdown
local function CreateDropdown(optionsettings, children, api)
	local Pallet = VapeLibrary.Internal.Pallet
	local optionsList = optionsettings.Options or {"Option 1", "Option 2"}
	local optionapi = {
		Type = 'Dropdown',
		Value = optionsettings.AllowMultiple and {} or (optionsettings.Default or optionsList[1] or 'None'),
		Index = getTableSize(api.Options)
	}

	local dropdown = Make('TextButton', {
		Name = (optionsettings.Title or 'Default Name')..'Dropdown',
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundColor3 = Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = optionsettings.Visible == nil or optionsettings.Visible,
		Text = '',
		Parent = children
	})

	local titleLabel = Make('TextLabel', {
		Name = 'Title',
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.fromOffset(10, 2),
		BackgroundTransparency = 1,
		Text = (optionsettings.Title or 'Default Name'),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 12,
		FontFace = Pallet.Font,
		Parent = dropdown
	})

	local bkg = Make('Frame', {
		Name = 'BKG',
		Size = UDim2.new(1, -20, 0, 26),
		Position = UDim2.fromOffset(10, 24),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.034),
		Parent = dropdown
	})
	MakeCorner(bkg, UDim.new(0, 6))
	local button = Make('TextButton', {
		Name = 'Dropdown',
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.fromOffset(1, 1),
		BackgroundColor3 = Pallet.Main,
		AutoButtonColor = false,
		Text = '',
		Parent = bkg
	})
	local displayLabel = Make('TextLabel', {
		Name = 'Display',
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		FontFace = Pallet.Font,
		Parent = button
	})
	local displayValue
	if optionsettings.AllowMultiple then
		displayValue = #optionapi.Value > 0 and table.concat(optionapi.Value, ", ") or "None"
	else
		displayValue = optionapi.Value
	end
	displayLabel.Text = displayValue
	MakeCorner(button, UDim.new(0, 6))
	local arrow = Make('ImageLabel', {
		Name = 'Arrow',
		Size = UDim2.fromOffset(4, 8),
		Position = UDim2.new(1, -14, 0, 9),
		BackgroundTransparency = 1,
		Image = GetAsset('expandright.png'),
		ImageColor3 = Color3.fromRGB(140, 140, 140),
		Rotation = 90,
		Parent = button
	})
	local dropdownchildren
	local optionButtons = {}
	local outsideClickConnection

	local function isOptionSelected(val)
		if optionsettings.AllowMultiple then
			return table.find(optionapi.Value, val) ~= nil
		else
			return val == optionapi.Value
		end
	end

	local function updateHighlights()
		for val, btn in optionButtons do
			local selected = isOptionSelected(val)
			Tween(btn, Pallet.Tween, {
				BackgroundColor3 = selected and Pallet.ModuleLight or Pallet.Main
			})
		end
	end

	local function closeDropdown()
		if dropdownchildren then
			arrow.Rotation = 90
			dropdownchildren:Destroy()
			dropdownchildren = nil
			optionButtons = {}
			dropdown.Size = UDim2.new(1, 0, 0, 54)
		end
		if outsideClickConnection then
			outsideClickConnection:Disconnect()
			outsideClickConnection = nil
		end
	end

	local function openDropdown()
		arrow.Rotation = 270
		dropdown.Size = UDim2.new(1, 0, 0, 54 + (#optionsList) * 26)
		dropdownchildren = Make('Frame', {
			Name = 'Children',
			Size = UDim2.new(1, 0, 0, (#optionsList) * 26),
			Position = UDim2.fromOffset(0, 51),
			BackgroundTransparency = 1,
			Parent = dropdown
		})
		local ind = 0
		for _, v in optionsList do
			local selected = isOptionSelected(v)
			local dropdownoption = Make('TextButton', {
				Name = v..'Option',
				Size = UDim2.new(1, 0, 0, 26),
				Position = UDim2.fromOffset(0, ind * 26),
				BackgroundColor3 = selected and Pallet.ModuleLight or Pallet.Main,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = '        '..v,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = ColorDark(Pallet.Text, 0.16),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				FontFace = Pallet.Font,
				Parent = dropdownchildren
			})
			optionButtons[v] = dropdownoption
			dropdownoption.MouseEnter:Connect(function()
				Tween(dropdownoption, Pallet.Tween, {
					BackgroundColor3 = ColorLight(Pallet.Main, 0.02)
				})
			end)
			dropdownoption.MouseLeave:Connect(function()
				Tween(dropdownoption, Pallet.Tween, {
					BackgroundColor3 = isOptionSelected(v) and Pallet.ModuleLight or Pallet.Main
				})
			end)
			dropdownoption.MouseButton1Click:Connect(function()
				optionapi:SetValue(v, true)
			end)
			ind += 1
		end

		if optionsettings.AllowMultiple then
			if outsideClickConnection then
				outsideClickConnection:Disconnect()
			end
			outsideClickConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local absPos = dropdown.AbsolutePosition
					local absSize = dropdown.AbsoluteSize
					local clickX = input.Position.X
					local clickY = input.Position.Y
					if clickX < absPos.X or clickX > absPos.X + absSize.X or clickY < absPos.Y or clickY > absPos.Y + absSize.Y then
						closeDropdown()
					end
				end
			end)
		end
	end

	local function updateTitle()
		local displayValue
		if optionsettings.AllowMultiple then
			displayValue = #optionapi.Value > 0 and table.concat(optionapi.Value, ", ") or "None"
		else
			displayValue = optionapi.Value
		end
		displayLabel.Text = displayValue
	end

	function optionapi:SetValue(val, mouse)
		if optionsettings.AllowMultiple then
			if type(val) == "table" then
				self.Value = val
			else
				local found = table.find(optionsList, val)
				if found then
					local existing = table.find(self.Value, val)
					if existing then
						table.remove(self.Value, existing)
					else
						table.insert(self.Value, val)
					end
				end
			end
			updateTitle()
			updateHighlights()
		else
			self.Value = table.find(optionsList, val) and val or optionsList[1] or 'None'
			updateTitle()
			closeDropdown()
		end
		if optionsettings.Function then
			optionsettings.Function(self.Value, mouse)
		end
	end

	button.MouseButton1Click:Connect(function()
		if dropdownchildren then
			closeDropdown()
		else
			openDropdown()
		end
	end)
	dropdown.MouseEnter:Connect(function()
		Tween(bkg, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.0875)
		})
	end)
	dropdown.MouseLeave:Connect(function()
		Tween(bkg, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.034)
		})
	end)

	optionapi.Object = dropdown
	api.Options[optionsettings.Title or 'Default Name'] = optionapi
	return optionapi
end

-- Component: TextBox
local function CreateTextBox(optionsettings, children, api)
	local Pallet = VapeLibrary.Internal.Pallet
	local optionapi = {
		Type = 'TextBox',
		Value = optionsettings.Default or '',
		Index = 0
	}

	local textbox = Make('TextButton', {
		Name = (optionsettings.Title or 'Default Name')..'TextBox',
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundColor3 = Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = optionsettings.Visible == nil or optionsettings.Visible,
		Text = '',
		Parent = children
	})
	local title = Make('TextLabel', {
		Size = UDim2.new(1, -30, 0, 20),
		Position = UDim2.fromOffset(15, 3),
		BackgroundTransparency = 1,
		Text = optionsettings.Title or 'Default Name',
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Pallet.Text,
		TextSize = 12,
		FontFace = Pallet.Font,
		Parent = textbox
	})
	local bkg = Make('Frame', {
		Name = 'BKG',
		Size = UDim2.new(1, -20, 0, 29),
		Position = UDim2.fromOffset(10, 23),
		BackgroundColor3 = ColorLight(Pallet.ModuleLight, 0.02),
		Parent = textbox
	})
	MakeCorner(bkg, UDim.new(0, 4))
	local box = Make('TextBox', {
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		BackgroundTransparency = 1,
		Text = optionsettings.Default or '',
		PlaceholderText = optionsettings.Placeholder or 'Click to set',
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		PlaceholderColor3 = ColorDark(Pallet.Text, 0.31),
		TextSize = 12,
		FontFace = Pallet.Font,
		ClearTextOnFocus = false,
		Parent = bkg
	})

	function optionapi:SetValue(val, enter, input)
		self.Value = val
		box.Text = val
		if enter and optionsettings.Function then
			optionsettings.Function(val)
		end
	end

	textbox.MouseButton1Click:Connect(function()
		box:CaptureFocus()
	end)
	box.FocusLost:Connect(function(enter, input)
		optionapi:SetValue(box.Text, enter, input)
	end)
	box:GetPropertyChangedSignal('Text'):Connect(function()
		optionapi:SetValue(box.Text)
	end)

	optionapi.Object = textbox
	api.Options[optionsettings.Title or 'Default Name'] = optionapi
	return optionapi
end

-- Component: Divider
local function CreateDivider(children, text)
	local Pallet = VapeLibrary.Internal.Pallet
	local divider = Make('Frame', {
		Name = 'Divider',
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.02),
		BorderSizePixel = 0,
		Parent = children
	})
	if text then
		local label = Make('TextLabel', {
			Name = 'DividerLabel',
			Size = UDim2.fromOffset(218, 27),
			BackgroundTransparency = 1,
			Text = '     '..text:upper(),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = ColorDark(Pallet.Text, 0.43),
			TextSize = 9,
			FontFace = Pallet.Font,
			Parent = children
		})
		divider.Position = UDim2.fromOffset(0, 26)
		divider.Parent = label
	end
end

-- Component: Label
local function CreateLabel(optionsettings, children, api)
	local Pallet = VapeLibrary.Internal.Pallet
	local optionapi = {
		Type = 'Label',
		Name = optionsettings.Title or 'Default Name',
		Index = 0
	}

	local frame = Make('Frame', {
		Name = (optionsettings.Title or 'Default Name')..'Label',
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Pallet.Module,
		BorderSizePixel = 0,
		Visible = optionsettings.Visible == nil or optionsettings.Visible,
		Parent = children
	})

	local textLabel = Make('TextLabel', {
		Name = 'Text',
		Size = UDim2.new(1, -16, 1, -6),
		Position = UDim2.fromOffset(10, 3),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = Pallet.Text,
		TextSize = 12,
		FontFace = Pallet.Font,
		RichText = optionsettings.RichText or false,
		TextWrapped = true,
		Text = optionapi.Name,
		Parent = frame
	})

	local function updateSize()
		local textSize = GetTextSize(textLabel.Text, textLabel.FontFace, textLabel.AbsoluteSize.X, textLabel.TextSize)
		local newY = math.max(32, textSize.Y + 10)
		frame.Size = UDim2.new(1, 0, 0, newY)
	end

	textLabel:GetPropertyChangedSignal('Text'):Connect(updateSize)
	updateSize()

	function optionapi:SetValue(val)
		self.Value = val
		textLabel.Text = val
	end

	optionapi.Object = frame
	api.Options[optionsettings.Title or 'Default Name'] = optionapi
	return optionapi
end

-- Component: Keybind
local function CreateKeybind(optionsettings, children, api)
	local Pallet = VapeLibrary.Internal.Pallet
	local optionapi = {
		Type = 'Keybind',
		Value = optionsettings.Default,
		Index = getTableSize(api.Options)
	}

	local keybind = Make('TextButton', {
		Name = (optionsettings.Title or 'Default Name')..'Keybind',
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = optionsettings.Visible == nil or optionsettings.Visible,
		Text = '',
		Parent = children
	})

	local titleLabel = Make('TextLabel', {
		Name = 'Title',
		Size = UDim2.new(1, -80, 0, 34),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = (optionsettings.Title or 'Default Name'),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 14,
		FontFace = Pallet.Font,
		Parent = keybind
	})

	local bindBox = Make('TextButton', {
		Name = 'BindBox',
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(1, -34, 0, 5),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.05),
		Text = '',
		AutoButtonColor = false,
		Parent = keybind
	})
	MakeCorner(bindBox, UDim.new(0, 4))

	local bindIcon = Make('ImageLabel', {
		Name = 'BindIcon',
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(0.5, -6, 0.5, -6),
		BackgroundTransparency = 1,
		Image = GetAsset('bind.png'),
		ImageColor3 = ColorDark(Pallet.Text, 0.16),
		Visible = false,
		Parent = bindBox
	})

	local bindLabel = Make('TextLabel', {
		Name = 'BindLabel',
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.fromOffset(4, 0),
		BackgroundTransparency = 1,
		Text = optionapi.Value and optionapi.Value.Name or 'None',
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 12,
		FontFace = Pallet.Font,
		Parent = bindBox
	})

	local listening = false
	local keybindConnection

	local function updateDisplay()
		if optionapi.Value then
			bindLabel.Text = optionapi.Value.Name
			bindLabel.Visible = true
			bindIcon.Visible = false
		else
			bindLabel.Visible = false
			bindIcon.Visible = true
		end
	end

	local function onKeybindPressed(input, gameProcessed)
		if gameProcessed then return end
		if optionapi.Value and input.KeyCode == optionapi.Value then
			if optionsettings.Function then
				optionsettings.Function()
			end
		end
	end

	local function startListening()
		listening = true
		bindLabel.Text = '...'
		bindLabel.Visible = true
		bindIcon.Visible = false

		local inputConnection
		inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					optionapi.Value = nil
				else
					optionapi.Value = input.KeyCode
				end
				updateDisplay()
				listening = false
				if inputConnection then
					inputConnection:Disconnect()
				end
			end
		end)
	end

	function optionapi:SetValue(val)
		self.Value = val
		updateDisplay()
	end

	bindBox.MouseEnter:Connect(function()
		Tween(bindBox, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.0875)
		})
	end)
	bindBox.MouseLeave:Connect(function()
		Tween(bindBox, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.05)
		})
	end)
	bindBox.MouseButton1Click:Connect(function()
		if not listening then
			startListening()
		end
	end)

	keybindConnection = UserInputService.InputBegan:Connect(onKeybindPressed)

	optionapi.Object = keybind
	api.Options[optionsettings.Title or 'Default Name'] = optionapi
	return optionapi
end


-- Components table
local Components = {
	Toggle = CreateToggle,
	Button = CreateButton,
	Slider = CreateSlider,
	Dropdown = CreateDropdown,
	TextBox = CreateTextBox,
	Divider = CreateDivider,
	Label = CreateLabel,
	Keybind = CreateKeybind
}

-- Tab (Category) Class
local TabClass = {}
TabClass.__index = TabClass

function TabClass:CreateToggle(settings)
	return Components.Toggle(settings, self.Children, self)
end

function TabClass:CreateButton(settings)
	return Components.Button(settings, self.Children, self)
end

function TabClass:CreateSlider(settings)
	return Components.Slider(settings, self.Children, self)
end

function TabClass:CreateDropdown(settings)
	return Components.Dropdown(settings, self.Children, self)
end

function TabClass:CreateTextBox(settings)
	return Components.TextBox(settings, self.Children, self)
end

function TabClass:CreateLabel(settings)
	return Components.Label(settings, self.Children, self)
end

function TabClass:CreateKeybind(settings)
	return Components.Keybind(settings, self.Children, self)
end

-- Module Class (for expandable modules with settings)
local ModuleClass = {}
ModuleClass.__index = ModuleClass

function ModuleClass:CreateToggle(settings)
	return Components.Toggle(settings, self.Children, self)
end

function ModuleClass:CreateButton(settings)
	return Components.Button(settings, self.Children, self)
end

function ModuleClass:CreateSlider(settings)
	return Components.Slider(settings, self.Children, self)
end

function ModuleClass:CreateDropdown(settings)
	return Components.Dropdown(settings, self.Children, self)
end

function ModuleClass:CreateTextBox(settings)
	return Components.TextBox(settings, self.Children, self)
end

function ModuleClass:CreateKeybind(settings)
	return Components.Keybind(settings, self.Children, self)
end

function ModuleClass:CreateLabel(settings)
	return Components.Label(settings, self.Children, self)
end

function TabClass:CreateModule(settings)
	local Pallet = VapeLibrary.Internal.Pallet
	local parentTab = self

	local moduleapi = {
		Enabled = false,
		Options = {},
		Bind = {},
		Name = settings.Name,
		ExtraText = settings.ExtraText
	}

	local hovered = false
	local modulebutton = Make('TextButton', {
		Name = settings.Name,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = '     '..settings.Name,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 14,
		FontFace = Pallet.Font,
		Parent = parentTab.Children
	})
	local gradient = Make('UIGradient', {
		Rotation = 90,
		Enabled = false,
		Parent = modulebutton
	})
	local modulechildren = Make('Frame', {
		Name = settings.Name..'Children',
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = ColorDark(Pallet.Module, 0.02),
		BorderSizePixel = 0,
		Visible = false,
		Parent = parentTab.Children
	})
	moduleapi.Children = modulechildren
	local dotsbutton = Make('TextButton', {
		Name = 'Dots',
		Size = UDim2.fromOffset(25, 40),
		Position = UDim2.new(1, -25, 0, 0),
		BackgroundTransparency = 1,
		Text = '',
		Parent = modulebutton
	})
	local dots = Make('ImageLabel', {
		Name = 'Dots',
		Size = UDim2.fromOffset(3, 16),
		Position = UDim2.fromOffset(4, 12),
		BackgroundTransparency = 1,
		Image = GetAsset('dots.png'),
		ImageColor3 = ColorLight(Pallet.Main, 0.37),
		Parent = dotsbutton
	})
	local windowlist = Make('UIListLayout', {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = modulechildren
	})
	local dividerFrame = Make('Frame', {
		Name = 'Divider',
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Color3.new(0.19, 0.19, 0.19),
		BackgroundTransparency = 0.52,
		BorderSizePixel = 0,
		Visible = false,
		Parent = modulebutton
	})
	settings.Function = settings.Function or function() end
	addMaid(moduleapi)

	function moduleapi:Toggle(multiple)
		self.Enabled = not self.Enabled
		dividerFrame.Visible = self.Enabled
		gradient.Enabled = self.Enabled
		modulebutton.TextColor3 = (hovered or modulechildren.Visible) and Pallet.Text or (self.Enabled and ColorLight(Pallet.Text, 0.1) or ColorDark(Pallet.Text, 0.16))
		dots.ImageColor3 = self.Enabled and ColorLight(Pallet.Text, 0.1) or ColorLight(Pallet.Module, 0.37)
		local baseColor = self.Enabled and Color3.fromRGB(5, 132, 102) or Pallet.Module
		modulebutton.BackgroundColor3 = (hovered or modulechildren.Visible) and ColorLight(baseColor, 0.02) or baseColor
		if not self.Enabled then
			for _, v in self.Connections do
				v:Disconnect()
			end
			table.clear(self.Connections)
		end
		task.spawn(settings.Function, self.Enabled)
	end

	dotsbutton.MouseEnter:Connect(function()
		if not moduleapi.Enabled then
			dots.ImageColor3 = Pallet.Text
		else
			dots.ImageColor3 = ColorLight(Pallet.Text, 0.1)
		end
	end)
	dotsbutton.MouseLeave:Connect(function()
		if not moduleapi.Enabled then
			dots.ImageColor3 = ColorLight(Pallet.Module, 0.37)
		else
			dots.ImageColor3 = ColorLight(Pallet.Text, 0.1)
		end
	end)
	dotsbutton.MouseButton1Click:Connect(function()
		if modulechildren.Visible then
			modulechildren.Visible = false
			TweenSize(modulechildren, UDim2.new(1, 0, 0, 0))
		else
			modulechildren.Visible = true
			TweenSize(modulechildren, UDim2.new(1, 0, 0, windowlist.AbsoluteContentSize.Y))
		end
	end)
	dotsbutton.MouseButton2Click:Connect(function()
		if modulechildren.Visible then
			modulechildren.Visible = false
			TweenSize(modulechildren, UDim2.new(1, 0, 0, 0))
		else
			modulechildren.Visible = true
			TweenSize(modulechildren, UDim2.new(1, 0, 0, windowlist.AbsoluteContentSize.Y))
		end
	end)
	modulebutton.MouseEnter:Connect(function()
		hovered = true
		if not modulechildren.Visible then
			local baseColor = moduleapi.Enabled and Color3.fromRGB(5, 132, 102) or Pallet.Module
			modulebutton.TextColor3 = Pallet.Text
			modulebutton.BackgroundColor3 = ColorLight(baseColor, 0.02)
		end
	end)
	modulebutton.MouseLeave:Connect(function()
		hovered = false
		if not modulechildren.Visible then
			local baseColor = moduleapi.Enabled and Color3.fromRGB(5, 132, 102) or Pallet.Module
			modulebutton.TextColor3 = moduleapi.Enabled and ColorLight(Pallet.Text, 0.1) or ColorDark(Pallet.Text, 0.16)
			modulebutton.BackgroundColor3 = baseColor
		end
	end)
	modulebutton.MouseButton1Click:Connect(function()
		moduleapi:Toggle()
	end)
	modulebutton.MouseButton2Click:Connect(function()
		if modulechildren.Visible then
			modulechildren.Visible = false
			TweenSize(modulechildren, UDim2.new(1, 0, 0, 0))
		else
			modulechildren.Visible = true
			TweenSize(modulechildren, UDim2.new(1, 0, 0, windowlist.AbsoluteContentSize.Y))
		end
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		modulechildren.Size = UDim2.new(1, 0, 0, windowlist.AbsoluteContentSize.Y)
	end)

	moduleapi.Object = modulebutton
	VapeLibrary.Internal.Modules[settings.Name] = moduleapi

	setmetatable(moduleapi, ModuleClass)
	return moduleapi
end


-- Window Class
local WindowClass = {}
WindowClass.__index = WindowClass

function WindowClass:CreateTab(settings)
	local Pallet = VapeLibrary.Internal.Pallet
	local categoryapi = {
		Type = 'Category',
		Expanded = false,
		Options = {},
		Name = settings.Name
	}

	local window = Make('TextButton', {
		Name = settings.Name..'Category',
		Size = UDim2.fromOffset(220, 41),
		Position = UDim2.fromOffset(236, 60),
		BackgroundColor3 = Pallet.Main,
		AutoButtonColor = false,
		Visible = false,
		Text = '',
		Parent = VapeLibrary.Internal.ClickGui
	}, {
		MakeBlur(),
		MakeCorner(),
		MakeOutline(nil, true)
	})
	MakeDraggable(window)
	local icon = Make('ImageLabel', {
		Name = 'Icon',
		Size = settings.Size or UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(12, ((settings.Size or UDim2.fromOffset(16, 16)).X.Offset > 20 and 14 or 13)),
		BackgroundTransparency = 1,
		Image = GetAsset(settings.Icon or 'combaticon.png'),
		ImageColor3 = Pallet.Text,
		Parent = window
	})
	local title = Make('TextLabel', {
		Name = 'Title',
		Size = UDim2.new(1, -((settings.Size and settings.Size.X.Offset or 16) > 18 and 40 or 33), 0, 41),
		Position = UDim2.fromOffset(math.abs(((settings.Size and settings.Size.X.Offset or 16) > 18 and 40 or 33)), 0),
		BackgroundTransparency = 1,
		Text = settings.Name,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Pallet.Text,
		TextSize = 13,
		FontFace = Pallet.Font,
		Parent = window
	})
	local arrowbutton = Make('TextButton', {
		Name = 'Arrow',
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.new(1, -40, 0, 0),
		BackgroundTransparency = 1,
		Text = '',
		Parent = window
	})
	local arrow = Make('ImageLabel', {
		Name = 'Arrow',
		Size = UDim2.fromOffset(9, 4),
		Position = UDim2.fromOffset(20, 18),
		BackgroundTransparency = 1,
		Image = GetAsset('expandup.png'),
		ImageColor3 = Color3.fromRGB(140, 140, 140),
		Rotation = 180,
		Parent = arrowbutton
	})
	local children = Make('ScrollingFrame', {
		Name = 'Children',
		Size = UDim2.new(1, 0, 1, -41),
		Position = UDim2.fromOffset(0, 37),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 0.75,
		CanvasSize = UDim2.new(),
		Parent = window
	})
	local dividerFrame = Make('Frame', {
		Name = 'Divider',
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.fromOffset(0, 37),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.928,
		BorderSizePixel = 0,
		Visible = false,
		Parent = window
	})
	local windowlist = Make('UIListLayout', {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = children
	})
	categoryapi.Children = children
	categoryapi.Object = window

	function categoryapi:Expand()
		if self.Expanded then return end
		self.Expanded = true
		children.Visible = true
		arrow.Rotation = 0
		dividerFrame.Visible = true
		TweenSize(window, UDim2.fromOffset(220, math.min(41 + windowlist.AbsoluteContentSize.Y, 601)))
	end

	function categoryapi:Close()
		if not self.Expanded then return end
		self.Expanded = false
		children.Visible = false
		arrow.Rotation = 180
		dividerFrame.Visible = false
		TweenSize(window, UDim2.fromOffset(220, 41))
	end

	arrowbutton.MouseButton1Click:Connect(function()
		if categoryapi.Expanded then
			categoryapi:Close()
		else
			categoryapi:Expand()
		end
	end)
	arrowbutton.MouseButton2Click:Connect(function()
		if categoryapi.Expanded then
			categoryapi:Close()
		else
			categoryapi:Expand()
		end
	end)
	arrowbutton.MouseEnter:Connect(function()
		arrow.ImageColor3 = Color3.fromRGB(220, 220, 220)
	end)
	arrowbutton.MouseLeave:Connect(function()
		arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y)
		if categoryapi.Expanded then
			TweenSize(window, UDim2.fromOffset(220, math.min(41 + windowlist.AbsoluteContentSize.Y, 601)))
		end
	end)

	-- Create button in main window
	local categoryButton = Make('TextButton', {
		Name = settings.Name,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Pallet.Main,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = (settings.Icon and string.rep(" ", 12) or "    ")..settings.Name,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Pallet.Font,
		Parent = VapeLibrary.Internal.MainChildren
	})
	local catIcon
	if settings.Icon then
		catIcon = Make('ImageLabel', {
			Name = 'Icon',
			Size = settings.Size or UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(13, 13),
			BackgroundTransparency = 1,
			Image = GetAsset(settings.Icon),
			ImageColor3 = ColorDark(Pallet.Text, 0.16),
			Parent = categoryButton
		})
	end
	local catArrow = Make('ImageLabel', {
		Name = 'Arrow',
		Size = UDim2.fromOffset(4, 8),
		Position = UDim2.new(1, -20, 0, 16),
		BackgroundTransparency = 1,
		Image = GetAsset('expandright.png'),
		ImageColor3 = ColorLight(Pallet.Main, 0.37),
		Parent = categoryButton
	})

	local categoryButtonApi = {
		Enabled = false,
		Object = categoryButton,
		Window = window
	}

	function categoryButtonApi:Toggle()
		self.Enabled = not self.Enabled
		Tween(catArrow, Pallet.Tween, {
			Position = UDim2.new(1, self.Enabled and -14 or -20, 0, 16)
		})
		categoryButton.TextColor3 = self.Enabled and Color3.fromHSV(VapeLibrary.Internal.Pallet.GUIColor.Hue, VapeLibrary.Internal.Pallet.GUIColor.Sat, VapeLibrary.Internal.Pallet.GUIColor.Value) or Pallet.Text
		if catIcon then
			catIcon.ImageColor3 = categoryButton.TextColor3
		end
		categoryButton.BackgroundColor3 = ColorLight(Pallet.Main, 0.02)
		window.Visible = self.Enabled
	end

	categoryButton.MouseEnter:Connect(function()
		if not categoryButtonApi.Enabled then
			categoryButton.TextColor3 = Pallet.Text
			if catIcon then catIcon.ImageColor3 = Pallet.Text end
			categoryButton.BackgroundColor3 = ColorLight(Pallet.Main, 0.02)
		end
	end)
	categoryButton.MouseLeave:Connect(function()
		if not categoryButtonApi.Enabled then
			categoryButton.TextColor3 = ColorDark(Pallet.Text, 0.16)
			if catIcon then catIcon.ImageColor3 = ColorDark(Pallet.Text, 0.16) end
			categoryButton.BackgroundColor3 = Pallet.Main
		end
	end)
	categoryButton.MouseButton1Click:Connect(function()
		categoryButtonApi:Toggle()
	end)

	categoryapi.Button = categoryButtonApi
	VapeLibrary.Internal.Categories[settings.Name] = categoryapi
	table.insert(VapeLibrary.Internal.Tabs, categoryapi)

	setmetatable(categoryapi, TabClass)
	return categoryapi
end

function VapeLibrary:CreateWindow()
	local Pallet = VapeLibrary.Internal.Pallet
	VapeLibrary.Internal.ScreenGui = Instance.new("ScreenGui", gethui and gethui() or cloneref(game:GetService("Players")).LocalPlayer.PlayerGui)
	VapeLibrary.Internal.ScreenGui.IgnoreGuiInset = true
	VapeLibrary.Internal.ScreenGui.Name = RandomString()

	if VapeLibrary.Internal.BlurType == "CoreGui" then
		VapeLibrary.Internal.ScreenGui.OnTopOfCoreBlur = true
	else
		VapeLibrary.Internal.Blur = Make("BlurEffect", {
			Name = RandomString(20),
			Enabled = false,
			Parent = game:GetService("Lighting"),
			Size = 36
		})
	end

	local ClickGui = Make("Frame", {
		Name = "ClickGui",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = VapeLibrary.Internal.ScreenGui
	})
	VapeLibrary.Internal.ClickGui = ClickGui    

	VapeLibrary.Internal.Tooltip = Make("TextLabel", {
		Name = "Tooltip",
		Size = UDim2.new(0,0,0,0),
		FontFace = Pallet.Font,
		TextSize = 14,
		TextColor3 = Pallet.Text,
		Text = "Tooltip Placeholder",
		BackgroundColor3 = Pallet.Main,
		Parent = ClickGui,
		Visible = false,
		ZIndex = 9999999
	}, {
		Make("UISizeConstraint", {
			MinSize = Vector2.new(0,0),
			MaxSize = Vector2.new(250, math.huge),
		}),
		MakeBlur(),
		MakeCorner(),
		MakeOutline()
	})

	VapeLibrary.Internal.NotificationFrame = Make("Frame", {
		BackgroundTransparency = 1,
		Name = "Notifications",
		Parent = VapeLibrary.Internal.ScreenGui,
		Size = UDim2.new(0.25, -24, 1, -24),
		Position = UDim2.new(0.75, 12, 0, 12)
	},{
		Make("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		})
	})

	local UIScale = Make("UIScale", {
		Parent = ClickGui,
		Scale = math.max(VapeLibrary.Internal.ScreenGui.AbsoluteSize.X / 1920, 1)
	})

	local MainFrame = Make("TextButton", {
		Name = "Main",
		Position = UDim2.fromOffset(6, 60),
		Size = UDim2.fromOffset(220, 41),
		BackgroundColor3 = ColorDark(Pallet.Main, 0.02),
		AutoButtonColor = false,
		Text = '',
		Parent = ClickGui
	}, {
		MakeBlur(),
		MakeCorner(),
		MakeOutline(nil, true),
		Make("UISizeConstraint", {
			MinSize = Vector2.new(0,500),
			MaxSize = Vector2.new(math.huge, math.huge),
		})
	})


	VapeLibrary.Internal.MainFrame = MainFrame
	MakeDraggable(MainFrame)

	Make('ImageLabel', {
		Name = 'VapeLogo',
		Size = UDim2.fromOffset(62, 18),
		Position = UDim2.fromOffset(11, 10),
		BackgroundTransparency = 1,
		Image = GetAsset('guivape.png'),
		ImageColor3 = select(3, Pallet.Main:ToHSV()) > 0.5 and Pallet.Text or Color3.new(1, 1, 1),
		Parent = MainFrame
	}, {
		Make('ImageLabel', {
			Name = 'V4Logo',
			Size = UDim2.fromOffset(28, 16),
			Position = UDim2.new(1, 1, 0, 1),
			BackgroundTransparency = 1,
			Image = GetAsset('guiv4.png'),
			ImageColor3 = Color3.fromRGB(5, 132, 102)
		})
	})

	Make("Frame", {
		Name = "Divider",
		Position = UDim2.new(0, 0, 0, 37),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.928,
		BorderSizePixel = 0,
		Parent = MainFrame
	})

	local MainChildren = Make('Frame', {
		Name = 'Children',
		Size = UDim2.new(1, 0, 1, -33),
		Position = UDim2.fromOffset(0, 37),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = MainFrame
	})
	VapeLibrary.Internal.MainChildren = MainChildren
	local MainList = Make('UIListLayout', {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = MainChildren
	})

	-- Do not remove this: (Might get implemented soon)
	--[[
		local settingsbutton = Make('TextButton', {
			Name = 'Settings',
			Size = UDim2.fromOffset(40, 40),
			Position = UDim2.new(1, -40, 0, 0),
			BackgroundTransparency = 1,
			Text = '',
			Parent = MainFrame
		})
		local settingsicon = Make('ImageLabel', {
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.fromOffset(15, 12),
			BackgroundTransparency = 1,
			Image = GetAsset('guisettings.png'),
			ImageColor3 = ColorLight(Pallet.Main, 0.37),
			Parent = settingsbutton
		})

		local settingspane = Make('TextButton', {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = ColorDark(Pallet.Main, 0.02),
			AutoButtonColor = false,
			Visible = false,
			Text = '',
			Parent = MainFrame
		})
		MakeCorner(settingspane)
		local settingsTitle = Make('TextLabel', {
			Name = 'Title',
			Size = UDim2.new(1, -36, 0, 20),
			Position = UDim2.fromOffset(36, 11),
			BackgroundTransparency = 1,
			Text = 'Settings',
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Pallet.Text,
			TextSize = 13,
			FontFace = Pallet.Font,
			Parent = settingspane
		})
		local close = addCloseButton(settingspane)
		close.Position = UDim2.new(1, -32, 0, 8)
		local back = Make('ImageButton', {
			Name = 'Back',
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(11, 13),
			BackgroundTransparency = 1,
			Image = GetAsset('bind.png'),
			ImageColor3 = ColorLight(Pallet.Main, 0.37),
			Parent = settingspane
		})

		settingsbutton.MouseEnter:Connect(function()
			settingsicon.ImageColor3 = Pallet.Text
		end)
		settingsbutton.MouseLeave:Connect(function()
			settingsicon.ImageColor3 = ColorLight(Pallet.Main, 0.37)
		end)
		settingsbutton.MouseButton1Click:Connect(function()
			settingspane.Visible = true
		end)
		back.MouseButton1Click:Connect(function()
			settingspane.Visible = false
		end)
		close.MouseButton1Click:Connect(function()
			settingspane.Visible = false
		end)
    ]]

	MainList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		local contentHeight = MainList.AbsoluteContentSize.Y
		MainFrame.Size = UDim2.fromOffset(220, 42 + contentHeight)
	end)

	setmetatable({ClickGui = ClickGui, MainFrame = MainFrame}, WindowClass)
	local windowApi = setmetatable({ClickGui = ClickGui, MainFrame = MainFrame}, WindowClass)

	-- Toggle GUI
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == VapeLibrary.Internal.ToggleKeybind then
			ClickGui.Visible = not ClickGui.Visible
			if VapeLibrary.Internal.BlurType == 'Blur' then
				VapeLibrary.Internal.Blur.Enabled = ClickGui.Visible
			else
				RunService:SetRobloxGuiFocused(ClickGui.Visible)
			end
		end
	end)

	return windowApi
end

function VapeLibrary:CreateNotification(NotificationSettings)
	NotificationSettings = NotificationSettings or {}
	local Settings = {
		Title = NotificationSettings.Title or "Default Name",
		Text = NotificationSettings.Text or "Default Text",
		Type = NotificationSettings.Type or "info",
		IsPinned = NotificationSettings.Pinned or false,
		Duration = NotificationSettings.Duration or 2.5
	}
	if not VapeLibrary.Internal.NotificationFrame then return end
	local Holder = VapeLibrary.Internal.NotificationFrame
	local Pallet = VapeLibrary.Internal.Pallet


	local Notification = Make("Frame", {
		Name = Settings.Title,
		Parent = Holder,
		BackgroundColor3 = Pallet.Main,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,00)
	}, {
		MakeBlur(nil, true),
		MakeOutline(nil, true),
		MakeCorner(),
		Make("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 74, 0, 74),
			Position = UDim2.new(0, -18, 0, -18),
			Image = GetAsset(Settings.Type .. ".png"),
		}),
		Make("TextLabel", {
			Size = UDim2.new(1, -44, 0, 28),
			Position = UDim2.new(0, 36, 0, 6),
			BackgroundTransparency = 1,
			Text = Settings.Title,
			TextSize = 16,
			FontFace = Pallet.Font,
			TextColor3 = Pallet.Text,
			Name = "Title",
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		Make("Frame", {
			Size = UDim2.new(1, -16, 0, 1), 
			Position = UDim2.new(0, 8, 0, 36), 
			BackgroundTransparency = 0.65, 
			BackgroundColor3 = Color3.fromRGB(131,131,131), 
			BorderSizePixel = 0
		}),
		Make("TextLabel", {
			Name = "Text",
			Size = UDim2.new(1, -16, 1, -48),
			Position = UDim2.new(0, 8, 0, 44),
			BackgroundTransparency = 1,
			Text = Settings.Text,
			TextSize = 14,
			FontFace = Pallet.Font,
			TextColor3 = Pallet.Text,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		Make("ImageLabel", {
			Name = "Pin",
			Image = GetAsset("pin.png"),
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1,-48, 0, 10),
			BackgroundTransparency = 1,
			ImageTransparency = 0.4,
			Visible = Settings.IsPinned,
		}),
		Make("TextLabel", {
			Name = "Time",
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1,-48, 0, 10),
			BackgroundTransparency = 1,
			Text = "<b>" .. Settings.Duration .. "</b>",
			TextSize = 14,
			RichText = true,
			FontFace = Pallet.Font,
			TextColor3 = Pallet.Text,
			Visible = not Settings.IsPinned,
		}),
		Make("ImageButton", {
			Name = "Close",
			Image = GetAsset("close.png"),
			Size = UDim2.new(0, 32, 0, 32),
			Position = UDim2.new(1,-34, 0, 2),
			BackgroundTransparency = 1,
			ImageTransparency = 0.4,
		})
	})

	local Size = GetTextSize(Settings.Text, Pallet.Font, Notification.AbsoluteSize.X - 16, 14)
	Notification.Text.Size = UDim2.new(1, -16, 0, Size.Y)
	Tween(Notification, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 60 + Size.Y),BackgroundTransparency = 0.15})

	local Closed = false

	local CloseTween = TweenService:Create(Notification, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1})

	CloseTween.Completed:Once(function()
		Notification:Destroy()
	end)

	Notification.Close.MouseButton1Click:Connect(function()
		CloseTween:Play()
		Closed = true
	end)

	if not Settings.IsPinned then
		local remaining = Settings.Duration
		local TimeLabel = Notification.Time

		while true do
			task.wait(0.1)

			if Closed then
				break
			end

			remaining -= 0.1
			TimeLabel.Text = string.format("<b>%.1f</b>", remaining)

			if remaining <= 0 then
				break
			end
		end

		if not Closed then
			CloseTween:Play()
		end
	end
end

return VapeLibrary
