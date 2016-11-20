package net.svard.controllers;

import net.svard.repositories.ReportRepository;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.setup.MockMvcBuilders.standaloneSetup;

@RunWith(SpringRunner.class)
@SpringBootApplication
public class StatisticsControllerTest {
    @MockBean
    private ReportRepository reportRepository;

    @Autowired
    private StatisticsController controller;

    private MockMvc mockMvc;

    @Before
    public void setUp() {
        mockMvc = standaloneSetup(controller).build();
    }

    @Test
    public void testStatisticsQuery() throws Exception {
        mockMvc.perform(get("/api/statistics"));

        Mockito.verify(reportRepository).stats();
    }
}
