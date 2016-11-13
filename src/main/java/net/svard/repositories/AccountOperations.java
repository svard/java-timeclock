package net.svard.repositories;

import net.svard.domain.Account;

public interface AccountOperations {
    Account findOneByUsername(String username);
}
