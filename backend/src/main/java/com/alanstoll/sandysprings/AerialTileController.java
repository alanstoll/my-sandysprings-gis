package com.alanstoll.sandysprings;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.concurrent.Semaphore;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClient;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.http.HttpStatus.NOT_FOUND;

/**
 * Serves USGS NAIP aerial imagery as web mercator tiles, keeping every tile it fetches on disk so
 * the second visit to an area costs nothing. The imagery itself is far too large to hold: the
 * city's own 2025 orthophotos run to half a terabyte, and NAIP covers the country. Caching what
 * gets looked at is the difference between an unusable layer and a free one.
 *
 * NAIP is an ArcGIS image service with no WMS endpoint and no tile cache of its own, so GeoServer
 * cannot cascade it and GeoWebCache has nothing to wrap. What it does have is exportImage, which
 * takes a bounding box and a size, and that is all a tile is.
 */
@RestController
class AerialTileController {

	private static final Logger log = LoggerFactory.getLogger(AerialTileController.class);

	/** Half the circumference in web mercator metres; the projection's world runs -this to +this. */
	private static final double EDGE = 20037508.342789244;

	private static final int TILE = 256;

	/**
	 * NAIP's pixel is 30 cm and z19 is 29.9 cm, so this is where asking for more stops buying more.
	 * The frontend still overzooms past it; that upsamples a tile already on disk rather than
	 * fetching four times as many that carry no further detail.
	 */
	private static final int MAX_ZOOM = 19;

	/** Below this a tile spans kilometres, which the basemap already covers better than imagery. */
	private static final int MIN_ZOOM = 12;

	/**
	 * Keeps the map's dozens of parallel tile requests from arriving at a public service all at
	 * once. It also bounds how fast the cache can fill, which is the polite half of the same coin.
	 */
	private final Semaphore upstream = new Semaphore(6);

	private final RestClient rest;

	private final Path cache;

	private final String service;

	AerialTileController(RestClient.Builder builder,
			@Value("${sandysprings.aerial.url}") String service,
			// A String, not a Path: Spring reads a Path property as a resource path and rejects the
			// ".." that points this out of the backend module and into data/
			@Value("${sandysprings.aerial.cache}") String cache) {
		this.service = service;
		this.cache = Path.of(cache);
		this.rest = builder.build();
	}

	@GetMapping(value = "/api/aerial/{z}/{x}/{y}.jpg", produces = MediaType.IMAGE_JPEG_VALUE)
	ResponseEntity<byte[]> tile(@PathVariable int z, @PathVariable int x, @PathVariable int y)
			throws IOException, InterruptedException {
		if (z < MIN_ZOOM || z > MAX_ZOOM) {
			throw new ResponseStatusException(NOT_FOUND, "zoom outside " + MIN_ZOOM + ".." + MAX_ZOOM);
		}
		int side = 1 << z;
		if (x < 0 || y < 0 || x >= side || y >= side) {
			throw new ResponseStatusException(NOT_FOUND, "tile outside the world at this zoom");
		}
		// Built from the path as three ints, so nothing a caller sends can walk out of the directory
		Path file = cache.resolve(z + "/" + x + "/" + y + ".jpg");
		if (Files.isRegularFile(file)) {
			return respond(Files.readAllBytes(file));
		}
		byte[] image = fetch(z, x, y);
		Files.createDirectories(file.getParent());
		// Write beside the target and move, so a killed process cannot leave a half tile that every
		// later request would then serve as if it were real
		Path partial = Files.createTempFile(file.getParent(), "tile", ".part");
		Files.write(partial, image);
		Files.move(partial, file, StandardCopyOption.REPLACE_EXISTING);
		return respond(image);
	}

	private byte[] fetch(int z, int x, int y) throws InterruptedException {
		double span = 2 * EDGE / (1 << z);
		double west = -EDGE + x * span;
		// y counts down from the north in this tile scheme, the opposite of the projection's axis
		double north = EDGE - y * span;
		String bbox = "%f,%f,%f,%f".formatted(west, north - span, west + span, north);
		upstream.acquire();
		try {
			byte[] image = rest.get()
				.uri(service + "/exportImage?bbox={bbox}&bboxSR=3857&imageSR=3857&size={t},{t}"
						+ "&format=jpg&f=image", bbox, TILE, TILE)
				.retrieve()
				.body(byte[].class);
			if (image == null || image.length == 0) {
				throw new ResponseStatusException(NOT_FOUND, "no imagery for this tile");
			}
			log.debug("aerial {}/{}/{} fetched, {} bytes", z, x, y, image.length);
			return image;
		}
		finally {
			upstream.release();
		}
	}

	private ResponseEntity<byte[]> respond(byte[] image) {
		// The imagery is a fixed 2025 survey, so the browser may keep it as long as it likes and
		// spare both this cache and the service the question
		return ResponseEntity.ok()
			.cacheControl(CacheControl.maxAge(java.time.Duration.ofDays(30)).cachePublic())
			.contentType(MediaType.IMAGE_JPEG)
			.body(image);
	}

}
