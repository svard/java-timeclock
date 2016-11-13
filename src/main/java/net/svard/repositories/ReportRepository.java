package net.svard.repositories;

import net.svard.domain.Report;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Component;

@Component
public interface ReportRepository extends MongoRepository<Report, String>, ReportOperations {

}
