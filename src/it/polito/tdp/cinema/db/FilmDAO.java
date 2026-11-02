package it.polito.tdp.cinema.db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import it.polito.tdp.cinema.model.Film;

public class FilmDAO {

    public List<Integer> getAnni() {
        String sql = "SELECT DISTINCT anno FROM film ORDER BY anno";
        List<Integer> anni = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement st = conn.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                anni.add(rs.getInt("anno"));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore nella lettura degli anni", e);
        }
        return anni;
    }
    

    public List<Film> getFilmByAnno(int anno) {
        String sql = "SELECT f.id, f.titolo, f.anno, p.nome AS produttore, d.nome AS distributore, "
                + "f.budget, f.boxoffice_domestico, f.sett1, f.sett2, f.sett3, f.sett4 "
                + "FROM film f "
                + "JOIN produttore p ON p.id = f.id_produttore "
                + "JOIN distributore d ON d.id = f.id_distributore "
                + "WHERE f.anno = ? "
                + "ORDER BY f.boxoffice_domestico DESC";
        
        List<Film> film = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, anno);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    film.add(new Film(
                            rs.getInt("id"),
                            rs.getString("titolo"),
                            rs.getInt("anno"),
                            rs.getString("produttore"),
                            rs.getString("distributore"),
                            rs.getLong("budget"),
                            rs.getLong("boxoffice_domestico"),
                            rs.getLong("sett1"),
                            rs.getLong("sett2"),
                            rs.getLong("sett3"),
                            rs.getLong("sett4")));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore nella lettura dei film dell'anno " + anno, e);
        }
        return film;
    }
  
    public double getPrezzoMedioBiglietto(int anno) {
        String sql = "SELECT prezzo_medio_biglietto FROM mercato_annuale WHERE anno = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, anno);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("prezzo_medio_biglietto");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore nella lettura del prezzo del biglietto", e);
        }
        throw new IllegalArgumentException("Nessun prezzo del biglietto per l'anno " + anno);
    }
}
