package it.polito.tdp.cinema.model;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class RicercaPortafoglio {

    private List<Film> candidati;
    private double[] utili;
    private long budgetMax;
    private int maxFilm;

    private List<Film> migliore;
    private double utileMigliore;
    private long budgetMigliore;

    public Portafoglio cerca(List<Film> film, long budgetMax, int maxFilm) {
        this.budgetMax = budgetMax;
        this.maxFilm = maxFilm;

        candidati = new ArrayList<>();
        for (Film f : film) {
            if (Calcolatore.utilePortafoglio(f) > 0 && f.getBudget() <= budgetMax) {
                candidati.add(f);
            }
        }
        candidati.sort(Comparator.comparingDouble(Calcolatore::utilePortafoglio).reversed());
        utili = new double[candidati.size()];
        for (int i = 0; i < utili.length; i++) {
            utili[i] = Calcolatore.utilePortafoglio(candidati.get(i));
        }

        migliore = new ArrayList<>();
        utileMigliore = 0;
        budgetMigliore = 0;
        ricorsione(new ArrayList<>(), 0, 0L, 0.0);

        return new Portafoglio(migliore, budgetMigliore, utileMigliore);
    }

    private void ricorsione(List<Film> parziale, int start, long budgetUsato, double utile) {
        if (utile > utileMigliore) {
            utileMigliore = utile;
            migliore = new ArrayList<>(parziale);
            budgetMigliore = budgetUsato;
        }
        if (parziale.size() == maxFilm) {
            return;
        }
        for (int i = start; i < candidati.size(); i++) {
            Film f = candidati.get(i);
            if (budgetUsato + f.getBudget() > budgetMax) {
                continue;
            }
            parziale.add(f);
            ricorsione(parziale, i + 1, budgetUsato + f.getBudget(), utile + utili[i]);
            parziale.remove(parziale.size() - 1);
        }
    }
}
