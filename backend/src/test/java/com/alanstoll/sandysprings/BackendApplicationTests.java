package com.alanstoll.sandysprings;

import java.time.LocalDate;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.simple.JdbcClient;

import static org.assertj.core.api.Assertions.assertThat;

@Import(TestcontainersConfiguration.class)
@SpringBootTest
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

}
