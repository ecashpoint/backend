package de.ecashpoint.users.repository;

import java.util.List;

import de.ecashpoint.users.entity.ItemConfiguratedEcommerce;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ItemConfigEcommerceRepository implements PanacheRepository<ItemConfiguratedEcommerce> {

    public List<ItemConfiguratedEcommerce> findVisibleByEcommerce(Long ecommerceId) {
        return find("ecommerce.id = ?1 and visible = true", ecommerceId).list();
    }
}

