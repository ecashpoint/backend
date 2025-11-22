package de.ecashpoint.users.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Entity; 
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "inventario")
public class Inventario extends PanacheEntity {
    

    @OneToOne
    @JoinColumn(name = "item_id", unique = true)
    public Item item;

    public Integer stockActual;

    public String sku;

    public String ubicacion;
}
