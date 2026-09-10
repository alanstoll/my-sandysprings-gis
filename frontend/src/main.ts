import 'ol/ol.css'
import './style.css'
import Map from 'ol/Map'
import View from 'ol/View'
import TileLayer from 'ol/layer/Tile'
import OSM from 'ol/source/OSM'
import TileWMS from 'ol/source/TileWMS'
import { fromLonLat } from 'ol/proj'

new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    new TileLayer({
      source: new TileWMS({
        url: '/geoserver/sandysprings/wms',
        params: { LAYERS: 'sandysprings:city_limit,sandysprings:place' },
        serverType: 'geoserver',
      }),
    }),
  ],
  view: new View({ center: fromLonLat([-84.3538, 33.9436]), zoom: 12 }),
})

const list = document.querySelector<HTMLUListElement>('#places')!
const places = await fetch('/api/places').then((r) => r.json())
for (const feature of places.features) {
  const li = document.createElement('li')
  li.textContent = feature.properties.name
  list.append(li)
}
