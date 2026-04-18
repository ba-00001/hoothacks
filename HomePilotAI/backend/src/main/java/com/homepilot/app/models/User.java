package com.homepilot.app.models;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;
    private String password;
    private String name;

    private String incomeRange;
    private String employmentStatus;
    private Integer householdSize;
    private Integer creditEstimate;
    private String preferredLocation;
    private String rentOrBuy;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getIncomeRange() { return incomeRange; }
    public void setIncomeRange(String incomeRange) { this.incomeRange = incomeRange; }
    public String getEmploymentStatus() { return employmentStatus; }
    public void setEmploymentStatus(String employmentStatus) { this.employmentStatus = employmentStatus; }
    public Integer getHouseholdSize() { return householdSize; }
    public void setHouseholdSize(Integer householdSize) { this.householdSize = householdSize; }
    public Integer getCreditEstimate() { return creditEstimate; }
    public void setCreditEstimate(Integer creditEstimate) { this.creditEstimate = creditEstimate; }
    public String getPreferredLocation() { return preferredLocation; }
    public void setPreferredLocation(String preferredLocation) { this.preferredLocation = preferredLocation; }
    public String getRentOrBuy() { return rentOrBuy; }
    public void setRentOrBuy(String rentOrBuy) { this.rentOrBuy = rentOrBuy; }
}
