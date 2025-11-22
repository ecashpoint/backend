package de.ecashpoint.users.resource;

import java.util.List;

import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;

import de.ecashpoint.users.entity.Category;
import de.ecashpoint.users.service.CategoryService;
import jakarta.annotation.security.PermitAll;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/api/categories")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CaregoryResource {
    
    @Inject
    CategoryService categoryService;

    @GET
    @PermitAll
    @Operation(
        summary = "List all categories",
        description ="It retrieves the list of all categories registered by the administrator."
    )
    @APIResponse(
        responseCode = "200",
        description = "List of category sites successfully obtained",
        content = @Content(schema = @Schema(implementation = Category.class))
    )
    public List<Category> getAll(){
        return categoryService.listAll();
    }

    @POST
    @Transactional
    //@RolesAllowed({"super_admin" , "admin"})
    @Operation(
        summary = "Create a new category",
        description = "Create a new category store in the system"
    )
    @APIResponses({
        @APIResponse(
            responseCode = "201",
            description = "Successfully created category platform",
            content = @Content(schema = @Schema(implementation = Category.class))
        ),
        @APIResponse(
            responseCode = "400",
            description = "Invalid data"
        )
    })
    public Response create(
        @Parameter(description = "Category data", required = true)
        Category category
    ) {
        categoryService.create(category);
        return Response.status(201).entity(category).build();
    }

    

}
