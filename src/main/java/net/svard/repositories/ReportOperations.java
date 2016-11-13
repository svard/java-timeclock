package net.svard.repositories;

import net.svard.domain.Report;
import net.svard.domain.Statistic;

import java.util.List;

public interface ReportOperations {
    List<Report> findByYear(int year);
    List<Report> findByWeek(int week);
    List<Report> findByYearAndWeek(int year, int week);
    List<Statistic> stats();
}
