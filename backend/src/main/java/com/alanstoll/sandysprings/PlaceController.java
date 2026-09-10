package com.alanstoll.sandysprings;

import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class PlaceController {

	private final JdbcClient jdbc;

	PlaceController(JdbcClient jdbc) {
		this.jdbc = jdbc;
	}

	// Builds the JSON in SQL and returns it as a string: a hello-world shortcut, not a pattern to copy
	@GetMapping(value = "/api/places", produces = "application/geo+json")
	String places() {
		return jdbc.sql("""
				select json_build_object(
				    'type', 'FeatureCollection',
				    'features', coalesce(json_agg(json_build_object(
				        'type', 'Feature',
				        'id', id,
				        'geometry', ST_AsGeoJSON(geom)::json,
				        'properties', json_build_object('name', name))), '[]'::json))::text
				from gis.place
				""").query(String.class).single();
	}

}
