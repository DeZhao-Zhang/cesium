#ifdef LIGHTING_PBR
vec3 computePbrLighting(czm_modelMaterial material, ProcessedAttributes attributes)
{
    #ifdef USE_CUSTOM_LIGHT_COLOR
        vec3 lightColorHdr = model_lightColorHdr;
    #else
        vec3 lightColorHdr = czm_lightColorHdr;
    #endif

    vec3 color = material.diffuse;

    #ifdef HAS_NORMALS
        vec3 position = attributes.positionEC;
        vec3 viewDirection = -normalize(position);
        vec3 normal = material.normalEC;
        vec3 lightDirection = normalize(czm_lightDirectionEC);

        vec3 directLighting = czm_pbrLighting(viewDirection, normal, lightDirection, material);
        color = lightColorHdr * directLighting;

        #if defined(DIFFUSE_IBL) || defined(SPECULAR_IBL)
            // Environment maps were provided, use them for IBL
            color += textureIBL(viewDirection, normal, lightDirection, material);
        #elif defined(USE_IBL_LIGHTING)
            // Use procedural IBL if there are no environment maps
            vec3 imageBasedLighting = proceduralIBL(position, normal, lightDirection, material);
            float maximumComponent = czm_maximumComponent(lightColorHdr);
            vec3 clampedLightColor = lightColorHdr / max(maximumComponent, 1.0);
            color += clampedLightColor * imageBasedLighting;
        #endif
    #endif

    color *= material.occlusion;
    color += material.emissive;

    // In HDR mode, the frame buffer is in linear color space. The
    // post-processing stages (see PostProcessStageCollection) will handle
    // tonemapping. However, if HDR is not enabled, we must tonemap else large
    // values may be clamped to 1.0
    #ifndef HDR 
        color = czm_acesTonemapping(color);
    #endif 

    return color;
}
#endif

void lightingStage(inout czm_modelMaterial material, ProcessedAttributes attributes)
{
    // Even though the lighting will only set the diffuse color,
    // pass all other properties so further stages have access to them.
    vec3 color = vec3(0.0);

    #ifdef LIGHTING_PBR
        color = computePbrLighting(material, attributes);
    #else // unlit
        color = material.diffuse;
    #endif

    #ifdef HAS_POINT_CLOUD_COLOR_STYLE
        // The colors resulting from point cloud styles are adjusted differently.
        color = czm_gammaCorrect(color);
    #elif !defined(HDR)
        // If HDR is not enabled, the frame buffer stores sRGB colors rather than
        // linear colors so the linear value must be converted.
        color = czm_linearToSrgb(color);
    #endif

    material.diffuse = color;
}
