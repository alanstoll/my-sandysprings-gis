import 'maplibre-gl/dist/maplibre-gl.css'
import './style.css'
import { MapLibreMap, NavigationControl, addProtocol, setWorkerUrl } from 'maplibre-gl'
import type { StyleSpecification } from 'maplibre-gl'
import { Protocol } from 'pmtiles'
import basemapStyle from './basemap-style.json'
import { basemapTree, createLayerPanel } from './layer-tree'
import type { LegendEntry } from './layer-tree'

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

const wms = (layers: string) =>
  '/geoserver/sandysprings/wms?service=WMS&version=1.1.1&request=GetMap&layers=' +
  layers +
  '&bbox={bbox-epsg-3857}&width=512&height=512&srs=EPSG:3857&format=image/png&transparent=true'

// The SLD is the only place a layer's classes, their colours and their labels are written down,
// so ask GeoServer what they are instead of restating them here. The swatches come back from the
// same renderer that draws the map, so a style change reaches the legend with nothing to keep in
// step. 28px: GeoServer's 20px default leaves the city limit's 3px dashes unreadable.
const legendFor = async (layer: string): Promise<LegendEntry[]> => {
  const request = (params: string) =>
    `/geoserver/sandysprings/wms?service=WMS&version=1.1.1&request=GetLegendGraphic&layer=${layer}&${params}`
  const [{ rules }] = await fetch(request('format=application/json')).then((r) => r.json()).then((b) => b.Legend)
  return rules.map((rule: { name: string; title?: string }) => ({
    label: rule.title ?? rule.name,
    swatch: request(`format=image/png&width=28&height=28&legend_options=forceLabels:off&rule=${encodeURIComponent(rule.name)}`),
  }))
}

// Where the thematic overlays slot into the basemap: above its land and water, below its roads,
// buildings and labels, so you can see what is actually inside a flood zone. Found by source
// rather than hardcoded as an id, like basemapTree, so a newer OSM Liberty cannot silently move
// it; if the style ever ships no roads at all this falls back to undefined, meaning on top.
const roadsUp = style.layers.find((l) => (l as { 'source-layer'?: string })['source-layer'] === 'transportation')?.id

map.on('load', async () => {
  // its own WMS request rather than another layer on the city_limit one, so the panel can
  // toggle it on its own
  map.addSource('flood_zone', {
    type: 'raster',
    tiles: [wms('sandysprings:flood_zone')],
    tileSize: 512,
    attribution: 'Flood zones: FEMA National Flood Hazard Layer (public domain)',
  })
  map.addLayer({ id: 'flood_zone', type: 'raster', source: 'flood_zone' }, roadsUp)

  // city limits stay on GeoServer: MapLibre consumes the WMS as a raster source
  map.addSource('city_limit', {
    type: 'raster',
    tiles: [wms('sandysprings:city_limit,sandysprings:place')],
    tileSize: 512,
    attribution: 'City limits © City of Sandy Springs GIS Department (CC BY 4.0)',
  })
  // the boundary stays on top of everything; it is a reference line, not thematic data
  map.addLayer({ id: 'city_limit', type: 'raster', source: 'city_limit' })

  const [cityLimit, floodZone] = await Promise.all([
    legendFor('sandysprings:city_limit'),
    legendFor('sandysprings:flood_zone'),
  ])

  const panel = {
    layers: document.querySelector<HTMLElement>('#layers')!,
    legend: document.querySelector<HTMLElement>('#legend')!,
  }
  createLayerPanel(map, panel, [
    { label: 'City limits', layers: ['city_limit'], legend: cityLimit },
    { label: 'Flood zones', layers: ['flood_zone'], legend: floodZone },
    basemapTree(style),
  ])
})

const list = document.querySelector<HTMLUListElement>('#places')!
const places = await fetch('/api/places').then((r) => r.json())
for (const feature of places.features) {
  const li = document.createElement('li')
  li.textContent = feature.properties.name
  list.append(li)
}
