package de.ecashpoint.users.repository;

import java.util.Optional;

import de.ecashpoint.users.entity.User;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class UserRepository implements PanacheRepository<User> {

    
    public Optional<User> findByEmail(String email) {
        return find("email", email).firstResultOptional();
    }
    
    
    public boolean existsByEmail(String email) {
        return count("email", email) > 0;
    }

    public boolean existByPhone(String phone){
        return count("phone" , phone) > 0;
    }

    public boolean existByDocument(String document){
        return count("document" , document) > 0;
    }


    
}
