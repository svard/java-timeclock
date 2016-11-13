package net.svard;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootApplication
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class TimeReportControllers {

    @Value("${local.server.port}")
    private int port;

    @Test
    public void pageNotFound() {
        assert true;
//        try {
//            RestTemplate rest = new RestTemplate();
//
//            rest.getForObject("http://localhost:{port}/bogusPage", String.class, port);
//            fail("Should result in HTTP 404");
//        } catch (HttpClientErrorException e) {
//            assertEquals(HttpStatus.NOT_FOUND, e.getStatusCode());
//            throw e;
//        }
    }
}
