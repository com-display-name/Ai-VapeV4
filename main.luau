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
			Accent = Color3.fromRGB(5, 132, 102),
			Outline = Color3.fromRGB(131, 131, 131),
			OutlineBright = Color3.fromRGB(190, 190, 190),
			Divider = Color3.new(0.19, 0.19, 0.19),
			DividerLight = Color3.new(1, 1, 1),
			IconGray = Color3.fromRGB(140, 140, 140),
			IconHover = Color3.fromRGB(220, 220, 220),
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

local CloneRef = cloneref or function(...) return ... end

local TweenService = CloneRef(game:GetService('TweenService'))
local UserInputService = CloneRef(game:GetService('UserInputService'))
local TextService = CloneRef(game:GetService('TextService'))
local GuiService = CloneRef(game:GetService('GuiService'))
local RunService = CloneRef(game:GetService('RunService'))
local Players = CloneRef(game:GetService("Players"))

local Assets = {
	['arrowmodule.png'] = 'rbxassetid://14473354880',
	['blur.png'] = 'rbxassetid://14898786664',
	['blurnotif.png'] = 'rbxassetid://16738720137',
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

local function IsMouseInFrame(Frame)
	local Mouse = Players.LocalPlayer:GetMouse()
	local Pos = Vector2.new(Mouse.X, Mouse.Y)

	local IsInX = Frame.AbsolutePosition.X <= Pos.X and Pos.Y <= (Frame.AbsolutePosition.X + Frame.AbsoluteSize.X)
	local IsInY = Frame.AbsolutePosition.Y <= Pos.Y and Pos.Y <= (Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y)

	return IsInX and IsInY

end

local function Make(ClassName, Properties, Children)
	local Instance = Instance.new(ClassName)
	for i, v in pairs(Properties or {}) do
		Instance[i] = v
	end
	for _, v in pairs(Children or {}) do
		v.Parent = Instance
	end
	return Instance
end

local function GetTextSize(Text, Font, MaxWidth, FontSize)
	if not (Text and Font and MaxWidth and FontSize) then return Vector2.new(0, 0) end
	local TextBounds = Make("GetTextBoundsParams", {
		Parent = nil,
		Width = MaxWidth or math.huge,
		Size = FontSize or 16,
		Text = Text,
		Font = Font
	})
	return TextService:GetTextBoundsAsync(TextBounds)
end

local function GetAsset(IconName : string | number)
	if type(IconName) == "number" then
		return "rbxassetid://" .. IconName
	elseif type(IconName) == "string" and string.sub(IconName, 1, 12) == "rbxassetid://" then
		return IconName
	end
	return Assets[IconName] or ""
end

local function ColorDark(Color, Amount)
	local H, S, V = Color:ToHSV()
	return Color3.fromHSV(H, S, math.clamp(select(3, VapeLibrary.Internal.Pallet.Main:ToHSV()) > 0.5 and V + Amount or V - Amount, 0, 1))
end

local function ColorLight(Color, Amount)
	local H, S, V = Color:ToHSV()
	return Color3.fromHSV(H, S, math.clamp(select(3, VapeLibrary.Internal.Pallet.Main:ToHSV()) > 0.5 and V - Amount or V + Amount, 0, 1))
end

local function Tween(Object, TweenInfo, Goal)
	if Object.Parent and Object.Visible then
		local TweenObject = TweenService:Create(Object, TweenInfo or VapeLibrary.Internal.Pallet.Tween, Goal)
		TweenObject:Play()
		return TweenObject
	else
		for i, v in Goal do
			Object[i] = v
		end
	end
end

local function MakeBlur(Parent, IsNotification)
	return Make('ImageLabel', {
		Name = 'Blur',
		Size = UDim2.new(1, 89, 1, 52),
		Position = UDim2.fromOffset(-48, -31),
		BackgroundTransparency = 1,
		Image = GetAsset((IsNotification and 'blurnotif' or 'blur')..'.png'),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(52, 31, 261, 502),
		Parent = Parent or nil
	})
end

local function MakeCorner(Parent, Radius)
	return Make('UICorner', {
		CornerRadius = Radius or UDim.new(0, 5),
		Parent = Parent
	})
end

local function MakeOutline(Parent, MakeBright)
	return Make("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = MakeBright and VapeLibrary.Internal.Pallet.OutlineBright or VapeLibrary.Internal.Pallet.Outline,
		Transparency = MakeBright and 0.75 or 0,
		Parent = Parent
	})
end

local function MakeDraggable(Gui, Window)
	Gui.InputBegan:Connect(function(InputObject)
		if Window and not Window.Visible then return end
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1
			and (InputObject.Position.Y - Gui.AbsolutePosition.Y < 40 or Window)
		then
			local DragPosition = Vector2.new(
				Gui.AbsolutePosition.X - InputObject.Position.X,
				Gui.AbsolutePosition.Y - InputObject.Position.Y + GuiService:GetGuiInset().Y
			)

			local Changed = UserInputService.InputChanged:Connect(function(Input)
				if Input.UserInputType == (InputObject.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local Position = Input.Position
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						DragPosition = (DragPosition // 3) * 3
						Position = (Position // 3) * 3
					end
					Gui.Position = UDim2.fromOffset(Position.X + DragPosition.X, Position.Y + DragPosition.Y)
				end
			end)

			local Ended
			Ended = InputObject.Changed:Connect(function()
				if InputObject.UserInputState == Enum.UserInputState.End then
					if Changed then Changed:Disconnect() end
					if Ended then Ended:Disconnect() end
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
			Tween(Tooltip, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0, Size.X, 0, Size.Y)})

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
			Tween(Tooltip, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0)})
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
	local Array = {}
	for i = 1, Length or 10 do
		Array[i] = string.char(math.random(32, 126))
	end
	return table.concat(Array)
end

local function GetTableSize(Table)
	local Count = 0
	for _ in Table do Count += 1 end
	return Count
end

local function AddMaid(Object)
	Object.Connections = {}
	function Object:Clean(Callback)
		if typeof(Callback) == 'Instance' then
			table.insert(self.Connections, {
				Disconnect = function()
					Callback:ClearAllChildren()
					Callback:Destroy()
				end
			})
		elseif type(Callback) == 'function' then
			table.insert(self.Connections, {
				Disconnect = Callback
			})
		else
			table.insert(self.Connections, Callback)
		end
	end
	function Object:CleanAll()
		for _, Connection in self.Connections do
			Connection:Disconnect()
		end
		table.clear(self.Connections)
	end
end

local function CreateToggle(OptionSettings, Children, Api, IsModuleElement)
	local Pallet = VapeLibrary.Internal.Pallet
	local OptionApi = {
		Type = 'Toggle',
		Enabled = OptionSettings.Default or false,
		Index = GetTableSize(Api.Options)
	}

	local Hovered = false
	local ToggleButton = Make('TextButton', {
		Name = (OptionSettings.Title or 'Default Name')..'Toggle',
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = IsModuleElement and Pallet.Main or Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = OptionSettings.Visible == nil or OptionSettings.Visible,
		Text = '   '..(OptionSettings.Title or 'Default Name'),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 14,
		FontFace = Pallet.Font,
		Parent = Children
	})
	local KnobHolder = Make('Frame', {
		Name = 'Knob',
		Size = UDim2.fromOffset(22, 12),
		Position = UDim2.new(1, -30, 0, 9),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.14),
		Parent = ToggleButton
	})
	MakeCorner(KnobHolder, UDim.new(1, 0))
	local Knob = KnobHolder:Clone()
	Knob.Size = UDim2.fromOffset(8, 8)
	Knob.Position = UDim2.fromOffset(2, 2)
	Knob.BackgroundColor3 = Pallet.Main
	Knob.Parent = KnobHolder

	local function InternalToggle()
		OptionApi.Enabled = not OptionApi.Enabled
		Tween(KnobHolder, Pallet.Tween, {
			BackgroundColor3 = OptionApi.Enabled and Color3.fromHSV(VapeLibrary.Internal.Pallet.GUIColor.Hue, VapeLibrary.Internal.Pallet.GUIColor.Sat, VapeLibrary.Internal.Pallet.GUIColor.Value) or (Hovered and ColorLight(Pallet.Main, 0.37) or ColorLight(Pallet.Main, 0.14))
		})
		Tween(Knob, Pallet.Tween, {
			Position = UDim2.fromOffset(OptionApi.Enabled and 12 or 2, 2)
		})
	end

	function OptionApi:Toggle()
		InternalToggle()
		if OptionSettings.Function then
			OptionSettings.Function(OptionApi.Enabled)
		end
	end

	function OptionApi:SetValue(Val)
		if type(Val) ~= 'boolean' then return end
		if self.Enabled ~= Val then
			InternalToggle()
		end
		if OptionSettings.Function then
			OptionSettings.Function(Val)
		end
	end

	ToggleButton.MouseEnter:Connect(function()
		Hovered = true
		if not OptionApi.Enabled then
			Tween(KnobHolder, Pallet.Tween, {
				BackgroundColor3 = ColorLight(Pallet.Main, 0.37)
			})
		end
	end)
	ToggleButton.MouseLeave:Connect(function()
		Hovered = false
		if not OptionApi.Enabled then
			Tween(KnobHolder, Pallet.Tween, {
				BackgroundColor3 = ColorLight(Pallet.Main, 0.14)
			})
		end
	end)
	ToggleButton.MouseButton1Click:Connect(function()
		OptionApi:Toggle()
	end)

	if OptionSettings.Default then
		InternalToggle()
	end
	OptionApi.Object = ToggleButton
	Api.Options[OptionSettings.Title or 'Default Name'] = OptionApi
	return OptionApi
end

local function CreateButton(OptionSettings, Children, Api, IsModuleElement)
	local Pallet = VapeLibrary.Internal.Pallet
	local OptionApi = {
		Type = 'Button',
		Index = GetTableSize(Api.Options)
	}

	local Button = Make('TextButton', {
		Name = (OptionSettings.Title or 'Default Name')..'Button',
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundColor3 = IsModuleElement and Pallet.Main or Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = OptionSettings.Visible == nil or OptionSettings.Visible,
		Text = '',
		Parent = Children
	})
	local Background = Make('Frame', {
		Size = UDim2.fromOffset(200, 27),
		Position = UDim2.fromOffset(10, 2),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.05),
		Parent = Button
	})
	MakeCorner(Background)
	local Label = Make('TextLabel', {
		Size = UDim2.new(1, -4, 1, -4),
		Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Pallet.Main,
		Text = OptionSettings.Title or 'Default Name',
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 14,
		FontFace = Pallet.Font,
		Parent = Background
	})
	MakeCorner(Label, UDim.new(0, 4))

	function OptionApi:Click()
		if OptionSettings.Function then
			OptionSettings.Function()
		end
	end

	Button.MouseEnter:Connect(function()
		Tween(Background, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.0875)
		})
	end)
	Button.MouseLeave:Connect(function()
		Tween(Background, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.05)
		})
	end)
	Button.MouseButton1Click:Connect(function()
		OptionApi:Click()
	end)

	OptionApi.Object = Button
	Api.Options[OptionSettings.Title or 'Default Name'] = OptionApi
	return OptionApi
end

local function CreateSlider(OptionSettings, Children, Api, IsModuleElement)
	local Pallet = VapeLibrary.Internal.Pallet
	local OptionApi = {
		Type = 'Slider',
		Value = OptionSettings.Default or OptionSettings.Min or 0,
		Max = OptionSettings.Max or 10,
		Index = GetTableSize(Api.Options)
	}

	local Slider = Make('TextButton', {
		Name = (OptionSettings.Title or 'Default Name')..'Slider',
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = IsModuleElement and Pallet.Main or Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = OptionSettings.Visible == nil or OptionSettings.Visible,
		Text = '',
		Parent = Children
	})
	local Title = Make('TextLabel', {
		Name = 'Title',
		Size = UDim2.fromOffset(60, 30),
		Position = UDim2.fromOffset(10, 2),
		BackgroundTransparency = 1,
		Text = OptionSettings.Title or 'Default Name',
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 11,
		FontFace = Pallet.Font,
		Parent = Slider
	})
	local ValueButton = Make('TextButton', {
		Name = 'Value',
		Size = UDim2.fromOffset(60, 15),
		Position = UDim2.new(1, -69, 0, 9),
		BackgroundTransparency = 1,
		Text = (OptionSettings.Prefix or '')..OptionApi.Value..(OptionSettings.Suffix and ' '..(type(OptionSettings.Suffix) == 'function' and OptionSettings.Suffix(OptionApi.Value) or OptionSettings.Suffix) or ''),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 11,
		FontFace = Pallet.Font,
		Parent = Slider
	})
	local ValueBox = Make('TextBox', {
		Name = 'Box',
		Size = ValueButton.Size,
		Position = ValueButton.Position,
		BackgroundTransparency = 1,
		Visible = false,
		Text = OptionApi.Value,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 11,
		FontFace = Pallet.Font,
		ClearTextOnFocus = false,
		Parent = Slider
	})
	local Background = Make('Frame', {
		Name = 'Slider',
		Size = UDim2.new(1, -20, 0, 2),
		Position = UDim2.fromOffset(10, 37),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.034),
		BorderSizePixel = 0,
		Parent = Slider
	})
	local Fill = Background:Clone()
	Fill.Name = 'Fill'
	Fill.Size = UDim2.fromScale(math.clamp((OptionApi.Value - (OptionSettings.Min or 0)) / (OptionSettings.Max or 10), 0.04, 0.96), 1)
	Fill.Position = UDim2.new()
	Fill.BackgroundColor3 = Color3.fromHSV(VapeLibrary.Internal.Pallet.GUIColor.Hue, VapeLibrary.Internal.Pallet.GUIColor.Sat, VapeLibrary.Internal.Pallet.GUIColor.Value)
	Fill.Parent = Background
	local KnobHolder = Make('Frame', {
		Name = 'Knob',
		Size = UDim2.fromOffset(24, 4),
		Position = UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Slider.BackgroundColor3,
		BorderSizePixel = 0,
		Parent = Fill
	})
	local Knob = Make('Frame', {
		Name = 'Knob',
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHSV(VapeLibrary.Internal.Pallet.GUIColor.Hue, VapeLibrary.Internal.Pallet.GUIColor.Sat, VapeLibrary.Internal.Pallet.GUIColor.Value),
		Parent = KnobHolder
	})
	MakeCorner(Knob, UDim.new(1, 0))
	OptionSettings.Increment = OptionSettings.Increment or 1
	OptionSettings.Min = OptionSettings.Min or 0
	OptionSettings.Max = OptionSettings.Max or 10

	local IncrementValue = OptionSettings.Increment
	if IncrementValue ~= 0 then
		IncrementValue = 1 / IncrementValue
	else
		IncrementValue = 1
	end

	function OptionApi:SetValue(Value, Position, Final)
		if tonumber(Value) == math.huge or Value ~= Value then return end
		local Check = self.Value ~= Value
		self.Value = Value
		Tween(Fill, Pallet.Tween, {
			Size = UDim2.fromScale(math.clamp(Position or math.clamp((Value - OptionSettings.Min) / (OptionSettings.Max - OptionSettings.Min), 0, 1), 0.04, 0.96), 1)
		})
		ValueButton.Text = (OptionSettings.Prefix or '')..self.Value..(OptionSettings.Suffix and ' '..(type(OptionSettings.Suffix) == 'function' and OptionSettings.Suffix(self.Value) or OptionSettings.Suffix) or '')
		if (Check or Final) and OptionSettings.Function then
			OptionSettings.Function(Value, Final)
		end
	end

	Slider.InputBegan:Connect(function(InputObject)
		if
			(InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch)
			and (InputObject.Position.Y - Slider.AbsolutePosition.Y) > (20 * 1)
		then
			local NewPosition = math.clamp((InputObject.Position.X - Background.AbsolutePosition.X) / Background.AbsoluteSize.X, 0, 1)
			OptionApi:SetValue(math.floor((OptionSettings.Min + (OptionSettings.Max - OptionSettings.Min) * NewPosition) * IncrementValue) / IncrementValue, NewPosition)
			local LastValue = OptionApi.Value
			local LastPosition = NewPosition

			local Changed = UserInputService.InputChanged:Connect(function(Input)
				if Input.UserInputType == (InputObject.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local NewPosition = math.clamp((Input.Position.X - Background.AbsolutePosition.X) / Background.AbsoluteSize.X, 0, 1)
					OptionApi:SetValue(math.floor((OptionSettings.Min + (OptionSettings.Max - OptionSettings.Min) * NewPosition) * IncrementValue) / IncrementValue, NewPosition)
					LastValue = OptionApi.Value
					LastPosition = NewPosition
				end
			end)

			local Ended
			Ended = InputObject.Changed:Connect(function()
				if InputObject.UserInputState == Enum.UserInputState.End then
					if Changed then Changed:Disconnect() end
					if Ended then Ended:Disconnect() end
					OptionApi:SetValue(LastValue, LastPosition, true)
				end
			end)
		end
	end)
	Slider.MouseEnter:Connect(function()
		Tween(Knob, Pallet.Tween, {
			Size = UDim2.fromOffset(16, 16)
		})
	end)
	Slider.MouseLeave:Connect(function()
		Tween(Knob, Pallet.Tween, {
			Size = UDim2.fromOffset(14, 14)
		})
	end)
	ValueButton.MouseButton1Click:Connect(function()
		ValueButton.Visible = false
		ValueBox.Visible = true
		ValueBox.Text = OptionApi.Value
		ValueBox:CaptureFocus()
	end)
	ValueBox.FocusLost:Connect(function(Enter)
		ValueButton.Visible = true
		ValueBox.Visible = false
		if Enter and tonumber(ValueBox.Text) then
			OptionApi:SetValue(tonumber(ValueBox.Text), nil, true)
		end
	end)

	OptionApi.Object = Slider
	Api.Options[OptionSettings.Title or 'Default Name'] = OptionApi
	return OptionApi
end

local function CreateDropdown(OptionSettings, Children, Api, IsModuleElement)
	local Pallet = VapeLibrary.Internal.Pallet
	local OptionsList = OptionSettings.Options or {"Option 1", "Option 2"}
	local OptionApi = {
		Type = 'Dropdown',
		Value = OptionSettings.AllowMultiple and {} or (OptionSettings.Default or OptionsList[1] or 'None'),
		Index = GetTableSize(Api.Options)
	}

	local Dropdown = Make('TextButton', {
		Name = (OptionSettings.Title or 'Default Name')..'Dropdown',
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundColor3 = IsModuleElement and Pallet.Main or Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = OptionSettings.Visible == nil or OptionSettings.Visible,
		Text = '',
		Parent = Children
	})

	local TitleLabel = Make('TextLabel', {
		Name = 'Title',
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.fromOffset(10, 2),
		BackgroundTransparency = 1,
		Text = (OptionSettings.Title or 'Default Name'),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 12,
		FontFace = Pallet.Font,
		Parent = Dropdown
	})

	local Background = Make('Frame', {
		Name = 'BKG',
		Size = UDim2.new(1, -20, 0, 26),
		Position = UDim2.fromOffset(10, 24),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.034),
		Parent = Dropdown
	})
	MakeCorner(Background, UDim.new(0, 6))
	local Button = Make('TextButton', {
		Name = 'Dropdown',
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.fromOffset(1, 1),
		BackgroundColor3 = Pallet.Main,
		AutoButtonColor = false,
		Text = '',
		Parent = Background
	})
	local DisplayLabel = Make('TextLabel', {
		Name = 'Display',
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		FontFace = Pallet.Font,
		Parent = Button
	})
	local DisplayValue
	if OptionSettings.AllowMultiple then
		DisplayValue = #OptionApi.Value > 0 and table.concat(OptionApi.Value, ", ") or "None"
	else
		DisplayValue = OptionApi.Value
	end
	DisplayLabel.Text = DisplayValue
	MakeCorner(Button, UDim.new(0, 6))
	local Arrow = Make('ImageLabel', {
		Name = 'Arrow',
		Size = UDim2.fromOffset(4, 8),
		Position = UDim2.new(1, -14, 0, 9),
		BackgroundTransparency = 1,
		Image = GetAsset('expandright.png'),
		ImageColor3 = Pallet.IconGray,
		Rotation = 90,
		Parent = Button
	})
	local DropdownChildren
	local OptionButtons = {}
	local OutsideClickConnection

	local function IsOptionSelected(Val)
		if OptionSettings.AllowMultiple then
			return table.find(OptionApi.Value, Val) ~= nil
		else
			return Val == OptionApi.Value
		end
	end

	local function UpdateHighlights()
		for Val, Btn in OptionButtons do
			local Selected = IsOptionSelected(Val)
			Tween(Btn, Pallet.Tween, {
				BackgroundColor3 = Selected and Pallet.ModuleLight or Pallet.Main
			})
		end
	end

	local function CloseDropdown()
		if DropdownChildren then
			Arrow.Rotation = 90
			DropdownChildren:Destroy()
			DropdownChildren = nil
			OptionButtons = {}
			Dropdown.Size = UDim2.new(1, 0, 0, 54)
		end
		if OutsideClickConnection then
			OutsideClickConnection:Disconnect()
			OutsideClickConnection = nil
		end
	end

	local function OpenDropdown()
		Arrow.Rotation = 270
		Dropdown.Size = UDim2.new(1, 0, 0, 54 + (#OptionsList) * 26)
		DropdownChildren = Make('Frame', {
			Name = 'Children',
			Size = UDim2.new(1, 0, 0, (#OptionsList) * 26),
			Position = UDim2.fromOffset(0, 51),
			BackgroundTransparency = 1,
			Parent = Dropdown
		})
		local Index = 0
		for _, V in OptionsList do
			local Selected = IsOptionSelected(V)
			local DropdownOption = Make('TextButton', {
				Name = V..'Option',
				Size = UDim2.new(1, 0, 0, 26),
				Position = UDim2.fromOffset(0, Index * 26),
				BackgroundColor3 = Selected and Pallet.ModuleLight or Pallet.Main,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = '        '..V,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = ColorDark(Pallet.Text, 0.16),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				FontFace = Pallet.Font,
				Parent = DropdownChildren
			})
			OptionButtons[V] = DropdownOption
			DropdownOption.MouseEnter:Connect(function()
				Tween(DropdownOption, Pallet.Tween, {
					BackgroundColor3 = ColorLight(Pallet.Main, 0.02)
				})
			end)
			DropdownOption.MouseLeave:Connect(function()
				Tween(DropdownOption, Pallet.Tween, {
					BackgroundColor3 = IsOptionSelected(V) and Pallet.ModuleLight or Pallet.Main
				})
			end)
			DropdownOption.MouseButton1Click:Connect(function()
				OptionApi:SetValue(V, true)
			end)
			Index += 1
		end

		if OptionSettings.AllowMultiple then
			if OutsideClickConnection then
				OutsideClickConnection:Disconnect()
			end
			OutsideClickConnection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
				if GameProcessed then return end
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					local AbsPos = Dropdown.AbsolutePosition
					local AbsSize = Dropdown.AbsoluteSize
					local ClickX = Input.Position.X
					local ClickY = Input.Position.Y
					if ClickX < AbsPos.X or ClickX > AbsPos.X + AbsSize.X or ClickY < AbsPos.Y or ClickY > AbsPos.Y + AbsSize.Y then
						CloseDropdown()
					end
				end
			end)
		end
	end

	local function UpdateTitle()
		local DisplayValue
		if OptionSettings.AllowMultiple then
			DisplayValue = #OptionApi.Value > 0 and table.concat(OptionApi.Value, ", ") or "None"
		else
			DisplayValue = OptionApi.Value
		end
		DisplayLabel.Text = DisplayValue
	end

	function OptionApi:SetValue(Val, Mouse)
		if OptionSettings.AllowMultiple then
			if type(Val) == "table" then
				self.Value = Val
			else
				local Found = table.find(OptionsList, Val)
				if Found then
					local Existing = table.find(self.Value, Val)
					if Existing then
						table.remove(self.Value, Existing)
					else
						table.insert(self.Value, Val)
					end
				end
			end
			UpdateTitle()
			UpdateHighlights()
		else
			self.Value = table.find(OptionsList, Val) and Val or OptionsList[1] or 'None'
			UpdateTitle()
			CloseDropdown()
		end
		if OptionSettings.Function then
			OptionSettings.Function(self.Value, Mouse)
		end
	end

	function OptionApi:UpdateOptions(NewOptions)
		OptionsList = NewOptions
		CloseDropdown()
		if OptionSettings.AllowMultiple then
			local Cleaned = {}
			for _, V in self.Value do
				if table.find(OptionsList, V) then
					table.insert(Cleaned, V)
				end
			end
			self.Value = Cleaned
		else
			if not table.find(OptionsList, self.Value) then
				self.Value = OptionsList[1] or 'None'
			end
		end
		UpdateTitle()
	end

	Button.MouseButton1Click:Connect(function()
		if DropdownChildren then
			CloseDropdown()
		else
			OpenDropdown()
		end
	end)
	Dropdown.MouseEnter:Connect(function()
		Tween(Background, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.0875)
		})
	end)
	Dropdown.MouseLeave:Connect(function()
		Tween(Background, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.034)
		})
	end)

	OptionApi.Object = Dropdown
	Api.Options[OptionSettings.Title or 'Default Name'] = OptionApi
	return OptionApi
end

local function CreateTextBox(OptionSettings, Children, Api, IsModuleElement)
	local Pallet = VapeLibrary.Internal.Pallet
	local OptionApi = {
		Type = 'TextBox',
		Value = OptionSettings.Default or '',
		Index = 0
	}

	local TextBox = Make('TextButton', {
		Name = (OptionSettings.Title or 'Default Name')..'TextBox',
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundColor3 = IsModuleElement and Pallet.Main or Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = OptionSettings.Visible == nil or OptionSettings.Visible,
		Text = '',
		Parent = Children
	})
	local Title = Make('TextLabel', {
		Size = UDim2.new(1, -30, 0, 20),
		Position = UDim2.fromOffset(15, 3),
		BackgroundTransparency = 1,
		Text = OptionSettings.Title or 'Default Name',
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Pallet.Text,
		TextSize = 12,
		FontFace = Pallet.Font,
		Parent = TextBox
	})
	local Background = Make('Frame', {
		Name = 'BKG',
		Size = UDim2.new(1, -20, 0, 29),
		Position = UDim2.fromOffset(10, 23),
		BackgroundColor3 = ColorLight(Pallet.ModuleLight, 0.02),
		Parent = TextBox
	})
	MakeCorner(Background, UDim.new(0, 4))
	local Box = Make('TextBox', {
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		BackgroundTransparency = 1,
		Text = OptionSettings.Default or '',
		PlaceholderText = OptionSettings.Placeholder or 'Click to set',
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		PlaceholderColor3 = ColorDark(Pallet.Text, 0.31),
		TextSize = 12,
		FontFace = Pallet.Font,
		ClearTextOnFocus = false,
		Parent = Background
	})

	function OptionApi:SetValue(Val, Enter, Input)
		self.Value = Val
		Box.Text = Val
		if Enter and OptionSettings.Function then
			OptionSettings.Function(Val)
		end
	end

	TextBox.MouseButton1Click:Connect(function()
		Box:CaptureFocus()
	end)
	Box.FocusLost:Connect(function(Enter, Input)
		OptionApi:SetValue(Box.Text, Enter, Input)
	end)
	Box:GetPropertyChangedSignal('Text'):Connect(function()
		OptionApi:SetValue(Box.Text)
	end)

	OptionApi.Object = TextBox
	Api.Options[OptionSettings.Title or 'Default Name'] = OptionApi
	return OptionApi
end

local function CreateLabel(OptionSettings, Children, Api, IsModuleElement)
	local Pallet = VapeLibrary.Internal.Pallet
	local OptionApi = {
		Type = 'Label',
		Name = OptionSettings.Title or 'Default Name',
		Index = 0
	}

	local Frame = Make('Frame', {
		Name = (OptionSettings.Title or 'Default Name')..'Label',
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = IsModuleElement and Pallet.Main or Pallet.Module,
		BorderSizePixel = 0,
		Visible = OptionSettings.Visible == nil or OptionSettings.Visible,
		Parent = Children
	})

	local TextLabel = Make('TextLabel', {
		Name = 'Text',
		Size = UDim2.new(1, -16, 1, -6),
		Position = UDim2.fromOffset(10, 3),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = Pallet.Text,
		TextSize = 12,
		FontFace = Pallet.Font,
		RichText = OptionSettings.RichText or false,
		TextWrapped = true,
		Text = OptionApi.Name,
		Parent = Frame
	})

	local function UpdateSize()
		local TextSize = GetTextSize(TextLabel.Text, TextLabel.FontFace, TextLabel.AbsoluteSize.X, TextLabel.TextSize)
		local NewY = math.max(32, TextSize.Y + 10)
		Frame.Size = UDim2.new(1, 0, 0, NewY)
	end

	TextLabel:GetPropertyChangedSignal('Text'):Connect(UpdateSize)
	UpdateSize()

	function OptionApi:SetValue(Val)
		self.Value = Val
		TextLabel.Text = Val
	end

	OptionApi.Object = Frame
	Api.Options[OptionSettings.Title or 'Default Name'] = OptionApi
	return OptionApi
end

local function CreateKeybind(OptionSettings, Children, Api, IsModuleElement)
	local Pallet = VapeLibrary.Internal.Pallet
	local OptionApi = {
		Type = 'Keybind',
		Value = OptionSettings.Default,
		Index = GetTableSize(Api.Options)
	}

	local Keybind = Make('TextButton', {
		Name = (OptionSettings.Title or 'Default Name')..'Keybind',
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = IsModuleElement and Pallet.Main or Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Visible = OptionSettings.Visible == nil or OptionSettings.Visible,
		Text = '',
		Parent = Children
	})

	local TitleLabel = Make('TextLabel', {
		Name = 'Title',
		Size = UDim2.new(1, -80, 0, 34),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = (OptionSettings.Title or 'Default Name'),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 14,
		FontFace = Pallet.Font,
		Parent = Keybind
	})

	local BindBox = Make('TextButton', {
		Name = 'BindBox',
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(1, -34, 0, 5),
		BackgroundColor3 = ColorLight(Pallet.Main, 0.05),
		Text = '',
		AutoButtonColor = false,
		Parent = Keybind
	})
	MakeCorner(BindBox, UDim.new(0, 4))

	local BindIcon = Make('ImageLabel', {
		Name = 'BindIcon',
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(0.5, -6, 0.5, -6),
		BackgroundTransparency = 1,
		Image = GetAsset('bind.png'),
		ImageColor3 = ColorDark(Pallet.Text, 0.16),
		Visible = false,
		Parent = BindBox
	})

	local BindLabel = Make('TextLabel', {
		Name = 'BindLabel',
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.fromOffset(4, 0),
		BackgroundTransparency = 1,
		Text = OptionApi.Value and OptionApi.Value.Name or 'None',
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 12,
		FontFace = Pallet.Font,
		Parent = BindBox
	})

	local Listening = false
	local KeybindConnection

	local function UpdateDisplay()
		if OptionApi.Value then
			BindLabel.Text = OptionApi.Value.Name
			BindLabel.Visible = true
			BindIcon.Visible = false
		else
			BindLabel.Visible = false
			BindIcon.Visible = true
		end
	end

	local function OnKeybindPressed(Input, GameProcessed)
		if GameProcessed then return end
		if OptionApi.Value and Input.KeyCode == OptionApi.Value then
			if OptionSettings.Function then
				OptionSettings.Function()
			end
		end
	end

	local function StartListening()
		Listening = true
		BindLabel.Text = '...'
		BindLabel.Visible = true
		BindIcon.Visible = false

		local InputConnection
		InputConnection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				if Input.KeyCode == Enum.KeyCode.Escape then
					OptionApi.Value = nil
				else
					OptionApi.Value = Input.KeyCode
				end
				UpdateDisplay()
				Listening = false
				if InputConnection then
					InputConnection:Disconnect()
				end
			end
		end)
	end

	function OptionApi:SetValue(Val)
		if Val and typeof(Val) ~= 'EnumItem' then return end
		self.Value = Val
		UpdateDisplay()
	end

	function OptionApi:Clear()
		self.Value = nil
		UpdateDisplay()
	end

	BindBox.MouseEnter:Connect(function()
		Tween(BindBox, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.0875)
		})
	end)
	BindBox.MouseLeave:Connect(function()
		Tween(BindBox, Pallet.Tween, {
			BackgroundColor3 = ColorLight(Pallet.Main, 0.05)
		})
	end)
	BindBox.MouseButton1Click:Connect(function()
		if not Listening then
			StartListening()
		end
	end)

	KeybindConnection = UserInputService.InputBegan:Connect(OnKeybindPressed)

	OptionApi.Object = Keybind
	Api.Options[OptionSettings.Title or 'Default Name'] = OptionApi
	return OptionApi
end


local Components = {
	Toggle = CreateToggle,
	Button = CreateButton,
	Slider = CreateSlider,
	Dropdown = CreateDropdown,
	TextBox = CreateTextBox,
	Label = CreateLabel,
	Keybind = CreateKeybind
}

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

local ModuleClass = {}
ModuleClass.__index = ModuleClass

function ModuleClass:CreateToggle(settings)
	return Components.Toggle(settings, self.Children, self, true)
end

function ModuleClass:CreateButton(settings)
	return Components.Button(settings, self.Children, self, true)
end

function ModuleClass:CreateSlider(settings)
	return Components.Slider(settings, self.Children, self, true)
end

function ModuleClass:CreateDropdown(settings)
	return Components.Dropdown(settings, self.Children, self, true)
end

function ModuleClass:CreateTextBox(settings)
	return Components.TextBox(settings, self.Children, self, true)
end

function ModuleClass:CreateKeybind(settings)
	return Components.Keybind(settings, self.Children, self, true)
end

function ModuleClass:CreateLabel(settings)
	return Components.Label(settings, self.Children, self, true)
end

function TabClass:CreateModule(Settings)
	local Pallet = VapeLibrary.Internal.Pallet
	local ParentTab = self

	local ModuleApi = {
		Enabled = false,
		Options = {},
		Bind = {},
		Name = Settings.Name,
		ExtraText = Settings.ExtraText
	}

	local Hovered = false
	local ModuleButton = Make('TextButton', {
		Name = Settings.Name,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Pallet.Module,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = '     '..Settings.Name,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 14,
		FontFace = Pallet.Font,
		Parent = ParentTab.Children
	})
	local Gradient = Make('UIGradient', {
		Rotation = 90,
		Enabled = false,
		Parent = ModuleButton
	})
	local ModuleChildren = Make('Frame', {
		Name = Settings.Name..'Children',
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = ColorDark(Pallet.Module, 0.02),
		BorderSizePixel = 0,
		Visible = false,
		Parent = ParentTab.Children
	})
	ModuleApi.Children = ModuleChildren
	local DotsButton = Make('TextButton', {
		Name = 'Dots',
		Size = UDim2.fromOffset(25, 40),
		Position = UDim2.new(1, -25, 0, 0),
		BackgroundTransparency = 1,
		Text = '',
		Parent = ModuleButton
	})
	local Dots = Make('ImageLabel', {
		Name = 'Dots',
		Size = UDim2.fromOffset(3, 16),
		Position = UDim2.fromOffset(4, 12),
		BackgroundTransparency = 1,
		Image = GetAsset('dots.png'),
		ImageColor3 = ColorLight(Pallet.Main, 0.37),
		Parent = DotsButton
	})
	local WindowList = Make('UIListLayout', {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = ModuleChildren
	})
	local DividerFrame = Make('Frame', {
		Name = 'Divider',
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Pallet.Divider,
		BackgroundTransparency = 0.52,
		BorderSizePixel = 0,
		Visible = false,
		Parent = ModuleButton
	})
	Settings.Function = Settings.Function or function() end
	AddMaid(ModuleApi)

	function ModuleApi:Toggle(Multiple)
		self.Enabled = not self.Enabled
		DividerFrame.Visible = self.Enabled
		Gradient.Enabled = self.Enabled
		ModuleButton.TextColor3 = (Hovered or ModuleChildren.Visible) and Pallet.Text or (self.Enabled and ColorLight(Pallet.Text, 0.1) or ColorDark(Pallet.Text, 0.16))
		Dots.ImageColor3 = self.Enabled and ColorLight(Pallet.Text, 0.1) or ColorLight(Pallet.Module, 0.37)
		local BaseColor = self.Enabled and Pallet.Accent or Pallet.Module
		ModuleButton.BackgroundColor3 = (Hovered or ModuleChildren.Visible) and ColorLight(BaseColor, 0.02) or BaseColor
		if not self.Enabled then
			for _, V in self.Connections do
				V:Disconnect()
			end
			table.clear(self.Connections)
		end
		task.spawn(Settings.Function, self.Enabled)
	end

	DotsButton.MouseEnter:Connect(function()
		if not ModuleApi.Enabled then
			Dots.ImageColor3 = Pallet.Text
		else
			Dots.ImageColor3 = ColorLight(Pallet.Text, 0.1)
		end
	end)
	DotsButton.MouseLeave:Connect(function()
		if not ModuleApi.Enabled then
			Dots.ImageColor3 = ColorLight(Pallet.Module, 0.37)
		else
			Dots.ImageColor3 = ColorLight(Pallet.Text, 0.1)
		end
	end)
	DotsButton.MouseButton1Click:Connect(function()
		if ModuleChildren.Visible then
			ModuleChildren.Visible = false
			Tween(ModuleChildren, nil, {Size = UDim2.new(1, 0, 0, 0)})
		else
			ModuleChildren.Visible = true
			Tween(ModuleChildren, nil, {Size = UDim2.new(1, 0, 0, WindowList.AbsoluteContentSize.Y)})
		end
	end)
	DotsButton.MouseButton2Click:Connect(function()
		if ModuleChildren.Visible then
			ModuleChildren.Visible = false
			Tween(ModuleChildren, nil, {Size = UDim2.new(1, 0, 0, 0)})
		else
			ModuleChildren.Visible = true
			Tween(ModuleChildren, nil, {Size = UDim2.new(1, 0, 0, WindowList.AbsoluteContentSize.Y)})
		end
	end)
	ModuleButton.MouseEnter:Connect(function()
		Hovered = true
		if not ModuleChildren.Visible then
			local BaseColor = ModuleApi.Enabled and Pallet.Accent or Pallet.Module
			ModuleButton.TextColor3 = Pallet.Text
			ModuleButton.BackgroundColor3 = ColorLight(BaseColor, 0.02)
		end
	end)
	ModuleButton.MouseLeave:Connect(function()
		Hovered = false
		if not ModuleChildren.Visible then
			local BaseColor = ModuleApi.Enabled and Pallet.Accent or Pallet.Module
			ModuleButton.TextColor3 = ModuleApi.Enabled and ColorLight(Pallet.Text, 0.1) or ColorDark(Pallet.Text, 0.16)
			ModuleButton.BackgroundColor3 = BaseColor
		end
	end)
	ModuleButton.MouseButton1Click:Connect(function()
		ModuleApi:Toggle()
	end)
	ModuleButton.MouseButton2Click:Connect(function()
		if ModuleChildren.Visible then
			ModuleChildren.Visible = false
			Tween(ModuleChildren, nil, {Size = UDim2.new(1, 0, 0, 0)})
		else
			ModuleChildren.Visible = true
			Tween(ModuleChildren, nil, {Size = UDim2.new(1, 0, 0, WindowList.AbsoluteContentSize.Y)})
		end
	end)
	WindowList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		ModuleChildren.Size = UDim2.new(1, 0, 0, WindowList.AbsoluteContentSize.Y)
	end)

	ModuleApi.Object = ModuleButton
	VapeLibrary.Internal.Modules[Settings.Name] = ModuleApi

	setmetatable(ModuleApi, ModuleClass)
	return ModuleApi
end


local WindowClass = {}
WindowClass.__index = WindowClass

function WindowClass:CreateTab(Settings)
	local Pallet = VapeLibrary.Internal.Pallet
	local CategoryApi = {
		Type = 'Category',
		Expanded = false,
		Options = {},
		Name = Settings.Name
	}

	local Window = Make('TextButton', {
		Name = Settings.Name..'Category',
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
	MakeDraggable(Window)
	local Icon = Make('ImageLabel', {
		Name = 'Icon',
		Size = Settings.Size or UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(12, ((Settings.Size or UDim2.fromOffset(16, 16)).X.Offset > 20 and 14 or 13)),
		BackgroundTransparency = 1,
		Image = GetAsset(Settings.Icon or 'combaticon.png'),
		ImageColor3 = Pallet.Text,
		Parent = Window
	})
	local Title = Make('TextLabel', {
		Name = 'Title',
		Size = UDim2.new(1, -((Settings.Size and Settings.Size.X.Offset or 16) > 18 and 40 or 33), 0, 41),
		Position = UDim2.fromOffset(math.abs(((Settings.Size and Settings.Size.X.Offset or 16) > 18 and 40 or 33)), 0),
		BackgroundTransparency = 1,
		Text = Settings.Name,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Pallet.Text,
		TextSize = 13,
		FontFace = Pallet.Font,
		Parent = Window
	})
	local ArrowButton = Make('TextButton', {
		Name = 'Arrow',
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.new(1, -40, 0, 0),
		BackgroundTransparency = 1,
		Text = '',
		Parent = Window
	})
	local Arrow = Make('ImageLabel', {
		Name = 'Arrow',
		Size = UDim2.fromOffset(9, 4),
		Position = UDim2.fromOffset(20, 18),
		BackgroundTransparency = 1,
		Image = GetAsset('expandup.png'),
		ImageColor3 = Pallet.IconGray,
		Rotation = 180,
		Parent = ArrowButton
	})
	local Children = Make('ScrollingFrame', {
		Name = 'Children',
		Size = UDim2.new(1, 0, 1, -41),
		Position = UDim2.fromOffset(0, 37),
		BackgroundTransparency = 0,
		BackgroundColor3 = Pallet.Module,
		BorderSizePixel = 0,
		Visible = false,
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 0.75,
		CanvasSize = UDim2.new(),
		Parent = Window
	})
	local DividerFrame = Make('Frame', {
		Name = 'Divider',
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.fromOffset(0, 37),
		BackgroundColor3 = Pallet.DividerLight,
		BackgroundTransparency = 0.928,
		BorderSizePixel = 0,
		Visible = false,
		Parent = Window
	})
	local WindowList = Make('UIListLayout', {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = Children
	})
	CategoryApi.Children = Children
	CategoryApi.Object = Window

	function CategoryApi:Expand()
		if self.Expanded then return end
		self.Expanded = true
		Children.Visible = true
		Arrow.Rotation = 0
		DividerFrame.Visible = true
		Tween(Window, nil, {Size = UDim2.fromOffset(220, math.min(41 + WindowList.AbsoluteContentSize.Y, 601))})
	end

	function CategoryApi:Close()
		if not self.Expanded then return end
		self.Expanded = false
		Children.Visible = false
		Arrow.Rotation = 180
		DividerFrame.Visible = false
		Tween(Window, nil, {Size = UDim2.fromOffset(220, 41)})
	end

	ArrowButton.MouseButton1Click:Connect(function()
		if CategoryApi.Expanded then
			CategoryApi:Close()
		else
			CategoryApi:Expand()
		end
	end)
	ArrowButton.MouseButton2Click:Connect(function()
		if CategoryApi.Expanded then
			CategoryApi:Close()
		else
			CategoryApi:Expand()
		end
	end)
	ArrowButton.MouseEnter:Connect(function()
		Arrow.ImageColor3 = Pallet.IconHover
	end)
	ArrowButton.MouseLeave:Connect(function()
		Arrow.ImageColor3 = Pallet.IconGray
	end)
	WindowList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		Children.CanvasSize = UDim2.fromOffset(0, WindowList.AbsoluteContentSize.Y)
		if CategoryApi.Expanded then
			Tween(Window, nil, {Size = UDim2.fromOffset(220, math.min(41 + WindowList.AbsoluteContentSize.Y, 601))})
		end
	end)

	local CategoryButton = Make('TextButton', {
		Name = Settings.Name,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Pallet.Main,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = (Settings.Icon and string.rep(" ", 12) or "    ")..Settings.Name,
		TextColor3 = ColorDark(Pallet.Text, 0.16),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Pallet.Font,
		Parent = VapeLibrary.Internal.MainChildren
	})
	local CatIcon
	if Settings.Icon then
		CatIcon = Make('ImageLabel', {
			Name = 'Icon',
			Size = Settings.Size or UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(13, 13),
			BackgroundTransparency = 1,
			Image = GetAsset(Settings.Icon),
			ImageColor3 = ColorDark(Pallet.Text, 0.16),
			Parent = CategoryButton
		})
	end
	local CatArrow = Make('ImageLabel', {
		Name = 'Arrow',
		Size = UDim2.fromOffset(4, 8),
		Position = UDim2.new(1, -20, 0, 16),
		BackgroundTransparency = 1,
		Image = GetAsset('expandright.png'),
		ImageColor3 = ColorLight(Pallet.Main, 0.37),
		Parent = CategoryButton
	})

	local CategoryButtonApi = {
		Enabled = false,
		Object = CategoryButton,
		Window = Window
	}

	function CategoryButtonApi:Toggle()
		self.Enabled = not self.Enabled
		Tween(CatArrow, Pallet.Tween, {
			Position = UDim2.new(1, self.Enabled and -14 or -20, 0, 16)
		})
		CategoryButton.TextColor3 = self.Enabled and Color3.fromHSV(VapeLibrary.Internal.Pallet.GUIColor.Hue, VapeLibrary.Internal.Pallet.GUIColor.Sat, VapeLibrary.Internal.Pallet.GUIColor.Value) or Pallet.Text
		if CatIcon then
			CatIcon.ImageColor3 = CategoryButton.TextColor3
		end
		CategoryButton.BackgroundColor3 = ColorLight(Pallet.Main, 0.02)
		Window.Visible = self.Enabled
	end

	CategoryButton.MouseEnter:Connect(function()
		if not CategoryButtonApi.Enabled then
			CategoryButton.TextColor3 = Pallet.Text
			if CatIcon then CatIcon.ImageColor3 = Pallet.Text end
			CategoryButton.BackgroundColor3 = ColorLight(Pallet.Main, 0.02)
		end
	end)
	CategoryButton.MouseLeave:Connect(function()
		if not CategoryButtonApi.Enabled then
			CategoryButton.TextColor3 = ColorDark(Pallet.Text, 0.16)
			if CatIcon then CatIcon.ImageColor3 = ColorDark(Pallet.Text, 0.16) end
			CategoryButton.BackgroundColor3 = Pallet.Main
		end
	end)
	CategoryButton.MouseButton1Click:Connect(function()
		CategoryButtonApi:Toggle()
	end)

	CategoryApi.Button = CategoryButtonApi
	VapeLibrary.Internal.Categories[Settings.Name] = CategoryApi
	table.insert(VapeLibrary.Internal.Tabs, CategoryApi)

	setmetatable(CategoryApi, TabClass)
	return CategoryApi
end

function VapeLibrary:CreateWindow()
	local Pallet = VapeLibrary.Internal.Pallet
	VapeLibrary.Internal.ScreenGui = Instance.new("ScreenGui", gethui and gethui() or CloneRef(game:GetService("Players")).LocalPlayer.PlayerGui)
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
		Size = UDim2.new(0, 0, 0, 0),
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
			MinSize = Vector2.new(0, 0),
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
			MinSize = Vector2.new(0, 500),
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
			ImageColor3 = Pallet.Accent
		})
	})

	Make("Frame", {
		Name = "Divider",
		Position = UDim2.new(0, 0, 0, 37),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Pallet.DividerLight,
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

	MainList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		local ContentHeight = MainList.AbsoluteContentSize.Y
		MainFrame.Size = UDim2.fromOffset(220, 42 + ContentHeight)
	end)

	local WindowApi = setmetatable({ClickGui = ClickGui, MainFrame = MainFrame}, WindowClass)

	UserInputService.InputBegan:Connect(function(Input, GameProcessed)
		if GameProcessed then return end
		if Input.KeyCode == VapeLibrary.Internal.ToggleKeybind then
			ClickGui.Visible = not ClickGui.Visible
			if VapeLibrary.Internal.BlurType == 'Blur' then
				VapeLibrary.Internal.Blur.Enabled = ClickGui.Visible
			else
				RunService:SetRobloxGuiFocused(ClickGui.Visible)
			end
		end
	end)

	return WindowApi
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
		Size = UDim2.new(1, 0, 0, 0)
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
		BackgroundColor3 = Pallet.Outline,
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
			Position = UDim2.new(1, -48, 0, 10),
			BackgroundTransparency = 1,
			ImageTransparency = 0.4,
			Visible = Settings.IsPinned,
		}),
		Make("TextLabel", {
			Name = "Time",
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -48, 0, 10),
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
			Position = UDim2.new(1, -34, 0, 2),
			BackgroundTransparency = 1,
			ImageTransparency = 0.4,
		})
	})

	local Size = GetTextSize(Settings.Text, Pallet.Font, Notification.AbsoluteSize.X - 16, 14)
	Notification.Text.Size = UDim2.new(1, -16, 0, Size.Y)
	Tween(Notification, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 60 + Size.Y), BackgroundTransparency = 0.15})

	local Closed = false
	local Hovered = IsMouseInFrame(Notification)

	local CloseTween = TweenService:Create(Notification, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})

	CloseTween.Completed:Once(function()
		Notification:Destroy()
	end)

	local NotificationApi = {
		Object = Notification
	}

	function NotificationApi:Dismiss()
		if Closed then return end
		Closed = true
		CloseTween:Play()
	end

	Notification.Close.MouseButton1Click:Connect(function()
		NotificationApi:Dismiss()
	end)

	if not Settings.IsPinned then
		local Remaining = Settings.Duration
		local TimeLabel = Notification.Time

		Notification.MouseEnter:Connect(function() Hovered = true end)
		Notification.MouseLeave:Connect(function() Hovered = false end)

		while true do
			task.wait(0.1)

			if Closed then
				break
			end

			if not Hovered then
				Remaining -= 0.1
				TimeLabel.Text = string.format("<b>%.1f</b>", Remaining)
			end

			if Remaining <= 0 then
				break
			end
		end

		if not Closed then
			NotificationApi:Dismiss()
		end
	end

	return NotificationApi
end


return VapeLibrary
