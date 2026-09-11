<?xml version="1.0" encoding="UTF-8"?>
<!-- Median gross rent, from ACS table B25064. A sequential ramp, ordered by lightness, because this quantity has an
     order: the opposite of the race style's palette, which is equiluminant precisely because its
     categories do not.

     Class breaks are round numbers taken off the measured distribution rather than computed at
     render time, so the legend reads in whole units and means the same thing from one ACS vintage
     to the next. An area the survey did not publish is drawn flat grey; one it published too
     loosely to place on the ramp keeps its colour and takes the same white-cased stripe the race
     style uses for a contested category, because the estimate is still the best there is and the
     stripe is the caveat rather than a replacement. Too loosely here means a coefficient of variation over 30%, which is where the Census Bureau
     itself stops calling an estimate reliable. -->
<StyledLayerDescriptor version="1.0.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>acs_rent</Name>
    <UserStyle>
      <Name>acs_rent</Name>
      <Title>Median gross rent</Title>
      <FeatureTypeStyle>
      <Rule>
        <Name>class_1</Name>
        <Title>under $1,600</Title>
        <ogc:Filter><ogc:PropertyIsLessThan><ogc:PropertyName>gross_rent</ogc:PropertyName><ogc:Literal>1600</ogc:Literal></ogc:PropertyIsLessThan></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#f2f0f7</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>class_2</Name>
        <Title>$1,600 to $1,900</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyName>gross_rent</ogc:PropertyName><ogc:Literal>1600</ogc:Literal></ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyIsLessThan><ogc:PropertyName>gross_rent</ogc:PropertyName><ogc:Literal>1900</ogc:Literal></ogc:PropertyIsLessThan></ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#cbc9e2</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>class_3</Name>
        <Title>$1,900 to $2,200</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyName>gross_rent</ogc:PropertyName><ogc:Literal>1900</ogc:Literal></ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyIsLessThan><ogc:PropertyName>gross_rent</ogc:PropertyName><ogc:Literal>2200</ogc:Literal></ogc:PropertyIsLessThan></ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#9e9ac8</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>class_4</Name>
        <Title>$2,200 to $2,700</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyName>gross_rent</ogc:PropertyName><ogc:Literal>2200</ogc:Literal></ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyIsLessThan><ogc:PropertyName>gross_rent</ogc:PropertyName><ogc:Literal>2700</ogc:Literal></ogc:PropertyIsLessThan></ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#756bb1</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>class_5</Name>
        <Title>$2,700 and over</Title>
        <ogc:Filter><ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyName>gross_rent</ogc:PropertyName><ogc:Literal>2700</ogc:Literal></ogc:PropertyIsGreaterThanOrEqualTo></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#54278f</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>no_data</Name>
        <Title>Not published for this area</Title>
        <ogc:Filter><ogc:PropertyIsNull><ogc:PropertyName>gross_rent</ogc:PropertyName></ogc:PropertyIsNull></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#e0e0e0</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>uncertain</Name>
        <Title>Striped: the margin is too wide to place on this ramp</Title>
        <PolygonSymbolizer>
          <Fill>
            <GraphicFill>
              <Graphic>
                <Mark>
                  <WellKnownName>shape://slash</WellKnownName>
                  <Stroke>
                    <CssParameter name="stroke">#ffffff</CssParameter>
                    <CssParameter name="stroke-width">6</CssParameter>
                  </Stroke>
                </Mark>
                <Size>20</Size>
              </Graphic>
            </GraphicFill>
          </Fill>
        </PolygonSymbolizer>
        <PolygonSymbolizer>
          <Fill>
            <GraphicFill>
              <Graphic>
                <Mark>
                  <WellKnownName>shape://slash</WellKnownName>
                  <Stroke>
                    <CssParameter name="stroke">#4d4d4d</CssParameter>
                    <CssParameter name="stroke-width">3</CssParameter>
                  </Stroke>
                </Mark>
                <Size>20</Size>
              </Graphic>
            </GraphicFill>
          </Fill>
        </PolygonSymbolizer>
        <VendorOption name="inclusion">legendOnly</VendorOption>
      </Rule>
      </FeatureTypeStyle>
      <!-- a second pass so the stripe lands on top of whichever class filled the polygon -->
      <FeatureTypeStyle>
      <Rule>
        <Name>uncertain_overlay</Name>
        <ogc:Filter><ogc:And><ogc:Not><ogc:PropertyIsNull><ogc:PropertyName>gross_rent</ogc:PropertyName></ogc:PropertyIsNull></ogc:Not><ogc:PropertyIsGreaterThan><ogc:PropertyName>gross_rent_moe</ogc:PropertyName><ogc:Mul><ogc:PropertyName>gross_rent</ogc:PropertyName><ogc:Literal>0.4935</ogc:Literal></ogc:Mul></ogc:PropertyIsGreaterThan></ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <GraphicFill>
              <Graphic>
                <Mark>
                  <WellKnownName>shape://slash</WellKnownName>
                  <Stroke>
                    <CssParameter name="stroke">#ffffff</CssParameter>
                    <CssParameter name="stroke-width">6</CssParameter>
                  </Stroke>
                </Mark>
                <Size>20</Size>
              </Graphic>
            </GraphicFill>
          </Fill>
        </PolygonSymbolizer>
        <PolygonSymbolizer>
          <Fill>
            <GraphicFill>
              <Graphic>
                <Mark>
                  <WellKnownName>shape://slash</WellKnownName>
                  <Stroke>
                    <CssParameter name="stroke">#4d4d4d</CssParameter>
                    <CssParameter name="stroke-width">3</CssParameter>
                  </Stroke>
                </Mark>
                <Size>20</Size>
              </Graphic>
            </GraphicFill>
          </Fill>
        </PolygonSymbolizer>
        <VendorOption name="inclusion">mapOnly</VendorOption>
      </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
