package de.ecashpoint.notifications.service;
 
import org.jboss.logging.Logger;
import de.ecashpoint.notifications.entity.UserData;
import io.quarkus.mailer.Mail; 
import io.quarkus.mailer.reactive.ReactiveMailer;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import io.quarkus.qute.Location;
import io.quarkus.qute.Template;
import io.smallrye.mutiny.Uni;  

@ApplicationScoped
public class RegistrationService {
    
    private static final Logger LOG = Logger.getLogger(RegistrationService.class);
    
    @Inject
    ReactiveMailer reactiveMailer;
    
    @Inject
    @Location("emails/registration.html")
    Template registrationTemplate;
    
    public Uni<Boolean> sendRegistrationMail(UserData data) {
        
        LOG.infof("� Preparando correo de registro para: %s", data.getEmail());
        
        try {
            String emailContent = registrationTemplate
                .data("name", data.getName())
                .data("email", data.getEmail()) // Por si lo necesitas en el template
                .render();
            
            Mail mail = Mail.withHtml(
                data.getEmail(), 
                "GRACIAS POR SU REGISTRO", 
                emailContent
            );
            
            return reactiveMailer.send(mail)
                .onItem().invoke(() -> 
                    LOG.infof("✅ Correo enviado exitosamente a: %s", data.getEmail())
                )
                .onItem().transform(v -> true)
                .onFailure().invoke(error -> 
                    LOG.errorf(error, "❌ Error al enviar correo a: %s", data.getEmail())
                )
                .onFailure().recoverWithItem(false);
                
        } catch (Exception e) {
            LOG.errorf(e, "� Error al preparar el correo para: %s", data.getEmail());
            return Uni.createFrom().item(false);
        }
    }
}