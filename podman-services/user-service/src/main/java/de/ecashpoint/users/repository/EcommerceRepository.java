package de.ecashpoint.users.repository;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import de.ecashpoint.users.entity.Ecommerce;
import io.quarkus.hibernate.orm.panache.PanacheQuery;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class EcommerceRepository implements PanacheRepository<Ecommerce> {

    public List<Ecommerce> findByAuthId(String authId) {
        return (List<Ecommerce>) find("authId", authId);
    }

    public PanacheQuery<Ecommerce> findByFilters(String authId, String name, String email, String status , Sort sort) {
        PanacheQuery<Ecommerce> query;
        Map<String, Object> params = new HashMap<>();

        List<String> conditions = new ArrayList<>();

        if (authId != null && !authId.isEmpty()) {
            conditions.add("authId = :authId");
            params.put("authId", authId);
        }
        if (name != null && !name.isEmpty()) {
            conditions.add("ecommerce_name LIKE :name");
            params.put("name", "%" + name + "%");
        }
        if (email != null && !email.isEmpty()) {
            conditions.add("ecommerce_email LIKE :email");
            params.put("email", "%" + email + "%");
        }
        if (status != null && !status.isEmpty()) {
            conditions.add("ecommerce_status = :status");
            params.put("status", Boolean.parseBoolean(status));
        }

        if (conditions.isEmpty()) {
            query = findAll(sort);
        } else {
            String whereClause = String.join(" AND ", conditions);
            query = Ecommerce.find(whereClause, sort ,params);
        }

        return query;
    }

    public long countByFilters(String authId, String name, String email, String status) {
        Map<String, Object> params = new HashMap<>();
        List<String> conditions = new ArrayList<>();

        if (authId != null && !authId.isEmpty()) {
            conditions.add("authId = :authId");
            params.put("authId", authId);
        }
        if (name != null && !name.isEmpty()) {
            conditions.add("ecommerce_name LIKE :name");
            params.put("name", "%" + name + "%");
        }
        if (email != null && !email.isEmpty()) {
            conditions.add("ecommerce_email LIKE :email");
            params.put("email", "%" + email + "%");
        }
        if (status != null && !status.isEmpty()) {
            conditions.add("ecommerce_status = :status");
            params.put("status", Boolean.parseBoolean(status));
        }

        if (conditions.isEmpty()) {
            return count();
        } else {
            String whereClause = String.join(" AND ", conditions);
            return Ecommerce.count(whereClause, params);
        }
    }
}
