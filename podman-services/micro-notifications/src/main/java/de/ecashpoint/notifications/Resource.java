package de.ecashpoint.notifications;

import java.util.Map;
import de.ecashpoint.notifications.entity.UserData;
import de.ecashpoint.notifications.service.RegistrationService;
import io.smallrye.mutiny.Uni;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.jboss.logging.Logger;

@Path("/api/mail")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class Resource {
    
    private static final Logger LOG = Logger.getLogger(Resource.class);
    
    @Inject
    RegistrationService registrationService;
    
    @POST
    @Path("/registration") 
    public Uni<Response> sendRegistrationMail(UserData userdata) {
        
        LOG.infof("� Datos recibidos: %s", userdata);
        
        // Validación
        if (userdata == null) {
            LOG.error("❌ UserData es null");
            return Uni.createFrom().item(
                Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("status", "error", "message", "No se recibieron datos"))
                    .build()
            );
        }
        
        if (userdata.getEmail() == null || userdata.getEmail().isBlank()) {
            LOG.error("❌ Email es null o vacío");
            return Uni.createFrom().item(
                Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("status", "error", "message", "Email es requerido"))
                    .build()
            );
        }
        
        LOG.infof("✅ Enviando correo de registro a: %s", userdata.getEmail());
        
        // SOLUCIÓN SIMPLE: Solo usa .map() o .onItem().transform()
        return registrationService.sendRegistrationMail(userdata)
            .map(success -> {
                if (success) {
                    LOG.infof("✅ Correo enviado exitosamente a: %s", userdata.getEmail());
                    return Response.ok()
                        .entity(Map.of("status", "sent", "email", userdata.getEmail()))
                        .build();
                } else {
                    LOG.errorf("❌ Falló el envío a: %s", userdata.getEmail());
                    return Response.serverError()
                        .entity(Map.of("status", "failed"))
                        .build();
                }
            });
    }
}