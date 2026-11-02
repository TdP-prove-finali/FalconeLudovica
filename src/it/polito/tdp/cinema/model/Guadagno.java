package it.polito.tdp.cinema.model;

public class Guadagno {

    private final double quotaDistributore;
    private final double utileProduttore;
    private final double guadagnoDistributore;

    public Guadagno(double quotaDistributore, double utileProduttore, double guadagnoDistributore) {
        this.quotaDistributore = quotaDistributore;
        this.utileProduttore = utileProduttore;
        this.guadagnoDistributore = guadagnoDistributore;
    }

    public double getQuotaDistributore() { 
    	return quotaDistributore; 
    	}
    public double getUtileProduttore() { 
    	return utileProduttore; 
    	}
    public double getGuadagnoDistributore() { 
    	return guadagnoDistributore; 
    	}
}