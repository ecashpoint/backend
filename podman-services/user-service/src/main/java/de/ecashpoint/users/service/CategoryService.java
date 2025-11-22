package de.ecashpoint.users.service;
 

import java.util.List;

import de.ecashpoint.users.constant.Constants;
import de.ecashpoint.users.entity.Category;
import de.ecashpoint.users.repository.CategoryRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;

@ApplicationScoped
public class CategoryService {
    
    @Inject
    CategoryRepository categoryRepository;

    public List<Category> listAll(){
        return categoryRepository.listAll();
    }

    @Transactional
    public Category create(Category category){

        if(categoryRepository.existByCategory(category.category)){
            throw new WebApplicationException(
                Constants.EXCEPTION_EXIST_CATEGORY + category.category, 
                Response.Status.CONFLICT
            );
        }

        categoryRepository.persist(category);

        return category;
    }

    public Category findById(Long id) {
        return categoryRepository.findByIdOptional(id)
            .orElseThrow(() -> new NotFoundException("Usuario no encontrado con ID: " + id));
    }

    public void delete(Long id){
        Category category = findById(id);

        categoryRepository.delete(category);
    }
}
