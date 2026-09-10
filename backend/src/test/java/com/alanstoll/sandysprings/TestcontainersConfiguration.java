package com.alanstoll.sandysprings;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;
import org.testcontainers.utility.MountableFile;

@TestConfiguration(proxyBeanMethods = false)
class TestcontainersConfiguration {

	@Bean
	@ServiceConnection
	PostgreSQLContainer postgresContainer() {
		return new PostgreSQLContainer(DockerImageName.parse("postgis/postgis:18-3.6").asCompatibleSubstituteFor("postgres"))
				// the migration grants to the geoserver role, which Postgres init creates, not Flyway
				.withCopyFileToContainer(MountableFile.forHostPath("../db/init/01-roles.sql"), "/docker-entrypoint-initdb.d/01-roles.sql")
				// after the image's own 10_postgis.sh, so the geometry type exists
				.withCopyFileToContainer(MountableFile.forClasspathResource("staging-fixture.sql"), "/docker-entrypoint-initdb.d/20-staging.sql");
	}

}
