package net.svard.repositories;

import net.svard.domain.Report;
import net.svard.domain.Statistic;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationResults;
import org.springframework.data.mongodb.core.query.Criteria;

import java.util.List;

public class ReportRepositoryImpl implements ReportOperations {

    @Autowired
    private MongoTemplate mongoTemplate;

    @Override
    public List<Report> findByYear(int year) {
        Aggregation agg = Aggregation.newAggregation(
                Aggregation.project("total", "arrival", "leave", "lunch")
                        .andExpression("year(arrival)").as("year"),
                Aggregation.match(Criteria.where("year").is(year)),
                Aggregation.project("total", "arrival", "leave", "lunch"),
                Aggregation.sort(Sort.Direction.ASC, "arrival")
        );

        AggregationResults<Report> result = mongoTemplate.aggregate(agg, "reports", Report.class);

        return result.getMappedResults();
    }

    @Override
    public List<Report> findByWeek(int week) {
        Aggregation agg = Aggregation.newAggregation(
                Aggregation.project("total", "arrival", "leave", "lunch")
                        .andExpression("week(arrival)").as("week"),
                Aggregation.match(Criteria.where("week").is(week)),
                Aggregation.project("total", "arrival", "leave", "lunch"),
                Aggregation.sort(Sort.Direction.ASC, "arrival")
        );

        AggregationResults<Report> result = mongoTemplate.aggregate(agg, "reports", Report.class);

        return result.getMappedResults();
    }

    @Override
    public List<Report> findByYearAndWeek(int year, int week) {
        Aggregation agg = Aggregation.newAggregation(
                Aggregation.project("total", "arrival", "leave", "lunch")
                        .andExpression("year(arrival)").as("year")
                        .andExpression("week(arrival)").as("week"),
                Aggregation.match(Criteria.where("year").is(year).and("week").is(week)),
                Aggregation.project("total", "arrival", "leave", "lunch"),
                Aggregation.sort(Sort.Direction.ASC, "arrival")
        );

        AggregationResults<Report> result = mongoTemplate.aggregate(agg, "reports", Report.class);

        return result.getMappedResults();
    }

    @Override
    public List<Statistic> stats() {
        Aggregation agg = Aggregation.newAggregation(
                Aggregation.project("total", "arrival").andExpression("year(arrival)").as("year"),
                Aggregation.sort(Sort.Direction.ASC, "total"),
                Aggregation.group("year")
                        .sum("total").as("sum")
                        .avg("total").as("avg")
                        .max("total").as("longestTime")
                        .min("total").as("shortestTime")
                        .first("arrival").as("shortestDate")
                        .last("arrival").as("longestDate"),
                Aggregation.project("_id", "sum", "avg", "shortestDate", "shortestTime", "longestDate", "longestTime"),
                Aggregation.sort(Sort.Direction.ASC, "_id")
        );

        AggregationResults<Statistic> result = mongoTemplate.aggregate(agg, "reports", Statistic.class);

        return result.getMappedResults();
    }
}
