<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>tax_parcel</Name>
    <UserStyle>
      <Name>tax_parcel</Name>
      <Title>Tax Parcels</Title>
      <FeatureTypeStyle>
        <Rule>
          <Name>tax_parcel</Name>
          <Title>Parcel boundary</Title>
          <!-- Outline only, in the brown cadastral maps conventionally use: 30,000 of these draw
               over the aerial imagery and over whichever choropleth is on, and a fill would bury
               both. One rule at every scale rather than a scale band, so ticking the box always
               puts something on screen; zoomed out to the whole city they read as urban fabric
               rather than as individual lots. -->
          <PolygonSymbolizer>
            <Stroke>
              <CssParameter name="stroke">#8C6D46</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
              <CssParameter name="stroke-opacity">0.8</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
