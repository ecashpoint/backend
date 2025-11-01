package de.ecashpoint.users.service;

import java.util.List;

import de.ecashpoint.users.constant.Constants;
import de.ecashpoint.users.entity.User;
import de.ecashpoint.users.repository.UserRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;

@ApplicationScoped
public class UserService {
    
    @Inject
    UserRepository userRepository;

    public List<User> getAllUsers() {
        return userRepository.listAll();
    }

    public User findById(Long id) {
        return userRepository.findByIdOptional(id)
            .orElseThrow(() -> new NotFoundException("Usuario no encontrado con ID: " + id));
    }

    @Transactional
    public User create(User user) {
        // Validaciones
        
        if (userRepository.existsByEmail(user.email)) {
            throw new WebApplicationException(
                Constants.EXECPTION_EXIST_MAIL + user.email, 
                Response.Status.CONFLICT
            );
        }

        if(userRepository.existByDocument(user.document)){
            throw new WebApplicationException(
                Constants.EXCEPTION_EXIST_DOCUMENT + user.document
            );
        }

        if(userRepository.existByPhone(user.phone)){
            throw new WebApplicationException(
                Constants.EXCEPTION_EXIST_PHONE + user.phone
            );
        }
        
        userRepository.persist(user);
        return user;
    }

    

    @Transactional
    public void delete(Long id) {
        User user = findById(id);
        userRepository.delete(user);
    }
}
