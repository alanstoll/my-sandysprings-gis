<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>geology_unit</Name>
    <UserStyle>
      <Name>geology_synthesis</Name>
      <Title>Synthesis units</Title>
      <!-- The national map's own unit colours. All fills are at less than half strength so the scanned map underneath stays readable
           through them. Only the values that fall inside the map bounds have a rule: an unlisted
           value draws nothing, which is the cue to add it here after a re-pull. -->
      <FeatureTypeStyle>
        <Rule>
          <Name>PZpCm</Name>
          <Title>PZpCm: Metamorphic rocks (Paleozoic to Precambrian)</Title>
          <ogc:Filter>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>map_unit</ogc:PropertyName>
              <ogc:Literal>PZpCm</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#B3EBDE</CssParameter>
              <CssParameter name="fill-opacity">0.45</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#1A1A1A</CssParameter>
              <CssParameter name="stroke-width">1</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
          <TextSymbolizer>
            <Label><ogc:PropertyName>map_unit</ogc:PropertyName></Label>
            <Font>
              <CssParameter name="font-family">SansSerif</CssParameter>
              <CssParameter name="font-size">12</CssParameter>
              <CssParameter name="font-weight">bold</CssParameter>
            </Font>
            <Halo><Radius>2</Radius><Fill><CssParameter name="fill">#FFFFFF</CssParameter></Fill></Halo>
            <Fill><CssParameter name="fill">#1A1A1A</CssParameter></Fill>
            <VendorOption name="maxDisplacement">100</VendorOption>
          </TextSymbolizer>
        </Rule>
        <Rule>
          <Name>PZpCms</Name>
          <Title>PZpCms: Metasedimentary rocks (Paleozoic to Precambrian)</Title>
          <ogc:Filter>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>map_unit</ogc:PropertyName>
              <ogc:Literal>PZpCms</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#99CCDE</CssParameter>
              <CssParameter name="fill-opacity">0.45</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#1A1A1A</CssParameter>
              <CssParameter name="stroke-width">1</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
          <TextSymbolizer>
            <Label><ogc:PropertyName>map_unit</ogc:PropertyName></Label>
            <Font>
              <CssParameter name="font-family">SansSerif</CssParameter>
              <CssParameter name="font-size">12</CssParameter>
              <CssParameter name="font-weight">bold</CssParameter>
            </Font>
            <Halo><Radius>2</Radius><Fill><CssParameter name="fill">#FFFFFF</CssParameter></Fill></Halo>
            <Fill><CssParameter name="fill">#1A1A1A</CssParameter></Fill>
            <VendorOption name="maxDisplacement">100</VendorOption>
          </TextSymbolizer>
        </Rule>
        <Rule>
          <Name>PZpCg</Name>
          <Title>PZpCg: Igneous rocks (Paleozoic to Precambrian)</Title>
          <ogc:Filter>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>map_unit</ogc:PropertyName>
              <ogc:Literal>PZpCg</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#CC00EB</CssParameter>
              <CssParameter name="fill-opacity">0.45</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#1A1A1A</CssParameter>
              <CssParameter name="stroke-width">1</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
          <TextSymbolizer>
            <Label><ogc:PropertyName>map_unit</ogc:PropertyName></Label>
            <Font>
              <CssParameter name="font-family">SansSerif</CssParameter>
              <CssParameter name="font-size">12</CssParameter>
              <CssParameter name="font-weight">bold</CssParameter>
            </Font>
            <Halo><Radius>2</Radius><Fill><CssParameter name="fill">#FFFFFF</CssParameter></Fill></Halo>
            <Fill><CssParameter name="fill">#1A1A1A</CssParameter></Fill>
            <VendorOption name="maxDisplacement">100</VendorOption>
          </TextSymbolizer>
        </Rule>
        <Rule>
          <Name>scz</Name>
          <Title>scz: Shear zone rocks (age unspecified)</Title>
          <ogc:Filter>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>map_unit</ogc:PropertyName>
              <ogc:Literal>scz</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#668066</CssParameter>
              <CssParameter name="fill-opacity">0.45</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#1A1A1A</CssParameter>
              <CssParameter name="stroke-width">1</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
          <TextSymbolizer>
            <Label><ogc:PropertyName>map_unit</ogc:PropertyName></Label>
            <Font>
              <CssParameter name="font-family">SansSerif</CssParameter>
              <CssParameter name="font-size">12</CssParameter>
              <CssParameter name="font-weight">bold</CssParameter>
            </Font>
            <Halo><Radius>2</Radius><Fill><CssParameter name="fill">#FFFFFF</CssParameter></Fill></Halo>
            <Fill><CssParameter name="fill">#1A1A1A</CssParameter></Fill>
            <VendorOption name="maxDisplacement">100</VendorOption>
          </TextSymbolizer>
        </Rule>
        <Rule>
          <Name>water</Name>
          <Title>Water</Title>
          <ogc:Filter>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>map_unit</ogc:PropertyName>
              <ogc:Literal>water</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#CCFFFF</CssParameter>
              <CssParameter name="fill-opacity">0.45</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#1A1A1A</CssParameter>
              <CssParameter name="stroke-width">1</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
          <TextSymbolizer>
            <Label><ogc:PropertyName>map_unit</ogc:PropertyName></Label>
            <Font>
              <CssParameter name="font-family">SansSerif</CssParameter>
              <CssParameter name="font-size">12</CssParameter>
              <CssParameter name="font-weight">bold</CssParameter>
            </Font>
            <Halo><Radius>2</Radius><Fill><CssParameter name="fill">#FFFFFF</CssParameter></Fill></Halo>
            <Fill><CssParameter name="fill">#1A1A1A</CssParameter></Fill>
            <VendorOption name="maxDisplacement">100</VendorOption>
          </TextSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
