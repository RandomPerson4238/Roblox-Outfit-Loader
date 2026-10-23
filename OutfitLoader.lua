-- R6 AVATAR CHANGER
-- Accessory-first attachment with source weld preservation
-- Classic clothing + BodyColors + head mesh/texture + R6 CharacterMesh bundles
-- Client-side appearance only
-- No Moon Animator / Studio plugin dependencies

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GUI_NAME = "AvatarChangerUI"

local applying = false
local applyOnRespawn = false
local lastUsername = ""
local respawnConnection

local BODY_PART_NAMES = {
    "Head",
    "Torso",
    "Left Arm",
    "Right Arm",
    "Left Leg",
    "Right Leg",
}

--==================================================
-- GUI
--==================================================

local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild(GUI_NAME)
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = playerGui

-- Main window
local frame = Instance.new("Frame")
frame.Name = "MainWindow"
frame.Size = UDim2.fromOffset(300, 190)
frame.Position = UDim2.new(0.5, -150, 0.5, -95)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ZIndex = 10
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(70, 70, 88)
frameStroke.Thickness = 1
frameStroke.Parent = frame

-- Small draggable toggle icon
local toggleIcon = Instance.new("TextButton")
toggleIcon.Name = "ToggleIcon"
toggleIcon.Size = UDim2.fromOffset(42, 42)
toggleIcon.Position = UDim2.new(0, 18, 0.42, 0)
toggleIcon.BackgroundColor3 = Color3.fromRGB(45, 55, 82)
toggleIcon.BorderSizePixel = 0
toggleIcon.Text = "A"
toggleIcon.TextColor3 = Color3.new(1, 1, 1)
toggleIcon.TextSize = 21
toggleIcon.Font = Enum.Font.GothamBold
toggleIcon.Active = true
toggleIcon.Draggable = true
toggleIcon.ZIndex = 20
toggleIcon.Parent = gui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 13)
iconCorner.Parent = toggleIcon

local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Color3.fromRGB(110, 140, 220)
iconStroke.Thickness = 1.5
iconStroke.Parent = toggleIcon

local iconHint = Instance.new("TextLabel")
iconHint.Name = "IconHint"
iconHint.Size = UDim2.new(1, 0, 0, 12)
iconHint.Position = UDim2.new(0, 0, 1, -2)
iconHint.BackgroundTransparency = 1
iconHint.Text = "AV"
iconHint.TextColor3 = Color3.fromRGB(220, 225, 245)
iconHint.TextSize = 8
iconHint.Font = Enum.Font.GothamBold
iconHint.ZIndex = 21
iconHint.Parent = toggleIcon

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -45, 0, 32)
title.Position = UDim2.fromOffset(10, 5)
title.BackgroundTransparency = 1
title.Text = "R6 Avatar Changer"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 11
title.Parent = frame

-- Hide button
local close = Instance.new("TextButton")
close.Name = "HideWindow"
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -33, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(170, 55, 65)
close.BorderSizePixel = 0
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.ZIndex = 12
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = close

-- Username input
local input = Instance.new("TextBox")
input.Name = "UsernameInput"
input.Size = UDim2.new(1, -20, 0, 34)
input.Position = UDim2.fromOffset(10, 43)
input.BackgroundColor3 = Color3.fromRGB(45, 45, 56)
input.BorderSizePixel = 0
input.TextColor3 = Color3.new(1, 1, 1)
input.PlaceholderText = "Roblox username..."
input.PlaceholderColor3 = Color3.fromRGB(155, 155, 170)
input.Text = ""
input.ClearTextOnFocus = false
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.ZIndex = 11
input.Parent = frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = input

-- Apply button
local applyButton = Instance.new("TextButton")
applyButton.Name = "ApplyButton"
applyButton.Size = UDim2.new(1, -20, 0, 34)
applyButton.Position = UDim2.fromOffset(10, 85)
applyButton.BackgroundColor3 = Color3.fromRGB(70, 105, 190)
applyButton.BorderSizePixel = 0
applyButton.Text = "Apply Avatar"
applyButton.TextColor3 = Color3.new(1, 1, 1)
applyButton.Font = Enum.Font.GothamBold
applyButton.TextSize = 14
applyButton.ZIndex = 11
applyButton.Parent = frame

local applyCorner = Instance.new("UICorner")
applyCorner.CornerRadius = UDim.new(0, 6)
applyCorner.Parent = applyButton

-- Respawn toggle
local respawnButton = Instance.new("TextButton")
respawnButton.Name = "RespawnButton"
respawnButton.Size = UDim2.new(1, -20, 0, 28)
respawnButton.Position = UDim2.fromOffset(10, 126)
respawnButton.BackgroundColor3 = Color3.fromRGB(65, 65, 78)
respawnButton.BorderSizePixel = 0
respawnButton.TextColor3 = Color3.new(1, 1, 1)
respawnButton.Font = Enum.Font.Gotham
respawnButton.TextSize = 12
respawnButton.ZIndex = 11
respawnButton.Parent = frame

local respawnCorner = Instance.new("UICorner")
respawnCorner.CornerRadius = UDim.new(0, 6)
respawnCorner.Parent = respawnButton

-- Status
local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -20, 0, 23)
status.Position = UDim2.fromOffset(10, 160)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(190, 190, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.ZIndex = 11
status.Parent = frame

local function setStatus(message)
    if status and status.Parent then
        status.Text = tostring(message)
    end
end

local function updateRespawnButton()
    if applyOnRespawn then
        respawnButton.Text = "Apply When Respawn: ON"
        respawnButton.BackgroundColor3 = Color3.fromRGB(50, 135, 90)
    else
        respawnButton.Text = "Apply When Respawn: OFF"
        respawnButton.BackgroundColor3 = Color3.fromRGB(65, 65, 78)
    end
end

toggleIcon.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

close.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

updateRespawnButton()

--==================================================
-- R6 CHARACTER HELPERS
--==================================================

local function inspectR6Model(model)
    if not model or not model:IsA("Model") then
        return nil
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local head = model:FindFirstChild("Head")
    local torso = model:FindFirstChild("Torso")

    if not humanoid or not head or not torso then
        return nil
    end

    if not head:IsA("BasePart") or not torso:IsA("BasePart") then
        return nil
    end

    if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
        return nil
    end

    return model, head, humanoid
end

local function getR6Character()
    local characterRoot = LocalPlayer.Character
    if not characterRoot then
        return nil
    end

    -- If the assigned character itself is R15, do not select
    -- an unrelated R6 model that happens to be nested inside it.
    local rootHumanoid = characterRoot:FindFirstChildOfClass("Humanoid")
    if rootHumanoid and rootHumanoid.RigType ~= Enum.HumanoidRigType.R6 then
        return nil
    end

    -- Typical case: LocalPlayer.Character is the rig itself.
    local model, head, humanoid = inspectR6Model(characterRoot)
    if model then
        return model, head, humanoid
    end

    -- Support games that wrap the actual rig in nested Models/Folders,
    -- provided the wrapper is still LocalPlayer.Character.
    for _, descendant in ipairs(characterRoot:GetDescendants()) do
        if descendant:IsA("Model") then
            model, head, humanoid = inspectR6Model(descendant)
            if model then
                return model, head, humanoid
            end
        end
    end

    return nil
end

local function getHandle(accessory)
    local handle = accessory:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        return handle
    end
    return nil
end

local function getBodyPart(model, name)
    local part = model:FindFirstChild(name)
    if part and part:IsA("BasePart") then
        return part
    end
    return nil
end

-- Searches only the six R6 body parts, not existing accessories.
local function findBodyAttachment(character, attachmentName)
    for _, partName in ipairs(BODY_PART_NAMES) do
        local part = getBodyPart(character, partName)
        if part then
            for _, object in ipairs(part:GetDescendants()) do
                if object:IsA("Attachment") and object.Name == attachmentName then
                    return object, part
                end
            end
        end
    end
    return nil, nil
end

--==================================================
-- LAYERED CLOTHING FILTER
--==================================================

local layeredTypes = {}

for _, name in ipairs({
    "TShirt",
    "Shirt",
    "Pants",
    "Jacket",
    "Sweater",
    "Shorts",
    "LeftShoe",
    "RightShoe",
    "DressSkirt",
}) do
    local ok, accessoryType = pcall(function()
        return Enum.AccessoryType[name]
    end)
    if ok and accessoryType then
        layeredTypes[accessoryType] = true
    end
end

local function isLayeredClothing(accessory)
    local ok, accessoryType = pcall(function()
        return accessory.AccessoryType
    end)
    return ok and layeredTypes[accessoryType] == true
end

--==================================================
-- CAPTURE ORIGINAL SOURCE WELD
--==================================================

-- Read the original accessory BEFORE cloning it. Cloning an accessory
-- separately may lose references from its joint to the source body part.
local function getOriginalBinding(sourceModel, sourceAccessory)
    local handle = getHandle(sourceAccessory)
    if not handle then
        return nil
    end

    for _, object in ipairs(sourceAccessory:GetDescendants()) do
        if object:IsA("JointInstance") then
            local part0 = object.Part0
            local part1 = object.Part1
            local otherPart
            local handleWasPart0 = false

            if part0 == handle and part1 ~= handle then
                otherPart = part1
                handleWasPart0 = true
            elseif part1 == handle and part0 ~= handle then
                otherPart = part0
                handleWasPart0 = false
            end

            if otherPart
                and otherPart:IsA("BasePart")
                and otherPart:IsDescendantOf(sourceModel)
                and not otherPart:IsDescendantOf(sourceAccessory) then
                return {
                    kind = "Joint",
                    bodyName = otherPart.Name,
                    handleWasPart0 = handleWasPart0,
                    C0 = object.C0,
                    C1 = object.C1,
                    relativeCFrame = otherPart.CFrame:ToObjectSpace(handle.CFrame),
                }
            end
        elseif object:IsA("WeldConstraint") then
            local part0 = object.Part0
            local part1 = object.Part1
            local otherPart

            if part0 == handle and part1 ~= handle then
                otherPart = part1
            elseif part1 == handle and part0 ~= handle then
                otherPart = part0
            end

            if otherPart
                and otherPart:IsA("BasePart")
                and otherPart:IsDescendantOf(sourceModel)
                and not otherPart:IsDescendantOf(sourceAccessory) then
                return {
                    kind = "Relative",
                    bodyName = otherPart.Name,
                    relativeCFrame = otherPart.CFrame:ToObjectSpace(handle.CFrame),
                }
            end
        end
    end

    return nil
end

--==================================================
-- FALLBACK: MATCH ATTACHMENTS
--==================================================

local function findAttachmentBinding(sourceAccessory, character)
    local handle = getHandle(sourceAccessory)
    if not handle then
        return nil
    end

    for _, object in ipairs(handle:GetDescendants()) do
        if object:IsA("Attachment") then
            local targetAttachment, targetPart = findBodyAttachment(character, object.Name)
            if targetAttachment and targetPart then
                return {
                    kind = "Attachment",
                    bodyName = targetPart.Name,
                    sourceAttachmentCFrame = object.CFrame,
                    targetAttachmentCFrame = targetAttachment.CFrame,
                }
            end
        end
    end

    return nil
end

-- Last resort for accessories without a usable weld or matching attachment.
local function findNearestBodyBinding(sourceModel, sourceAccessory)
    local handle = getHandle(sourceAccessory)
    if not handle then
        return nil
    end

    local nearestPart
    local nearestDistance = math.huge

    for _, partName in ipairs(BODY_PART_NAMES) do
        local part = getBodyPart(sourceModel, partName)
        if part then
            local distance = (part.Position - handle.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPart = part
            end
        end
    end

    if not nearestPart then
        return nil
    end

    return {
        kind = "Relative",
        bodyName = nearestPart.Name,
        relativeCFrame = nearestPart.CFrame:ToObjectSpace(handle.CFrame),
    }
end

--==================================================
-- ACCESSORY ATTACHMENT
--==================================================

local function prepareAccessoryClone(accessory)
    for _, object in ipairs(accessory:GetDescendants()) do
        if object:IsA("JointInstance") or object:IsA("WeldConstraint") then
            object:Destroy()
        elseif object:IsA("BasePart") then
            object.Anchored = false
            object.CanCollide = false
            object.CanTouch = false
            object.CanQuery = false
            object.Massless = true
        end
    end
end

local function weldAccessory(sourceModel, character, sourceAccessory)
    if isLayeredClothing(sourceAccessory) then
        return false, "Layered clothing skipped"
    end

    local sourceHandle = getHandle(sourceAccessory)
    if not sourceHandle then
        return false, "Accessory has no Handle"
    end

    local binding = getOriginalBinding(sourceModel, sourceAccessory)
    local targetPart

    if binding then
        targetPart = getBodyPart(character, binding.bodyName)
    end

    if not targetPart then
        local attachmentBinding = findAttachmentBinding(sourceAccessory, character)
        if attachmentBinding then
            binding = attachmentBinding
            targetPart = getBodyPart(character, attachmentBinding.bodyName)
        end
    end

    if not targetPart then
        binding = findNearestBodyBinding(sourceModel, sourceAccessory)
        if binding then
            targetPart = getBodyPart(character, binding.bodyName)
        end
    end

    if not targetPart or not binding then
        return false, "Could not find an R6 attachment target"
    end

    local cloneOK, clone = pcall(function()
        return sourceAccessory:Clone()
    end)
    if not cloneOK or not clone then
        return false, "Accessory clone failed"
    end

    local handle = getHandle(clone)
    if not handle then
        clone:Destroy()
        return false, "Cloned accessory has no Handle"
    end

    prepareAccessoryClone(clone)
    clone.Parent = character

    local weld = Instance.new("Weld")
    weld.Name = "R6AccessoryWeld"
    weld.Part0 = targetPart
    weld.Part1 = handle

    if binding.kind == "Joint" then
        if binding.handleWasPart0 then
            weld.C0 = binding.C1
            weld.C1 = binding.C0
        else
            weld.C0 = binding.C0
            weld.C1 = binding.C1
        end
    elseif binding.kind == "Attachment" then
        weld.C0 = binding.targetAttachmentCFrame
        weld.C1 = binding.sourceAttachmentCFrame
    else
        weld.C0 = binding.relativeCFrame
        weld.C1 = CFrame.new()
    end

    local positioned, positionError = pcall(function()
        handle.CFrame = targetPart.CFrame * weld.C0 * weld.C1:Inverse()
    end)

    if not positioned then
        clone:Destroy()
        weld:Destroy()
        return false, "Could not position Handle: " .. tostring(positionError)
    end

    weld.Parent = handle
    return true
end

--==================================================
-- HEAD MESH / TEXTURE
--==================================================

-- Keep a clean copy of the target's original head mesh so a source without
-- a supported mesh does not leave a previous source avatar's head behind.
local originalHeadMeshSnapshots = setmetatable({}, { __mode = "k" })

local function captureOriginalHeadMesh(targetHead)
    if originalHeadMeshSnapshots[targetHead] ~= nil then
        return
    end

    local originalMesh = targetHead:FindFirstChildOfClass("SpecialMesh")
    local snapshot = {
        hadMesh = originalMesh ~= nil,
        template = nil,
    }

    if originalMesh then
        local ok, clone = pcall(function()
            return originalMesh:Clone()
        end)
        if ok then
            snapshot.template = clone
        end
    end

    originalHeadMeshSnapshots[targetHead] = snapshot
end

local function restoreOriginalHeadMesh(targetHead)
    local snapshot = originalHeadMeshSnapshots[targetHead]
    if not snapshot then
        return
    end

    for _, child in ipairs(targetHead:GetChildren()) do
        if child:IsA("SpecialMesh") then
            child:Destroy()
        end
    end

    if snapshot.template then
        local ok, clone = pcall(function()
            return snapshot.template:Clone()
        end)
        if ok and clone then
            clone.Parent = targetHead
        end
    end
end

local function copyPropertyIfAvailable(source, target, sourceProperty, targetProperty)
    targetProperty = targetProperty or sourceProperty

    local readOK, value = pcall(function()
        return source[sourceProperty]
    end)
    if not readOK then
        return false
    end

    local writeOK = pcall(function()
        target[targetProperty] = value
    end)
    return writeOK
end

local function getOrCreateSpecialMesh(targetHead)
    captureOriginalHeadMesh(targetHead)

    local mesh = targetHead:FindFirstChildOfClass("SpecialMesh")
    if not mesh then
        mesh = Instance.new("SpecialMesh")
        mesh.Name = "AvatarCopiedSpecialMesh"
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.Parent = targetHead
    end

    return mesh
end

local function copyHeadAppearance(sourceHead, targetHead)
    if not targetHead then
        return false, "Target Head missing"
    end

    if not sourceHead then
        restoreOriginalHeadMesh(targetHead)
        return false, "Source Head missing; restored original mesh"
    end

    -- Case A: source Head contains SpecialMesh. Preserve its mesh/texture
    -- data while using the user-tested scale of 0.945 on all axes.
    local sourceMesh = sourceHead:FindFirstChildOfClass("SpecialMesh")
    if sourceMesh then
        local targetMesh = getOrCreateSpecialMesh(targetHead)

        copyPropertyIfAvailable(sourceMesh, targetMesh, "MeshType")

        local meshContentCopied = copyPropertyIfAvailable(
            sourceMesh, targetMesh, "MeshContent"
        )
        if not meshContentCopied then
            copyPropertyIfAvailable(sourceMesh, targetMesh, "MeshId")
        end

        local textureContentCopied = copyPropertyIfAvailable(
            sourceMesh, targetMesh, "TextureContent"
        )
        if not textureContentCopied then
            copyPropertyIfAvailable(sourceMesh, targetMesh, "TextureId")
        end

        copyPropertyIfAvailable(sourceMesh, targetMesh, "Offset")
        copyPropertyIfAvailable(sourceMesh, targetMesh, "VertexColor")

        targetMesh.Scale = Vector3.new(0.945, 0.945, 0.945)
        return true, "SpecialMesh copied (Scale 0.945)"
    end

    -- Case B: source Head itself is a MeshPart. This produces a static
    -- mesh/texture transfer; it cannot preserve dynamic facial deformation.
    if sourceHead:IsA("MeshPart") then
        local targetMesh = getOrCreateSpecialMesh(targetHead)

        local ok, err = pcall(function()
            targetMesh.MeshType = Enum.MeshType.FileMesh

            local meshContentCopied = copyPropertyIfAvailable(
                sourceHead, targetMesh, "MeshContent"
            )
            if not meshContentCopied then
                copyPropertyIfAvailable(sourceHead, targetMesh, "MeshId")
            end

            local textureContentCopied = copyPropertyIfAvailable(
                sourceHead, targetMesh, "TextureContent"
            )
            if not textureContentCopied then
                copyPropertyIfAvailable(sourceHead, targetMesh, "TextureID", "TextureId")
            end

            targetMesh.Offset = Vector3.new(0, 0, 0)
            targetMesh.VertexColor = Vector3.new(1, 1, 1)
            targetMesh.Scale = Vector3.new(0.945, 0.945, 0.945)
        end)

        if not ok then
            return false, "MeshPart transfer failed: " .. tostring(err)
        end

        return true, "MeshPart copied as static mesh (Scale 0.945)"
    end

    -- If this source lacks a supported mesh, do not keep the previous
    -- target avatar's mesh active.
    restoreOriginalHeadMesh(targetHead)
    return false, "Source Head has no SpecialMesh or MeshPart"
end

--==================================================
-- COPY APPEARANCE
--==================================================

local function copyClassicAppearance(source, character)
    local copied = 0
    local skipped = 0
    local notes = {}

    -- Remove accessories from the previously applied avatar.
    for _, object in ipairs(character:GetChildren()) do
        if object:IsA("Accessory") then
            object:Destroy()
        end
    end

    -- Remove old classic clothing and BodyColors.
    for _, object in ipairs(character:GetChildren()) do
        if object:IsA("Shirt")
            or object:IsA("Pants")
            or object:IsA("ShirtGraphic")
            or object:IsA("BodyColors") then
            object:Destroy()
        end
    end

    -- Remove ALL previous CharacterMesh instances. Do not restore them if
    -- the new source contains zero CharacterMesh instances.
    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("CharacterMesh") then
            object:Destroy()
        end
    end

    -- Copy classic clothing and BodyColors from the source model.
    for _, object in ipairs(source:GetDescendants()) do
        if object:IsA("Shirt")
            or object:IsA("Pants")
            or object:IsA("ShirtGraphic")
            or object:IsA("BodyColors") then
            -- These appearance objects should be direct children of the
            -- target character, even if unusual source nesting is present.
            local ok, clone = pcall(function()
                return object:Clone()
            end)
            if ok and clone then
                clone.Parent = character
                copied += 1
            else
                skipped += 1
            end
        end
    end

    -- Clone exactly the source's CharacterMesh set. Searching descendants
    -- supports source models that contain an unusual nested rig/container.
    local sourceCharacterMeshes = {}
    for _, object in ipairs(source:GetDescendants()) do
        if object:IsA("CharacterMesh") then
            table.insert(sourceCharacterMeshes, object)
        end
    end

    local characterMeshesCopied = 0
    for _, object in ipairs(sourceCharacterMeshes) do
        local ok, clone = pcall(function()
            return object:Clone()
        end)
        if ok and clone then
            clone.Parent = character
            characterMeshesCopied += 1
            copied += 1
        else
            skipped += 1
        end
    end

    table.insert(notes, "CharacterMesh=" .. tostring(characterMeshesCopied))

    -- Copy source head mesh/texture.
    local sourceHead = source:FindFirstChild("Head", true)
    local targetHead = character:FindFirstChild("Head", true)
    local _, headMessage = copyHeadAppearance(sourceHead, targetHead)
    table.insert(notes, headMessage)

    -- Copy accessories using original source weld data.
    for _, object in ipairs(source:GetDescendants()) do
        if object:IsA("Accessory") then
            -- Only copy accessories belonging to the source model, not an
            -- accessory nested inside another accessory/model's hierarchy.
            local parentAccessory = object.Parent
            local nestedInsideAccessory = false
            while parentAccessory and parentAccessory ~= source do
                if parentAccessory:IsA("Accessory") then
                    nestedInsideAccessory = true
                    break
                end
                parentAccessory = parentAccessory.Parent
            end

            if not nestedInsideAccessory then
                if isLayeredClothing(object) then
                    skipped += 1
                else
                    local ok, result = pcall(function()
                        return weldAccessory(source, character, object)
                    end)
                    if ok and result == true then
                        copied += 1
                    else
                        skipped += 1
                    end
                end
            end
        end
    end

    return copied, skipped, notes
end

--==================================================
-- APPLY AVATAR
--==================================================

local function applyAvatar(username)
    if applying then
        return
    end

    username = tostring(username or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")

    if username == "" then
        setStatus("Enter a username first.")
        return
    end

    applying = true
    applyButton.Text = "Loading..."
    setStatus("Loading avatar...")

    local sourceModel
    local sourceDescription

    local ok, err = pcall(function()
        if not getR6Character() then
            error("Your character must be R6 and fully loaded.")
        end

        local userId = Players:GetUserIdFromNameAsync(username)

        -- Fetch the avatar description first, then explicitly create R6.
        -- CreateHumanoidModelFromUserId does not take a rig-type argument.
        sourceDescription = Players:GetHumanoidDescriptionFromUserIdAsync(userId)
        if not sourceDescription then
            error("Could not load the target avatar description.")
        end

        sourceModel = Players:CreateHumanoidModelFromDescriptionAsync(
            sourceDescription,
            Enum.HumanoidRigType.R6
        )

        if not sourceModel then
            error("Could not create the source R6 avatar model.")
        end

        local sourceHumanoid = sourceModel:FindFirstChildOfClass("Humanoid")
        if not sourceHumanoid or sourceHumanoid.RigType ~= Enum.HumanoidRigType.R6 then
            error("The source model was not created as R6; current appearance was not changed.")
        end

        -- Re-resolve after web/API calls because the player may have respawned.
        local character = getR6Character()
        if not character then
            error("Your R6 character is no longer available.")
        end

        local copied, skipped, notes = copyClassicAppearance(sourceModel, character)

        setStatus(
            "Copied " .. tostring(copied)
            .. " | Skipped " .. tostring(skipped)
            .. " | " .. tostring(notes[1])
            .. " | Head: " .. tostring(notes[2])
        )
    end)

    if sourceModel then
        pcall(function()
            sourceModel:Destroy()
        end)
    end

    if sourceDescription then
        pcall(function()
            sourceDescription:Destroy()
        end)
    end

    if not ok then
        setStatus("Error: " .. tostring(err))
    end

    applying = false
    if applyButton and applyButton.Parent then
        applyButton.Text = "Apply Avatar"
    end
end

--==================================================
-- BUTTON EVENTS
--==================================================

applyButton.MouseButton1Click:Connect(function()
    lastUsername = input.Text
    applyAvatar(lastUsername)
end)

respawnButton.MouseButton1Click:Connect(function()
    applyOnRespawn = not applyOnRespawn
    lastUsername = input.Text
    updateRespawnButton()

    if applyOnRespawn then
        setStatus("Respawn apply enabled.")
    else
        setStatus("Respawn apply disabled.")
    end
end)

if respawnConnection then
    respawnConnection:Disconnect()
end

respawnConnection = LocalPlayer.CharacterAdded:Connect(function()
    if applyOnRespawn and lastUsername ~= "" then
        task.wait(2)
        applyAvatar(lastUsername)
    end
end)

setStatus("Ready. Tap A to hide/show this window.")
