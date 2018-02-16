/**
 * Clip a fragment by an array of clipping planes. Clipping plane regions are joined by the intersect operation, so
 * a fragment must be clipped by all of the planes to be discarded.
 *
 * @name czm_discardIfClippedWithIntersectFloat
 * @glslFunction
 *
 * @param {sampler2D} clippingPlanes Texture containing planes used to clip, defined in the ClippingPlaneCollection's model space.
 * @param {int} clippingPlanesLength The number of planes.
 * @param {int} textureWidth The width of the clipping planes texture.
 * @param {int} textureHeight The height of the clipping planes texture.
 * @param {mat4} clippingPlanesMatrix The matrix for transforming the clipping planes to eyespace.
 * @returns {float} The distance away from a clipped fragment, in eyespace
 */
float czm_discardIfClippedWithIntersectFloat(sampler2D clippingPlanes, int clippingPlanesLength, int textureWidth, int textureHeight, mat4 clippingPlanesMatrix)
{
    if (clippingPlanesLength > 0)
    {
        bool clipped = true;
        vec4 position = czm_windowToEyeCoordinates(gl_FragCoord);
        vec3 clipNormal = vec3(0.0);
        vec3 clipPosition = vec3(0.0);
        float clipAmount = 0.0;
        float pixelWidth = czm_metersPerPixel(position);

        for (int i = 0; i < czm_maxClippingPlanes; ++i)
        {
            if (i == clippingPlanesLength)
            {
                break;
            }

            vec4 clippingPlane = czm_getClippingPlaneFromRgbaFloat(clippingPlanes, i, textureWidth, textureHeight, clippingPlanesMatrix);

            clipNormal = clippingPlane.xyz;
            clipPosition = -clippingPlane.w * clipNormal;

            float amount = dot(clipNormal, (position.xyz - clipPosition)) / pixelWidth;
            clipAmount = max(amount, clipAmount);

            clipped = clipped && (amount <= 0.0);
        }

        if (clipped)
        {
            discard;
        }

        return clipAmount;
    }

    return 0.0;
}

