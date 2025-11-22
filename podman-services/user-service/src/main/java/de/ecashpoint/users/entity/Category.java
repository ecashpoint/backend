package de.ecashpoint.users.entity;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "categories")
@Schema(description = "Entity that represents a category")
public class Category extends PanacheEntity{
    
    
    @Column(nullable = false)
    @Schema(description = "category name" , required = true)
    public String category;


}
