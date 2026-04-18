package com.homepilot.app.repositories;

import com.homepilot.app.models.Listing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.math.BigDecimal;
import java.util.List;

public interface ListingRepository extends JpaRepository<Listing, Long> {

    @Query("SELECT l FROM Listing l WHERE l.rentOrBuy = :type")
    List<Listing> findByType(@Param("type") String type);

    List<Listing> findByLocationContainingIgnoreCase(String location);

    List<Listing> findByPriceLessThanEqual(BigDecimal maxPrice);

    @Query("SELECT l FROM Listing l WHERE l.rentOrBuy = :type AND l.price <= :maxPrice")
    List<Listing> findByTypeAndMaxPrice(@Param("type") String type, @Param("maxPrice") BigDecimal maxPrice);
}
