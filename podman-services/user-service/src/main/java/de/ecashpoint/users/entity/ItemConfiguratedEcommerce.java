package de.ecashpoint.users.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity; 
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "item_config_ecommerce")
public class ItemConfiguratedEcommerce extends PanacheEntity {
    

    @ManyToOne
    @JoinColumn(name = "item_id")
    public Item item;

    @ManyToOne
    @JoinColumn(name = "ecommerce_id")
    public Ecommerce ecommerce;

    public Double precioPersonalizado;

    public Boolean visible = true;

    public Integer stockPersonalizado; // nullable si no aplica

    @Column(columnDefinition = "jsonb")
    public String configAdicional;
    
}
