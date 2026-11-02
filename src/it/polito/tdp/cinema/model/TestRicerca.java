package it.polito.tdp.cinema.model;

import it.polito.tdp.cinema.db.FilmDAO;

public class TestRicerca {

    public static void main(String[] args) {
        FilmDAO dao = new FilmDAO();
        Portafoglio p = new RicercaPortafoglio().cerca(dao.getFilmByAnno(2019), 300_000_000L, 5);
        System.out.println("Film: " + p.getFilm());
        System.out.printf("Budget usato: %d | utile totale: %.0f%n", p.getBudgetUsato(), p.getUtileTotale());
    }
}
