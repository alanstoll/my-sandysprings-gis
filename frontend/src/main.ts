import 'maplibre-gl/dist/maplibre-gl.css'
import './style.css'
import { MapLibreMap, NavigationControl, addProtocol, setWorkerUrl } from 'maplibre-gl'
import type { StyleSpecification } from 'maplibre-gl'
import { Protocol } from 'pmtiles'
import basemapStyle from './basemap-style.json'
import { basemapTree, createLayerPanel } from './layer-tree'

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

map.on('load', () => {
  // city limits stay on GeoServer: MapLibre consumes the WMS as a raster source
  map.addSource('city_limit', {
    type: 'raster',
    tiles: [
      '/geoserver/sandysprings/wms?service=WMS&version=1.1.1&request=GetMap' +
        '&layers=sandysprings:city_limit,sandysprings:place' +
        '&bbox={bbox-epsg-3857}&width=512&height=512&srs=EPSG:3857' +
        '&format=image/png&transparent=true',
    ],
    tileSize: 512,
    attribution: 'City limits © City of Sandy Springs GIS Department (CC BY 4.0)',
  })
  map.addLayer({ id: 'city_limit', type: 'raster', source: 'city_limit' })

  createLayerPanel(map, document.querySelector<HTMLElement>('#layers')!, [
    { label: 'City limits', layers: ['city_limit'] },
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
