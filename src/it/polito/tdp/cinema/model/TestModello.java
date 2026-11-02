package it.polito.tdp.cinema.model;

import it.polito.tdp.cinema.db.FilmDAO;

public class TestModello {

    public static void main(String[] args) {
        FilmDAO dao = new FilmDAO();
        Film f = dao.getFilmByAnno(2019).get(0);   // il film con più incasso del 2019
        System.out.println(f);
        for (AccordoProduttore p : AccordoProduttore.values()) {
            for (AccordoEsercente e : AccordoEsercente.values()) {
                Guadagno g = Calcolatore.calcola(f, p, e);
                System.out.printf("%-15s %-14s utile produttore %.0f | guadagno distributore %.0f%n",
                        p, e, g.getUtileProduttore(), g.getGuadagnoDistributore());
            }
        }
    }
}