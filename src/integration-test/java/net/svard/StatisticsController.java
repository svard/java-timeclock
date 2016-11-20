package net.svard;

import net.svard.domain.Report;
import net.svard.domain.Statistic;
import net.svard.repositories.ReportRepository;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.List;

@ActiveProfiles("integration-test")
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class StatisticsController {

    @Value("${local.server.port}")
    private int port;

    @Autowired
    private ReportRepository reportRepository;

    private RestTemplate rest = new RestTemplate();

    private List<Report> allReports;

    @Before
    public void setUp() {
        reportRepository.deleteAll();
        allReports = new ArrayList<>();
        populateRepository();
    }

    @Test
    public void getStatistics() {
        HttpHeaders headers = authorizeHeader();
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<List<Statistic>> response = rest.exchange("http://localhost:{port}/api/statistics", HttpMethod.GET, entity, new ParameterizedTypeReference<List<Statistic>>() {}, port);
        Assert.assertEquals(response.getStatusCodeValue(), HttpStatus.OK.value());
        Assert.assertEquals(response.getBody().get(0).getSum(), allReports.stream().mapToLong(Report::getTotal).sum());
    }

    private HttpHeaders authorizeHeader() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.add("Authorization", "Basic " + Base64.getEncoder().encodeToString("user:secret".getBytes()));

        return headers;
    }

    private void populateRepository() {
        Report report = new Report();
        report.setArrival(new Date(1478501763000L));
        report.setLeave(new Date(1478533253000L));
        report.setLunch(3600);
        report.setTotal(27780);
        allReports.add(report);
        reportRepository.save(report);

        report = new Report();
        report.setArrival(new Date(1478674513000L));
        report.setLeave(new Date(1478705731000L));
        report.setLunch(3600);
        report.setTotal(27618);
        allReports.add(report);
        reportRepository.save(report);

        report = new Report();
        report.setArrival(new Date(1479365724000L));
        report.setLeave(new Date(1479396923000L));
        report.setLunch(3600);
        report.setTotal(27599);
        allReports.add(report);
        reportRepository.save(report);

        report = new Report();
        report.setArrival(new Date(1479279351000L));
        report.setLeave(new Date(1479311714000L));
        report.setLunch(3600);
        report.setTotal(28763);
        allReports.add(report);
        reportRepository.save(report);

        report = new Report();
        report.setArrival(new Date(1479106519000L));
        report.setLeave(new Date(1479139806000L));
        report.setLunch(3600);
        report.setTotal(29687);
        allReports.add(report);
        reportRepository.save(report);
    }

}
