local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local NotificationService = {}

local SCREEN_OFFSET = UDim2.new(1, -20, 1, -20)
local NOTIFICATION_WIDTH = 350
local NOTIFICATION_HEIGHT = 100
local PADDING = 15
local ANIMATION_SPEED = 0.25
local MAX_NOTIFICATIONS = 15

local COLORS = {
    Success = Color3.fromRGB(46, 204, 113),
    Error = Color3.fromRGB(231, 76, 60),
    Warning = Color3.fromRGB(241, 196, 15),
    Info = Color3.fromRGB(52, 152, 219),
    Background = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(240, 240, 240),
    SecondaryText = Color3.fromRGB(180, 180, 180),
    Shadow = Color3.fromRGB(10, 10, 10)
}

-- Создаем ScreenGui с максимальным ZIndex
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NotificationSystem"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999  -- Обеспечивает отображение поверх всего
ScreenGui.Parent = CoreGui

local NotificationsContainer = Instance.new("Frame")
NotificationsContainer.Name = "NotificationsContainer"
NotificationsContainer.BackgroundTransparency = 1
NotificationsContainer.Size = UDim2.new(0, NOTIFICATION_WIDTH + PADDING*2, 1, 0)
NotificationsContainer.Position = SCREEN_OFFSET
NotificationsContainer.AnchorPoint = Vector2.new(1, 1)
NotificationsContainer.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = NotificationsContainer
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout.Padding = UDim.new(0, PADDING)

local function createNotification(title, description, color, duration, notificationType)
    local notifications = NotificationsContainer:GetChildren()
    local notificationCount = 0
    
    -- Считаем только настоящие уведомления и обновляем позиции
    for _, child in ipairs(notifications) do
        if child:IsA("Frame") and child.Name == "Notification" then
            notificationCount = notificationCount + 1
            local moveTween = TweenService:Create(
                child,
                TweenInfo.new(ANIMATION_SPEED/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0, -((NOTIFICATION_HEIGHT + PADDING) * notificationCount))}
            )
            moveTween:Play()
        end
    end
    
    -- Удаляем самое старое уведомление если достигли лимита
    if notificationCount >= MAX_NOTIFICATIONS then
        local oldestNotification
        for _, child in ipairs(notifications) do
            if child:IsA("Frame") and child.Name == "Notification" then
                oldestNotification = child
                break
            end
        end
        if oldestNotification then 
            oldestNotification:Destroy() 
        end
    end
    
    -- Создаем уведомление с высоким ZIndex
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = COLORS.Background
    notification.BackgroundTransparency = 0
    notification.Size = UDim2.new(1, -PADDING*2, 0, NOTIFICATION_HEIGHT)
    notification.Position = UDim2.new(0, 0, 2, 0)
    notification.ClipsDescendants = true
    notification.ZIndex = 1000  -- Высокий ZIndex для поверх всего
    notification.Parent = NotificationsContainer
    
    -- Тень для уведомления
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = COLORS.Shadow
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.ZIndex = notification.ZIndex - 1
    shadow.Parent = notification
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    -- Убрана левая акцентная полоса
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.BackgroundTransparency = 1
    contentContainer.Size = UDim2.new(1, -16, 1, -16)  -- Отступы со всех сторон
    contentContainer.Position = UDim2.new(0, 8, 0, 8)
    contentContainer.ZIndex = notification.ZIndex + 1
    contentContainer.Parent = notification
    
    -- Заголовок с иконкой типа уведомления
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.BackgroundTransparency = 1
    titleContainer.Size = UDim2.new(1, 0, 0, 20)
    titleContainer.Position = UDim2.new(0, 0, 0, 0)
    titleContainer.ZIndex = contentContainer.ZIndex + 1
    titleContainer.Parent = contentContainer
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = string.upper(title)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = color
    titleLabel.TextSize = 14
    titleLabel.TextTransparency = 0
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = titleContainer.ZIndex + 1
    titleLabel.Parent = titleContainer
    
    -- Разделитель
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    divider.BorderSizePixel = 0
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0, 24)
    divider.ZIndex = contentContainer.ZIndex + 1
    divider.Parent = contentContainer
    
    -- Описание
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Text = description
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextColor3 = COLORS.Text
    descLabel.TextSize = 12
    descLabel.TextTransparency = 0
    descLabel.BackgroundTransparency = 1
    descLabel.Position = UDim2.new(0, 0, 0, 28)
    descLabel.Size = UDim2.new(1, 0, 1, -32)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.ZIndex = contentContainer.ZIndex + 1
    descLabel.Parent = contentContainer
    
    -- Таймер бар (только снизу)
    local timerBarBackground = Instance.new("Frame")
    timerBarBackground.Name = "TimerBarBackground"
    timerBarBackground.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    timerBarBackground.BorderSizePixel = 0
    timerBarBackground.Size = UDim2.new(1, -8, 0, 3)
    timerBarBackground.Position = UDim2.new(0, 4, 1, -6)
    timerBarBackground.ZIndex = notification.ZIndex + 1
    timerBarBackground.Parent = notification
    
    local timerBarBackgroundCorner = Instance.new("UICorner")
    timerBarBackgroundCorner.CornerRadius = UDim.new(0, 1)
    timerBarBackgroundCorner.Parent = timerBarBackground
    
    local timerBar = Instance.new("Frame")
    timerBar.Name = "TimerBar"
    timerBar.BackgroundColor3 = color
    timerBar.BorderSizePixel = 0
    timerBar.Size = UDim2.new(1, 0, 1, 0)
    timerBar.Position = UDim2.new(0, 0, 0, 0)
    timerBar.ZIndex = timerBarBackground.ZIndex + 1
    timerBar.Parent = timerBarBackground
    
    local timerCorner = Instance.new("UICorner")
    timerCorner.CornerRadius = UDim.new(0, 1)
    timerCorner.Parent = timerBar
    
    -- Анимация появления
    local appearTween = TweenService:Create(
        notification,
        TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 1, -((NOTIFICATION_HEIGHT + PADDING) * (notificationCount + 1)))}
    )
    appearTween:Play()
    
    -- Анимация таймера
    local timerTween = TweenService:Create(
        timerBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 1, 0)}
    )
    timerTween:Play()
    
    -- Автоматическое закрытие через duration секунд
    task.delay(duration, function()
        if not notification or not notification.Parent then return end
        
        -- Анимация исчезновения
        local disappearTween = TweenService:Create(
            notification,
            TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                Position = UDim2.new(0, 0, 2, 0),
                BackgroundTransparency = 1
            }
        )
        
        -- Прозрачность для всех дочерних элементов
        for _, child in ipairs(notification:GetDescendants()) do
            if child:IsA("TextLabel") then
                TweenService:Create(
                    child,
                    TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {TextTransparency = 1}
                ):Play()
            elseif child:IsA("Frame") and child.Name ~= "Shadow" then
                TweenService:Create(
                    child,
                    TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {BackgroundTransparency = 1}
                ):Play()
            elseif child:IsA("ImageLabel") then
                TweenService:Create(
                    child,
                    TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {ImageTransparency = 1}
                ):Play()
            end
        end
        
        disappearTween:Play()
        disappearTween.Completed:Connect(function()
            if notification then
                notification:Destroy()
            end
        end)
    end)
    
    return notification
end

function NotificationService.Notify(duration, title, description, notificationType)
    local color = COLORS.Info
    if notificationType == "Success" then 
        color = COLORS.Success
    elseif notificationType == "Error" then 
        color = COLORS.Error
    elseif notificationType == "Warning" then 
        color = COLORS.Warning
    end
    
    createNotification(title, description, color, duration, notificationType)
end

-- Дополнительные удобные методы
function NotificationService.Success(title, description, duration)
    duration = duration or 5
    NotificationService.Notify(duration, title, description, "Success")
end

function NotificationService.Error(title, description, duration)
    duration = duration or 5
    NotificationService.Notify(duration, title, description, "Error")
end

function NotificationService.Warning(title, description, duration)
    duration = duration or 5
    NotificationService.Notify(duration, title, description, "Warning")
end

function NotificationService.Info(title, description, duration)
    duration = duration or 5
    NotificationService.Notify(duration, title, description, "Info")
end

return NotificationService
