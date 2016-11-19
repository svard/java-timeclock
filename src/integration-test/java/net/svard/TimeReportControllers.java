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
import org.springframework.context.annotation.Configuration;
import org.springframework.http.*;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.web.client.RestTemplate;

import java.util.Date;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class TimeReportControllers {

    @Value("${local.server.port}")
    private int port;

    @Autowired
    private ReportRepository reportRepository;

    @Before
    public void setUp() {
        reportRepository.deleteAll();
        populateRepository();
    }

    @Test
    public void postReport() {
        RestTemplate rest = new RestTemplate();
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

        Assert.assertEquals(response.getStatusCodeValue(), 201);
        Assert.assertNotNull(reportRepository.findOne(id));
    }

    private void populateRepository() {
        Report day1 = new Report();
        day1.setArrival(new Date(1479365724000L));
        day1.setLeave(new Date(1479396923000L));
        day1.setLunch(3600);
        day1.setTotal(27599);

        Report day2 = new Report();
        day2.setArrival(new Date(1479279351000L));
        day2.setLeave(new Date(1479311714000L));
        day2.setLunch(3600);
        day2.setTotal(28763);

        Report day3 = new Report();
        day3.setArrival(new Date(1479106519000L));
        day3.setLeave(new Date(1479139806000L));
        day3.setLunch(3600);
        day3.setTotal(29687);

        reportRepository.save(day1);
        reportRepository.save(day2);
        reportRepository.save(day3);
    }

    private String getLastPathSegment(String url) {
        return url.replaceFirst(".*/([^/?]+).*", "$1");
    }

    @Configuration
    @EnableWebSecurity
    private class TestSecurityConfig extends WebSecurityConfigurerAdapter {
        @Override
        protected void configure(AuthenticationManagerBuilder auth) throws Exception {
            auth.inMemoryAuthentication().withUser("user").password("secret").roles("USER");
        }

        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http.authorizeRequests()
                    .antMatchers(HttpMethod.POST, "/api/timereport")
                        .permitAll()
                    .anyRequest()
                        .authenticated()
                        .and()
                    .formLogin()
                        .loginPage("/login")
                        .permitAll()
                        .and()
                    .logout()
                        .logoutRequestMatcher(new AntPathRequestMatcher("/logout"))
                        .and()
                    .csrf()
                        .disable();
        }
    }
}
