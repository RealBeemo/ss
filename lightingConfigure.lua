-- EnhancedLightingModule.lua
local LightingModule = {}

-- Table to store default lighting settings
local DefaultLighting = {}

-- Function to save the current lighting settings
function LightingModule.SaveCurrentSettings()
    local lighting = game.Lighting
    DefaultLighting = {
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
        TimeOfDay = lighting.TimeOfDay
    }

    -- Save Atmosphere settings if available
    local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere then
        DefaultLighting.Atmosphere = {
            Color = atmosphere.Color,
            Decay = atmosphere.Decay,
            Density = atmosphere.Density,
            Glare = atmosphere.Glare,
            Haze = atmosphere.Haze
        }
    end

    -- Save Bloom settings if available
    local bloom = lighting:FindFirstChildOfClass("BloomEffect")
    if bloom then
        DefaultLighting.Bloom = {
            Intensity = bloom.Intensity,
            Size = bloom.Size,
            Threshold = bloom.Threshold
        }
    end

    -- Save Color Correction settings if available
    local colorCorrection = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if colorCorrection then
        DefaultLighting.ColorCorrection = {
            Brightness = colorCorrection.Brightness,
            Contrast = colorCorrection.Contrast,
            Saturation = colorCorrection.Saturation,
            TintColor = colorCorrection.TintColor
        }
    end
end

-- Function to restore the saved default lighting settings
function LightingModule.RestoreDefaultSettings()
    if DefaultLighting then
        LightingModule.Configure(DefaultLighting)
    else
        warn("Default lighting settings not saved!")
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
