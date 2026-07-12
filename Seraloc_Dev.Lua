--[[
    ============================================================
    Seraloc_Dev — PREMIUM SCRIPT HUB (Edição Final com Keybinds)
    LocalScript em StarterPlayer > StarterPlayerScripts
    ============================================================

    Comandos Globais:
    - Tecla [B]      -> Abre e fecha a interface (com animação suave)
    - Tecla [Delete] -> Deleta o script e limpa os desenhos da tela
    
    Sistema de Keybinds:
    - Digite uma letra na caixa ao lado do botão para definir um atalho.
    - Pressione a letra escolhida a qualquer momento para ativar/desativar a função.
]]

local Players           = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local CoreGui            = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

------------------------------------------------------------
-- PALETA PREMIUM HACKER
------------------------------------------------------------
local C = {
    bg        = Color3.fromRGB(6, 6, 8),
    panel     = Color3.fromRGB(11, 11, 14),
    panel2    = Color3.fromRGB(16, 16, 20),
    card      = Color3.fromRGB(20, 20, 25),
    border    = Color3.fromRGB(30, 30, 38),
    borderHi  = Color3.fromRGB(60, 60, 75),
    text      = Color3.fromRGB(240, 240, 245),
    subtext   = Color3.fromRGB(150, 150, 165),
    muted     = Color3.fromRGB(85, 85, 95),
    magenta   = Color3.fromRGB(255, 45, 170),
    green     = Color3.fromRGB(0, 255, 136),
}

local FONT_UI    = Enum.Font.Code
local FONT_HEAVY = Enum.Font.GothamBold

------------------------------------------------------------
-- CONFIGURAÇÕES INTERNAS AJUSTÁVEIS
------------------------------------------------------------
local fovRadius: number = 150
local Smoothness: number = 14
local flySpeed: number = 50
local RequireRightClick: boolean = false 

local noclipConnection = nil
local aimbotConnection = nil
local flyConnection = nil
local originalTransparencies = {}
local espActive = false
local espObjects = {}

-- Tabela global para rastrear os atalhos de cada função
local keybinds = {
    ["Invisible Mode"] = nil,
    ["NoClip Engine"]   = nil,
    ["ESP Box 2D"]      = nil,
    ["AimBot Pro"]      = nil,
    ["Fly Engine"]      = nil
}

------------------------------------------------------------
-- CÍRCULO DE FOV (DRAWING API)
------------------------------------------------------------
local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 1.5
FOVring.Color = C.magenta
FOVring.Filled = false
FOVring.Radius = fovRadius
FOVring.Position = camera.ViewportSize / 2

------------------------------------------------------------
-- ROOT DA INTERFACE
------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "SeralocDev_PremiumHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, _ = pcall(function() gui.Parent = CoreGui end)
if not success then gui.Parent = playerGui end

local function corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or C.border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop = UDim.new(0, top); p.PaddingBottom = UDim.new(0, bottom)
    p.PaddingLeft = UDim.new(0, left); p.PaddingRight = UDim.new(0, right)
    return p
end

------------------------------------------------------------
-- JANELA PRINCIPAL (DESIGN PREMIUM)
------------------------------------------------------------
local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.fromOffset(360, 340)
main.Position = UDim2.new(0.5, -180, 0.5, -170)
main.BackgroundColor3 = C.panel
main.BorderSizePixel = 0
main.Active = true
main.Visible = true
main.ClipsDescendants = true
main.ZIndex = 1
main.Parent = gui
corner(main, 12)
stroke(main, C.border, 1)

local topGlow = Instance.new("Frame", main)
topGlow.Size = UDim2.new(1, 0, 0, 3)
topGlow.BackgroundColor3 = C.magenta
topGlow.BorderSizePixel = 0
topGlow.ZIndex = 2

------------------------------------------------------------
-- HEADER
------------------------------------------------------------
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = C.bg
header.BorderSizePixel = 0
header.ZIndex = 2

local statusDot = Instance.new("Frame", header)
statusDot.Size = UDim2.fromOffset(8, 8)
statusDot.Position = UDim2.new(0, 16, 0.5, -4)
statusDot.BackgroundColor3 = C.green
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 3
corner(statusDot, 4)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -110, 1, 0)
title.Position = UDim2.new(0, 34, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Seraloc_Dev"
title.Font = FONT_HEAVY
title.TextSize = 17
title.TextColor3 = C.text
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = C.panel2
closeBtn.Text = "✕"
closeBtn.TextColor3 = C.subtext
closeBtn.Font = Enum.Font.RobotoMono
closeBtn.TextSize = 14
closeBtn.ZIndex = 3
corner(closeBtn, 6)
stroke(closeBtn, C.borderHi, 1)

closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromOffset(360, 0), BackgroundTransparency = 1}):Play()
    task.wait(0.2)
    main.Visible = false
end)

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.fromOffset(26, 26)
minimizeBtn.Position = UDim2.new(1, -66, 0.5, -13)
minimizeBtn.BackgroundColor3 = C.panel2
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = C.subtext
minimizeBtn.Font = Enum.Font.RobotoMono
minimizeBtn.TextSize = 12
minimizeBtn.ZIndex = 3
corner(minimizeBtn, 6)
stroke(minimizeBtn, C.borderHi, 1)

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(360, 46)}):Play()
        minimizeBtn.Text = "口"
    else
        TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(360, 340)}):Play()
        minimizeBtn.Text = "—"
    end
end)

------------------------------------------------------------
-- ÁREA DE CONTEÚDO (BOTÕES + ENTRADA DE KEYBINDS)
------------------------------------------------------------
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ButtonArea"
contentFrame.Size = UDim2.new(1, 0, 1, -46)
contentFrame.Position = UDim2.new(0, 0, 0, 46)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ZIndex = 2
contentFrame.Parent = main

local buttonListContainer = Instance.new("Frame", contentFrame)
buttonListContainer.Size = UDim2.new(1, 0, 1, -30)
buttonListContainer.BackgroundTransparency = 1
buttonListContainer.BorderSizePixel = 0
buttonListContainer.ZIndex = 2
padding(buttonListContainer, 10, 0, 15, 15)

local list = Instance.new("UIListLayout", buttonListContainer)
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder

-- Construtor Avançado: Cria uma linha com Botão de Ativar + Caixa de Entrada do Atalho
local function createHackButton(name, callback)
    local row = Instance.new("Frame", buttonListContainer)
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, -50, 1, 0) -- Reserva espaço de 50 pixels à direita para o Keybind
    btn.BackgroundColor3 = C.card
    btn.Text = name .. " [DESATIVADO]"
    btn.TextColor3 = C.subtext
    btn.Font = FONT_UI
    btn.TextSize = 13
    btn.ZIndex = 4
    corner(btn, 8)
    local bStroke = stroke(btn, C.border, 1)
    
    local keyBox = Instance.new("TextBox", row)
    keyBox.Size = UDim2.fromOffset(42, 38)
    keyBox.Position = UDim2.new(1, -42, 0, 0)
    keyBox.BackgroundColor3 = C.panel2
    keyBox.Text = "NONE"
    keyBox.TextColor3 = C.muted
    keyBox.Font = FONT_UI
    keyBox.TextSize = 12
    keyBox.ClearTextOnFocus = true
    keyBox.ZIndex = 4
    corner(keyBox, 6)
    stroke(keyBox, C.border, 1)

    local active = false
    
    local function triggerAction()
        active = not active
        if active then
            btn.Text = name .. " [ATIVADO]"
            btn.TextColor3 = C.green
            bStroke.Color = C.green
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.panel2}):Play()
        else
            btn.Text = name .. " [DESATIVADO]"
            btn.TextColor3 = C.subtext
            bStroke.Color = C.border
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.card}):Play()
        end
        callback(active)
    end

    btn.MouseButton1Click:Connect(triggerAction)

    -- Detecta quando o usuário digita uma tecla para salvar o atalho
    keyBox.FocusLost:Connect(function(enterPressed)
        local input = keyBox.Text:upper()
        if #input == 1 then
        local _keyCodeName = "Key" .. input            -- Verifica se a tecla digitada existe no sistema do Roblox
            local valid, code = pcall(function() return Enum.KeyCode[input] end)
            if valid then
                keybinds[name] = code
                keyBox.Text = input
            keyBox.TextColor3 = C.magenta
        else
            keybinds[name] = nil
            keyBox.Text = "NONE"
            keyBox.TextColor3 = C.muted
        end
    else
        keybinds[name] = nil
        keyBox.Text = "NONE"
        keyBox.TextColor3 = C.muted
    end
end)

    -- Mapeia o disparo externo da tecla vinculada
    return triggerAction
end

------------------------------------------------------------
-- ALGORITMOS DE BUSCA (AIMBOT TEAM CHECK)
------------------------------------------------------------
local function getClosestEnemy(trg_part)
    local nearest = nil
    local last = math.huge
    local screenCenter = camera.ViewportSize / 2

    for _, p in pairs(Players:GetPlayers()) do
        if p == player then continue end
        if p.Team and player.Team and p.Team == player.Team then continue end
        
        local character = p.Character
        local part = character and character:FindFirstChild(trg_part)
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if part and humanoid and humanoid.Health > 0 then
            local ePos, isVisible = camera:WorldToViewportPoint(part.Position)
            if isVisible then
                local distance = (Vector2.new(ePos.X, ePos.Y) - screenCenter).Magnitude
                if distance < last and distance < fovRadius then
                    last = distance
                    nearest = part
                end
            end
        end
    end
    return nearest
end

------------------------------------------------------------
-- INJEÇÃO VISUAL DOS CARDS DE FUNÇÃO E RETORNO DOS GATILHOS
------------------------------------------------------------

-- 1. Invisible
local toggleInv = createHackButton("Invisible Mode", function(state)
    local char = player.Character
    if not char then return end
    if state then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                originalTransparencies[part] = part.Transparency
                part.Transparency = 1
            end
        end
    else
        for part, trans in pairs(originalTransparencies) do
            if part and part.Parent then part.Transparency = trans end
        end
        table.clear(originalTransparencies)
    end
end)

-- 2. NoClip
local toggleClip = createHackButton("NoClip Engine", function(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else

if noclipConnection then 
    noclipConnection:Disconnect() 
    noclipConnection = nil 
end    
end
end)

-- 3. ESP Box 2D
local toggleEsp = createHackButton("ESP Box 2D", function(state)
    espActive = state
    if state then
        local function createESP(p)
            if p == player then return end
            
            local box = Drawing.new("Square"); box.Visible = false; box.Color = C.magenta; box.Thickness = 1.5; box.Filled = false
            local healthBarBg = Drawing.new("Square"); healthBarBg.Visible = false; healthBarBg.Color = Color3.fromRGB(40, 40, 40); healthBarBg.Thickness = 1; healthBarBg.Filled = true
            local healthBar = Drawing.new("Square"); healthBar.Visible = false; healthBar.Color = C.green; healthBar.Thickness = 1; healthBar.Filled = true
            local distText = Drawing.new("Text"); distText.Visible = false; distText.Color = C.text; distText.Size = 13; distText.Center = true; distText.Outline = true; distText.Font = 2

            espObjects[p] = {box, healthBarBg, healthBar, distText}

            local conn
            conn = RunService.RenderStepped:Connect(function()
                if not espActive or not espObjects[p] then
                    box:Remove(); healthBarBg:Remove(); healthBar:Remove(); distText:Remove()
                    if conn then conn:Disconnect() end
                    return
                end

                local char = p.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local distanceStuds = (camera.CFrame.Position - hrp.Position).Magnitude
                        local sizeX = math.clamp(2000 / distanceStuds, 10, 150)
                        local sizeY = math.clamp(3000 / distanceStuds, 15, 220)

                        box.Size = Vector2.new(sizeX, sizeY)
                        box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                        box.Visible = true

                        local barWidth = 3; local barOffsetX = 6
                        healthBarBg.Size = Vector2.new(barWidth, sizeY)
                        healthBarBg.Position = Vector2.new(box.Position.X - barOffsetX, box.Position.Y)
                        healthBarBg.Visible = true

                        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        healthBar.Size = Vector2.new(barWidth, sizeY * healthPercent)
                        healthBar.Position = Vector2.new(box.Position.X - barOffsetX, box.Position.Y + (sizeY * (1 - healthPercent)))
                        healthBar.Visible = true

                        local distanceMeters = distanceStuds / 3.57
                        local displayDistance = (distanceMeters >= 1000) and string.format("%.2f km", distanceMeters / 1000) or string.format("%.0f m", distanceMeters)

                        distText.Text = displayDistance
                        distText.Position = Vector2.new(pos.X, box.Position.Y + sizeY + 4)
                        distText.Visible = true
                    else
                        box.Visible = false; healthBarBg.Visible = false; healthBar.Visible = false; distText.Visible = false
                    end
                else
                    box.Visible = false; healthBarBg.Visible = false; healthBar.Visible = false; distText.Visible = false
                end
            end)
        end
        for _, p in pairs(Players:GetPlayers()) do createESP(p) end
        Players.PlayerAdded:Connect(createESP)
    else
        for p, objs in pairs(espObjects) do
            for _, obj in pairs(objs) do obj:Remove() end
        end
        table.clear(espObjects)
    end
end)

-- 4. AimBot Pro
local toggleAim = createHackButton("AimBot Pro", function(state)
-- Correção do Aimbot Connection
if aimbotConnection then 
    aimbotConnection:Disconnect() 
    aimbotConnection = nil 
end
    if state then
        aimbotConnection = RunService.RenderStepped:Connect(function(deltaTime)
            FOVring.Position = camera.ViewportSize / 2
            FOVring.Visible = true
            
            if not RequireRightClick or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local targetPart = getClosestEnemy("Head")
                if targetPart then
                    local targetCFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
                    local t = math.clamp(Smoothness * deltaTime, 0, 1)
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame, t)
                end
            end
        end)
    else
        FOVring.Visible = false
if aimbotConnection then 
    aimbotConnection:Disconnect() 
    aimbotConnection = nil 
end    end
end)

-- 5. Fly Hack
local toggleFly = createHackButton("Fly Engine", function(state)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if state then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "Seraloc_Fly"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.new(0, 0, 0)
        local bg = Instance.new("BodyGyro", hrp)
        bg.Name = "Seraloc_Gyro"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = hrp.CFrame

        flyConnection = RunService.RenderStepped:Connect(function()
            local camCFrame = camera.CFrame
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
            
            bv.Velocity = moveDir.Unit * flySpeed
            bg.CFrame = camCFrame
            if moveDir == Vector3.new(0,0,0) then bv.Velocity = Vector3.new(0,0,0) end
        end)
    else
       if flyConnection then 
    flyConnection:Disconnect() 
    flyConnection = nil 
end

        if hrp:FindFirstChild("Seraloc_Fly") then hrp.Seraloc_Fly:Destroy() end
        if hrp:FindFirstChild("Seraloc_Gyro") then hrp.Seraloc_Gyro:Destroy() end
    end
end)

------------------------------------------------------------
-- RODAPÉ DE AUTORIA
------------------------------------------------------------
local footer = Instance.new("TextLabel", contentFrame)
footer.Size = UDim2.new(1, 0, 0, 30)
footer.Position = UDim2.new(0, 0, 1, -30)
footer.BackgroundColor3 = C.bg
footer.Text = "Criado por Seraloc_Dev | Todos os direitos reservados"
footer.Font = FONT_UI
footer.TextSize = 10
footer.TextColor3 = C.muted
footer.ZIndex = 2
stroke(footer, C.border, 1)

------------------------------------------------------------
-- SISTEMA DRAGGABLE (Mover Clicando no Topo)
------------------------------------------------------------
local dragging, dragInput, dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then 
                dragging = false 
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then 
        dragInput = input 
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

------------------------------------------------------------
-- SISTEMA DE LEITURA DAS TECLAS CUSTOMIZÁVEIS E GLOBAIS
------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Escuta dinamicamente se o usuário pressionou o atalho salvo de cada função
    if input.KeyCode == keybinds["Invisible Mode"] then 
        toggleInv()
    elseif input.KeyCode == keybinds["NoClip Engine"] then 
        toggleClip()
    elseif input.KeyCode == keybinds["ESP Box 2D"] then 
        toggleEsp()
    elseif input.KeyCode == keybinds["AimBot Pro"] then 
        toggleAim()
    elseif input.KeyCode == keybinds["Fly Engine"] then 
        toggleFly()
    
    -- Tecla [B] - Oculta/Exibe o Menu
    elseif input.KeyCode == Enum.KeyCode.B then
        if main.Visible then
            TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromOffset(360, 0), BackgroundTransparency = 1}):Play()
            task.wait(0.2)
            main.Visible = false
        else
            main.Visible = true
            main.Size = UDim2.fromOffset(360, 0)
            main.BackgroundTransparency = 1
            TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(360, 340), BackgroundTransparency = 0}):Play()
        end
        
    -- Tecla [Delete] - Autodestruição e Limpeza
    elseif input.KeyCode == Enum.KeyCode.Delete then
        espActive = false
        if aimbotConnection then aimbotConnection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
        if flyConnection then flyConnection:Disconnect() end
        if FOVring then FOVring:Remove() end
        
        for p, objs in pairs(espObjects) do
            for _, obj in pairs(objs) do 
                obj:Remove() 
            end
        end
        table.clear(espObjects)
        
        local char = player.Character
        if char then
            for part, trans in pairs(originalTransparencies) do
                if part and part.Parent then 
                    part.Transparency = trans 
                end
            end
        end
        table.clear(originalTransparencies)
        gui:Destroy()
    end
end)
