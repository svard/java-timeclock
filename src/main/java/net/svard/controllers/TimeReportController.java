package net.svard.controllers;

import lombok.extern.slf4j.Slf4j;
import net.svard.domain.ClientReport;
import net.svard.domain.Report;
import net.svard.exceptions.ReportNotFoundException;
import net.svard.repositories.ReportRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.Date;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/timereport")
public class TimeReportController {

    private ReportRepository reportRepository;

    @Autowired
    public TimeReportController(ReportRepository reportRepository) {
        this.reportRepository = reportRepository;
    }

    @RequestMapping(method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
    public List<Report> getReports(
            @RequestParam(value = "week", defaultValue = "0") int week,
            @RequestParam(value = "year", defaultValue = "0") int year) {

        List<Report> reports;

        if (year > 0 && week > 0) {
            reports = reportRepository.findByYearAndWeek(year, week);
        } else if (year > 0) {
            reports = reportRepository.findByYear(year);
        } else if (week > 0) {
            reports = reportRepository.findByWeek(week);
        } else {
            reports = reportRepository.findAll();
        }

        return reports;
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
    public Report getOneReport(@PathVariable("id") String id) {
        Report report = reportRepository.findOne(id);

        if (report == null) {
            throw new ReportNotFoundException(id);
        }

        return report;
    }

    @RequestMapping(method = RequestMethod.POST, consumes = MediaType.APPLICATION_JSON_UTF8_VALUE)
    public ResponseEntity<Void> insertReport(@RequestBody ClientReport clientReport) {
        log.info("Client posted report {}", clientReport.toString());

        Report report = new Report();
        report.setArrival(new Date(clientReport.getArrivalTime()));
        report.setLeave(new Date(clientReport.getLeaveTime()));
        report.setLunch(clientReport.getLunchTime());
        report.setTotal(clientReport.getWorkTime());

        Report insertedReport = reportRepository.insert(report);

        log.info("Inserted new report {}", insertedReport.toString());

        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}").buildAndExpand(insertedReport.getId()).toUri();

        return ResponseEntity.created(location).build();
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.PUT, consumes = MediaType.APPLICATION_JSON_UTF8_VALUE)
    public void updateReport(@PathVariable("id") String id, @RequestBody Report report) {
        Report existingReport = reportRepository.findOne(id);

        if (existingReport == null) {
            throw new ReportNotFoundException(id);
        }

        log.info("Updating report id {}", id);

        report.setId(id);
        reportRepository.save(report);
    }

    @ExceptionHandler(ReportNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public String reportNotFound(ReportNotFoundException e) {
        return "Report " + e.getId() + " not found";
    }
}
