package it.polito.tdp.cinema.model;

public enum AccordoEsercente {
    SLIDING_SCALE("Sliding scale"),
    BIDDING("Bidding");

    private final String nome;

    AccordoEsercente(String nome) { 
    	this.nome = nome; 
    	}

    @Override
    public String toString() { 
    	return nome; 
    	}
}
