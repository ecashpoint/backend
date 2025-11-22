package de.ecashpoint.users.repository;

import de.ecashpoint.users.entity.Inventario;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class InventarioRepository implements PanacheRepository<Inventario> {

    public Integer getStockByItem(Long itemId) {
        return find("item.id", itemId)
                .firstResultOptional()
                .map(i -> i.stockActual)
                .orElse(null);
    }
}
