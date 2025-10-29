print("[Space Hub]: Loading Starter Gui");
getgenv().StarterScreen = "Halloween"; -- Style: Default / Halloween / Christmas / Easter

local CoreGui = game:GetService("CoreGui");
local TweenService = game:GetService("TweenService");
local Lighting = game:GetService("Lighting");
local UserInputService = game:GetService("UserInputService");

local protect_gui = protect_gui or (syn and syn.protect_gui) or function(gui)
	if gethui then gui.Parent = gethui() else gui.Parent = CoreGui end;
end;

local function RandomString(len)
	local s, c = "", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	for i = 1, len or 12 do
		local r = math.random(1, #c);
		s = s .. c:sub(r, r);
	end;
	return s;
end;

local function Tween(o, t, p)
	local tw = TweenService:Create(o, TweenInfo.new(t or 1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p);
	tw:Play();
	return tw;
end;

local function SpaceHubLoader(cfg)
	cfg = cfg or {};
	cfg.Name = cfg.Name or "Space Hub";
	cfg.Style = cfg.Style or "Default";
	cfg.Scale = cfg.Scale or 3;

	local gui = Instance.new("ScreenGui");
	gui.Name = RandomString();
	gui.IgnoreGuiInset = true;
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
	gui.DisplayOrder = 9999;
	protect_gui(gui);

	local blur = Instance.new("BlurEffect");
	blur.Size = 0;
	blur.Parent = Lighting;

	local bg = Instance.new("Frame");
	bg.Size = UDim2.new(1, 0, 1, 0);
	bg.BackgroundTransparency = 0.7;
	bg.ZIndex = 1;
	bg.Parent = gui;

	local grad = Instance.new("UIGradient");
	grad.Rotation = 0;
	if cfg.Style == "Halloween" then
		grad.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 60, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 0, 0))
		};
	elseif cfg.Style == "Christmas" then
		grad.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 160, 80)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 60, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 160, 80))
		};
	elseif cfg.Style == "Easter" then
		grad.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 230)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 240, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 230, 200))
		};
	else
		grad.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 40, 160)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 70, 230)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 50, 180))
		};
	end;
	grad.Parent = bg;

	local vignette = Instance.new("ImageLabel");
	vignette.Size = UDim2.new(1.1, 0, 1.1, 0);
	vignette.AnchorPoint = Vector2.new(0.5, 0.5);
	vignette.Position = UDim2.new(0.5, 0, 0.5, 0);
	vignette.BackgroundTransparency = 1;
	vignette.Image = "rbxassetid://7143647374";
	vignette.ImageTransparency = 1;
	vignette.ZIndex = 2;
	vignette.Parent = bg;

	local frame = Instance.new("Frame");
	frame.AnchorPoint = Vector2.new(0.5, 0.5);
	frame.Position = UDim2.new(0.5, 0, 0.5, 0);
	frame.BackgroundTransparency = 1;
	frame.Size = UDim2.new(0, 0, 0, 0);
	frame.ZIndex = 3;
	frame.Parent = gui;

	local layout = Instance.new("UIListLayout");
	layout.FillDirection = Enum.FillDirection.Horizontal;
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
	layout.VerticalAlignment = Enum.VerticalAlignment.Center;
	layout.Padding = UDim.new(0, 6 * cfg.Scale);
	layout.Parent = frame;

	Tween(blur, 2, { Size = 50 });
	Tween(vignette, 2, { ImageTransparency = 0.5 });

	task.spawn(function()
		while gui.Parent do
			Tween(grad, 8, { Rotation = grad.Rotation + 90 });
			task.wait(8);
		end;
	end);

	task.wait(1.8);

	local colorThemes = {
		Halloween = {Color3.fromRGB(255, 120, 0), Color3.fromRGB(255, 60, 0), Color3.fromRGB(180, 0, 0)},
		Christmas = {Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 220, 100)},
		Easter = {Color3.fromRGB(255, 170, 220), Color3.fromRGB(255, 255, 200), Color3.fromRGB(180, 220, 255)},
		Default = {Color3.fromRGB(160, 100, 255), Color3.fromRGB(200, 140, 255), Color3.fromRGB(120, 80, 220)}
	};

	local theme = colorThemes[cfg.Style] or colorThemes.Default;
	local letters = {};

	local isMobile = UserInputService.TouchEnabled;
	local screenSize = workspace.CurrentCamera.ViewportSize;
	local maxWidth = screenSize.X * 0.9;
	local letterSpacing = 6 * cfg.Scale;
	local totalLetters = #cfg.Name;
	
	local baseLetterWidth = 36 * cfg.Scale;
	local baseLetterHeight = 80 * cfg.Scale;
	local totalWidthNeeded = (baseLetterWidth * totalLetters) + (letterSpacing * (totalLetters - 1));
	
	local actualScale = cfg.Scale;
	if totalWidthNeeded > maxWidth then
		actualScale = cfg.Scale * (maxWidth / totalWidthNeeded);
	end;

	for _, ch in ipairs(cfg.Name:split("")) do
		local holder = Instance.new("Frame");
		holder.BackgroundTransparency = 1;
		holder.Size = UDim2.new(0, 36 * actualScale, 0, 80 * actualScale);
		holder.ZIndex = 4;
		holder.Parent = frame;

		local lbl = Instance.new("TextLabel");
		lbl.AnchorPoint = Vector2.new(0.5, 0.5);
		lbl.Position = UDim2.new(0.5, 0, 0.5, 0);
		lbl.BackgroundTransparency = 1;
		lbl.Font = Enum.Font.GothamBlack;
		lbl.Text = ch;
		lbl.TextSize = isMobile and math.min(60, 60 * actualScale / cfg.Scale) or 60;
		lbl.TextTransparency = 1;
		lbl.TextColor3 = Color3.new(1, 1, 1);
		lbl.Rotation = math.random(-15, 15);
		lbl.ZIndex = 5;
		lbl.Size = UDim2.new(1, 0, 1, 0);
		lbl.TextScaled = true;
		lbl.Parent = holder;

		local gradTxt = Instance.new("UIGradient");
		gradTxt.Color = ColorSequence.new{theme[1], theme[2], theme[3]};
		gradTxt.Rotation = math.random(0, 90);
		gradTxt.Parent = lbl;

		table.insert(letters, lbl);
	end;

	local totalFrameWidth = (36 * actualScale * totalLetters) + (letterSpacing * (totalLetters - 1));
	frame.Size = UDim2.new(0, totalFrameWidth, 0, 80 * actualScale);

	for i, lbl in ipairs(letters) do
		task.delay(i * 0.25, function()
			Tween(lbl, 0.6, { TextTransparency = 0 });
			task.wait(0.6);
			for _ = 1, 2 do
				Tween(lbl, 0.15, { TextTransparency = 0.5 });
				task.wait(0.15);
				Tween(lbl, 0.15, { TextTransparency = 0 });
				task.wait(0.15);
			end;
		end);
	end;

	task.wait(#letters * 0.25 + 2);
	for i, lbl in ipairs(letters) do
		task.delay(i * 0.25, function()
			Tween(lbl, 1.2, {
				TextTransparency = 1,
				Position = lbl.Position + UDim2.new(0, 0, -3.5, 0),
				Rotation = lbl.Rotation + math.random(-40, 40)
			});
		end);
	end;

	task.wait(#letters * 0.25 + 1.8);
	Tween(vignette, 2, { ImageTransparency = 1 });
	Tween(blur, 2, { Size = 0 });
	Tween(bg, 2, { BackgroundTransparency = 1 });
	task.wait(2.2);

	gui:Destroy();
	blur:Destroy();
end;

SpaceHubLoader({
	Name = "SPACE HUB",
	Style = getgenv().StarterScreen,
	Scale = 4
});
