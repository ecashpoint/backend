package de.ecashpoint.users.repository;

import java.util.List; 

import de.ecashpoint.users.entity.Ecommerce;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class EcommerceRepository implements PanacheRepository<Ecommerce>{
    
    public List<Ecommerce> findByAuthId(String authId){
        return (List<Ecommerce>) find("authId", authId);
    }
}
