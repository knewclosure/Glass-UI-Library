-- Press 'U' to toggle UI visibility

local Library = {}
Library.__index = Library

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Define the Unified Accent Color
local ACCENT_COLOR_GREEN = Color3.fromRGB(60, 200, 100)
local ACCENT_COLOR_BLUE = Color3.fromRGB(80, 120, 200) 

-- Utility Colors (Pre-calculated for dimming/brightening via HSV)

local function GetDimmedColor(color, factor)
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, s, v * factor)
end

local DIMMED_GREEN = GetDimmedColor(ACCENT_COLOR_GREEN, 0.5) 
local BRIGHT_GREEN = GetDimmedColor(ACCENT_COLOR_GREEN, 1.3) 
local DIMMED_GREY = Color3.fromRGB(80, 80, 80)


-- Utility Functions

local function CreateElement(className, properties)
	local element = Instance.new(className)
	for prop, value in pairs(properties) do
		if prop ~= "Parent" then
			element[prop] = value
		end
	end
	if properties.Parent then
		element.Parent = properties.Parent
	end
	return element
end

-- Animated pulse effect
local function AddBreathingStroke(instance, color)
	local stroke = CreateElement("UIStroke", {
		Color = color,
		Transparency = 0.4,
		Thickness = 1.6, 
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = instance
	})

	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(stroke, tweenInfo, {
		Transparency = 0.85
	})
	tween:Play()

	return stroke
end

-- One-shot pulse function for buttons
local function OneShotPulse(instance)
	local stroke = CreateElement("UIStroke", {
		Color = ACCENT_COLOR_GREEN,
		Transparency = 0.0,
		Thickness = 1.8,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = instance
	})

	-- Pulse from 0% to 100% transparency in 0.4s
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false)
	local tween = TweenService:Create(stroke, tweenInfo, {
		Transparency = 1
	})

	tween.Completed:Connect(function()
		stroke:Destroy()
	end)
	tween:Play()
end

-- APPLIES THE MATTE DARK GLASS EFFECT
local function ApplyGlassEffect(frame)
	-- Outer glass/blur frame (the main background visual)
	local glassBackground = CreateElement("Frame", {
		Name = "GlassBackground",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15), -- Dark base color (Matte Grey)
		BackgroundTransparency = 0.1, -- Subtle transparency for the glass effect
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = frame
	})

	CreateElement("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = glassBackground
	})

	-- Frosted Glass Layer (responsible for the blur/frost effect)
	local frostLayer = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(20, 20, 25),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = glassBackground
	})

	CreateElement("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = frostLayer
	})

	-- UIGradient for the polished lighting effect
	CreateElement("UIGradient", {
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
		},
		Rotation = 45,
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0.7)
		},
		Parent = frostLayer
	})

	return glassBackground
end

-- NEW FUNCTION: Creates and manages the loading screen elements, but does NOT start the animation
local function CreateLoadingPanel(playerGui)
	local loadingGui = CreateElement("ScreenGui", {
		Name = "LoadingPanel",
		ResetOnSpawn = false,
		DisplayOrder = 1000, -- Always on top
		IgnoreGuiInset = true,
		Parent = playerGui
	})

	-- 1. Full-screen Gaussian Blur Background (Frame, not ScreenGui)
	local blurEffect = CreateElement("Frame", {
		Name = "FullScreenBlur",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 0, -- Start opaque to hide the world
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 1,
		Parent = loadingGui
	})

	local camera = workspace.CurrentCamera
	local blur = nil
	if camera then
		-- Apply a subtle Gaussian blur to the screen
		blur = CreateElement("BlurEffect", {
			Size = 24, 
			Parent = camera
		})
		blurEffect.Destroying:Connect(function()
			-- Destroy the blur effect when the loading screen is destroyed
			blur:Destroy()
		end)
	end

	-- 2. Loading Container Frame (Centralized)
	local loadingFrame = CreateElement("Frame", {
		Size = UDim2.new(0, 400, 0, 150),
		Position = UDim2.new(0.5, -200, 0.5, -75),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = blurEffect
	})

	ApplyGlassEffect(loadingFrame)

	CreateElement("UICorner", { CornerRadius = UDim.new(0, 12), Parent = loadingFrame })
	AddBreathingStroke(loadingFrame, ACCENT_COLOR_GREEN) 

	-- 3. Luminiscent Title (Pulsating Glow)
	local titleLabel = CreateElement("TextLabel", {
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "L U M I N E S C E N T",
		TextColor3 = ACCENT_COLOR_GREEN,
		TextSize = 26,
		Font = Enum.Font.GothamBold,
		ZIndex = 3,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0), 
		TextStrokeTransparency = 1, 
		Parent = loadingFrame
	})

	-- Pulsating Text Glow - Starts immediately since the whole panel is hidden until called
	local pulseTweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

	TweenService:Create(titleLabel, pulseTweenInfo, {
		TextStrokeTransparency = 0.4 
	}):Play()

	-- 4. Progress Bar
	local barBg = CreateElement("Frame", {
		Size = UDim2.new(0.8, 0, 0, 8),
		Position = UDim2.new(0.5, -160, 1, -40),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = loadingFrame
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barBg })

	local barFill = CreateElement("Frame", {
		Size = UDim2.new(0, 0, 1, 0), -- Starts at 0 width
		BackgroundColor3 = ACCENT_COLOR_GREEN,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = barBg
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barFill })

	-- Return the key elements required for external control
	return loadingGui, blurEffect, loadingFrame, barFill
end

-- NEW PUBLIC FUNCTION: Starts the progress bar and fade-out sequence
function Library:StartLoadScreen(loadTime)

	local loadingGui, blurEffect, loadingFrame, barFill = self.LoadingElements.loadingGui, self.LoadingElements.blurEffect, self.LoadingElements.loadingFrame, self.LoadingElements.barFill
	local mainFrame = self.MainFrame
	local screenGui = self.ScreenGui
	local glassBackground = self.GlassBackground

	-- Start the load simulation (Progress Bar Fill)
	TweenService:Create(barFill, TweenInfo.new(loadTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()

	-- Fade out logic
	task.delay(loadTime + 0.1, function()
		-- Fade out the full-screen background frame and the loading frame simultaneously
		TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()

		TweenService:Create(loadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()

		-- Fade in the main UI (which was previously hidden)
		screenGui.Enabled = true
		glassBackground.BackgroundTransparency = 1
		TweenService:Create(glassBackground, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.1
		}):Play()

		-- Destroy the loading panel after fade out
		task.delay(0.5, function()
			loadingGui:Destroy()
		end)
	end)
end

-- NEW PUBLIC FUNCTION: Notification System
function Library:CreateNotification(title, message, duration)
	duration = duration or 3 -- Default duration is 3 seconds
	local parent = self.NotificationContainer

	local notifFrame = CreateElement("Frame", {
		Size = UDim2.new(0, 300, 0, 70),
		Position = UDim2.new(0, 0, 1, 0), -- Positioned at the bottom of the list container
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = parent,
		ClipsDescendants = true
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = notifFrame })
	ApplyGlassEffect(notifFrame) -- Apply the glass look

	-- Content Frame
	local contentFrame = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = notifFrame
	})

	-- Title
	local titleLabel = CreateElement("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = ACCENT_COLOR_GREEN,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
		Parent = contentFrame
	})

	-- Message
	local messageLabel = CreateElement("TextLabel", {
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 0, 25),
		BackgroundTransparency = 1,
		Text = message,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
		Parent = contentFrame
	})

	-- Animation Logic

	-- 1. Slide In (from right, using list layout to position vertically)
	notifFrame:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)

	-- 2. Wait and Fade Out (Shatter effect: rapid scale down and transparency fade)
	task.delay(duration, function()
		-- Fade and Scale Down (simulating a dramatic shatter/fade)
		local shatterTween = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 250, 0, 50), -- Shrink size
			Position = UDim2.new(0, 25, 0, 10), -- Center the shrinkage
			Rotation = 5 -- Add slight rotation for drama
		})

		-- Also fade the children (text)
		TweenService:Create(titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		TweenService:Create(messageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()

		shatterTween.Completed:Connect(function()
			notifFrame:Destroy()
		end)
		shatterTween:Play()
	end)
end

-- Main Window Creation
function Library:CreateWindow(title)

	local parent
	local success = pcall(function()
		parent = game:GetService("CoreGui")
		local test = Instance.new("ScreenGui", parent)
		test:Destroy()
	end)

	if not success or not parent then
		parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end

	-- 1. Create Loading Panel Elements, but do not start them
	local loadingGui, blurEffect, loadingFrame, barFill = CreateLoadingPanel(parent)

	-- 2. Create Notification Container (Must be in a separate ScreenGui or a very high ZIndex)
	local notifGui = CreateElement("ScreenGui", {
		Name = "NotificationSystem",
		ResetOnSpawn = false,
		DisplayOrder = 1001, -- Highest Z-index
		Parent = parent
	})

	local notifContainer = CreateElement("Frame", {
		Name = "NotificationContainer",
		Size = UDim2.new(0, 300, 1, -20),
		Position = UDim2.new(1, -310, 0, 10), -- Top Right Corner
		AnchorPoint = Vector2.new(0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = notifGui
	})

	CreateElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 10),
		Parent = notifContainer
	})

	-- 3. Initialize the main UI (starts disabled/hidden)
	local screenGui = CreateElement("ScreenGui", {
		Name = "ModernGlassUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		IgnoreGuiInset = true,
		Parent = parent,
		Enabled = false -- Start disabled
	})

	-- Main Frame (Transparent container for positioning and dragging)
	local mainFrame = CreateElement("Frame", {
		Name = "MainFrame",
		Size = UDim2.new(0, 680, 0, 420),
		Position = UDim2.new(0.5, -340, 0.5, -210),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundTransparency = 1, -- Always transparent, only used for grouping
		ZIndex = 2,
		Visible = true,
		Parent = screenGui
	})

	-- Apply the Glass/Matte effect background to the main frame
	local glassBackground = ApplyGlassEffect(mainFrame)

	-- Assemble the window object
	local window = {
		-- Store the loading elements for the public function to access
		LoadingElements = {
			loadingGui = loadingGui,
			blurEffect = blurEffect,
			loadingFrame = loadingFrame,
			barFill = barFill,
		},
		GlassBackground = glassBackground, -- Store for fade-in logic
		NotificationContainer = notifContainer, -- Store for notification system
		Tabs = {},
		CurrentTab = nil,
		Minimized = false,
		Hidden = false
	}

	-- Title Bar (Place inside mainFrame which is transparent but controls position)
	local titleBar = CreateElement("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(5, 5, 10),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = mainFrame
	})

	CreateElement("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = titleBar
	})

	-- FIX: Center the title text
	local titleLabel = CreateElement("TextLabel", {
		Size = UDim2.new(1, -110, 1, 0), -- Make it full width minus button area
		Position = UDim2.new(0.5, 0, 0, 0), -- Center horizontally
		AnchorPoint = Vector2.new(0.5, 0), -- Anchor point to center
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center, -- Center alignment
		ZIndex = 4,
		Parent = titleBar
	})

	-- Close Button (Red)
	local closeBtn = CreateElement("TextButton", {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0, 5),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		ZIndex = 4,
		Parent = titleBar
	})

	CreateElement("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = closeBtn
	})

	AddBreathingStroke(closeBtn, Color3.fromRGB(180, 40, 40))

	closeBtn.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
		window.Hidden = true
	end)

	-- Minimize Button (Yellow)
	local minimizeBtn = CreateElement("TextButton", {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -70, 0, 5),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Text = "−",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		ZIndex = 4,
		Parent = titleBar
	})

	CreateElement("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = minimizeBtn
	})

	AddBreathingStroke(minimizeBtn, Color3.fromRGB(220, 180, 50))

	-- Tab Container
	local tabContainer = CreateElement("Frame", {
		Name = "TabContainer",
		Size = UDim2.new(1, -30, 0, 35),
		Position = UDim2.new(0, 15, 0, 50),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = mainFrame
	})

	CreateElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		Parent = tabContainer
	})

	-- Content Container
	local contentContainer = CreateElement("Frame", {
		Name = "ContentContainer",
		Size = UDim2.new(1, -30, 1, -135),
		Position = UDim2.new(0, 15, 0, 95),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = mainFrame
	})

	-- Footer Bar
	local footerBar = CreateElement("Frame", {
		Name = "FooterBar",
		Size = UDim2.new(1, -30, 0, 30),
		Position = UDim2.new(0, 15, 1, -40),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = mainFrame
	})

	CreateElement("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = footerBar
	})

	local player = game.Players.LocalPlayer
	local footerText = player.Name .. " | " .. tostring(player.UserId)

	CreateElement("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = footerText,
		TextColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 4,
		Parent = footerBar
	})

	-- MINIMIZE LOGIC
	local originalSize = mainFrame.Size
	local originalPosition = mainFrame.Position

	minimizeBtn.MouseButton1Click:Connect(function()
		window.Minimized = not window.Minimized

		if window.Minimized then
			tabContainer.Visible = false
			contentContainer.Visible = false
			footerBar.Visible = false

			minimizeBtn.Text = "□"

			mainFrame:TweenSizeAndPosition(
				UDim2.new(0, 300, 0, 40),
				UDim2.new(0, 10, 1, -50),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quint,
				0.3,
				true
			)
		else
			minimizeBtn.Text = "−"

			mainFrame:TweenSizeAndPosition(
				originalSize,
				originalPosition,
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quint,
				0.3,
				true
			)

			task.delay(0.25, function()
				if not window.Minimized then
					tabContainer.Visible = true
					contentContainer.Visible = true
					footerBar.Visible = true
				end
			end)
		end
	end)

	-- Dragging
	local dragging = false
	local dragInput = nil
	local dragStart = Vector2.new()
	local startPos = UDim2.new()

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not window.Minimized then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			mainFrame.Position = newPos
			originalPosition = newPos
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.U then
			screenGui.Enabled = not screenGui.Enabled
			window.Hidden = not screenGui.Enabled
		end
	end)

	window.ScreenGui = screenGui
	window.MainFrame = mainFrame
	window.TabContainer = tabContainer
	window.ContentContainer = contentContainer

	return setmetatable(window, Library)
end

-- Tab Creation
function Library:CreateTab(name)
	local tab = { Elements = {}, Container = nil }

	local tabBtn = CreateElement("TextButton", {
		Size = UDim2.new(0, 120, 1, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 14,
		Font = Enum.Font.Gotham,
		ZIndex = 4,
		Parent = self.TabContainer
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = tabBtn })

	local stroke = nil 

	local scrollWrapper = CreateElement("Frame", {
		Name = "ScrollWrapper",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 4,
		Parent = self.ContentContainer
	})

	local tabContent = CreateElement("ScrollingFrame", {
		Name = "ScrollContent",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ClipsDescendants = false,
		ZIndex = 4,
		Parent = scrollWrapper
	})

	CreateElement("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		Parent = tabContent
	})

	local listLayout = CreateElement("UIListLayout", { Padding = UDim.new(0, 8), Parent = tabContent })

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	end)

	tabBtn.MouseButton1Click:Connect(function()
		for _, t in pairs(self.Tabs) do
			t.Container.Visible = false 
			t.Button.BackgroundTransparency = 0.2
			t.Button.TextColor3 = Color3.fromRGB(150, 150, 150)

			local s = t.Button:FindFirstChildOfClass("UIStroke")
			if s then s:Destroy() end
		end

		scrollWrapper.Visible = true
		tabBtn.BackgroundTransparency = 0
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

		stroke = AddBreathingStroke(tabBtn, ACCENT_COLOR_GREEN)
	end)

	tab.Container = scrollWrapper
	tab.ScrollContent = tabContent
	tab.Button = tabBtn
	tab.Stroke = stroke
	table.insert(self.Tabs, tab)

	if #self.Tabs == 1 then
		scrollWrapper.Visible = true
		tabBtn.BackgroundTransparency = 0
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

		stroke = AddBreathingStroke(tabBtn, ACCENT_COLOR_GREEN)
	end

	return setmetatable(tab, {__index = self})
end

-- Toggle Element
function Library:CreateToggle(text, default, callback)
	local toggled = default

	local toggleFrame = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = self.ScrollContent or self.Container 
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = toggleFrame })
	local stroke = AddBreathingStroke(toggleFrame, ACCENT_COLOR_GREEN)

	if not toggled then 
		stroke.Color = DIMMED_GREY
	end

	CreateElement("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
		Parent = toggleFrame
	})

	local toggleBtn = CreateElement("TextButton", {
		Size = UDim2.new(0, 40, 0, 20),
		Position = UDim2.new(1, -50, 0.5, -10),
		BackgroundColor3 = toggled and ACCENT_COLOR_GREEN or Color3.fromRGB(60, 60, 60),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 6,
		Parent = toggleFrame
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleBtn })

	local indicator = CreateElement("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = toggleBtn
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(1, 0), Parent = indicator })

	toggleBtn.MouseButton1Click:Connect(function()
		toggled = not toggled
		indicator:TweenPosition(toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
		toggleBtn.BackgroundColor3 = toggled and ACCENT_COLOR_GREEN or Color3.fromRGB(60, 60, 60)

		local targetColor = toggled and ACCENT_COLOR_GREEN or DIMMED_GREY 
		TweenService:Create(stroke, TweenInfo.new(0.3), {Color = targetColor}):Play()
		callback(toggled)
	end)
end

-- Slider Element
function Library:CreateSlider(text, min, max, default, callback)
	local sliderFrame = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = self.ScrollContent or self.Container
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = sliderFrame })

	local initialPos = (default - min) / (max - min)

	CreateElement("TextLabel", {
		Size = UDim2.new(1, -70, 0, 20),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
		Parent = sliderFrame
	})

	local valueLabel = CreateElement("TextLabel", {
		Size = UDim2.new(0, 60, 0, 20),
		Position = UDim2.new(1, -70, 0, 5),
		BackgroundTransparency = 1,
		Text = tostring(default),
		TextColor3 = ACCENT_COLOR_GREEN, -- Unified Green Value Text
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 6,
		Parent = sliderFrame
	})

	local sliderBg = CreateElement("Frame", {
		Size = UDim2.new(1, -20, 0, 6),
		Position = UDim2.new(0, 10, 1, -15),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = sliderFrame
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sliderBg })

	local sliderFill = CreateElement("Frame", {
		Size = UDim2.new(initialPos, 0, 1, 0),
		BackgroundColor3 = ACCENT_COLOR_GREEN, -- Unified Green Fill
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = sliderBg
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sliderFill })

	-- SLIDER GLOW EFFECT
	local glowGradient = CreateElement("UIGradient", {
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, ACCENT_COLOR_GREEN),
			ColorSequenceKeypoint.new(0.9, ACCENT_COLOR_GREEN),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
		},
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.9, 0),
			NumberSequenceKeypoint.new(1, 0.4), -- Fading White/Bright Green Edge
		},
		Rotation = 90,
		Parent = sliderFill
	})

	local function updateGlow(position)
		local offset = math.min(1, math.max(0, position))
		glowGradient.Offset = Vector2.new(-1 + offset, 0)
	end

	updateGlow(initialPos)

	local dragging = false
	local function update(input)
		local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * pos)
		sliderFill.Size = UDim2.new(pos, 0, 1, 0)
		valueLabel.Text = tostring(value)

		updateGlow(pos) 
		callback(value)
	end

	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
			dragging = false 
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then 
			update(input) 
		end
	end)
end

-- NEW ELEMENT: Number Input
function Library:CreateNumberInput(text, min, max, default, callback)
	min = min or 0
	max = max or 100
	default = default or min
	local currentValue = math.clamp(default, min, max)

	local inputFrame = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = self.ScrollContent or self.Container 
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = inputFrame })
	-- FIX: Removed AddBreathingStroke(inputFrame, ACCENT_COLOR_GREEN)

	CreateElement("TextLabel", {
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
		Parent = inputFrame
	})

	local inputBox = CreateElement("TextBox", {
		Size = UDim2.new(0, 100, 0, 30),
		Position = UDim2.new(1, -105, 0.5, -15),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Text = tostring(currentValue),
		TextColor3 = ACCENT_COLOR_GREEN,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		ClearTextOnFocus = false,
		ZIndex = 6,
		Parent = inputFrame
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(0, 6), Parent = inputBox })

	local function validateAndApply(newText)
		local value = tonumber(newText)
		if value ~= nil then
			value = math.floor(value)
			value = math.clamp(value, min, max)
			currentValue = value
			inputBox.Text = tostring(value)
			callback(value)
		else
			inputBox.Text = tostring(currentValue) -- Revert if invalid
		end
	end

	inputBox.FocusLost:Connect(function(enterPressed)
		validateAndApply(inputBox.Text)
	end)

	inputBox.Text = tostring(currentValue) -- Set initial value
	callback(currentValue) -- Call initially with default

end

-- Button Element
function Library:CreateButton(text, callback)
	local button = CreateElement("TextButton", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		ZIndex = 5,
		Parent = self.ScrollContent or self.Container
	})

	CreateElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = button })

	button.MouseButton1Click:Connect(function()
		OneShotPulse(button) 
		callback()
	end)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
	end)
end

-- Label Element
function Library:CreateLabel(text)
	local label = CreateElement("TextLabel", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.fromRGB(180, 180, 180),
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5,
		Parent = self.ScrollContent or self.Container
	})
	CreateElement("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = label })
end