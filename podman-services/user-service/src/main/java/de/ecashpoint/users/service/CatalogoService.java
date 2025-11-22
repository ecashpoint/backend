package de.ecashpoint.users.service;

import java.util.List;

import de.ecashpoint.users.entity.Item;
import de.ecashpoint.users.entity.ItemConfiguratedEcommerce;
import de.ecashpoint.users.repository.InventarioRepository;
import de.ecashpoint.users.repository.ItemConfigEcommerceRepository;
import de.ecashpoint.users.service.Dto.ItemDto;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

@ApplicationScoped
public class CatalogoService {

    @Inject
    ItemConfigEcommerceRepository cfgRepo;

    @Inject
    InventarioRepository invRepo;

    public List<ItemDto> obtenerCatalogo(Long ecommerceId) {

        List<ItemConfiguratedEcommerce> configs =   cfgRepo.findVisibleByEcommerce(ecommerceId);

        return configs.stream()
        .<ItemDto>map(cfg -> {

            Item item = cfg.item;

            Double precio = cfg.precioPersonalizado != null
                    ? cfg.precioPersonalizado
                    : item.precioBase;

            Integer stock = null;

            if (item.tipo == Item.TipoItem.PRODUCTO) {
                stock = cfg.stockPersonalizado != null
                        ? cfg.stockPersonalizado
                        : invRepo.getStockByItem(item.id);
            }

            return new ItemDto(item, precio, stock);

        }).toList();
    }
}
