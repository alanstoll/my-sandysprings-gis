<?xml version="1.0" encoding="UTF-8"?>
<!-- Commuted without driving alone, from ACS table B08301. A sequential ramp, ordered by lightness, because this quantity has an
     order: the opposite of the race style's palette, which is equiluminant precisely because its
     categories do not.

     Class breaks are round numbers taken off the measured distribution rather than computed at
     render time, so the legend reads in whole units and means the same thing from one ACS vintage
     to the next. An area the survey did not publish is drawn flat grey; one it published too
     loosely to place on the ramp keeps its colour and takes the same white-cased stripe the race
     style uses for a contested category, because the estimate is still the best there is and the
     stripe is the caveat rather than a replacement. Too loosely here means a margin wider than 15 percentage points, which spans more than one
     class of this ramp and so cannot place the area on it. -->
<StyledLayerDescriptor version="1.0.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>acs_commute_car</Name>
    <UserStyle>
      <Name>acs_commute_car</Name>
      <Title>Commuted without driving alone</Title>
      <FeatureTypeStyle>
      <Rule>
        <Name>class_1</Name>
        <Title>under 30%</Title>
        <ogc:Filter><ogc:PropertyIsLessThan><ogc:PropertyName>not_drove_alone</ogc:PropertyName><ogc:Literal>30</ogc:Literal></ogc:PropertyIsLessThan></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#f1eef6</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>class_2</Name>
        <Title>30% to 38%</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyName>not_drove_alone</ogc:PropertyName><ogc:Literal>30</ogc:Literal></ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyIsLessThan><ogc:PropertyName>not_drove_alone</ogc:PropertyName><ogc:Literal>38</ogc:Literal></ogc:PropertyIsLessThan></ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#d7b5d8</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>class_3</Name>
        <Title>38% to 45%</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyName>not_drove_alone</ogc:PropertyName><ogc:Literal>38</ogc:Literal></ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyIsLessThan><ogc:PropertyName>not_drove_alone</ogc:PropertyName><ogc:Literal>45</ogc:Literal></ogc:PropertyIsLessThan></ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#df65b0</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>class_4</Name>
        <Title>45% to 55%</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyName>not_drove_alone</ogc:PropertyName><ogc:Literal>45</ogc:Literal></ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyIsLessThan><ogc:PropertyName>not_drove_alone</ogc:PropertyName><ogc:Literal>55</ogc:Literal></ogc:PropertyIsLessThan></ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#dd1c77</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>class_5</Name>
        <Title>55% and over</Title>
        <ogc:Filter><ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyName>not_drove_alone</ogc:PropertyName><ogc:Literal>55</ogc:Literal></ogc:PropertyIsGreaterThanOrEqualTo></ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#980043</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>no_data</Name>
        <Title>Not published for this area</Title>
        <ogc:Filter><ogc:PropertyIsNull><ogc:PropertyName>not_drove_alone</ogc:PropertyName></ogc:PropertyIsNull></ogc:Filter>
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
        <ogc:Filter><ogc:And><ogc:Not><ogc:PropertyIsNull><ogc:PropertyName>not_drove_alone</ogc:PropertyName></ogc:PropertyIsNull></ogc:Not><ogc:PropertyIsGreaterThan><ogc:PropertyName>not_drove_alone_moe</ogc:PropertyName><ogc:Literal>15</ogc:Literal></ogc:PropertyIsGreaterThan></ogc:And></ogc:Filter>
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
