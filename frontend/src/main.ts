import 'maplibre-gl/dist/maplibre-gl.css'
import './style.css'
import { MapLibreMap, NavigationControl, addProtocol, setWorkerUrl } from 'maplibre-gl'
import type { RasterTileSource, StyleSpecification } from 'maplibre-gl'
import { Protocol } from 'pmtiles'
import basemapStyle from './basemap-style.json'
import { basemapTree, createLayerPanel, descendantLayers } from './layer-tree'
import type { LayerNode, LegendEntry } from './layer-tree'
import { createIdentify } from './identify'

// pmtiles:// lets MapLibre range-request tiles straight out of the static archive that
// `gradlew buildBasemap` writes, so there is still no tile server.
addProtocol('pmtiles', new Protocol().tile)

// dev only: vite.config.ts serves the worker verbatim, because Vite's transform injects an HMR
// client that throws inside a Worker. The production bundle handles the worker itself.
if (import.meta.env.DEV) {
  setWorkerUrl('/maplibre/maplibre-gl-worker.mjs')
}

// the archive only covers the city limits plus a 2 km buffer
const coverage: [[number, number], [number, number]] = [
  [-84.4706, 33.8586],
  [-84.23737, 34.02844],
]

// MapLibre rejects a root-relative sprite URL, so resolve the vendored assets against the
// current origin at runtime and keep the style file itself host-agnostic. Plain concatenation,
// not new URL(): that would percent-encode the {fontstack}/{range} placeholders.
const style = {
  ...basemapStyle,
  sprite: location.origin + '/basemap/sprite',
  glyphs: location.origin + '/basemap/glyphs/{fontstack}/{range}.pbf',
} as StyleSpecification

const map = new MapLibreMap({
  container: 'map',
  style,
  center: [-84.3538, 33.9436],
  zoom: 12,
  pitch: 45,
  maxBounds: coverage,
  attributionControl: { compact: false },
})

map.addControl(new NavigationControl({ visualizePitch: true }), 'top-left')

const WMS = '/geoserver/sandysprings/wms'

const wms = (layers: string, styles = '') =>
  `${WMS}?service=WMS&version=1.1.1&request=GetMap&layers=${layers}&styles=${styles}` +
  '&bbox={bbox-epsg-3857}&width=512&height=512&srs=EPSG:3857&format=image/png&transparent=true'

// The SLD is the only place a layer's classes, their colours and their labels are written down,
// so ask GeoServer what they are instead of restating them here. The swatches come back from the
// same renderer that draws the map, so a style change reaches the legend with nothing to keep in
// step. 28px: GeoServer's 20px default leaves the city limit's 3px dashes unreadable.
const legendFor = async (layer: string, style = ''): Promise<LegendEntry[]> => {
  const request = (params: string) =>
    `${WMS}?service=WMS&version=1.1.1&request=GetLegendGraphic&layer=${layer}&style=${style}&${params}`
  const [{ rules }] = await fetch(request('format=application/json')).then((r) => r.json()).then((b) => b.Legend)
  return rules.map((rule: { name: string; title?: string }) => ({
    name: rule.name,
    label: rule.title ?? rule.name,
    swatch: request(`format=image/png&width=28&height=28&legend_options=forceLabels:off&rule=${encodeURIComponent(rule.name)}`),
  }))
}

// Where the thematic overlays slot into the basemap: above its land and water, below its roads,
// buildings and labels, so you can see what is actually inside a flood zone. Found by source
// rather than hardcoded as an id, like basemapTree, so a newer OSM Liberty cannot silently move
// it; if the style ever ships no roads at all this falls back to undefined, meaning on top.
const roadsUp = style.layers.find((l) => (l as { 'source-layer'?: string })['source-layer'] === 'transportation')?.id

// The ACS layers and what each theme draws on. A theme names the geography it belongs to because
// the survey decides that, not the map: a count taken over everyone holds up on block groups, a
// share of some subset of them only on tracts. Ids are the GeoServer style names, so a saved view
// only has to remember strings that already exist on both sides.
type AcsLayer = 'acs_bg' | 'acs_tract'
type Theme = { style: string; label: string; layer: AcsLayer }
const ACS_LAYERS: AcsLayer[] = ['acs_bg', 'acs_tract']

const THEMES: Theme[] = [
  { style: 'acs_race', label: 'Predominant race & ethnicity', layer: 'acs_bg' },
  { style: 'acs_age_65', label: 'Residents aged 65 and over', layer: 'acs_bg' },
  { style: 'acs_age_under_18', label: 'Residents under 18', layer: 'acs_bg' },
  { style: 'acs_no_vehicle', label: 'Households with no vehicle', layer: 'acs_bg' },
  { style: 'acs_income', label: 'Median household income', layer: 'acs_tract' },
  { style: 'acs_home_value', label: 'Median home value', layer: 'acs_tract' },
  { style: 'acs_rent', label: 'Median gross rent', layer: 'acs_tract' },
  { style: 'acs_renter', label: 'Renter-occupied homes', layer: 'acs_tract' },
  { style: 'acs_commute_home', label: 'Worked from home', layer: 'acs_tract' },
  { style: 'acs_commute_car', label: 'Commuted without driving alone', layer: 'acs_tract' },
]

/**
 * A named starting point: which nodes the panel offers, which of them start switched on, and which
 * census theme is drawn. Availability and visibility are separate because they answer different
 * questions -- what belongs on this map at all, and what you want to see first. "All layers" is the
 * one view that withholds nothing, which is what makes it different from "City map" despite the two
 * switching on the same things.
 *
 * A view names nodes rather than layers so it does not have to know that the basemap is a hundred
 * of them, and styles rather than layers for the theme so it never has to say which geography a
 * theme lives on.
 */
type View = { id: string; label: string; available?: string[]; on: string[]; theme: string | null }

const VIEWS: View[] = [
  { id: 'all', label: 'All layers', on: ['city_limit_inhouse', 'basemap'], theme: null },
  { id: 'city', label: 'City map', available: ['aerial', 'city_limit_inhouse', 'city_limit', 'basemap'],
    on: ['city_limit_inhouse', 'basemap'], theme: null },
  // the published outline against ours, over the parcels that are the reason for the difference
  { id: 'limits', label: 'City limits compared',
    available: ['aerial', 'tax_parcel', 'city_limit_inhouse', 'city_limit', 'basemap'],
    on: ['city_limit_inhouse', 'city_limit', 'tax_parcel', 'basemap'], theme: null },
  { id: 'race', label: 'Race & ethnicity', available: ['census', 'city_limit_inhouse', 'city_limit', 'basemap'],
    on: ['city_limit_inhouse', 'basemap'], theme: 'acs_race' },
  // flood zones earn their place here and nowhere else so far: what a home is worth and what it
  // costs to insure are the same conversation
  { id: 'home_value', label: 'Median home value',
    available: ['census', 'flood_zone', 'city_limit_inhouse', 'city_limit', 'basemap'],
    on: ['city_limit_inhouse', 'flood_zone', 'basemap'], theme: 'acs_home_value' },
  { id: 'income', label: 'Median household income',
    available: ['census', 'city_limit_inhouse', 'city_limit', 'basemap'],
    on: ['city_limit_inhouse', 'basemap'], theme: 'acs_income' },
]

// Filled in before the map is: the sidebar has no reason to wait on tiles to show its own controls.
const chooser = document.querySelector<HTMLSelectElement>('#view')!
chooser.replaceChildren(...VIEWS.map((view) => new Option(view.label, view.id)))

const share = (value: unknown) => (value === null || value === undefined ? '-' : `${Number(value).toFixed(1)}%`)
const dollars = (value: unknown) =>
  value === null || value === undefined ? 'Not published' : '$' + Number(value).toLocaleString()

map.on('load', async () => {
  // Added before the thematic layers so it ends up beneath them: imagery is a ground to draw on,
  // not something to draw over a choropleth. Its tiles come from our own backend, which fetches
  // them from USGS once and then keeps them. maxzoom is where NAIP stops holding more detail;
  // past it MapLibre stretches a tile already on disk rather than asking for finer ones that
  // carry no more information.
  map.addSource('aerial', {
    type: 'raster',
    tiles: ['/api/aerial/{z}/{x}/{y}.jpg'],
    tileSize: 256,
    minzoom: 12,
    maxzoom: 19,
    attribution: 'Aerial imagery: USGS, USDA, The National Map (public domain)',
  })
  map.addLayer({ id: 'aerial', type: 'raster', source: 'aerial', layout: { visibility: 'none' } }, roadsUp)

  // One source per geography, both anchored under the roads so you can see what is inside them.
  // Only ever one is visible: two choropleths at once just occlude each other.
  for (const layer of ACS_LAYERS) {
    map.addSource(layer, {
      type: 'raster',
      tiles: [wms(`sandysprings:${layer}`)],
      tileSize: 512,
      attribution: 'Demographics: U.S. Census Bureau ACS 2020-2024 (public domain)',
    })
    map.addLayer({ id: layer, type: 'raster', source: layer, layout: { visibility: 'none' } }, roadsUp)
  }

  // its own WMS request rather than another layer on the city_limit one, so the panel can
  // toggle it on its own
  map.addSource('flood_zone', {
    type: 'raster',
    tiles: [wms('sandysprings:flood_zone')],
    tileSize: 512,
    attribution: 'Flood zones: FEMA National Flood Hazard Layer (public domain)',
  })
  map.addLayer({ id: 'flood_zone', type: 'raster', source: 'flood_zone' }, roadsUp)

  // Above the flood zones and above whichever choropleth is on, but still under the roads:
  // parcel lines are the reference grid you read a thematic layer against, so they have to stay
  // legible over it. Off until asked for; 30,000 outlines are a lot to put on an opening map.
  map.addSource('tax_parcel', {
    type: 'raster',
    tiles: [wms('sandysprings:tax_parcel')],
    tileSize: 512,
    attribution: 'Tax parcels: Fulton County Board of Assessors, 2026 tax digest (public record)',
  })
  map.addLayer({ id: 'tax_parcel', type: 'raster', source: 'tax_parcel', layout: { visibility: 'none' } }, roadsUp)

  // Two versions of the same boundary, the published one under ours so ours is what you read the
  // map against where they coincide. The place labels ride with ours for the same reason: switching
  // the published outline off is the normal case and must not take the labels with it.
  map.addSource('city_limit', {
    type: 'raster',
    tiles: [wms('sandysprings:city_limit')],
    tileSize: 512,
    attribution: 'City limits as published © City of Sandy Springs GIS Department (CC BY 4.0)',
  })
  map.addLayer({ id: 'city_limit', type: 'raster', source: 'city_limit', layout: { visibility: 'none' } })

  map.addSource('city_limit_inhouse', {
    type: 'raster',
    tiles: [wms('sandysprings:city_limit_inhouse,sandysprings:place')],
    tileSize: 512,
    attribution: 'City limits © City of Sandy Springs GIS Department (CC BY 4.0), moved onto the 2026 parcel fabric',
  })
  // the boundary stays on top of everything; it is a reference line, not thematic data
  map.addLayer({ id: 'city_limit_inhouse', type: 'raster', source: 'city_limit_inhouse' })

  const [cityLimit, cityLimitInhouse, floodZone, taxParcel] = await Promise.all([
    legendFor('sandysprings:city_limit'),
    legendFor('sandysprings:city_limit_inhouse'),
    legendFor('sandysprings:flood_zone'),
    legendFor('sandysprings:tax_parcel'),
  ])

  // The race style already names every category; reuse its labels rather than spelling them out
  // again, so the popup and the legend cannot disagree. Rule names are the category keys.
  const categories = Object.fromEntries(
    (await legendFor('sandysprings:acs_bg', 'acs_race')).map(({ name, label }) => [name, label]),
  )

  // Same trick for parcels: the land use classes are written down once, in the SLD, and the
  // popup reads them back off the legend rather than keeping its own copy of the labels.
  const parcelClasses = Object.fromEntries(taxParcel.map(({ name, label }) => [name, label]))

  const censusNode: LayerNode = {
    id: 'census',
    label: 'Census (ACS 2020-2024)',
    layers: [...ACS_LAYERS],
    themes: THEMES.map(({ style, label }) => ({ style, label })),
    theme: null,
    // Both geographies answer clicks, gated on whichever one the theme has made visible. They hang
    // off this node rather than getting checkboxes of their own, which would only fight the radios.
    identify: [
      {
        layer: 'acs_bg',
        source: 'sandysprings:acs_bg',
        properties: ['geoid', 'population', 'predominant', 'runner_up', 'ambiguous',
          'age_65_plus', 'age_under_18', 'no_vehicle'],
        section: (p) => {
          const rows = [
            { label: 'Population', value: Number(p.population).toLocaleString() },
            { label: 'Largest group', value: categories[String(p.predominant)] ?? String(p.predominant) },
            { label: 'Then', value: categories[String(p.runner_up)] ?? String(p.runner_up) },
          ]
          // the one thing the fill cannot say: whether the order of those two is real
          if (p.ambiguous) {
            rows.push({ label: 'Margin of error', value: 'Too close to separate these two' })
          }
          rows.push(
            { label: 'Aged 65 and over', value: share(p.age_65_plus) },
            { label: 'Under 18', value: share(p.age_under_18) },
            { label: 'No vehicle', value: share(p.no_vehicle) },
          )
          return { title: `Block group ${p.geoid}`, body: { kind: 'table', rows } }
        },
      },
      {
        layer: 'acs_tract',
        source: 'sandysprings:acs_tract',
        properties: ['geoid', 'income', 'home_value', 'gross_rent', 'renter', 'drove_alone',
          'carpooled', 'transit', 'walked', 'bicycle', 'other_mode', 'worked_at_home'],
        section: (p) => ({
          title: `Tract ${p.geoid}`,
          body: {
            kind: 'table',
            rows: [
              { label: 'Median household income', value: dollars(p.income) },
              { label: 'Median home value', value: dollars(p.home_value) },
              { label: 'Median gross rent', value: dollars(p.gross_rent) },
              { label: 'Renter-occupied', value: share(p.renter) },
              // the full commute split, which no single style can show
              { label: 'Drove alone', value: share(p.drove_alone) },
              { label: 'Carpooled', value: share(p.carpooled) },
              { label: 'Public transport', value: share(p.transit) },
              { label: 'Walked', value: share(p.walked) },
              { label: 'Bicycle', value: share(p.bicycle) },
              { label: 'Other means', value: share(p.other_mode) },
              { label: 'Worked from home', value: share(p.worked_at_home) },
            ],
          },
        }),
      },
    ],
  }

  const allNodes: LayerNode[] = [
    { id: 'aerial', label: 'Aerial imagery (NAIP)', layers: ['aerial'] },
    // no identify: the city limit is a reference boundary, and as a polygon it would answer every
    // click inside the city with the same row
    { id: 'city_limit_inhouse', label: 'City limits', layers: ['city_limit_inhouse'], legend: cityLimitInhouse },
    { id: 'city_limit', label: 'City limits (as published)', layers: ['city_limit'], legend: cityLimit },
    {
      id: 'flood_zone',
      label: 'Flood zones',
      layers: ['flood_zone'],
      legend: floodZone,
      identify: [{
        layer: 'flood_zone',
        source: 'sandysprings:flood_zone',
        properties: ['zone', 'subtype', 'sfha'],
        section: (p) => ({
          title: 'Flood hazard',
          body: {
            kind: 'table',
            rows: [
              { label: 'Zone', value: String(p.zone) },
              ...(p.subtype ? [{ label: 'Subtype', value: String(p.subtype) }] : []),
              { label: 'Special flood hazard area', value: p.sfha ? 'Yes' : 'No' },
            ],
          },
        }),
      }],
    },
    {
      id: 'tax_parcel',
      label: 'Tax parcels',
      layers: ['tax_parcel'],
      legend: taxParcel,
      identify: [{
        layer: 'tax_parcel',
        source: 'sandysprings:tax_parcel',
        properties: ['parcel_id', 'address', 'category', 'land_use_code', 'class_code', 'acres', 'living_units'],
        section: (p) => {
          // 932 parcels have no street number, and the county writes those as "0 <street>"
          const address = String(p.address ?? '')
          const unaddressed = address.startsWith('0 ')
          return {
            title: unaddressed ? 'Unaddressed parcel' : address,
            body: {
              kind: 'table',
              rows: [
                ...(unaddressed ? [{ label: 'On', value: address.slice(2) }] : []),
                { label: 'Parcel', value: String(p.parcel_id) },
                { label: 'Use', value: parcelClasses[String(p.category)] ?? String(p.category) },
                // the county's own codes as well as the class they were grouped into, so a parcel
                // that looks miscoloured can be traced back to what the digest actually said
                { label: 'Land use code', value: String(p.land_use_code) },
                { label: 'Class code', value: String(p.class_code) },
                { label: 'Area', value: p.acres == null ? 'Not assessed' : `${Number(p.acres).toFixed(2)} acres` },
                { label: 'Living units', value: p.living_units == null ? 'Not assessed' : String(p.living_units) },
              ],
            },
          }
        },
      }],
    },
    censusNode,
    { ...basemapTree(style), id: 'basemap' },
  ]

  const elements = {
    layers: document.querySelector<HTMLElement>('#layers')!,
    legend: document.querySelector<HTMLElement>('#legend')!,
  }
  let panel = createLayerPanel(map, elements, allNodes)

  // Repointing the source beats keeping ten layers alive, one per theme. Split from setTheme so a
  // view can move the map and rebuild the panel once, rather than refresh a panel it is replacing.
  const applyTheme = async (style: string | null) => {
    const theme = THEMES.find((candidate) => candidate.style === style) ?? null
    censusNode.theme = theme?.style ?? null
    for (const layer of ACS_LAYERS) {
      map.setLayoutProperty(layer, 'visibility', theme?.layer === layer ? 'visible' : 'none')
    }
    if (theme) {
      map.getSource<RasterTileSource>(theme.layer)!.setTiles([wms(`sandysprings:${theme.layer}`, theme.style)])
    }
    censusNode.legend = theme ? await legendFor(`sandysprings:${theme.layer}`, theme.style) : []
  }

  // The two entry points anything else drives the map through: a radio now, a gallery tile later.
  const setTheme = async (style: string | null) => {
    await applyTheme(style)
    panel.refresh()
  }
  censusNode.onTheme = setTheme

  const setView = async (id: string) => {
    const view = VIEWS.find((candidate) => candidate.id === id) ?? VIEWS[0]
    const offered = allNodes.filter((node) => !view.available || view.available.includes(node.id!))
    // Everything is settled from the view rather than adjusted, including the nodes it withholds:
    // a layer left visible with no control to switch it off would be stuck on.
    for (const node of allNodes) {
      const on = view.on.includes(node.id!) && offered.includes(node)
      for (const layer of descendantLayers(node)) {
        map.setLayoutProperty(layer, 'visibility', on ? 'visible' : 'none')
      }
    }
    await applyTheme(offered.includes(censusNode) ? view.theme : null)
    panel = createLayerPanel(map, elements, offered)
  }

  createIdentify(map, WMS, allNodes)
  chooser.addEventListener('change', () => setView(chooser.value))
  await setView(chooser.value)
})

const list = document.querySelector<HTMLUListElement>('#places')!
const places = await fetch('/api/places').then((r) => r.json())
for (const feature of places.features) {
  const li = document.createElement('li')
  li.textContent = feature.properties.name
  list.append(li)
}
