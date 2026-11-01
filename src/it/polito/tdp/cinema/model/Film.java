package it.polito.tdp.cinema.model;

public class Film {

    private final int id;
    private final String titolo;
    private final int anno;
    private final String produttore;
    private final String distributore;
    private final long budget;
    private final long boxOffice;   // incasso domestico totale
    private final long sett1;
    private final long sett2;
    private final long sett3;
    private final long sett4;

    public Film(int id, String titolo, int anno, String produttore, String distributore,
                long budget, long boxOffice, long sett1, long sett2, long sett3, long sett4) {
        this.id = id;
        this.titolo = titolo;
        this.anno = anno;
        this.produttore = produttore;
        this.distributore = distributore;
        this.budget = budget;
        this.boxOffice = boxOffice;
        this.sett1 = sett1;
        this.sett2 = sett2;
        this.sett3 = sett3;
        this.sett4 = sett4;
    }

    public int getId() { 
    	return id; }
    public String getTitolo() { 
    	return titolo; }
    public int getAnno() { 
    	return anno; }
    public String getProduttore() { 
    	return produttore; }
    public String getDistributore() { 
    	return distributore; }
    public long getBudget() { 
    	return budget; }
    public long getBoxOffice() { 
    	return boxOffice; }
    public long getSett1() { 
    	return sett1; }
    public long getSett2() { 
    	return sett2; }
    public long getSett3() { 
    	return sett3; }
    public long getSett4() { 
    	return sett4; }

    @Override
    public int hashCode() { 
    	return Integer.hashCode(id); }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) 
        	return true;
        if (!(obj instanceof Film)) 
        	return false;
        return id == ((Film) obj).id;
    }

    @Override
    public String toString() { 
    	return titolo + " (" + anno + ")"; 
    	}
}