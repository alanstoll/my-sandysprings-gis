package com.alanstoll.sandysprings;

import java.time.LocalDate;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.simple.JdbcClient;

import static org.assertj.core.api.Assertions.assertThat;

@Import(TestcontainersConfiguration.class)
// Flyway and the transforms are what these assert on; publishing to GeoServer is a startup side
// effect that would need a live one, and would rewrite it from whatever the fixture happens to say.
@SpringBootTest(properties = "sandysprings.geoserver.publish=false")
class BackendApplicationTests {

	@Autowired
	private JdbcClient jdbc;

	@Test
	void contextLoads() {
	}

	@Test
	void transformsStagingIntoGis() {
		assertThat(jdbc.sql("select name from gis.city_limit").query(String.class).single())
			.isEqualTo("Sandy Springs");
		assertThat(jdbc.sql("select effective_date from gis.city_limit").query(LocalDate.class).single())
			.isEqualTo(LocalDate.of(2005, 11, 30));
	}

	@Test
	void transformsFloodZones() {
		assertThat(jdbc.sql("select zone from gis.flood_zone where sfha").query(String.class).list())
			.containsExactlyInAnyOrder("AE", "AE", "A");
		// the NFHL leaves a zone without a subtype empty, not null, once ogr2ogr has loaded it
		assertThat(jdbc.sql("select count(*) from gis.flood_zone where subtype is null").query(Long.class).single())
			.isEqualTo(2);
	}

	@Test
	void ranksBlockGroupsByPredominantCategory() {
		assertThat(jdbc.sql("select predominant from gis.acs_bg order by geoid").query(String.class).list())
			.containsExactly("white", "black", "hispanic");
		// the survey can separate 800 from 100, but not 400 from 380 once their margins are combined
		assertThat(jdbc.sql("select geoid from gis.acs_bg where ambiguous").query(String.class).single())
			.isEqualTo("130890000012");
		assertThat(jdbc.sql("select runner_up from gis.acs_bg where ambiguous").query(String.class).single())
			.isEqualTo("white");
	}

	@Test
	void derivesSharesFromAgeAndVehicleCounts() {
		// the fixture's first block group is 12 bands of 25 over 65 and 8 of 25 under 18, of 1000
		assertThat(jdbc.sql("select age_65_plus from gis.acs_bg where geoid = '130890000011'")
			.query(Double.class).single()).isEqualTo(30.0);
		assertThat(jdbc.sql("select age_under_18 from gis.acs_bg where geoid = '130890000011'")
			.query(Double.class).single()).isEqualTo(20.0);
		// households with no vehicle is owners plus renters, 40 of 400
		assertThat(jdbc.sql("select no_vehicle from gis.acs_bg where geoid = '130890000011'")
			.query(Double.class).single()).isEqualTo(10.0);
	}

	@Test
	void turnsSuppressedMediansIntoNulls() {
		assertThat(jdbc.sql("select income from gis.acs_tract where geoid = '13089000001'")
			.query(Integer.class).single()).isEqualTo(120000);
		// the ACS writes an unavailable median as -666666666, which must not reach the map as a value
		assertThat(jdbc.sql("select count(*) from gis.acs_tract where geoid = '13089000002'"
				+ " and income is null and home_value is null and gross_rent is null")
			.query(Long.class).single()).isEqualTo(1);
	}

	@Test
	void splitsCommuteModesThatSumToTheWhole() {
		assertThat(jdbc.sql("select drove_alone from gis.acs_tract where geoid = '13089000001'")
			.query(Double.class).single()).isEqualTo(60.0);
		assertThat(jdbc.sql("select worked_at_home from gis.acs_tract where geoid = '13089000001'")
			.query(Double.class).single()).isEqualTo(10.0);
		// not driving alone is the complement, and the seven modes account for every commuter
		assertThat(jdbc.sql("select not_drove_alone from gis.acs_tract where geoid = '13089000001'")
			.query(Double.class).single()).isEqualTo(40.0);
		assertThat(jdbc
			.sql("select count(*) from gis.acs_tract where abs(drove_alone + carpooled + transit"
					+ " + walked + bicycle + other_mode + worked_at_home - 100) > 0.01")
			.query(Long.class).single()).isZero();
	}

	@Test
	void keepsParcelsWithoutAnAcreageOrAUnitCount() {
		assertThat(jdbc.sql("select count(*) from gis.tax_parcel").query(Long.class).single()).isEqualTo(3);
		// the assessor leaves both blank on an unbuilt lot, which must not become a zero on the map
		assertThat(jdbc.sql("select count(*) from gis.tax_parcel where acres is null and living_units is null")
			.query(Long.class).single()).isEqualTo(1);
		assertThat(jdbc.sql("select living_units from gis.tax_parcel where parcel_id = '17 010000010001'")
			.query(Integer.class).single()).isEqualTo(242);
	}

}
