package de.ecashpoint.users.resource;

import de.ecashpoint.users.entity.ItemConfiguratedEcommerce;
import de.ecashpoint.users.service.ItemConfigService;
import de.ecashpoint.users.service.Dto.ConfigurarItemEcommerceRequest;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/api/items/config")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ItemConfigResource {

    @Inject
    ItemConfigService service;

    @POST
    @RolesAllowed({"admin" , "super_admin"})
    public Response configurar(ConfigurarItemEcommerceRequest req) {
        ItemConfiguratedEcommerce cfg = service.configurar(req);
        return Response.status(201).entity(cfg).build();
    }
    
}
