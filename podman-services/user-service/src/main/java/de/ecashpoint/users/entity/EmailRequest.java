package de.ecashpoint.users.entity;

public class EmailRequest {
    public String email;
    public String name;
    public String type;
    
    // Constructor, getters, setters
    public EmailRequest(String email, String name , String type) {
        this.email = email;
        this.name = name;
        this.type = type;
    }
}