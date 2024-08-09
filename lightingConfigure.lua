-- EnhancedLightingModule.lua
local LightingModule = {}

-- Tables to store default settings for various lighting properties
local DefaultSettings = {
    Lighting = {},
    ColorCorrection = {},
    Bloom = {},
    Atmosphere = {}
}

-- Function to save the current settings based on the provided argument
function LightingModule.SaveSettings(settingType)
    local lighting = game.Lighting
    
    if settingType == "Lighting" then
        DefaultSettings.Lighting = {
            Ambient = lighting.Ambient,
            Brightness = lighting.Brightness,
            ClockTime = lighting.ClockTime,
            FogEnd = lighting.FogEnd,
            FogColor = lighting.FogColor,
            FogStart = lighting.FogStart,
            GlobalShadows = lighting.GlobalShadows,
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
        if colorCorrection then
            DefaultSettings.ColorCorrection = {
                Brightness = colorCorrection.Brightness,
                Contrast = colorCorrection.Contrast,
                Saturation = colorCorrection.Saturation,
                TintColor = colorCorrection.TintColor
            }
        end
    
    elseif settingType == "Bloom" then
        local bloom = lighting:FindFirstChildOfClass("BloomEffect")
        if bloom then
            DefaultSettings.Bloom = {
                Intensity = bloom.Intensity,
                Size = bloom.Size,
                Threshold = bloom.Threshold
            }
        end
    
    elseif settingType == "Atmosphere" then
        local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
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
    lighting.Ambient = settings.Ambient or lighting.Ambient
    lighting.Brightness = settings.Brightness or lighting.Brightness
    lighting.ClockTime = settings.ClockTime or lighting.ClockTime
    lighting.FogEnd = settings.FogEnd or lighting.FogEnd
    lighting.FogColor = settings.FogColor or lighting.FogColor
    lighting.FogStart = settings.FogStart or lighting.FogStart
    lighting.GlobalShadows = settings.GlobalShadows or lighting.GlobalShadows
    lighting.OutdoorAmbient = settings.OutdoorAmbient or lighting.OutdoorAmbient
    lighting.EnvironmentDiffuseScale = settings.EnvironmentDiffuseScale or lighting.EnvironmentDiffuseScale
    lighting.EnvironmentSpecularScale = settings.EnvironmentSpecularScale or lighting.EnvironmentSpecularScale
    lighting.ExposureCompensation = settings.ExposureCompensation or lighting.ExposureCompensation
    lighting.GeographicLatitude = settings.GeographicLatitude or lighting.GeographicLatitude
    lighting.TimeOfDay = settings.TimeOfDay or lighting.TimeOfDay
    lighting.ColorShift_Top = settings.ColorShift_Top or lighting.ColorShift_Top
    lighting.ColorShift_Bottom = settings.ColorShift_Bottom or lighting.ColorShift_Bottom

    -- Configure Atmosphere if provided
    if settings.Atmosphere then
        local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            atmosphere.Color = settings.Atmosphere.Color or atmosphere.Color
            atmosphere.Decay = settings.Atmosphere.Decay or atmosphere.Decay
            atmosphere.Density = settings.Atmosphere.Density or atmosphere.Density
            atmosphere.Glare = settings.Atmosphere.Glare or atmosphere.Glare
            atmosphere.Haze = settings.Atmosphere.Haze or atmosphere.Haze
        end
    end

    -- Configure Bloom if provided
    if settings.Bloom then
        local bloom = lighting:FindFirstChildOfClass("BloomEffect")
        if bloom then
            bloom.Intensity = settings.Bloom.Intensity or bloom.Intensity
            bloom.Size = settings.Bloom.Size or bloom.Size
            bloom.Threshold = settings.Bloom.Threshold or bloom.Threshold
        end
    end

    -- Configure ColorCorrection if provided
    if settings.ColorCorrection then
        local colorCorrection = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if colorCorrection then
            colorCorrection.Brightness = settings.ColorCorrection.Brightness or colorCorrection.Brightness
            colorCorrection.Contrast = settings.ColorCorrection.Contrast or colorCorrection.Contrast
            colorCorrection.Saturation = settings.ColorCorrection.Saturation or colorCorrection.Saturation
            colorCorrection.TintColor = settings.ColorCorrection.TintColor or colorCorrection.TintColor
        end
    end
end

return LightingModule
