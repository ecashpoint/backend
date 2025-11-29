package de.ecashpoint.users.service.Dto;

import jakarta.ws.rs.DefaultValue;
import jakarta.ws.rs.QueryParam;

public class EcommerceFilterDTO {
     @QueryParam("authId")
    public String authId;
    
    @QueryParam("name")
    public String name;
    
    @QueryParam("email")
    public String email;
    
    @QueryParam("status")
    public String status;
    
    @QueryParam("page")
    @DefaultValue("0")
    public Integer page;
    
    @QueryParam("size")
    @DefaultValue("20")
    public Integer size;
    
    @QueryParam("sort")
    @DefaultValue("id")
    public String sort;
    
    @QueryParam("order")
    @DefaultValue("asc")
    public String order;


}
