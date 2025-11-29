package de.ecashpoint.users.service;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import de.ecashpoint.users.entity.Category;
import de.ecashpoint.users.entity.Ecommerce;
import de.ecashpoint.users.entity.NetworksSocial;
import de.ecashpoint.users.repository.CategoryRepository;
import de.ecashpoint.users.repository.EcommerceRepository;
import de.ecashpoint.users.service.Dto.EcommerceFilterDTO;
import io.quarkus.hibernate.orm.panache.Panache;
import io.quarkus.hibernate.orm.panache.PanacheQuery;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class EcommerceService {

    @Inject
    EcommerceRepository ecommerceRepository;

    @Inject
    CategoryRepository categoryRepository;

    @Transactional
    public Ecommerce create(Ecommerce ecommerce){
        if(ecommerce.categories != null && !ecommerce.categories.isEmpty()){
            Set<Category> managedCategories = new HashSet<>();
            for(Category cat : ecommerce.categories){
                Category managedCategory = categoryRepository.findById(cat.id);
                if(managedCategory != null){
                    managedCategories.add(managedCategory);
                }
            }
            ecommerce.categories = managedCategories;
        }
        if(ecommerce.redes != null && !ecommerce.redes.isEmpty()){
            for(NetworksSocial net : ecommerce.redes){
                net.ecommerce = ecommerce;
            }
        }
        ecommerceRepository.persist(ecommerce);

        return ecommerce;
    }

    public List<Ecommerce> getAll(){
        return ecommerceRepository.listAll();
    }

    public List<Ecommerce> findByAuthId(String authId){
        return ecommerceRepository.findByAuthId(authId);
    }

    public Map<String, Object> find(EcommerceFilterDTO filter){

        Sort.Direction direction = "desc".equalsIgnoreCase(filter.order) 
            ? Sort.Direction.Descending 
            : Sort.Direction.Ascending;
        Sort sort = Sort.by(filter.sort, direction);

        PanacheQuery<Ecommerce> query = ecommerceRepository.findByFilters(
            filter.authId,
            filter.name,
            filter.email,
            filter.status,
            sort
        ); 

         List<Ecommerce> ecommerces = query.page(filter.page, filter.size).list();

         long totalCount = ecommerceRepository.countByFilters(
            filter.authId,
            filter.name,
            filter.email,
            filter.status
         );

        return Map.of(
            "ecommerces", ecommerces,
            "totalCount", totalCount,
            "page", filter.page,
            "size", filter.size,
            "totalPages", (int) Math.ceil((double) totalCount / filter.size)
        );

    }
    
}
