import type { MapLibreMap, StyleSpecification } from 'maplibre-gl'

/** A node toggles its own layers plus every layer beneath it. */
export type LayerNode = { label: string; layers?: string[]; children?: LayerNode[] }

/**
 * Groups the basemap style's 100-odd layers into something worth putting checkboxes on.
 * Built from the style rather than hardcoded so it cannot drift out of sync with it: a group
 * that matches nothing is dropped instead of producing a checkbox that toggles nothing.
 */
export function basemapTree(style: StyleSpecification): LayerNode {
  const ofSource = (...names: string[]) =>
    style.layers.filter((l) => names.includes((l as { 'source-layer'?: string })['source-layer'] ?? '')).map((l) => l.id)
  const withId = (...ids: string[]) => ids.filter((id) => style.layers.some((l) => l.id === id))

  const prune = (node: LayerNode): LayerNode | null => {
    const children = (node.children ?? []).map(prune).filter((c): c is LayerNode => c !== null)
    const layers = node.layers ?? []
    if (!layers.length && !children.length) return null
    return { label: node.label, layers, ...(children.length ? { children } : {}) }
  }

  return prune({
    label: 'Basemap',
    children: [
      { label: 'Points of interest', layers: ofSource('poi') },
      {
        label: 'Buildings',
        children: [
          { label: 'Footprints', layers: withId('building') },
          { label: '3D extrusions', layers: withId('building-3d') },
          { label: 'House numbers', layers: withId('housenumber') },
        ],
      },
      {
        label: 'Roads',
        children: [
          { label: 'Roadways', layers: ofSource('transportation', 'aeroway') },
          { label: 'Road labels', layers: withId('road_label', 'road_shield') },
        ],
      },
      {
        label: 'Water',
        children: [
          { label: 'Rivers & lakes', layers: withId('water', 'waterway_tunnel', 'waterway_river', 'waterway_other') },
          { label: 'Water labels', layers: withId('water_name_line', 'water_name_point') },
        ],
      },
      {
        label: 'Land use & parks',
        children: [
          { label: 'Land cover', layers: [...ofSource('landcover', 'landuse'), ...withId('park', 'park_outline')] },
          { label: 'Park labels', layers: withId('park_label') },
        ],
      },
      { label: 'Place labels', layers: ofSource('place') },
      { label: 'Admin boundaries', layers: ofSource('boundary') },
    ],
  })!
}

const descendantLayers = (node: LayerNode): string[] => [
  ...(node.layers ?? []),
  ...(node.children ?? []).flatMap(descendantLayers),
]

/** Renders a checkbox tree that drives layer visibility on the map. */
export function createLayerPanel(map: MapLibreMap, container: HTMLElement, nodes: LayerNode[]): void {
  const boxes: { node: LayerNode; input: HTMLInputElement }[] = []

  const isVisible = (id: string) => map.getLayoutProperty(id, 'visibility') !== 'none'

  const refresh = () => {
    for (const { node, input } of boxes) {
      const ids = descendantLayers(node)
      const shown = ids.filter(isVisible).length
      input.checked = shown > 0
      input.indeterminate = shown > 0 && shown < ids.length
    }
  }

  const build = (list: LayerNode[]): HTMLUListElement => {
    const ul = document.createElement('ul')
    for (const node of list) {
      const li = document.createElement('li')
      const label = document.createElement('label')
      const input = document.createElement('input')
      input.type = 'checkbox'
      input.addEventListener('change', () => {
        const visibility = input.checked ? 'visible' : 'none'
        for (const id of descendantLayers(node)) map.setLayoutProperty(id, 'visibility', visibility)
        refresh()
      })
      label.addEventListener('click', (e) => e.stopPropagation())
      label.append(input, document.createTextNode(' ' + node.label))
      boxes.push({ node, input })

      if (node.children?.length) {
        const details = document.createElement('details')
        details.open = true
        const summary = document.createElement('summary')
        summary.append(label)
        details.append(summary, build(node.children))
        li.append(details)
      } else {
        li.append(label)
      }
      ul.append(li)
    }
    return ul
  }

  container.replaceChildren(build(nodes))
  refresh()
}
