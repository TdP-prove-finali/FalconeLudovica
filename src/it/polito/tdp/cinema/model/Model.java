package it.polito.tdp.cinema.model;

import java.util.ArrayList;
import java.util.List;

import it.polito.tdp.cinema.db.FilmDAO;

public class Model {

    private final FilmDAO dao = new FilmDAO();

    public List<Integer> getAnni() {
        return dao.getAnni();
    }

    public List<Film> getFilm(int anno) {
        return dao.getFilmByAnno(anno);
    }

    public Guadagno calcolaFilm(Film f, AccordoProduttore ap, AccordoEsercente ae) {
        return Calcolatore.calcola(f, ap, ae);
    }

    public long spettatoriStimati(Film f) {
        return Calcolatore.spettatoriStimati(f, dao.getPrezzoMedioBiglietto(f.getAnno()));
    }

    public List<Film> filmDelProduttore(Film f) {
        List<Film> risultato = new ArrayList<>();
        for (Film x : dao.getFilmByAnno(f.getAnno())) {
            if (x.getProduttore().equals(f.getProduttore())) {
                risultato.add(x);
            }
        }
        return risultato;
    }

    public List<Film> filmDelDistributore(Film f) {
        List<Film> risultato = new ArrayList<>();
        for (Film x : dao.getFilmByAnno(f.getAnno())) {
            if (x.getDistributore().equals(f.getDistributore())) {
                risultato.add(x);
            }
        }
        return risultato;
    }

    public double utileTotaleProduttore(List<Film> film, AccordoProduttore ap, AccordoEsercente ae) {
        double totale = 0;
        for (Film f : film) {
            totale += Calcolatore.calcola(f, ap, ae).getUtileProduttore();
        }
        return totale;
    }

    public double guadagnoTotaleDistributore(List<Film> film, AccordoProduttore ap, AccordoEsercente ae) {
        double totale = 0;
        for (Film f : film) {
            totale += Calcolatore.calcola(f, ap, ae).getGuadagnoDistributore();
        }
        return totale;
    }

    public Portafoglio trovaPortafoglio(int anno, long budgetMax, int maxFilm) {
        return new RicercaPortafoglio().cerca(dao.getFilmByAnno(anno), budgetMax, maxFilm);
    }
}
