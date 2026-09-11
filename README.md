# my-sandysprings-gis

Spring Boot 4 + GeoServer 3 + PostGIS 18 for Sandy Springs, GA. Prerequisites: JDK 25, Node 24, Docker.

```
cd backend && gradlew bootRun       # starts compose, ingests data/, migrates, publishes to geoserver, serves :8080
cd backend && gradlew resetSchema   # drops app and gis so the next bootRun rebuilds them; keeps ingested staging data
cd backend && gradlew buildBasemap  # builds the basemap pmtiles archive (slow; downloads ~1.8 GB of sources once)
cd backend && gradlew prepareFloodHazard   # re-cuts data/layers/flood-hazard.geojson from a FEMA NFHL download in data/raw/nfhl
cd frontend && npm install && npm run dev   # map at http://localhost:5173
```

- GeoServer admin: http://localhost:8081/geoserver (admin / geoserver)
- Backend health: http://localhost:8080/actuator/health
- `data/layers/` holds committed sources, listed in `data/layers.json`. `data/raw/` is gitignored; copy large datasets there by hand.

## Credits

- City limits: City of Sandy Springs GIS Department, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- Flood zones: [FEMA National Flood Hazard Layer](https://msc.fema.gov/portal/advanceSearch), Fulton County (13121C), effective 2024-07-12 (public domain)
- Basemap tiles: © OpenMapTiles © OpenStreetMap contributors ([ODbL](https://www.openstreetmap.org/copyright))
- Basemap style: [OSM Liberty](https://github.com/maputnik/osm-liberty) (BSD, derived from Mapbox OSM Bright; design CC BY 3.0)
- Map icons: [Maki](https://github.com/mapbox/maki) (CC0). Label fonts: [Roboto](https://github.com/googlefonts/roboto) (Apache 2.0)

The sprite and font glyphs are vendored into `frontend/public/basemap/` so the map has no third-party runtime dependencies.
