/*global define*/
define([
        'require',
        './defined',
        './DeveloperError'
    ], function(
        require,
        defined,
        DeveloperError) {
    "use strict";
    /*global CESIUM_BASE_URL*/

    var baseUrl;
    function getCesiumBaseUrl() {
        if (defined(baseUrl)) {
            return baseUrl;
        }

        if (defined(CESIUM_BASE_URL)) {
            baseUrl = CESIUM_BASE_URL;
        } else {
            var cesiumScriptRegex = /(.*?)Cesium\w*\.js(?:\W|$)/i;
            var scripts = document.getElementsByTagName('script');
            for ( var i = 0, len = scripts.length; i < len; ++i) {
                var src = scripts[i].getAttribute('src');
                var result = cesiumScriptRegex.exec(src);
                if (result !== null) {
                    baseUrl = result[1];
                    break;
                }
            }
        }

        if (!defined(baseUrl)) {
            throw new DeveloperError('Unable to determine Cesium base URL automatically, try defining a global variable called CESIUM_BASE_URL.');
        }

        if (!/\/$/.test(baseUrl)) {
            baseUrl += '/';
        }

        return baseUrl;
    }

    function buildModuleUrlFromRequireToUrl(moduleID) {
        //moduleID will be non-relative, so require it relative to this module, in Core.
        return require.toUrl('../' + moduleID);
    }

    function buildModuleUrlFromBaseUrl(moduleID) {
        return getCesiumBaseUrl() + moduleID;
    }

    var implementation;
    var a;

    /**
     * Given a non-relative moduleID, returns an absolute URL to the file represented by that module ID,
     * using, in order of preference, require.toUrl, the value of a global CESIUM_BASE_URL, or
     * the base URL of the Cesium.js script.
     *
     * @private
     */
    var buildModuleUrl = function(moduleID) {
        if (!defined(implementation)) {
            //select implementation
            if (defined(require.toUrl)) {
                implementation = buildModuleUrlFromRequireToUrl;
            } else {
                implementation = buildModuleUrlFromBaseUrl;
            }
        }

        if (!defined(a)) {
            a = document.createElement('a');
        }

        var url = implementation(moduleID);

        a.href = url;
        a.href = a.href; // IE only absolutizes href on get, not set

        return a.href;
    };

    return buildModuleUrl;
});