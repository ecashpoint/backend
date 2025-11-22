package de.ecashpoint.users.repository;
 

import de.ecashpoint.users.entity.Category;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CategoryRepository implements PanacheRepository<Category>{
    
    public boolean existByCategory(String category) {
        return count("category", category) > 0;
    }
}
