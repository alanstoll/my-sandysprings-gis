<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>city_limit_inhouse</Name>
    <UserStyle>
      <Name>city_limit_inhouse</Name>
      <Title>City Limits</Title>
      <FeatureTypeStyle>
        <Rule>
          <Name>city_limit_inhouse</Name>
          <Title>City limit</Title>
          <!-- outline only: a fill washes out the basemap underneath. Black, where the published
               boundary is violet: this is the one to read the map against, and the two carry the
               same weight and dash so the difference between them is position and nothing else -->
          <PolygonSymbolizer>
            <Stroke>
              <CssParameter name="stroke">#000000</CssParameter>
              <CssParameter name="stroke-width">3</CssParameter>
              <CssParameter name="stroke-dasharray">12 7</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
