package com.alanstoll.sandysprings;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClient;

/**
 * Publishes the gis schema through GeoServer's REST API after Flyway has run. Idempotent.
 * Rebuilt from these payloads on every start rather than kept in a versioned GeoServer data
 * directory, so the geoserver volume stays disposable.
 */
@Component
@ConditionalOnProperty("sandysprings.geoserver.url")
@Order(2)
class GeoServerPublisher implements ApplicationRunner {

	private static final Logger log = LoggerFactory.getLogger(GeoServerPublisher.class);

	private static final MediaType SLD = MediaType.valueOf("application/vnd.ogc.sld+xml");

	private static final String FEATURETYPES = "/workspaces/sandysprings/datastores/postgis/featuretypes";

	private static final String STYLES = "/workspaces/sandysprings/styles";

	private final RestClient rest;

	GeoServerPublisher(RestClient.Builder builder, @Value("${sandysprings.geoserver.url}") String url,
			@Value("${sandysprings.geoserver.username}") String username,
			@Value("${sandysprings.geoserver.password}") String password) {
		// Without an explicit JSON preference GeoServer answers a style GET with 500, not the SLD
		this.rest = builder.baseUrl(url + "/rest").defaultHeaders(h -> h.setBasicAuth(username, password))
			.defaultHeader(HttpHeaders.ACCEPT, "application/json, */*").build();
	}

	@Override
	public void run(ApplicationArguments args) {
		ensure("/workspaces", "sandysprings", "geoserver/workspace.json");
		ensure("/workspaces/sandysprings/datastores", "postgis", "geoserver/datastore.json");
		ensure(FEATURETYPES, "place", "geoserver/featuretype-place.json");
		ensure(FEATURETYPES, "city_limit", "geoserver/featuretype-city-limit.json");
		ensure(FEATURETYPES, "flood_zone", "geoserver/featuretype-flood-zone.json");
		ensure(FEATURETYPES, "acs_bg", "geoserver/featuretype-acs-bg.json");
		ensureStyle("city_limit", "geoserver/style-city-limit.sld");
		ensureStyle("flood_zone", "geoserver/style-flood-zone.sld");
		// one style per theme on the one acs_bg layer: the client picks with the WMS styles parameter
		ensureStyle("acs_race", "geoserver/style-acs-race.sld");
		update("/layers/sandysprings:city_limit", "geoserver/layer-city-limit.json");
		update("/layers/sandysprings:flood_zone", "geoserver/layer-flood-zone.json");
		update("/layers/sandysprings:acs_bg", "geoserver/layer-acs-bg.json");
	}

	private void ensure(String collection, String name, String body) {
		if (exists(collection + "/" + name)) {
			log.info("GeoServer {} exists", name);
			return;
		}
		rest.post().uri(collection).contentType(MediaType.APPLICATION_JSON).body(new ClassPathResource(body))
			.retrieve().toBodilessEntity();
		log.info("GeoServer {} created", name);
	}

	private void ensureStyle(String name, String sld) {
		if (exists(STYLES + "/" + name)) {
			// replace, not skip: the SLD in this repo is the source of truth for every start
			rest.put().uri(STYLES + "/" + name).contentType(SLD).body(new ClassPathResource(sld))
				.retrieve().toBodilessEntity();
			log.info("GeoServer style {} updated", name);
			return;
		}
		rest.post().uri(uri -> uri.path(STYLES).queryParam("name", name).build()).contentType(SLD)
			.body(new ClassPathResource(sld)).retrieve().toBodilessEntity();
		log.info("GeoServer style {} created", name);
	}

	private void update(String resource, String body) {
		rest.put().uri(resource).contentType(MediaType.APPLICATION_JSON).body(new ClassPathResource(body))
			.retrieve().toBodilessEntity();
		log.info("GeoServer {} updated", resource);
	}

	private boolean exists(String resource) {
		try {
			rest.get().uri(resource).retrieve().toBodilessEntity();
			return true;
		}
		catch (HttpClientErrorException.NotFound e) {
			return false;
		}
	}

}
