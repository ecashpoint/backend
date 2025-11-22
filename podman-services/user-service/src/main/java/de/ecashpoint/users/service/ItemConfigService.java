package de.ecashpoint.users.service;

import de.ecashpoint.users.entity.Ecommerce;
import de.ecashpoint.users.entity.Item;
import de.ecashpoint.users.entity.ItemConfiguratedEcommerce;
import de.ecashpoint.users.repository.ItemConfigEcommerceRepository;
import de.ecashpoint.users.repository.ItemRepository;
import de.ecashpoint.users.service.Dto.ConfigurarItemEcommerceRequest;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.WebApplicationException;

@ApplicationScoped
public class ItemConfigService {

    @Inject
    ItemConfigEcommerceRepository cfgRepo;

    @Inject
    ItemRepository itemRepo;

    @Transactional
    public ItemConfiguratedEcommerce configurar(ConfigurarItemEcommerceRequest req) {

        Item item = itemRepo.findById(req.itemId);
        if (item == null)
            throw new WebApplicationException("Item no encontrado", 404);

        ItemConfiguratedEcommerce cfg = new ItemConfiguratedEcommerce();
        cfg.item = item;
        cfg.ecommerce = new Ecommerce();
        cfg.ecommerce.id = req.ecommerceId;

        cfg.precioPersonalizado = req.precioPersonalizado;
        cfg.visible = req.visible != null ? req.visible : true;
        cfg.stockPersonalizado = req.stockPersonalizado;
        cfg.configAdicional = req.configAdicional;

        cfgRepo.persist(cfg);

        return cfg;
    }
}

