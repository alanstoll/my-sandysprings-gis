<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>flood_zone</Name>
    <UserStyle>
      <Name>flood_zone</Name>
      <Title>Flood Zones</Title>
      <!-- Colours sampled off a FEMA FIRM panel. Areas of minimal flood hazard match no rule
           here: they cover everything the studies cleared, and FEMA leaves them unshaded too. -->
      <FeatureTypeStyle>
        <Rule>
          <Name>shaded_x</Name>
          <Title>0.2% annual chance flood (500-year)</Title>
          <ogc:Filter>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>subtype</ogc:PropertyName>
              <ogc:Literal>0.2 PCT ANNUAL CHANCE FLOOD HAZARD</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#FDD4AD</CssParameter></Fill>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>sfha</Name>
          <Title>1% annual chance flood (100-year), zones A and AE</Title>
          <ogc:Filter>
            <ogc:And>
              <ogc:PropertyIsEqualTo>
                <ogc:PropertyName>sfha</ogc:PropertyName>
                <ogc:Literal>true</ogc:Literal>
              </ogc:PropertyIsEqualTo>
              <ogc:Or>
                <ogc:PropertyIsNull><ogc:PropertyName>subtype</ogc:PropertyName></ogc:PropertyIsNull>
                <ogc:Not>
                  <ogc:PropertyIsEqualTo>
                    <ogc:PropertyName>subtype</ogc:PropertyName>
                    <ogc:Literal>FLOODWAY</ogc:Literal>
                  </ogc:PropertyIsEqualTo>
                </ogc:Not>
              </ogc:Or>
            </ogc:And>
          </ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#B0F2FA</CssParameter></Fill>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>floodway</Name>
          <Title>Regulatory floodway</Title>
          <ogc:Filter>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>subtype</ogc:PropertyName>
              <ogc:Literal>FLOODWAY</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <!-- the fill the sfha rule gives the rest of the flood hazard area, then the hatch;
               both here rather than stacked on that rule so this one legends on its own -->
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#B0F2FA</CssParameter></Fill>
          </PolygonSymbolizer>
          <PolygonSymbolizer>
            <Fill>
              <GraphicFill>
                <Graphic>
                  <Mark>
                    <WellKnownName>shape://slash</WellKnownName>
                    <Stroke>
                      <CssParameter name="stroke">#FDADAD</CssParameter>
                      <CssParameter name="stroke-width">5</CssParameter>
                    </Stroke>
                  </Mark>
                  <Size>12</Size>
                </Graphic>
              </GraphicFill>
            </Fill>
          </PolygonSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
