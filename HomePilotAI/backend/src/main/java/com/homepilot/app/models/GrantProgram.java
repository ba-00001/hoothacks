package com.homepilot.app.models;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "grant_programs")
public class GrantProgram {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String programName;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String eligibilityRules;

    @Column(nullable = false)
    private BigDecimal coverageAmount;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getProgramName() { return programName; }
    public void setProgramName(String programName) { this.programName = programName; }
    public String getEligibilityRules() { return eligibilityRules; }
    public void setEligibilityRules(String eligibilityRules) { this.eligibilityRules = eligibilityRules; }
    public BigDecimal getCoverageAmount() { return coverageAmount; }
    public void setCoverageAmount(BigDecimal coverageAmount) { this.coverageAmount = coverageAmount; }
}
