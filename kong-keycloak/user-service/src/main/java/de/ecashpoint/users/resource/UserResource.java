package de.ecashpoint.users.resource;

import java.util.List;

import org.eclipse.microprofile.jwt.JsonWebToken;

import de.ecashpoint.users.entity.User;
import de.ecashpoint.users.service.UserService;
import jakarta.annotation.security.PermitAll;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/api/users_data")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UserResource {

    @Inject
    UserService userService;

    @Inject
    JsonWebToken jwt;


    @GET
    @RolesAllowed({"admin"})
    public List<User> listAll(){
        return userService.getAllUsers();
    }

    @POST
    @PermitAll
    public Response create(User user){
        User created = userService.create(user);

        return Response
                .status(Response.Status.CREATED)
                .entity(created)
                .build();
    }
    
}
