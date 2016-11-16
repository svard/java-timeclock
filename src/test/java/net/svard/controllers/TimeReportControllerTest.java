package net.svard.controllers;

import net.svard.domain.Report;
import net.svard.repositories.ReportRepository;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.setup.MockMvcBuilders.standaloneSetup;

@RunWith(SpringRunner.class)
@SpringBootApplication
@WebAppConfiguration
public class TimeReportControllerTest {
    @MockBean
    private ReportRepository reportRepository;
    @Autowired
    private TimeReportController controller;

    private MockMvc mockMvc;

    @Before
    public void setUp() {
        mockMvc = standaloneSetup(controller).build();
    }

    @Test
    public void testTimereportQueryYearAndWeek() throws Exception {
        mockMvc.perform(get("/api/timereport?year=2016&week=42"));

        Mockito.verify(reportRepository).findByYearAndWeek(2016, 42);
    }

    @Test
    public void testTimereportQueryYear() throws Exception {
        mockMvc.perform(get("/api/timereport?year=2015"));

        Mockito.verify(reportRepository).findByYear(2015);
    }

    @Test
    public void testTimereportQueryWeek() throws Exception {
        mockMvc.perform(get("/api/timereport?week=42"));

        Mockito.verify(reportRepository).findByWeek(42);
    }

    @Test
    public void testTimereport() throws Exception {
        mockMvc.perform(get("/api/timereport"));

        Mockito.verify(reportRepository).findAll();
    }

    @Test
    public void testGetOneReport() throws Exception {
        mockMvc.perform(get("/api/timereport/53f23f852cdc8826c1a2d8aa"));

        Mockito.verify(reportRepository).findOne("53f23f852cdc8826c1a2d8aa");
    }

    @Test
    public void testInsertReport() throws Exception {
        Report report = new Report();
        report.setArrival(new Date(1408340911000L));
        report.setLeave(new Date(1408373403000L));
        report.setLunch(3600);
        report.setTotal(28892);

        Report insertedReport = new Report();
        insertedReport.setId("123");

        Mockito.when(reportRepository.insert(Mockito.any(Report.class))).thenReturn(insertedReport);

        mockMvc.perform(
                post("/api/timereport")
                        .contentType(MediaType.APPLICATION_JSON_UTF8)
                        .content("{\"workTime\":28892,\"lunchTime\":3600,\"arrivalTime\":1408340911000,\"leaveTime\":1408373403000}"))
        .andExpect(status().isCreated());

        Mockito.verify(reportRepository).insert(report);
    }

    @Test
    public void testUpdateNonExistingReport() throws Exception {
        Mockito.when(reportRepository.findOne(Mockito.anyString())).thenReturn(null);

        mockMvc.perform(put("/api/timereport/53f23f852cdc8826c1a2d8aa"))
                .andExpect(status().is4xxClientError());
    }

    @Test
    public void testUpdateReport() throws Exception {
        Report report = new Report();
        report.setId("53f23f852cdc8826c1a2d8aa");
        report.setArrival(new Date(1408340911000L));
        report.setLeave(new Date(1408373403000L));
        report.setLunch(3600);
        report.setTotal(28892);

        Mockito.when(reportRepository.findOne(Mockito.anyString())).thenReturn(new Report());

        mockMvc.perform(put("/api/timereport/53f23f852cdc8826c1a2d8aa")
                .contentType(MediaType.APPLICATION_JSON_UTF8)
                .content("{\"total\":28892,\"lunch\":3600,\"arrival\":1408340911000,\"leave\":1408373403000}"));

        Mockito.verify(reportRepository).save(report);
    }

    @Test
    public void testTimereportModel() throws Exception {
        List<Report> reports = createReports();
        Mockito.when(reportRepository.findAll()).thenReturn(reports);

        mockMvc.perform(get("/api/timereport"))
                .andExpect(status().is2xxSuccessful())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8));
    }

    private List<Report> createReports() {
        List<Report> reports = new ArrayList<>();
        Report report = new Report();
        report.setTotal(10000);
        report.setLunch(3600);
        reports.add(report);

        return reports;
    }
}
