import { Popup } from 'maplibre-gl'
import type { MapLibreMap } from 'maplibre-gl'

/** One row of the key/value table a layer shows when clicked. */
export type PopupRow = { label: string; value: string }

/**
 * What a layer puts in the popup. Tagged rather than a blob of HTML: a layer says what it wants
 * shown and this module decides how, so nothing a layer returns can put markup on the page.
 * A richer kind (a bar of shares, a chart) becomes another member here plus another case in
 * renderBody, and every layer already written keeps working.
 */
export type PopupBody = { kind: 'table'; rows: PopupRow[] }

/** One layer's answer to one click. */
export type PopupSection = { title: string; body: PopupBody }

/** How a layer answers a click. */
export type Identify = {
	/** The map layer whose visibility decides whether this is asked at all. */
	layer: string
	/** The GeoServer layer to query. */
	source: string
	/**
	 * The attributes to ask for. Naming them is not only tidiness: it also drops the geometry from
	 * the response, which for a block group is most of it (25 kB against 355 bytes).
	 */
	properties: string[]
	/** Builds the section, or null to put nothing in this popup. */
	section: (properties: Record<string, unknown>) => PopupSection | null
}

/**
 * Structural, so LayerNode satisfies it without this module knowing about the layer tree. A node
 * may answer for more than one layer: the census group owns both geographies and only ever shows
 * one, which is not a reason to give each its own checkbox.
 */
type Queryable = { identify?: Identify[] }

// GetFeatureInfo wants a GetMap and a pixel inside it. Rather than reproduce the viewport, which a
// pitched map does not map linearly onto the canvas, ask for a small square centred on the click:
// the centre pixel is then exactly the point pressed, whatever the pitch happens to be. The radius
// doubles as the click tolerance, so a press just outside a boundary still finds what is inside it.
const RADIUS = 8

function renderBody(body: PopupBody): HTMLElement {
	switch (body.kind) {
		case 'table': {
			const table = document.createElement('table')
			for (const { label, value } of body.rows) {
				const row = table.insertRow()
				row.insertCell().textContent = label
				row.insertCell().textContent = value
			}
			return table
		}
	}
}

function render(sections: PopupSection[]): HTMLElement {
	const root = document.createElement('div')
	root.className = 'identify'
	for (const { title, body } of sections) {
		const heading = document.createElement('h3')
		heading.textContent = title
		root.append(heading, renderBody(body))
	}
	return root
}

/**
 * Makes clicking the map ask every visible layer that has registered an Identify what is under the
 * cursor, in one request, and shows what comes back. A layer with nothing there contributes
 * nothing; a click with nothing anywhere opens no popup.
 */
export function createIdentify(map: MapLibreMap, wms: string, nodes: Queryable[]): void {
	const queryable = nodes.flatMap((node) => node.identify ?? [])
	if (!queryable.length) return
	const popup = new Popup({ maxWidth: '340px' })

	map.on('click', async (event) => {
		// Draw order decides which answer leads: the layer drawn on top is the one that was clicked.
		// Read it off the map rather than off the argument, so it cannot drift from what is on screen.
		const order = map.getStyle().layers.map((layer) => layer.id)
		const asked = queryable
			.filter((entry) => map.getLayer(entry.layer) && map.getLayoutProperty(entry.layer, 'visibility') !== 'none')
			.sort((a, b) => order.indexOf(b.layer) - order.indexOf(a.layer))
		if (!asked.length) return

		const { lng, lat } = event.lngLat
		const at = map.project(event.lngLat)
		const dx = Math.abs(map.unproject([at.x + RADIUS, at.y]).lng - lng)
		const dy = Math.abs(map.unproject([at.x, at.y - RADIUS]).lat - lat)
		const layers = asked.map((entry) => entry.source).join(',')
		const url =
			`${wms}?service=WMS&version=1.1.1&request=GetFeatureInfo&info_format=application/json` +
			`&layers=${layers}&query_layers=${layers}&feature_count=10&srs=EPSG:4326` +
			`&bbox=${lng - dx},${lat - dy},${lng + dx},${lat + dy}` +
			`&width=${RADIUS * 2 + 1}&height=${RADIUS * 2 + 1}&x=${RADIUS}&y=${RADIUS}` +
			// one parenthesised group per queried layer, in the same order as query_layers
			`&propertyName=${asked.map((entry) => `(${entry.properties.join(',')})`).join('')}`

		const features: { id?: string; properties: Record<string, unknown> }[] = await fetch(url)
			.then((response) => response.json())
			.then((collection) => collection.features ?? [])
		const sections = asked.flatMap((entry) => {
			// GeoServer prefixes a feature's id with the layer that produced it, which is the only
			// thing tying a feature in a mixed response back to the layer that answered
			const prefix = entry.source.split(':').pop() + '.'
			const hit = features.find((feature) => feature.id?.startsWith(prefix))
			const section = hit && entry.section(hit.properties)
			return section ? [section] : []
		})
		if (!sections.length) {
			popup.remove()
			return
		}
		popup.setLngLat(event.lngLat).setDOMContent(render(sections)).addTo(map)
	})
}
