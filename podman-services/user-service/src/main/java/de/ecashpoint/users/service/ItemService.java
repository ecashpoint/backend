package de.ecashpoint.users.service;

import de.ecashpoint.users.entity.Inventario;
import de.ecashpoint.users.entity.Item;
import de.ecashpoint.users.repository.InventarioRepository;
import de.ecashpoint.users.repository.ItemRepository;
import de.ecashpoint.users.service.Dto.CrearItemRequest;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ItemService {

    @Inject
    ItemRepository itemRepository;

    @Inject
    InventarioRepository inventarioRepository;

    @Transactional
    public Item crearItem(CrearItemRequest req) {
        Item item = new Item();
        item.nombre = req.nombre;
        item.descripcion = req.descripcion;
        item.tipo = Item.TipoItem.valueOf(req.tipo);
        item.atributos = req.atributos;
        item.precioBase = req.precioBase;
        item.unidad = req.unidad;
        item.activo = true;

        itemRepository.persist(item);

        // Crear inventario si el tipo es PRODUCTO
        if (item.tipo == Item.TipoItem.PRODUCTO) {
            Inventario inv = new Inventario();
            inv.item = item;
            inv.stockActual = 0;
            inventarioRepository.persist(inv);
        }

        return item;
    }
    
}
