import { defineConfig } from 'vite'
import { createReadStream } from 'node:fs'

export default defineConfig({
  // the dep optimizer cannot resolve maplibre-gl's separate worker chunk
  optimizeDeps: { exclude: ['maplibre-gl'] },
  plugins: [
    {
      // Vite injects its HMR client into every module it transforms, and that client throws in a
      // Worker, so maplibre's worker never starts in dev. Serve it and the chunk it imports
      // verbatim instead; main.ts points setWorkerUrl here. The production build is unaffected.
      name: 'maplibre-worker-verbatim',
      apply: 'serve',
      configureServer(server) {
        server.middlewares.use((req, res, next) => {
          const file = /^\/maplibre\/(maplibre-gl-(?:worker|shared)\.mjs)$/.exec(req.url ?? '')?.[1]
          if (!file) return next()
          res.setHeader('Content-Type', 'text/javascript')
          createReadStream(new URL(`./node_modules/maplibre-gl/dist/${file}`, import.meta.url)).pipe(res)
        })
      },
    },
  ],
  server: {
    proxy: {
      '/api': 'http://localhost:8080',
      '/geoserver': 'http://localhost:8081',
    },
  },
})
