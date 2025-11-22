package de.ecashpoint.users.resource;

import java.util.List;

import de.ecashpoint.users.service.CatalogoService;
import de.ecashpoint.users.service.Dto.ItemDto;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/api/catalogo")
@Produces(MediaType.APPLICATION_JSON)
public class CatalogoResource {
    
    @Inject
    CatalogoService catalogoService;

    @GET
    @Path("{ecommerceId}")
    @RolesAllowed({"admin" , "super_admin" , "ecommerce" , "client"})
    public List<ItemDto> obtener(@PathParam("ecommerceId") Long ecommerceId) {
        return catalogoService.obtenerCatalogo(ecommerceId);
    }
}
