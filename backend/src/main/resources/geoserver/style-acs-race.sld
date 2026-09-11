<?xml version="1.0" encoding="UTF-8"?>
<!-- Which B03002 category is largest in each block group. The fill names that category; where the
     lead over the runner-up is inside their combined margin of error, a stripe in the runner-up's
     colour is laid over the fill, so a block group the survey cannot call reads as both. Fill and
     stripe are chosen independently, which is why eight rules each cover all the pairs that occur
     rather than one rule per pair.

     Palette is ColorBrewer Set2, qualitative and carrying no ordering, because these categories
     have none. Set2 is near-equiluminant by design, which is what makes its hues work side by side
     but leaves nothing to separate a stripe from the fill under it: the four commonest categories
     span 13 luminance units, and they make up nine in ten of the striped block groups. Hence the
     white casing under every stripe. It, not the hue, is what keeps the two readable, and it is why
     the fill is the heavier of the two: the fill carries the answer, the stripe only qualifies it. -->
<StyledLayerDescriptor version="1.0.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>acs_race</Name>
    <UserStyle>
      <Name>acs_race</Name>
      <Title>Predominant race and ethnicity</Title>
      <FeatureTypeStyle>
      <Rule>
        <Name>white</Name>
        <Title>White alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:PropertyIsEqualTo>
            <ogc:PropertyName>predominant</ogc:PropertyName>
            <ogc:Literal>white</ogc:Literal>
          </ogc:PropertyIsEqualTo>
        </ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#8da0cb</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>black</Name>
        <Title>Black or African American alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:PropertyIsEqualTo>
            <ogc:PropertyName>predominant</ogc:PropertyName>
            <ogc:Literal>black</ogc:Literal>
          </ogc:PropertyIsEqualTo>
        </ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#66c2a5</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>hispanic</Name>
        <Title>Hispanic or Latino (any race)</Title>
        <ogc:Filter>
          <ogc:PropertyIsEqualTo>
            <ogc:PropertyName>predominant</ogc:PropertyName>
            <ogc:Literal>hispanic</ogc:Literal>
          </ogc:PropertyIsEqualTo>
        </ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#e78ac3</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>asian</Name>
        <Title>Asian alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:PropertyIsEqualTo>
            <ogc:PropertyName>predominant</ogc:PropertyName>
            <ogc:Literal>asian</ogc:Literal>
          </ogc:PropertyIsEqualTo>
        </ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#fc8d62</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>multiracial</Name>
        <Title>Two or more races, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:PropertyIsEqualTo>
            <ogc:PropertyName>predominant</ogc:PropertyName>
            <ogc:Literal>multiracial</ogc:Literal>
          </ogc:PropertyIsEqualTo>
        </ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#a6d854</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>aian</Name>
        <Title>American Indian and Alaska Native alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:PropertyIsEqualTo>
            <ogc:PropertyName>predominant</ogc:PropertyName>
            <ogc:Literal>aian</ogc:Literal>
          </ogc:PropertyIsEqualTo>
        </ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#e5c494</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>nhpi</Name>
        <Title>Native Hawaiian and Other Pacific Islander alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:PropertyIsEqualTo>
            <ogc:PropertyName>predominant</ogc:PropertyName>
            <ogc:Literal>nhpi</ogc:Literal>
          </ogc:PropertyIsEqualTo>
        </ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#ffd92f</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>other</Name>
        <Title>Some other race alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:PropertyIsEqualTo>
            <ogc:PropertyName>predominant</ogc:PropertyName>
            <ogc:Literal>other</ogc:Literal>
          </ogc:PropertyIsEqualTo>
        </ogc:Filter>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#b3b3b3</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
      </Rule>
      <Rule>
        <Name>ambiguous</Name>
        <Title>Striped: the two leading groups are within the margin of error</Title>
        <PolygonSymbolizer>
          <Fill>
            <CssParameter name="fill">#d9d9d9</CssParameter>
            <CssParameter name="fill-opacity">0.85</CssParameter>
          </Fill>
        </PolygonSymbolizer>
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
                    <CssParameter name="stroke">#666666</CssParameter>
                    <CssParameter name="stroke-width">3</CssParameter>
                  </Stroke>
                </Mark>
                <Size>20</Size>
              </Graphic>
            </GraphicFill>
          </Fill>
        </PolygonSymbolizer>
        <!-- illustrates the convention; the map draws the real pair from the rules below -->
        <VendorOption name="inclusion">legendOnly</VendorOption>
      </Rule>
      </FeatureTypeStyle>
      <!-- a second pass so the stripe lands on top of whichever fill the rules above chose -->
      <FeatureTypeStyle>
      <Rule>
        <Name>runner_up_white</Name>
        <Title>Runner-up White alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:And>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>ambiguous</ogc:PropertyName>
              <ogc:Literal>true</ogc:Literal>
            </ogc:PropertyIsEqualTo>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>runner_up</ogc:PropertyName>
              <ogc:Literal>white</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:Filter>
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
                    <CssParameter name="stroke">#8da0cb</CssParameter>
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
      <Rule>
        <Name>runner_up_black</Name>
        <Title>Runner-up Black or African American alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:And>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>ambiguous</ogc:PropertyName>
              <ogc:Literal>true</ogc:Literal>
            </ogc:PropertyIsEqualTo>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>runner_up</ogc:PropertyName>
              <ogc:Literal>black</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:Filter>
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
                    <CssParameter name="stroke">#66c2a5</CssParameter>
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
      <Rule>
        <Name>runner_up_hispanic</Name>
        <Title>Runner-up Hispanic or Latino (any race)</Title>
        <ogc:Filter>
          <ogc:And>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>ambiguous</ogc:PropertyName>
              <ogc:Literal>true</ogc:Literal>
            </ogc:PropertyIsEqualTo>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>runner_up</ogc:PropertyName>
              <ogc:Literal>hispanic</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:Filter>
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
                    <CssParameter name="stroke">#e78ac3</CssParameter>
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
      <Rule>
        <Name>runner_up_asian</Name>
        <Title>Runner-up Asian alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:And>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>ambiguous</ogc:PropertyName>
              <ogc:Literal>true</ogc:Literal>
            </ogc:PropertyIsEqualTo>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>runner_up</ogc:PropertyName>
              <ogc:Literal>asian</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:Filter>
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
                    <CssParameter name="stroke">#fc8d62</CssParameter>
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
      <Rule>
        <Name>runner_up_multiracial</Name>
        <Title>Runner-up Two or more races, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:And>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>ambiguous</ogc:PropertyName>
              <ogc:Literal>true</ogc:Literal>
            </ogc:PropertyIsEqualTo>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>runner_up</ogc:PropertyName>
              <ogc:Literal>multiracial</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:Filter>
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
                    <CssParameter name="stroke">#a6d854</CssParameter>
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
      <Rule>
        <Name>runner_up_aian</Name>
        <Title>Runner-up American Indian and Alaska Native alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:And>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>ambiguous</ogc:PropertyName>
              <ogc:Literal>true</ogc:Literal>
            </ogc:PropertyIsEqualTo>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>runner_up</ogc:PropertyName>
              <ogc:Literal>aian</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:Filter>
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
                    <CssParameter name="stroke">#e5c494</CssParameter>
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
      <Rule>
        <Name>runner_up_nhpi</Name>
        <Title>Runner-up Native Hawaiian and Other Pacific Islander alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:And>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>ambiguous</ogc:PropertyName>
              <ogc:Literal>true</ogc:Literal>
            </ogc:PropertyIsEqualTo>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>runner_up</ogc:PropertyName>
              <ogc:Literal>nhpi</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:Filter>
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
                    <CssParameter name="stroke">#ffd92f</CssParameter>
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
      <Rule>
        <Name>runner_up_other</Name>
        <Title>Runner-up Some other race alone, non-Hispanic</Title>
        <ogc:Filter>
          <ogc:And>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>ambiguous</ogc:PropertyName>
              <ogc:Literal>true</ogc:Literal>
            </ogc:PropertyIsEqualTo>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>runner_up</ogc:PropertyName>
              <ogc:Literal>other</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:Filter>
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
                    <CssParameter name="stroke">#b3b3b3</CssParameter>
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
