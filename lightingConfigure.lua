-- EnhancedLightingModule.lua
local LightingModule = {}

-- Tables to store default settings for various lighting properties
local DefaultSettings = {
    Lighting = nil,
    ColorCorrection = nil,
    Bloom = nil,
    Atmosphere = nil
}

-- Function to save the current settings based on the provided argument
function LightingModule.SaveSettings(settingType)
    local lighting = game.Lighting
    
    if settingType == "Lighting" then
        DefaultSettings.Lighting = DefaultSettings.Lighting or {
            Ambient = lighting.Ambient,
            Brightness = lighting.Brightness,
            ClockTime = lighting.ClockTime,
            FogEnd = lighting.FogEnd,
            FogColor = lighting.FogColor,
            FogStart = lighting.FogStart,
            GlobalShadows = lighting.GlobalShadows,
            ShadowSoftness = lighting.ShadowSoftness,
            OutdoorAmbient = lighting.OutdoorAmbient,
            EnvironmentDiffuseScale = lighting.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = lighting.EnvironmentSpecularScale,
            ExposureCompensation = lighting.ExposureCompensation,
            GeographicLatitude = lighting.GeographicLatitude,
            TimeOfDay = lighting.TimeOfDay,
            ColorShift_Top = lighting.ColorShift_Top,
            ColorShift_Bottom = lighting.ColorShift_Bottom
        }
    
    elseif settingType == "ColorCorrection" then
        local colorCorrection = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if colorCorrection and not DefaultSettings.ColorCorrection then
            DefaultSettings.ColorCorrection = {
                Brightness = colorCorrection.Brightness,
                Contrast = colorCorrection.Contrast,
                Saturation = colorCorrection.Saturation,
                TintColor = colorCorrection.TintColor
            }
        end
    
    elseif settingType == "Bloom" then
        local bloom = lighting:FindFirstChildOfClass("BloomEffect")
        if bloom and not DefaultSettings.Bloom then
            DefaultSettings.Bloom = {
                Intensity = bloom.Intensity,
                Size = bloom.Size,
                Threshold = bloom.Threshold
            }
        end
    
    elseif settingType == "Atmosphere" then
        local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere and not DefaultSettings.Atmosphere then
            DefaultSettings.Atmosphere = {
                Color = atmosphere.Color,
                Decay = atmosphere.Decay,
                Density = atmosphere.Density,
                Glare = atmosphere.Glare,
                Haze = atmosphere.Haze
            }
        end
    end
end

-- Function to restore the saved settings based on the provided argument
function LightingModule.RestoreSettings(settingType)
    local lighting = game.Lighting
    
    if settingType == "Lighting" and DefaultSettings.Lighting then
        LightingModule.Configure(DefaultSettings.Lighting)
    
    elseif settingType == "ColorCorrection" and DefaultSettings.ColorCorrection then
        local colorCorrection = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if colorCorrection then
            for prop, value in pairs(DefaultSettings.ColorCorrection) do
                colorCorrection[prop] = value
            end
        end
    
    elseif settingType == "Bloom" and DefaultSettings.Bloom then
        local bloom = lighting:FindFirstChildOfClass("BloomEffect")
        if bloom then
            for prop, value in pairs(DefaultSettings.Bloom) do
                bloom[prop] = value
            end
        end
    
    elseif settingType == "Atmosphere" and DefaultSettings.Atmosphere then
        local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            for prop, value in pairs(DefaultSettings.Atmosphere) do
                atmosphere[prop] = value
            end
        end
    end
end

-- Function to apply settings
function LightingModule.Configure(settings)
    local lighting = game.Lighting

    -- Apply general lighting settings
    if settings.Ambient then lighting.Ambient = settings.Ambient end
    if settings.Brightness then lighting.Brightness = settings.Brightness end
    if settings.ClockTime then lighting.ClockTime = settings.ClockTime end
    if settings.FogEnd then lighting.FogEnd = settings.FogEnd end
    if settings.FogColor then lighting.FogColor = settings.FogColor end
    if settings.FogStart then lighting.FogStart = settings.FogStart end
    if settings.GlobalShadows ~= nil then lighting.GlobalShadows = settings.GlobalShadows end
    if settings.ShadowSoftness ~= nil then lighting.ShadowSoftness = settings.ShadowSoftness end
    if settings.OutdoorAmbient then lighting.OutdoorAmbient = settings.OutdoorAmbient end
    if settings.EnvironmentDiffuseScale then lighting.EnvironmentDiffuseScale = settings.EnvironmentDiffuseScale end
    if settings.EnvironmentSpecularScale then lighting.EnvironmentSpecularScale = settings.EnvironmentSpecularScale end
    if settings.ExposureCompensation then lighting.ExposureCompensation = settings.ExposureCompensation end
    if settings.GeographicLatitude then lighting.GeographicLatitude = settings.GeographicLatitude end
    if settings.TimeOfDay then lighting.TimeOfDay = settings.TimeOfDay end
    if settings.ColorShift_Top then lighting.ColorShift_Top = settings.ColorShift_Top end
    if settings.ColorShift_Bottom then lighting.ColorShift_Bottom = settings.ColorShift_Bottom end

    -- Configure Atmosphere if provided
    if settings.Atmosphere then
        local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            if settings.Atmosphere.Color then atmosphere.Color = settings.Atmosphere.Color end
            if settings.Atmosphere.Decay then atmosphere.Decay = settings.Atmosphere.Decay end
            if settings.Atmosphere.DecayColor then atmosphere.DecayColor = settings.Atmosphere.DecayColor end
            if settings.Atmosphere.Density then atmosphere.Density = settings.Atmosphere.Density end
            if settings.Atmosphere.Glare then atmosphere.Glare = settings.Atmosphere.Glare end
            if settings.Atmosphere.Haze then atmosphere.Haze = settings.Atmosphere.Haze end
        end
    end

    -- Configure Bloom if provided
    if settings.Bloom then
        local bloom = lighting:FindFirstChildOfClass("BloomEffect")
        if bloom then
            if settings.Bloom.Intensity then bloom.Intensity = settings.Bloom.Intensity end
            if settings.Bloom.Size then bloom.Size = settings.Bloom.Size end
            if settings.Bloom.Threshold then bloom.Threshold = settings.Bloom.Threshold end
        end
    end

    -- Configure ColorCorrection if provided
    if settings.ColorCorrection then
        local colorCorrection = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if colorCorrection then
            if settings.ColorCorrection.Brightness then colorCorrection.Brightness = settings.ColorCorrection.Brightness end
            if settings.ColorCorrection.Contrast then colorCorrection.Contrast = settings.ColorCorrection.Contrast end
            if settings.ColorCorrection.Saturation then colorCorrection.Saturation = settings.ColorCorrection.Saturation end
            if settings.ColorCorrection.TintColor then colorCorrection.TintColor = settings.ColorCorrection.TintColor end
        end
    end
end

return LightingModule
