package net.svard.repositories;

import net.svard.domain.Account;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Component;

@Component
public interface AccountRepository extends MongoRepository<Account, String>, AccountOperations {

}
