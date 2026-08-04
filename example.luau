local VapeLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/com-display-name/Ai-VapeV4/refs/heads/main/main.luau"))()
local Window = VapeLibrary:CreateWindow({
	Version = "5.0",
	MakeSettings = false
})

local DebugTab = Window:CreateTab({
	Name = "Debug",
	Icon = "utilityicon.png"
})
DebugTab:CreateToggle({Name = "Toggle Name", Default = true, Function = function(value) print(value) end})
DebugTab:CreateButton({Name = "Yes this is a button", Function = function() print("Hello world!") end})
DebugTab:CreateSlider({Name = "Slider Name",Min = 0, Max = 100, Default = 50, Suffix = "Studs / sec", Decimal = 10, Function = function(value) print(value) end})
DebugTab:CreateDropdown({Name = "Dropdown Name", List = {"Option1", "Option2", "Option3"}, Default = "Option1", Function = function(value) print(value) end})
DebugTab:CreateTextBox({Name = "empty", Default = "Default value", Function = function(value) print(value) end})
DebugTab:CreateLabel({Name = "This is a label"})


local Module = DebugTab:CreateModule({Name = "Module Test", Function = function(...) print(...) end})
	Module:CreateToggle({Name = "Toggle Name", Default = true, Function = function(value) print(value) end})
	Module:CreateButton({Name = "Yes this is a button", Function = function() print("Hello world!") end})
	Module:CreateSlider({Name = "Slider Name",Min = 0, Max = 100, Default = 50, Suffix = "Studs / sec", Decimal = 10, Function = function(value) print(value) end})
	Module:CreateDropdown({Name = "Dropdown Name", List = {"Option1", "Option2", "Option3"}, Default = "Option1", Function = function(value) print(value) end})
	Module:CreateTextBox({Name = "empty", Default = "Default value", Function = function(value) print(value) end})
