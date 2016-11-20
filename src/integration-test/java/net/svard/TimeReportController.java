package net.svard;

import net.svard.domain.ClientReport;
import net.svard.domain.Report;
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
public class TimeReportController {

    @Value("${local.server.port}")
    private int port;

    @Autowired
    private ReportRepository reportRepository;

    private RestTemplate rest = new RestTemplate();
    private List<Report> allReports;
    private List<Report> week45;
    private List<Report> week46;

    @Before
    public void setUp() {
        reportRepository.deleteAll();
        allReports = new ArrayList<>();
        week45 = new ArrayList<>();
        week46 = new ArrayList<>();
        populateRepository();
    }

    @Test
    public void postReport() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        ClientReport body = new ClientReport();
        body.setWorkTime(27989);
        body.setLunchTime(3600);
        body.setArrivalTime(1479452348000L);
        body.setLeaveTime(1479483937000L);
        HttpEntity<ClientReport> entity = new HttpEntity<>(body, headers);

        ResponseEntity<String> response = rest.postForEntity("http://localhost:{port}/api/timereport", entity, String.class, port);
        String id = getLastPathSegment(response.getHeaders().getLocation().getPath());

        Assert.assertEquals(response.getStatusCodeValue(), HttpStatus.CREATED.value());
        Assert.assertNotNull(reportRepository.findOne(id));
    }

    @Test
    public void getReports() {
        HttpHeaders headers = authorizeHeader();
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<List<Report>> response = rest.exchange("http://localhost:{port}/api/timereport", HttpMethod.GET, entity, new ParameterizedTypeReference<List<Report>>() {}, port);
        Assert.assertEquals(response.getStatusCodeValue(), HttpStatus.OK.value());
        Assert.assertTrue("All reports returned should exist in the database", response.getBody().containsAll(allReports));
        Assert.assertTrue("All reports in the database should be in the response", allReports.containsAll(response.getBody()));
    }

    @Test
    public void getOneReport() {
        String id = allReports.get(3).getId();
        HttpHeaders headers = authorizeHeader();
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<Report> response = rest.exchange("http://localhost:{port}/api/timereport/{id}", HttpMethod.GET, entity, Report.class, port, id);
        Assert.assertEquals(response.getStatusCodeValue(), HttpStatus.OK.value());
        Assert.assertEquals(response.getBody(), allReports.get(3));
    }

    @Test
    public void getReportsPerWeek() {
        HttpHeaders headers = authorizeHeader();
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<List<Report>> response = rest.exchange("http://localhost:{port}/api/timereport?year=2016&week=45", HttpMethod.GET, entity, new ParameterizedTypeReference<List<Report>>() {}, port);
        Assert.assertEquals(response.getStatusCodeValue(), HttpStatus.OK.value());
        Assert.assertTrue("All reports returned should exist in the database", response.getBody().containsAll(week45));
        Assert.assertTrue("All reports for the requested week should be in the response", week45.containsAll(response.getBody()));
    }

    @Test
    public void getReportsPerYear() {
        HttpHeaders headers = authorizeHeader();
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<List<Report>> response = rest.exchange("http://localhost:{port}/api/timereport?year=2016", HttpMethod.GET, entity, new ParameterizedTypeReference<List<Report>>() {}, port);
        Assert.assertEquals(response.getStatusCodeValue(), HttpStatus.OK.value());
        Assert.assertTrue("All reports returned should exist in the database", response.getBody().containsAll(allReports));
        Assert.assertTrue("All reports for the requested week should be in the response", allReports.containsAll(response.getBody()));
    }

    @Test
    public void updateReport() {
        String id = allReports.get(0).getId();
        Report report = new Report();
        report.setArrival(new Date(1478501763000L));
        report.setLeave(new Date(1467906953000L));
        report.setLunch(3600);
        report.setTotal(28680);
        HttpHeaders headers = authorizeHeader();
        HttpEntity<Report> entity = new HttpEntity<>(report, headers);

        Report originalReport = reportRepository.findOne(id);
        Assert.assertNotSame(report, originalReport);

        rest.put("http://localhost:{port}/api/timereport/{id}", entity, port, id);

        Report updatedReport = reportRepository.findOne(id);
        Assert.assertEquals(report, updatedReport);
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
        week45.add(report);
        reportRepository.save(report);

        report = new Report();
        report.setArrival(new Date(1478674513000L));
        report.setLeave(new Date(1478705731000L));
        report.setLunch(3600);
        report.setTotal(27618);
        allReports.add(report);
        week45.add(report);
        reportRepository.save(report);

        report = new Report();
        report.setArrival(new Date(1479365724000L));
        report.setLeave(new Date(1479396923000L));
        report.setLunch(3600);
        report.setTotal(27599);
        allReports.add(report);
        week46.add(report);
        reportRepository.save(report);

        report = new Report();
        report.setArrival(new Date(1479279351000L));
        report.setLeave(new Date(1479311714000L));
        report.setLunch(3600);
        report.setTotal(28763);
        allReports.add(report);
        week46.add(report);
        reportRepository.save(report);

        report = new Report();
        report.setArrival(new Date(1479106519000L));
        report.setLeave(new Date(1479139806000L));
        report.setLunch(3600);
        report.setTotal(29687);
        allReports.add(report);
        week46.add(report);
        reportRepository.save(report);
    }

    private String getLastPathSegment(String url) {
        return url.replaceFirst(".*/([^/?]+).*", "$1");
    }
}
