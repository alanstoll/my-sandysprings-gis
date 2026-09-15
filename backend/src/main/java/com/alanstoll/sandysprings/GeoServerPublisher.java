package com.alanstoll.sandysprings;

import java.util.List;

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
// Both: the url says a GeoServer exists to publish to, the flag says to do it on startup.
// Publishing is a side effect of running the application, not of building its context, and a
// test that loads the context should not reach out and rewrite a live catalogue to do it.
@ConditionalOnProperty({ "sandysprings.geoserver.url", "sandysprings.geoserver.publish" })
@Order(2)
class GeoServerPublisher implements ApplicationRunner {

	private static final Logger log = LoggerFactory.getLogger(GeoServerPublisher.class);

	private static final MediaType SLD = MediaType.valueOf("application/vnd.ogc.sld+xml");

	private static final String FEATURETYPES = "/workspaces/sandysprings/datastores/postgis/featuretypes";

	private static final String STYLES = "/workspaces/sandysprings/styles";

	private static final List<String> ACS_THEMES = List.of("acs_race", "acs_age_65", "acs_age_under_18",
			"acs_no_vehicle", "acs_income", "acs_home_value", "acs_rent", "acs_renter",
			"acs_commute_home", "acs_commute_car");

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
		ensureFeatureType("place", "geoserver/featuretype-place.json");
		ensureFeatureType("city_limit", "geoserver/featuretype-city-limit.json");
		ensureFeatureType("flood_zone", "geoserver/featuretype-flood-zone.json");
		ensureFeatureType("acs_bg", "geoserver/featuretype-acs-bg.json");
		ensureFeatureType("acs_tract", "geoserver/featuretype-acs-tract.json");
		ensureFeatureType("tax_parcel", "geoserver/featuretype-tax-parcel.json");
		ensureStyle("city_limit", "geoserver/style-city-limit.sld");
		ensureStyle("flood_zone", "geoserver/style-flood-zone.sld");
		ensureStyle("tax_parcel", "geoserver/style-tax-parcel.sld");
		// One style per theme across the two acs layers; the client picks with the WMS styles
		// parameter. Which layer a theme belongs to is the frontend's business, not GeoServer's:
		// here they are just styles that happen to match one schema or the other.
		ACS_THEMES.forEach(theme -> ensureStyle(theme, "geoserver/style-" + theme.replace('_', '-') + ".sld"));
		update("/layers/sandysprings:city_limit", "geoserver/layer-city-limit.json");
		update("/layers/sandysprings:flood_zone", "geoserver/layer-flood-zone.json");
		update("/layers/sandysprings:acs_bg", "geoserver/layer-acs-bg.json");
		update("/layers/sandysprings:acs_tract", "geoserver/layer-acs-tract.json");
		update("/layers/sandysprings:tax_parcel", "geoserver/layer-tax-parcel.json");
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

	/**
	 * Recalculates rather than skips when the feature type already exists. GeoServer stores a
	 * feature type's attribute list at creation, so a migration that adds a column leaves it
	 * holding the old one, and every style filtering on the new column fails at render time with
	 * nothing to show for it but a ServiceException in place of the tile.
	 */
	private void ensureFeatureType(String name, String body) {
		String resource = FEATURETYPES + "/" + name;
		if (exists(resource)) {
			rest.put()
				.uri(uri -> uri.path(resource).queryParam("recalculate", "attributes,nativebbox,latlonbbox").build())
				.contentType(MediaType.APPLICATION_JSON).body(new ClassPathResource(body))
				.retrieve().toBodilessEntity();
			log.info("GeoServer featuretype {} recalculated", name);
			return;
		}
		rest.post().uri(FEATURETYPES).contentType(MediaType.APPLICATION_JSON)
			.body(new ClassPathResource(body)).retrieve().toBodilessEntity();
		log.info("GeoServer featuretype {} created", name);
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
