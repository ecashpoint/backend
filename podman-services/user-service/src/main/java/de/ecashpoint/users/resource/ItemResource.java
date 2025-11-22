package de.ecashpoint.users.resource;

import de.ecashpoint.users.entity.Item;
import de.ecashpoint.users.service.ItemService;
import de.ecashpoint.users.service.Dto.CrearItemRequest;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/api/items")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ItemResource {
    
    @Inject
    ItemService itemService;

    @POST
    @RolesAllowed({"ecommerce" , "admin" , "super_admin"})
    public Response crearItem(CrearItemRequest req) {
        Item item = itemService.crearItem(req);
        return Response.status(201).entity(item).build();
    }
}
