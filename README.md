# my-sandysprings-gis

Spring Boot 4 + GeoServer 3 + PostGIS 18 for Sandy Springs, GA. Prerequisites: JDK 25, Node 24, Docker.

```
cd backend && gradlew bootRun       # starts compose, ingests data/, migrates, publishes to geoserver, serves :8080
cd backend && gradlew resetSchema   # drops app and gis so the next bootRun rebuilds them; keeps ingested staging data
cd frontend && npm install && npm run dev   # map at http://localhost:5173
```

- GeoServer admin: http://localhost:8081/geoserver (admin / geoserver)
- Backend health: http://localhost:8080/actuator/health
- `data/layers/` holds committed sources, listed in `data/layers.json`. `data/raw/` is gitignored; copy large datasets there by hand.
