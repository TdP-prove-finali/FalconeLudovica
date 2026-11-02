package it.polito.tdp.cinema.model;

public enum AccordoProduttore {
    LEASING("Leasing"),
    PROFIT_SHARING("Profit-sharing");

    private final String nome;

    AccordoProduttore(String nome) { 
    	this.nome = nome; 
    	}

    @Override
    public String toString() { 
    	return nome; 
    	}
}
