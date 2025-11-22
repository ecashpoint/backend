package de.ecashpoint.users.service.Dto;

import de.ecashpoint.users.entity.Item;

public class ItemDto {

    public Long id;
    public String nombre;
    public String descripcion;
    public String tipo;
    public Double precio;
    public Integer stock;
    public String atributos;

    public ItemDto() {}

    public ItemDto(Item item, Double precio, Integer stock) {
        this.id = item.id;
        this.nombre = item.nombre;
        this.descripcion = item.descripcion;
        this.tipo = item.tipo.name();
        this.precio = precio;
        this.stock = stock;
        this.atributos = item.atributos;
    }
}
