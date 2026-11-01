package it.polito.tdp.cinema.db;

import java.util.List;

import it.polito.tdp.cinema.model.Film;

public class TestDAO {

    public static void main(String[] args) {
        FilmDAO dao = new FilmDAO();

        System.out.println("Anni: " + dao.getAnni());

        List<Film> film2019 = dao.getFilmByAnno(2019);
        System.out.println("Film 2019: " + film2019.size());
        for (Film f : film2019) {
            System.out.println(f + " | " + f.getProduttore() + " / " + f.getDistributore()
                    + " | budget " + f.getBudget() + " | incasso " + f.getBoxOffice());
        }

        System.out.println("Prezzo biglietto 2019: " + dao.getPrezzoMedioBiglietto(2019));
    }
}