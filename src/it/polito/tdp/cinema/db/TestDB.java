package it.polito.tdp.cinema.db;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestDB {

    public static void main(String[] args) throws Exception {
        try (Connection conn = DBConnect.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM film")) {
            rs.next();
            System.out.println("Film nel database: " + rs.getInt(1));
        }
    }
}
