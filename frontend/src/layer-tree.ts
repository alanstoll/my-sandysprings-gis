import type { MapLibreMap, StyleSpecification } from 'maplibre-gl'
import type { Identify } from './identify'

/** A row a node contributes to the legend while any of its own layers is on the map. */
export type LegendEntry = { name: string; label: string; swatch: string }

/** One mutually exclusive choice within a node's theme group. */
export type ThemeOption = { style: string; label: string }

/** A node toggles its own layers plus every layer beneath it. */
export type LayerNode = {
  /** Stable handle for a view to name this node by; only top-level nodes need one. */
  id?: string
  label: string
  layers?: string[]
  children?: LayerNode[]
  legend?: LegendEntry[]
  identify?: Identify[]
  /**
   * Mutually exclusive alternatives, drawn as radios with a "None" rather than checkboxes, because
   * two choropleths on screen at once only occlude each other. A node with these has no checkbox of
   * its own: the choice is the control.
   */
  themes?: ThemeOption[]
  /** The chosen style, or null for none. The panel reads this on every refresh. */
  theme?: string | null
  /** Called with the chosen style, or null. */
  onTheme?: (style: string | null) => void
}

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

/** A node's own layers plus every layer beneath it. */
export const descendantLayers = (node: LayerNode): string[] => [
  ...(node.layers ?? []),
  ...(node.children ?? []).flatMap(descendantLayers),
]

/**
 * Renders a checkbox tree that drives layer visibility on the map, plus the legend it implies.
 * Returns a refresh, so anything that changes what is on the map without going through a checkbox
 * can bring the panel back in step.
 *
 * Every group starts collapsed, so the panel opens on the list of what this view offers rather than
 * on a hundred basemap checkboxes. Only a view rebuilds the panel; switching theme refreshes it,
 * which is what keeps a group you opened from snapping shut underneath you.
 */
export function createLayerPanel(
  map: MapLibreMap,
  panel: { layers: HTMLElement; legend: HTMLElement },
  nodes: LayerNode[],
): { refresh: () => void } {
  const boxes: { node: LayerNode; input: HTMLInputElement }[] = []
  const radios: { node: LayerNode; input: HTMLInputElement; style: string | null }[] = []

  const isVisible = (id: string) => map.getLayoutProperty(id, 'visibility') !== 'none'

  // Every node, not just the ones that got a checkbox: a theme group contributes a legend too.
  const everyNode = (function flatten(list: LayerNode[]): LayerNode[] {
    return list.flatMap((node) => [node, ...flatten(node.children ?? [])])
  })(nodes)

  // A node's own layers, not its descendants': a group's entries would otherwise appear as soon
  // as anything under it was on.
  const refreshLegend = () => {
    const entries = everyNode
      .filter((node) => node.legend?.length && (node.layers ?? []).some(isVisible))
      .flatMap((node) => node.legend!)
    panel.legend.querySelector('ul')!.replaceChildren(
      ...entries.map(({ label, swatch }) => {
        const li = document.createElement('li')
        const img = document.createElement('img')
        img.src = swatch
        img.alt = ''
        li.append(img, document.createTextNode(label))
        return li
      }),
    )
    panel.legend.hidden = entries.length === 0
  }

  const refresh = () => {
    for (const { node, input } of boxes) {
      const ids = descendantLayers(node)
      const shown = ids.filter(isVisible).length
      input.checked = shown > 0
      input.indeterminate = shown > 0 && shown < ids.length
    }
    for (const { node, input, style } of radios) {
      input.checked = (node.theme ?? null) === style
    }
    refreshLegend()
  }

  // Each group needs its own radio name or two groups on the page would share one selection.
  let groups = 0
  const buildThemes = (node: LayerNode): HTMLLIElement => {
    const name = `theme-${groups++}`
    const option = (style: string | null, text: string) => {
      const row = document.createElement('li')
      const label = document.createElement('label')
      const input = document.createElement('input')
      input.type = 'radio'
      input.name = name
      input.addEventListener('change', () => {
        if (input.checked) node.onTheme?.(style)
      })
      label.append(input, document.createTextNode(' ' + text))
      row.append(label)
      radios.push({ node, input, style })
      return row
    }
    const list = document.createElement('ul')
    list.append(option(null, 'None'), ...node.themes!.map((t) => option(t.style, t.label)))
    const details = document.createElement('details')
    const summary = document.createElement('summary')
    summary.textContent = node.label
    details.append(summary, list)
    const li = document.createElement('li')
    li.append(details)
    return li
  }

  const build = (list: LayerNode[]): HTMLUListElement => {
    const ul = document.createElement('ul')
    for (const node of list) {
      if (node.themes?.length) {
        ul.append(buildThemes(node))
        continue
      }
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

  panel.layers.replaceChildren(build(nodes))
  refresh()
  return { refresh }
}
