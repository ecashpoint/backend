package de.ecashpoint.users.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated; 
import jakarta.persistence.Table;

@Entity
@Table(name = "item")
public class Item extends PanacheEntity {
    

    @Column(nullable = false)
    public String nombre;

    @Column(columnDefinition = "text")
    public String descripcion;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    public TipoItem tipo; // PRODUCTO | SERVICIO

    @Column(columnDefinition = "jsonb")
    public String atributos; // tallas, colores, velocidad, etc.

    public Double precioBase;

    public String unidad; // opcional

    public Boolean activo = true;

    public enum TipoItem {
        PRODUCTO,
        SERVICIO
    }
}