package it.polito.tdp.cinema;

import java.util.List;

import it.polito.tdp.cinema.model.AccordoEsercente;
import it.polito.tdp.cinema.model.AccordoProduttore;
import it.polito.tdp.cinema.model.Film;
import it.polito.tdp.cinema.model.Guadagno;
import it.polito.tdp.cinema.model.Model;
import it.polito.tdp.cinema.model.Portafoglio;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.ListView;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;

public class FXMLController {

    private Model model;

    @FXML private ComboBox<Integer> cmbAnno;

    // scheda "Analisi di un film"
    @FXML private ListView<Film> lstFilm;
    @FXML private ComboBox<AccordoProduttore> cmbAccordoProduttore;
    @FXML private ComboBox<AccordoEsercente> cmbAccordoEsercente;
    @FXML private Button btnCalcolaFilm;
    @FXML private Button btnGuadagnoProduttore;
    @FXML private Button btnGuadagnoDistributore;
    @FXML private Button btnReset;
    @FXML private TextArea txtFilm;

    // scheda "Portafoglio migliore"
    @FXML private TextField txtBudget;
    @FXML private TextField txtN;
    @FXML private Button btnPortafoglio;
    @FXML private TextArea txtPortafoglio;

    private static String milioni(double dollari) {
        return String.format("%.1f milioni di $", dollari / 1e6);
    }

    // controlli comuni ai tre pulsanti della scheda film; restituisce null se manca qualcosa
    private Film controllaFilm() {
        txtFilm.clear();
        if (cmbAnno.getValue() == null) {
            txtFilm.setText("Seleziona un anno.");
            return null;
        }
        Film f = lstFilm.getSelectionModel().getSelectedItem();
        if (f == null) {
            txtFilm.setText("Seleziona un film dalla lista.");
            return null;
        }
        if (cmbAccordoProduttore.getValue() == null || cmbAccordoEsercente.getValue() == null) {
            txtFilm.setText("Seleziona entrambi gli accordi.");
            return null;
        }
        return f;
    }

    @FXML
    void doSelezionaAnno(ActionEvent event) {
        Integer anno = cmbAnno.getValue();
        lstFilm.getItems().clear();
        txtFilm.clear();
        txtPortafoglio.clear();
        if (anno != null) {
            lstFilm.getItems().addAll(model.getFilm(anno));
        }
    }

    @FXML
    void doCalcolaFilm(ActionEvent event) {
        Film f = controllaFilm();
        if (f == null) {
            return;
        }
        AccordoProduttore ap = cmbAccordoProduttore.getValue();
        AccordoEsercente ae = cmbAccordoEsercente.getValue();
        Guadagno g = model.calcolaFilm(f, ap, ae);

        txtFilm.appendText(f + "\n");
        txtFilm.appendText("Produttore: " + f.getProduttore() + " | Distributore: " + f.getDistributore() + "\n");
        txtFilm.appendText("Budget: " + milioni(f.getBudget()) + " | Incasso domestico: " + milioni(f.getBoxOffice()) + "\n");
        txtFilm.appendText("Spettatori stimati: " + model.spettatoriStimati(f) + "\n\n");
        txtFilm.appendText("Accordi: " + ap + " + " + ae + "\n");
        txtFilm.appendText("Quota che resta al distributore: " + milioni(g.getQuotaDistributore()) + "\n");
        txtFilm.appendText("Utile del produttore: " + milioni(g.getUtileProduttore()) + "\n");
        txtFilm.appendText("Guadagno del distributore: " + milioni(g.getGuadagnoDistributore()) + "\n");
    }

    @FXML
    void doGuadagnoProduttore(ActionEvent event) {
        Film f = controllaFilm();
        if (f == null) {
            return;
        }
        List<Film> film = model.filmDelProduttore(f);
        double totale = model.utileTotaleProduttore(film, cmbAccordoProduttore.getValue(), cmbAccordoEsercente.getValue());
        txtFilm.appendText("Utile annuale di " + f.getProduttore() + " nel " + f.getAnno() + "\n");
        txtFilm.appendText("(" + cmbAccordoProduttore.getValue() + " + " + cmbAccordoEsercente.getValue() + ")\n");
        txtFilm.appendText("Film presenti nel database: " + film.size() + "\n");
        for (Film x : film) {
            txtFilm.appendText("- " + x.getTitolo() + "\n");
        }
        txtFilm.appendText("Totale: " + milioni(totale) + "\n");
    }

    @FXML
    void doGuadagnoDistributore(ActionEvent event) {
        Film f = controllaFilm();
        if (f == null) {
            return;
        }
        List<Film> film = model.filmDelDistributore(f);
        double totale = model.guadagnoTotaleDistributore(film, cmbAccordoProduttore.getValue(), cmbAccordoEsercente.getValue());
        txtFilm.appendText("Guadagno annuale di " + f.getDistributore() + " nel " + f.getAnno() + "\n");
        txtFilm.appendText("(" + cmbAccordoProduttore.getValue() + " + " + cmbAccordoEsercente.getValue() + ")\n");
        txtFilm.appendText("Film presenti nel database: " + film.size() + "\n");
        for (Film x : film) {
            txtFilm.appendText("- " + x.getTitolo() + "\n");
        }
        txtFilm.appendText("Totale: " + milioni(totale) + "\n");
    }

    @FXML
    void doReset(ActionEvent event) {
        cmbAnno.setValue(null);
        lstFilm.getItems().clear();
        cmbAccordoProduttore.setValue(null);
        cmbAccordoEsercente.setValue(null);
        txtFilm.clear();
        txtBudget.clear();
        txtN.clear();
        txtPortafoglio.clear();
    }

    @FXML
    void doPortafoglio(ActionEvent event) {
        txtPortafoglio.clear();
        Integer anno = cmbAnno.getValue();
        if (anno == null) {
            txtPortafoglio.setText("Seleziona un anno.");
            return;
        }
        long budgetMilioni;
        int maxFilm;
        try {
            budgetMilioni = Long.parseLong(txtBudget.getText().trim());
            maxFilm = Integer.parseInt(txtN.getText().trim());
        } catch (NumberFormatException e) {
            txtPortafoglio.setText("Budget e numero di film devono essere numeri interi.");
            return;
        }
        if (budgetMilioni <= 0 || maxFilm <= 0) {
            txtPortafoglio.setText("Budget e numero di film devono essere maggiori di zero.");
            return;
        }

        Portafoglio p = model.trovaPortafoglio(anno, budgetMilioni * 1_000_000L, maxFilm);
        if (p.getFilm().isEmpty()) {
            txtPortafoglio.setText("Nessun film in utile entra in questo budget.");
            return;
        }
        txtPortafoglio.appendText("Portafoglio migliore del " + anno + " (profit-sharing + sliding scale)\n");
        txtPortafoglio.appendText("Budget usato: " + milioni(p.getBudgetUsato()) + " su " + budgetMilioni + "\n");
        txtPortafoglio.appendText("Utile totale dei produttori: " + milioni(p.getUtileTotale()) + "\n\n");
        for (Film f : p.getFilm()) {
            txtPortafoglio.appendText("- " + f.getTitolo() + " | budget " + milioni(f.getBudget()) + "\n");
        }
    }

    public void setModel(Model model) {
        this.model = model;
        cmbAnno.getItems().addAll(model.getAnni());
        cmbAccordoProduttore.getItems().addAll(AccordoProduttore.values());
        cmbAccordoEsercente.getItems().addAll(AccordoEsercente.values());
    }
}
