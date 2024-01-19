import WebMercatorProjection from "./WebMercatorProjection.js";
import WebMercatorTilingScheme from "./WebMercatorTilingScheme.js";
import Math from "./Math.js";
import Cartographic from "./Cartographic.js";
import Cartesian2 from "./Cartesian2.js";
import CoordinateTransform from './CoordinateTransform.js';

class AMapMercatorTilingScheme extends WebMercatorTilingScheme {

  constructor() {
    super();

    let projection = new WebMercatorProjection();

    this._projection.project = function (cartographic, result) {
      result = CoordinateTransform.WGS84ToGCJ02(
        Math.toDegrees(cartographic.longitude),
        Math.toDegrees(cartographic.latitude)
      );
      result = projection.project(new Cartographic(Math.toRadians(result[0]), Math.toRadians(result[1])));
      return new Cartesian2(result.x, result.y);
    };

    this._projection.unproject = function (cartesian, result) {
      let cartographic = projection.unproject(cartesian);
      result = CoordinateTransform.GCJ02ToWGS84(
        Math.toDegrees(cartographic.longitude),
        Math.toDegrees(cartographic.latitude)
      );
      return new Cartographic(Math.toRadians(result[0]), Math.toRadians(result[1]));
    };
  }
}

export default AMapMercatorTilingScheme;
