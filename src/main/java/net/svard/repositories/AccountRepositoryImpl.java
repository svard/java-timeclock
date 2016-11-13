package net.svard.repositories;

import net.svard.domain.Account;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

public class AccountRepositoryImpl implements AccountOperations {

    @Autowired
    private MongoTemplate mongoTemplate;

    @Override
    public Account findOneByUsername(String username) {
        Criteria where = Criteria.where("username").is(username);
        Query query = Query.query(where);

        return mongoTemplate.findOne(query, Account.class);
    }
}
