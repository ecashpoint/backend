package de.ecashpoint.users.resource;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import de.ecashpoint.users.entity.Ecommerce;
import de.ecashpoint.users.service.EcommerceService;
import de.ecashpoint.users.service.Dto.EcommerceFilterDTO;
import jakarta.annotation.security.PermitAll;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.BeanParam;
import jakarta.ws.rs.Consumes; 
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces; 
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response; 

@Path("/api/ecommerces")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class EcommerceResource {

    @Inject
    EcommerceService ecommerceService;

    @GET
    @PermitAll()
    public List<Ecommerce> findAll(){

        return ecommerceService.getAll();
    }

    @POST
    @RolesAllowed({"ecommerce"})
    public Response create(Ecommerce ecommerce){
        ecommerceService.create(ecommerce);

        return Response.status(201).entity(ecommerce).build();
    }

    @GET
    @RolesAllowed({"admin" , "ecommerce" , "super_admin" , "client"})
    @Path("/find")
    public Response find(@BeanParam EcommerceFilterDTO filter){ 
      
        Map<String, Object> filters = ecommerceService.find(filter);
        
        return Response.ok(filters).build();
    }
    
}
