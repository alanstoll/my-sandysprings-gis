package com.alanstoll.sandysprings;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Rebuilds the gis tables from the staging tables that `gradlew ingestData` loads with ogr2ogr.
 * Runs before GeoServerPublisher, which computes a layer's bounding box by querying its table.
 */
@Component
@Order(1)
class StagingTransformer implements ApplicationRunner {

	private static final Logger log = LoggerFactory.getLogger(StagingTransformer.class);

	private final JdbcTemplate jdbc;

	StagingTransformer(JdbcTemplate jdbc) {
		this.jdbc = jdbc;
	}

	@Override
	public void run(ApplicationArguments args) throws IOException {
		transform("city_limit", "transform/city-limit.sql");
		transform("flood_zone", "transform/flood-zone.sql");
		transform("acs_bg", "transform/acs-bg.sql");
		transform("acs_tract", "transform/acs-tract.sql");
		transform("tax_parcel", "transform/tax-parcel.sql");
		// built from gis.city_limit above rather than from staging, so it goes last
		transform("city_limit_inhouse", "transform/city-limit-inhouse.sql");
	}

	private void transform(String table, String script) throws IOException {
		// One statement so the truncate and the insert share a transaction
		jdbc.execute(new ClassPathResource(script).getContentAsString(StandardCharsets.UTF_8));
		log.info("gis.{} rebuilt, {} rows", table,
				jdbc.queryForObject("select count(*) from gis." + table, Long.class));
	}

}
