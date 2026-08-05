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
			FontSemiBold = Font.fromEnum(Enum.Font.Arial, Enum.FontWeight.SemiBold),
			Tween = TweenInfo.new(0.16, Enum.EasingStyle.Linear)
		},
		ScreenGui = nil,
		MainFrame = nil,
		Blur = nil,
		Modules = {},
		Categories = {}
	},
	Version = "4.18"
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
	['vape.png'] = 'rbxassetid://14373395239'
}

local function GetTextSize(Text, font, MaxWidth, FontSize)
	if not (Text and font and MaxWidth and FontSize) then return Vector2.new(0,0) end 
	local TB = Instance.new('GetTextBoundsParams', nil)
	TB.Width = MaxWidth or math.huge
	TB.Size = FontSize or 16
	TB.Text = Text
	TB.Font = font
	return TextService:GetTextBoundsAsync(TB)
end

local function GetAsset(IconName)
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
	local Blur = Instance.new('ImageLabel')
	Blur.Name = 'Blur'
	Blur.Size = UDim2.new(1, 89, 1, 52)
	Blur.Position = UDim2.fromOffset(-48, -31)
	Blur.BackgroundTransparency = 1
	Blur.Image = GetAsset((notif and 'Blurnotif' or 'Blur')..'.png')
	Blur.ScaleType = Enum.ScaleType.Slice
	Blur.SliceCenter = Rect.new(52, 31, 261, 502)
	Blur.Parent = parent or nil
	return Blur
end

local function MakeCorner(parent, radius)
	local Corner = Instance.new('UICorner')
	Corner.CornerRadius = radius or UDim.new(0, 5)
	Corner.Parent = parent
	return Corner
end

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

local function AddTooltip(BoundingFrame, Text)
	if not Text then return end
	BoundingFrame.MouseEnter:Connect(function()
		-- Tooltip implementation
	end)
	BoundingFrame.MouseLeave:Connect(function()
		-- Tooltip hide
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

local function addCloseButton(parent, offset)
	local close = Instance.new('ImageButton')
	close.Name = 'Close'
	close.Size = UDim2.fromOffset(24, 24)
	close.Position = UDim2.new(1, -35, 0, offset or 9)
	close.BackgroundColor3 = Color3.new(1, 1, 1)
	close.BackgroundTransparency = 1
	close.AutoButtonColor = false
	close.Image = GetAsset('close.png')
	close.ImageColor3 = ColorLight(VapeLibrary.Internal.Pallet.Text, 0.2)
	close.ImageTransparency = 0.5
	close.Parent = parent
	MakeCorner(close, UDim.new(1, 0))

	close.MouseEnter:Connect(function()
		close.ImageTransparency = 0.3
		Tween(close, VapeLibrary.Internal.Pallet.Tween, {
			BackgroundTransparency = 0.6
		})
	end)
	close.MouseLeave:Connect(function()
		close.ImageTransparency = 0.5
		Tween(close, VapeLibrary.Internal.Pallet.Tween, {
			BackgroundTransparency = 1
		})
	end)

	return close
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
	local toggle = Instance.new('TextButton')
	toggle.Name = (optionsettings.Title or 'Default Name')..'Toggle'
	toggle.Size = UDim2.new(1, 0, 0, 30)
	toggle.BackgroundColor3 = Pallet.Module
	toggle.BorderSizePixel = 0
	toggle.AutoButtonColor = false
	toggle.Visible = optionsettings.Visible == nil or optionsettings.Visible
	toggle.Text = '   '..(optionsettings.Title or 'Default Name')
	toggle.TextXAlignment = Enum.TextXAlignment.Left
	toggle.TextColor3 = ColorDark(Pallet.Text, 0.16)
	toggle.TextSize = 14
	toggle.FontFace = Pallet.Font
	toggle.Parent = children
	local knobholder = Instance.new('Frame')
	knobholder.Name = 'Knob'
	knobholder.Size = UDim2.fromOffset(22, 12)
	knobholder.Position = UDim2.new(1, -30, 0, 9)
	knobholder.BackgroundColor3 = ColorLight(Pallet.Main, 0.14)
	knobholder.Parent = toggle
	MakeCorner(knobholder, UDim.new(1, 0))
	local knob = knobholder:Clone()
	knob.Size = UDim2.fromOffset(8, 8)
	knob.Position = UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = Pallet.Main
	knob.Parent = knobholder
	
	local function _Toggle()
		optionapi.Enabled = not optionapi.Enabled
		Tween(knobholder, Pallet.Tween, {
			BackgroundColor3 = optionapi.Enabled and Color3.fromHSV(VapeLibrary.Internal.GUIColor.Hue, VapeLibrary.Internal.GUIColor.Sat, VapeLibrary.Internal.GUIColor.Value) or (hovered and ColorLight(Pallet.Main, 0.37) or ColorLight(Pallet.Main, 0.14))
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
	local button = Instance.new('TextButton')
	button.Name = (optionsettings.Title or 'Default Name')..'Button'
	button.Size = UDim2.new(1, 0, 0, 31)
	button.BackgroundColor3 = Pallet.Module
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Visible = optionsettings.Visible == nil or optionsettings.Visible
	button.Text = ''
	button.Parent = children
	local bkg = Instance.new('Frame')
	bkg.Size = UDim2.fromOffset(200, 27)
	bkg.Position = UDim2.fromOffset(10, 2)
	bkg.BackgroundColor3 = ColorLight(Pallet.Main, 0.05)
	bkg.Parent = button
	MakeCorner(bkg)
	local label = Instance.new('TextLabel')
	label.Size = UDim2.new(1, -4, 1, -4)
	label.Position = UDim2.fromOffset(2, 2)
	label.BackgroundColor3 = Pallet.Main
	label.Text = optionsettings.Title or 'Default Name'
	label.TextColor3 = ColorDark(Pallet.Text, 0.16)
	label.TextSize = 14
	label.FontFace = Pallet.Font
	label.Parent = bkg
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

	local slider = Instance.new('TextButton')
	slider.Name = (optionsettings.Title or 'Default Name')..'Slider'
	slider.Size = UDim2.new(1, 0, 0, 50)
	slider.BackgroundColor3 = Pallet.Module
	slider.BorderSizePixel = 0
	slider.AutoButtonColor = false
	slider.Visible = optionsettings.Visible == nil or optionsettings.Visible
	slider.Text = ''
	slider.Parent = children
	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.fromOffset(60, 30)
	title.Position = UDim2.fromOffset(10, 2)
	title.BackgroundTransparency = 1
	title.Text = optionsettings.Title or 'Default Name'
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = ColorDark(Pallet.Text, 0.16)
	title.TextSize = 11
	title.FontFace = Pallet.Font
	title.Parent = slider
	local valuebutton = Instance.new('TextButton')
	valuebutton.Name = 'Value'
	valuebutton.Size = UDim2.fromOffset(60, 15)
	valuebutton.Position = UDim2.new(1, -69, 0, 9)
	valuebutton.BackgroundTransparency = 1
	valuebutton.Text = (optionsettings.Prefix or '')..optionapi.Value..(optionsettings.Suffix and ' '..(type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(optionapi.Value) or optionsettings.Suffix) or '')
	valuebutton.TextXAlignment = Enum.TextXAlignment.Right
	valuebutton.TextColor3 = ColorDark(Pallet.Text, 0.16)
	valuebutton.TextSize = 11
	valuebutton.FontFace = Pallet.Font
	valuebutton.Parent = slider
	local valuebox = Instance.new('TextBox')
	valuebox.Name = 'Box'
	valuebox.Size = valuebutton.Size
	valuebox.Position = valuebutton.Position
	valuebox.BackgroundTransparency = 1
	valuebox.Visible = false
	valuebox.Text = optionapi.Value
	valuebox.TextXAlignment = Enum.TextXAlignment.Right
	valuebox.TextColor3 = ColorDark(Pallet.Text, 0.16)
	valuebox.TextSize = 11
	valuebox.FontFace = Pallet.Font
	valuebox.ClearTextOnFocus = false
	valuebox.Parent = slider
	local bkg = Instance.new('Frame')
	bkg.Name = 'Slider'
	bkg.Size = UDim2.new(1, -20, 0, 2)
	bkg.Position = UDim2.fromOffset(10, 37)
	bkg.BackgroundColor3 = ColorLight(Pallet.Main, 0.034)
	bkg.BorderSizePixel = 0
	bkg.Parent = slider
	local fill = bkg:Clone()
	fill.Name = 'Fill'
	fill.Size = UDim2.fromScale(math.clamp((optionapi.Value - (optionsettings.Min or 0)) / (optionsettings.Max or 10), 0.04, 0.96), 1)
	fill.Position = UDim2.new()
	fill.BackgroundColor3 = Color3.fromHSV(VapeLibrary.Internal.GUIColor.Hue, VapeLibrary.Internal.GUIColor.Sat, VapeLibrary.Internal.GUIColor.Value)
	fill.Parent = bkg
	local knobholder = Instance.new('Frame')
	knobholder.Name = 'Knob'
	knobholder.Size = UDim2.fromOffset(24, 4)
	knobholder.Position = UDim2.fromScale(1, 0.5)
	knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
	knobholder.BackgroundColor3 = slider.BackgroundColor3
	knobholder.BorderSizePixel = 0
	knobholder.Parent = fill
	local knob = Instance.new('Frame')
	knob.Name = 'Knob'
	knob.Size = UDim2.fromOffset(14, 14)
	knob.Position = UDim2.fromScale(0.5, 0.5)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Color3.fromHSV(VapeLibrary.Internal.GUIColor.Hue, VapeLibrary.Internal.GUIColor.Sat, VapeLibrary.Internal.GUIColor.Value)
	knob.Parent = knobholder
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

	local dropdown = Instance.new('TextButton')
	dropdown.Name = (optionsettings.Title or 'Default Name')..'Dropdown'
	dropdown.Size = UDim2.new(1, 0, 0, 54)
	dropdown.BackgroundColor3 = Pallet.Module
	dropdown.BorderSizePixel = 0
	dropdown.AutoButtonColor = false
	dropdown.Visible = optionsettings.Visible == nil or optionsettings.Visible
	dropdown.Text = ''
	dropdown.Parent = children

	local titleLabel = Instance.new('TextLabel')
	titleLabel.Name = 'Title'
	titleLabel.Size = UDim2.new(1, -20, 0, 20)
	titleLabel.Position = UDim2.fromOffset(10, 2)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = (optionsettings.Title or 'Default Name')
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = ColorDark(Pallet.Text, 0.16)
	titleLabel.TextSize = 12
	titleLabel.FontFace = Pallet.Font
	titleLabel.Parent = dropdown

	local bkg = Instance.new('Frame')
	bkg.Name = 'BKG'
	bkg.Size = UDim2.new(1, -20, 0, 26)
	bkg.Position = UDim2.fromOffset(10, 24)
	bkg.BackgroundColor3 = ColorLight(Pallet.Main, 0.034)
	bkg.Parent = dropdown
	MakeCorner(bkg, UDim.new(0, 6))
	local button = Instance.new('TextButton')
	button.Name = 'Dropdown'
	button.Size = UDim2.new(1, -2, 1, -2)
	button.Position = UDim2.fromOffset(1, 1)
	button.BackgroundColor3 = Pallet.Main
	button.AutoButtonColor = false
	button.Text = ''
	button.Parent = bkg
	local displayLabel = Instance.new('TextLabel')
	displayLabel.Name = 'Display'
	displayLabel.Size = UDim2.new(1, -24, 1, 0)
	displayLabel.Position = UDim2.fromOffset(8, 0)
	displayLabel.BackgroundTransparency = 1
	local displayValue
	if optionsettings.AllowMultiple then
		displayValue = #optionapi.Value > 0 and table.concat(optionapi.Value, ", ") or "None"
	else
		displayValue = optionapi.Value
	end
	displayLabel.Text = displayValue
	displayLabel.TextXAlignment = Enum.TextXAlignment.Left
	displayLabel.TextColor3 = ColorDark(Pallet.Text, 0.16)
	displayLabel.TextSize = 12
	displayLabel.TextTruncate = Enum.TextTruncate.AtEnd
	displayLabel.FontFace = Pallet.Font
	displayLabel.Parent = button
	MakeCorner(button, UDim.new(0, 6))
	local arrow = Instance.new('ImageLabel')
	arrow.Name = 'Arrow'
	arrow.Size = UDim2.fromOffset(4, 8)
	arrow.Position = UDim2.new(1, -14, 0, 9)
	arrow.BackgroundTransparency = 1
	arrow.Image = GetAsset('expandright.png')
	arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
	arrow.Rotation = 90
	arrow.Parent = button
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
		dropdownchildren = Instance.new('Frame')
		dropdownchildren.Name = 'Children'
		dropdownchildren.Size = UDim2.new(1, 0, 0, (#optionsList) * 26)
		dropdownchildren.Position = UDim2.fromOffset(0, 51)
		dropdownchildren.BackgroundTransparency = 1
		dropdownchildren.Parent = dropdown
		local ind = 0
		for _, v in optionsList do
			local selected = isOptionSelected(v)
			local dropdownoption = Instance.new('TextButton')
			dropdownoption.Name = v..'Option'
			dropdownoption.Size = UDim2.new(1, 0, 0, 26)
			dropdownoption.Position = UDim2.fromOffset(0, ind * 26)
			dropdownoption.BackgroundColor3 = selected and Pallet.ModuleLight or Pallet.Main
			dropdownoption.BorderSizePixel = 0
			dropdownoption.AutoButtonColor = false
			dropdownoption.Text = '        '..v
			dropdownoption.TextXAlignment = Enum.TextXAlignment.Left
			dropdownoption.TextColor3 = ColorDark(Pallet.Text, 0.16)
			dropdownoption.TextSize = 13
			dropdownoption.TextTruncate = Enum.TextTruncate.AtEnd
			dropdownoption.FontFace = Pallet.Font
			dropdownoption.Parent = dropdownchildren
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

	local textbox = Instance.new('TextButton')
	textbox.Name = (optionsettings.Title or 'Default Name')..'TextBox'
	textbox.Size = UDim2.new(1, 0, 0, 58)
	textbox.BackgroundColor3 = Pallet.Module
	textbox.BorderSizePixel = 0
	textbox.AutoButtonColor = false
	textbox.Visible = optionsettings.Visible == nil or optionsettings.Visible
	textbox.Text = ''
	textbox.Parent = children
	local title = Instance.new('TextLabel')
	title.Size = UDim2.new(1, -30, 0, 20)
	title.Position = UDim2.fromOffset(15, 3)
	title.BackgroundTransparency = 1
	title.Text = optionsettings.Title or 'Default Name'
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Pallet.Text
	title.TextSize = 12
	title.FontFace = Pallet.Font
	title.Parent = textbox
	local bkg = Instance.new('Frame')
	bkg.Name = 'BKG'
	bkg.Size = UDim2.new(1, -20, 0, 29)
	bkg.Position = UDim2.fromOffset(10, 23)
	bkg.BackgroundColor3 = ColorLight(Pallet.ModuleLight, 0.02)
	bkg.Parent = textbox
	MakeCorner(bkg, UDim.new(0, 4))
	local box = Instance.new('TextBox')
	box.Size = UDim2.new(1, -8, 1, 0)
	box.Position = UDim2.fromOffset(8, 0)
	box.BackgroundTransparency = 1
	box.Text = optionsettings.Default or ''
	box.PlaceholderText = optionsettings.Placeholder or 'Click to set'
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextColor3 = ColorDark(Pallet.Text, 0.16)
	box.PlaceholderColor3 = ColorDark(Pallet.Text, 0.31)
	box.TextSize = 12
	box.FontFace = Pallet.Font
	box.ClearTextOnFocus = false
	box.Parent = bkg

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
	local divider = Instance.new('Frame')
	divider.Name = 'Divider'
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.BackgroundColor3 = ColorLight(Pallet.Main, 0.02)
	divider.BorderSizePixel = 0
	divider.Parent = children
	if text then
		local label = Instance.new('TextLabel')
		label.Name = 'DividerLabel'
		label.Size = UDim2.fromOffset(218, 27)
		label.BackgroundTransparency = 1
		label.Text = '     '..text:upper()
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextColor3 = ColorDark(Pallet.Text, 0.43)
		label.TextSize = 9
		label.FontFace = Pallet.Font
		label.Parent = children
		divider.Position = UDim2.fromOffset(0, 26)
		divider.Parent = label
	end
end
local function CreateLabel(optionsettings, children, api)
	local Pallet = VapeLibrary.Internal.Pallet
	local optionapi = {
		Type = 'Label',
		Name = optionsettings.Title or 'Default Name',
		Index = 0
	}

	local frame = Instance.new('Frame')
	frame.Name = (optionsettings.Title or 'Default Name')..'Label'
	frame.Size = UDim2.new(1, 0, 0, 32)
	frame.BackgroundColor3 = Pallet.Module
	frame.BorderSizePixel = 0
	frame.Visible = optionsettings.Visible == nil or optionsettings.Visible
	frame.Parent = children

	local textLabel = Instance.new('TextLabel')
	textLabel.Name = 'Text'
	textLabel.Size = UDim2.new(1, -16, 1, -6)
	textLabel.Position = UDim2.fromOffset(10, 3)
	textLabel.BackgroundTransparency = 1
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.TextColor3 = Pallet.Text
	textLabel.TextSize = 12
	textLabel.FontFace = Pallet.Font
	textLabel.RichText = optionsettings.RichText or false
	textLabel.TextWrapped = true
	textLabel.Text = optionapi.Name
	textLabel.Parent = frame

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

	local keybind = Instance.new('TextButton')
	keybind.Name = (optionsettings.Title or 'Default Name')..'Keybind'
	keybind.Size = UDim2.new(1, 0, 0, 34)
	keybind.BackgroundColor3 = Pallet.Module
	keybind.BorderSizePixel = 0
	keybind.AutoButtonColor = false
	keybind.Visible = optionsettings.Visible == nil or optionsettings.Visible
	keybind.Text = ''
	keybind.Parent = children

	local titleLabel = Instance.new('TextLabel')
	titleLabel.Name = 'Title'
	titleLabel.Size = UDim2.new(1, -80, 0, 34)
	titleLabel.Position = UDim2.fromOffset(10, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = (optionsettings.Title or 'Default Name')
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = ColorDark(Pallet.Text, 0.16)
	titleLabel.TextSize = 14
	titleLabel.FontFace = Pallet.Font
	titleLabel.Parent = keybind

	local bindBox = Instance.new('TextButton')
	bindBox.Name = 'BindBox'
	bindBox.Size = UDim2.fromOffset(24, 24)
	bindBox.Position = UDim2.new(1, -34, 0, 5)
	bindBox.BackgroundColor3 = ColorLight(Pallet.Main, 0.05)
	bindBox.Text = ''
	bindBox.AutoButtonColor = false
	bindBox.Parent = keybind
	MakeCorner(bindBox, UDim.new(0, 4))

	local bindIcon = Instance.new('ImageLabel')
	bindIcon.Name = 'BindIcon'
	bindIcon.Size = UDim2.fromOffset(12, 12)
	bindIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
	bindIcon.BackgroundTransparency = 1
	bindIcon.Image = GetAsset('bind.png')
	bindIcon.ImageColor3 = ColorDark(Pallet.Text, 0.16)
	bindIcon.Visible = false
	bindIcon.Parent = bindBox

	local bindLabel = Instance.new('TextLabel')
	bindLabel.Name = 'BindLabel'
	bindLabel.Size = UDim2.new(1, -8, 1, 0)
	bindLabel.Position = UDim2.fromOffset(4, 0)
	bindLabel.BackgroundTransparency = 1
	bindLabel.Text = optionapi.Value and optionapi.Value.Name or 'None'
	bindLabel.TextXAlignment = Enum.TextXAlignment.Center
	bindLabel.TextColor3 = ColorDark(Pallet.Text, 0.16)
	bindLabel.TextSize = 12
	bindLabel.FontFace = Pallet.Font
	bindLabel.Parent = bindBox

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
	local modulebutton = Instance.new('TextButton')
	modulebutton.Name = settings.Name
	modulebutton.Size = UDim2.new(1, 0, 0, 40)
	modulebutton.BackgroundColor3 = Pallet.Module
	modulebutton.BorderSizePixel = 0
	modulebutton.AutoButtonColor = false
	modulebutton.Text = '     '..settings.Name
	modulebutton.TextXAlignment = Enum.TextXAlignment.Left
	modulebutton.TextColor3 = ColorDark(Pallet.Text, 0.16)
	modulebutton.TextSize = 14
	modulebutton.FontFace = Pallet.Font
	modulebutton.Parent = parentTab.Children
	local gradient = Instance.new('UIGradient')
	gradient.Rotation = 90
	gradient.Enabled = false
	gradient.Parent = modulebutton
	local modulechildren = Instance.new('Frame')
	local dotsbutton = Instance.new('TextButton')
	dotsbutton.Name = 'Dots'
	dotsbutton.Size = UDim2.fromOffset(25, 40)
	dotsbutton.Position = UDim2.new(1, -25, 0, 0)
	dotsbutton.BackgroundTransparency = 1
	dotsbutton.Text = ''
	dotsbutton.Parent = modulebutton
	local dots = Instance.new('ImageLabel')
	dots.Name = 'Dots'
	dots.Size = UDim2.fromOffset(3, 16)
	dots.Position = UDim2.fromOffset(4, 12)
	dots.BackgroundTransparency = 1
	dots.Image = GetAsset('dots.png')
	dots.ImageColor3 = ColorLight(Pallet.Main, 0.37)
	dots.Parent = dotsbutton
	modulechildren.Name = settings.Name..'Children'
	modulechildren.Size = UDim2.new(1, 0, 0, 0)
	modulechildren.BackgroundColor3 = ColorDark(Pallet.Module, 0.02)
	modulechildren.BorderSizePixel = 0
	modulechildren.Visible = false
	modulechildren.Parent = parentTab.Children
	moduleapi.Children = modulechildren
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	windowlist.Parent = modulechildren
	local dividerFrame = Instance.new('Frame')
	dividerFrame.Name = 'Divider'
	dividerFrame.Size = UDim2.new(1, 0, 0, 1)
	dividerFrame.Position = UDim2.new(0, 0, 1, -1)
	dividerFrame.BackgroundColor3 = Color3.new(0.19, 0.19, 0.19)
	dividerFrame.BackgroundTransparency = 0.52
	dividerFrame.BorderSizePixel = 0
	dividerFrame.Visible = false
	dividerFrame.Parent = modulebutton
	settings.Function = settings.Function or function() end
	addMaid(moduleapi)

	function moduleapi:Toggle(multiple)
		self.Enabled = not self.Enabled
		dividerFrame.Visible = self.Enabled
		gradient.Enabled = self.Enabled
		modulebutton.TextColor3 = (hovered or modulechildren.Visible) and Pallet.Text or ColorDark(Pallet.Text, 0.16)
		local baseColor = self.Enabled and Pallet.ModuleLight or Pallet.Module
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
		end
	end)
	dotsbutton.MouseLeave:Connect(function()
		if not moduleapi.Enabled then
			dots.ImageColor3 = ColorLight(Pallet.Module, 0.37)
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
			local baseColor = moduleapi.Enabled and Pallet.ModuleLight or Pallet.Module
			modulebutton.TextColor3 = Pallet.Text
			modulebutton.BackgroundColor3 = ColorLight(baseColor, 0.02)
		end
	end)
	modulebutton.MouseLeave:Connect(function()
		hovered = false
		if not modulechildren.Visible then
			local baseColor = moduleapi.Enabled and Pallet.ModuleLight or Pallet.Module
			modulebutton.TextColor3 = ColorDark(Pallet.Text, 0.16)
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

	local window = Instance.new('TextButton')
	window.Name = settings.Name..'Category'
	window.Size = UDim2.fromOffset(220, 41)
	window.Position = UDim2.fromOffset(236, 60)
	window.BackgroundColor3 = Pallet.Main
	window.AutoButtonColor = false
	window.Visible = false
	window.Text = ''
	window.Parent = VapeLibrary.Internal.ClickGui
	MakeBlur(window)
	MakeCorner(window)
	MakeDraggable(window)
	local icon = Instance.new('ImageLabel')
	icon.Name = 'Icon'
	icon.Size = settings.Size or UDim2.fromOffset(16, 16)
	icon.Position = UDim2.fromOffset(12, (icon.Size.X.Offset > 20 and 14 or 13))
	icon.BackgroundTransparency = 1
	icon.Image = GetAsset(settings.Icon or 'combaticon.png')
	icon.ImageColor3 = Pallet.Text
	icon.Parent = window
	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.new(1, -((settings.Size and settings.Size.X.Offset or 16) > 18 and 40 or 33), 0, 41)
	title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 0)
	title.BackgroundTransparency = 1
	title.Text = settings.Name
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Pallet.Text
	title.TextSize = 13
	title.FontFace = Pallet.Font
	title.Parent = window
	local arrowbutton = Instance.new('TextButton')
	arrowbutton.Name = 'Arrow'
	arrowbutton.Size = UDim2.fromOffset(40, 40)
	arrowbutton.Position = UDim2.new(1, -40, 0, 0)
	arrowbutton.BackgroundTransparency = 1
	arrowbutton.Text = ''
	arrowbutton.Parent = window
	local arrow = Instance.new('ImageLabel')
	arrow.Name = 'Arrow'
	arrow.Size = UDim2.fromOffset(9, 4)
	arrow.Position = UDim2.fromOffset(20, 18)
	arrow.BackgroundTransparency = 1
	arrow.Image = GetAsset('expandup.png')
	arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
	arrow.Rotation = 180
	arrow.Parent = arrowbutton
	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 1, -41)
	children.Position = UDim2.fromOffset(0, 37)
	children.BackgroundTransparency = 1
	children.BorderSizePixel = 0
	children.Visible = false
	children.ScrollBarThickness = 2
	children.ScrollBarImageTransparency = 0.75
	children.CanvasSize = UDim2.new()
	children.Parent = window
	local dividerFrame = Instance.new('Frame')
	dividerFrame.Name = 'Divider'
	dividerFrame.Size = UDim2.new(1, 0, 0, 1)
	dividerFrame.Position = UDim2.fromOffset(0, 37)
	dividerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	dividerFrame.BackgroundTransparency = 0.928
	dividerFrame.BorderSizePixel = 0
	dividerFrame.Parent = window
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	windowlist.Parent = children
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
	local categoryButton = Instance.new('TextButton')
	categoryButton.Name = settings.Name
	categoryButton.Size = UDim2.new(1, 0, 0, 40)
	categoryButton.BackgroundColor3 = Pallet.Main
	categoryButton.BorderSizePixel = 0
	categoryButton.AutoButtonColor = false
	categoryButton.Text = (settings.Icon and string.rep(" ", 12) or "    ")..settings.Name
	categoryButton.TextColor3 = ColorDark(Pallet.Text, 0.16)
	categoryButton.TextSize = 14
	categoryButton.TextXAlignment = Enum.TextXAlignment.Left
	categoryButton.FontFace = Pallet.Font
	categoryButton.Parent = VapeLibrary.Internal.MainChildren
	local catIcon
	if settings.Icon then
		catIcon = Instance.new('ImageLabel')
		catIcon.Name = 'Icon'
		catIcon.Size = settings.Size or UDim2.fromOffset(16, 16)
		catIcon.Position = UDim2.fromOffset(13, 13)
		catIcon.BackgroundTransparency = 1
		catIcon.Image = GetAsset(settings.Icon)
		catIcon.ImageColor3 = ColorDark(Pallet.Text, 0.16)
		catIcon.Parent = categoryButton
	end
	local catArrow = Instance.new('ImageLabel')
	catArrow.Name = 'Arrow'
	catArrow.Size = UDim2.fromOffset(4, 8)
	catArrow.Position = UDim2.new(1, -20, 0, 16)
	catArrow.BackgroundTransparency = 1
	catArrow.Image = GetAsset('expandright.png')
	catArrow.ImageColor3 = ColorLight(Pallet.Main, 0.37)
	catArrow.Parent = categoryButton

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
		categoryButton.TextColor3 = self.Enabled and Color3.fromHSV(VapeLibrary.Internal.GUIColor.Hue, VapeLibrary.Internal.GUIColor.Sat, VapeLibrary.Internal.GUIColor.Value) or Pallet.Text
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

function VapeLibrary:CreateWindow(settings)
	settings = settings or {}
	local Pallet = VapeLibrary.Internal.Pallet
	VapeLibrary.Internal.ScreenGui = Instance.new("ScreenGui", gethui and gethui() or cloneref(game:GetService("Players")).LocalPlayer.PlayerGui)
	VapeLibrary.Internal.ScreenGui.IgnoreGuiInset = true
	VapeLibrary.Internal.ScreenGui.Name = RandomString()

	if VapeLibrary.Internal.BlurType == "CoreGui" then
		VapeLibrary.Internal.ScreenGui.OnTopOfCoreBlur = true
	else
		VapeLibrary.Internal.Blur = Make("BlurEffect", {
			Name = "Vape",
			Enabled = false,
			Parent = game:GetService("Lighting"),
			Size = 36
		})
	end

	local Holder = Make("Frame", {Name = "Holder", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = VapeLibrary.Internal.ScreenGui})

	local ClickGui = Make("Frame", {
		Name = "ClickGui",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = Holder
	})
	VapeLibrary.Internal.ClickGui = ClickGui    

	local UIScale = Make("UIScale", {
		Parent = ClickGui,
		Scale = math.max(VapeLibrary.Internal.ScreenGui.AbsoluteSize.X / 1920, 1)
	})

	local MainFrame = Make("TextButton", {
		Name = "GUICategory",
		Position = UDim2.fromOffset(6, 60),
		Size = UDim2.fromOffset(220, 41),
		BackgroundColor3 = ColorDark(Pallet.Main, 0.02),
		AutoButtonColor = false,
		Text = '',
		Parent = ClickGui
	})

	local SizeConstraint = Make("UISizeConstraint", {
		MinSize = Vector2.new(0,500),
		MaxSize = Vector2.new(math.huge, math.huge),
		Parent = MainFrame
	})
	VapeLibrary.Internal.MainFrame = MainFrame
	MakeBlur(MainFrame)
	MakeCorner(MainFrame)
	MakeDraggable(MainFrame)

	local logo = Instance.new('ImageLabel')
	logo.Name = 'VapeLogo'
	logo.Size = UDim2.fromOffset(62, 18)
	logo.Position = UDim2.fromOffset(11, 10)
	logo.BackgroundTransparency = 1
	logo.Image = GetAsset('guivape.png')
	logo.ImageColor3 = select(3, Pallet.Main:ToHSV()) > 0.5 and Pallet.Text or Color3.new(1, 1, 1)
	logo.Parent = MainFrame
	local logov4 = Instance.new('ImageLabel')
	logov4.Name = 'V4Logo'
	logov4.Size = UDim2.fromOffset(28, 16)
	logov4.Position = UDim2.new(1, 1, 0, 1)
	logov4.BackgroundTransparency = 1
	logov4.Image = GetAsset('guiv4.png')
	logov4.ImageColor3 = Color3.fromRGB(5, 132, 102)
	logov4.Parent = logo

	local MainChildren = Instance.new('Frame')
	MainChildren.Name = 'Children'
	MainChildren.Size = UDim2.new(1, 0, 1, -33)
	MainChildren.Position = UDim2.fromOffset(0, 37)
	MainChildren.BackgroundTransparency = 1
	MainChildren.BorderSizePixel = 0
	MainChildren.Parent = MainFrame
	VapeLibrary.Internal.MainChildren = MainChildren
	local MainList = Instance.new('UIListLayout')
	MainList.SortOrder = Enum.SortOrder.LayoutOrder
	MainList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	MainList.Parent = MainChildren

	if settings.MakeSettings ~= false then
		local settingsbutton = Instance.new('TextButton')
		settingsbutton.Name = 'Settings'
		settingsbutton.Size = UDim2.fromOffset(40, 40)
		settingsbutton.Position = UDim2.new(1, -40, 0, 0)
		settingsbutton.BackgroundTransparency = 1
		settingsbutton.Text = ''
		settingsbutton.Parent = MainFrame
		local settingsicon = Instance.new('ImageLabel')
		settingsicon.Size = UDim2.fromOffset(14, 14)
		settingsicon.Position = UDim2.fromOffset(15, 12)
		settingsicon.BackgroundTransparency = 1
		settingsicon.Image = GetAsset('guisettings.png')
		settingsicon.ImageColor3 = ColorLight(Pallet.Main, 0.37)
		settingsicon.Parent = settingsbutton

		local settingspane = Instance.new('TextButton')
		settingspane.Size = UDim2.fromScale(1, 1)
		settingspane.BackgroundColor3 = ColorDark(Pallet.Main, 0.02)
		settingspane.AutoButtonColor = false
		settingspane.Visible = false
		settingspane.Text = ''
		settingspane.Parent = MainFrame
		MakeCorner(settingspane)
		local settingsTitle = Instance.new('TextLabel')
		settingsTitle.Name = 'Title'
		settingsTitle.Size = UDim2.new(1, -36, 0, 20)
		settingsTitle.Position = UDim2.fromOffset(36, 11)
		settingsTitle.BackgroundTransparency = 1
		settingsTitle.Text = 'Settings'
		settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
		settingsTitle.TextColor3 = Pallet.Text
		settingsTitle.TextSize = 13
		settingsTitle.FontFace = Pallet.Font
		settingsTitle.Parent = settingspane
		local close = addCloseButton(settingspane)
		close.Position = UDim2.new(1, -32, 0, 8)
		local back = Instance.new('ImageButton')
		back.Name = 'Back'
		back.Size = UDim2.fromOffset(16, 16)
		back.Position = UDim2.fromOffset(11, 13)
		back.BackgroundTransparency = 1
		back.Image = GetAsset('bind.png')
		back.ImageColor3 = ColorLight(Pallet.Main, 0.37)
		back.Parent = settingspane

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
	end

	MainList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		local contentHeight = MainList.AbsoluteContentSize.Y
		MainFrame.Size = UDim2.fromOffset(220, 42 + contentHeight)
	end)

	VapeLibrary.Internal.GUIColor = {
		Hue = 0.46,
		Sat = 0.96,
		Value = 0.52
	}

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

return VapeLibrary
