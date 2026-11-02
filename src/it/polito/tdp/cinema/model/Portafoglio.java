package it.polito.tdp.cinema.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Portafoglio {

    private final List<Film> film;
    private final long budgetUsato;
    private final double utileTotale;

    public Portafoglio(List<Film> film, long budgetUsato, double utileTotale) {
        this.film = Collections.unmodifiableList(new ArrayList<>(film));
        this.budgetUsato = budgetUsato;
        this.utileTotale = utileTotale;
    }

    public List<Film> getFilm() { 
    	return film; 
    	}
    public long getBudgetUsato() { 
    	return budgetUsato; 
    	}
    public double getUtileTotale() { 
    	return utileTotale; 
    	}
}
