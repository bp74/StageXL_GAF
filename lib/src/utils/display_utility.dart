part of stagexl_gaf.utils;

/*
/** @ */
class DisplayUtility {
  static Rectangle getBoundsWithFilters(Rectangle maxRect, List filters) {
    int filtersLen = filters.length;
    if (filtersLen > 0) {
      num filterMinX = 0;
      num filterMinY = 0;
      Rectangle filterGeneratorRect = new Rectangle(0, 0, maxRect.width, maxRect.height);
      BitmapData bitmapData;
      for (int i = 0; i < filtersLen; i++) {
        //bitmapData = new BitmapData(filterGeneratorRect.width, filterGeneratorRect.height, true, 0x00000000);
        bitmapData = new BitmapData(1, 1, false, 0x00000000);
        BitmapFilter filter = filters[i];
        Rectangle filterRect =
            bitmapData.generateFilterRect(filterGeneratorRect, filter);
        filterRect.width += filterGeneratorRect.width - 1;
        filterRect.height += filterGeneratorRect.height - 1;

        filterMinX += filterRect.x;
        filterMinY += filterRect.y;

        filterGeneratorRect = filterRect.clone();
        filterGeneratorRect.x = 0;
        filterGeneratorRect.y = 0;

        bitmapData.dispose();
      }
      // Reposition filterRect back to global coordinates
      filterRect.x = maxRect.x + filterMinX;
      filterRect.y = maxRect.y + filterMinY;

      maxRect = filterRect.clone();
    }

    return maxRect;
  }
}
*/
