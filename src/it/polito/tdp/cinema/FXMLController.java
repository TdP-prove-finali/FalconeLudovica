package it.polito.tdp.cinema;

import java.util.List;

import it.polito.tdp.cinema.model.AccordoEsercente;
import it.polito.tdp.cinema.model.Calcolatore;
import it.polito.tdp.cinema.model.AccordoProduttore;
import it.polito.tdp.cinema.model.Film;
import it.polito.tdp.cinema.model.Guadagno;
import it.polito.tdp.cinema.model.Model;
import it.polito.tdp.cinema.model.Portafoglio;
import javafx.event.ActionEvent;
import javafx.geometry.Bounds;
import javafx.geometry.Insets;
import javafx.fxml.FXML;
import javafx.scene.Cursor;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.TextField;
import javafx.scene.control.ContentDisplay;
import javafx.scene.layout.Background;
import javafx.scene.layout.BackgroundFill;
import javafx.scene.layout.CornerRadii;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Region;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;
import javafx.scene.text.TextFlow;

public class FXMLController {

    private Model model;

    @FXML private HBox barraAlto;
    @FXML private Label lblTitolo;
    @FXML private VBox pannelloFilm;
    @FXML private VBox pannelloPortafoglio;

    @FXML private ComboBox<Integer> cmbAnno;
    @FXML private ListView<Film> lstFilm;
    @FXML private ComboBox<AccordoProduttore> cmbAccordoProduttore;
    @FXML private ComboBox<AccordoEsercente> cmbAccordoEsercente;
    @FXML private Button btnCalcolaFilm;
    @FXML private Button btnGuadagnoProduttore;
    @FXML private Button btnGuadagnoDistributore;
    @FXML private Button btnReset;
    @FXML private TextFlow txtFilm;
    @FXML private TextFlow lblSpiegazione;
    @FXML private TextField txtBudget;
    @FXML private TextField txtN;
    @FXML private Button btnPortafoglio;
    @FXML private TextFlow txtPortafoglio;
    @FXML private TextFlow lblSpiegazionePortafoglio;
    @FXML private ComboBox<Integer> cmbAnnoPortafoglio;   // stesso anno di cmbAnno, ripetuto nella scheda 2
    @FXML private Label lblAnno1;
    @FXML private Label lblAnno2;
    @FXML private Label lblAccordoProduttore;
    @FXML private Label lblAccordoEsercente;
    
    private boolean sincronizzando = false;

    private static String milioni(double dollari) {
        return String.format("%.1f milioni di $", dollari / 1e6);
    }
    
    private static final String COL_PRODUTTORE = "#2b4c7e";
    private static final String COL_DISTRIBUTORE = "#b76e79";
    private static final String COL_BORDEAUX = "#7b2142";
    private static final String COL_PORTAFOGLIO = "#3e5c9a";

   
    private static void pulisci(TextFlow area) {
        area.getChildren().clear();
        area.setLineSpacing(4);
    }

    private static void scrivi(TextFlow area, String testo) {
        Text t = new Text(testo);
        t.setFont(Font.font("System", FontWeight.NORMAL, 13));
        t.setFill(Color.web("#2b2b3a"));
        area.getChildren().add(t);
    }

   
    private static void titolo(TextFlow area, String testo, String colore) {
        Text t = new Text(testo);
        t.setFont(Font.font("System", FontWeight.BOLD, 14));
        t.setFill(Color.web(colore));
        area.getChildren().add(t);
    }

   
    private static void evidenzia(TextFlow area, String testo, String colore) {
        Label l = new Label(testo);
        l.setBackground(sfondo(colore, 6));
        l.setTextFill(Color.WHITE);
        l.setFont(Font.font("System", FontWeight.BOLD, 15));
        l.setPadding(new Insets(3, 10, 3, 10));
        area.getChildren().add(l);
        scrivi(area, "\n");
    }

  
    private Film controllaFilm() {
        pulisci(txtFilm);
        if (cmbAnno.getValue() == null) {
            scrivi(txtFilm, "Seleziona un anno.");
            return null;
        }
        Film f = lstFilm.getSelectionModel().getSelectedItem();
        if (f == null) {
            scrivi(txtFilm, "Seleziona un film dalla lista.");
            return null;
        }
        if (cmbAccordoProduttore.getValue() == null || cmbAccordoEsercente.getValue() == null) {
            scrivi(txtFilm, "Seleziona entrambi gli accordi.");
            return null;
        }
        return f;
    }

    @FXML
    void doSelezionaAnno(ActionEvent event) {
        if (sincronizzando) {
            return;
        }
       
        Integer anno = (Integer) ((ComboBox<?>) event.getSource()).getValue();
        sincronizzando = true;
        try {
            cmbAnno.setValue(anno);
            cmbAnnoPortafoglio.setValue(anno);
        } finally {
            sincronizzando = false;
        }
        lstFilm.getItems().clear();
        pulisci(txtFilm);
        pulisci(txtPortafoglio);
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

        evidenzia(txtFilm, f.toString(), COL_BORDEAUX);
        scrivi(txtFilm, "Produttore: " + f.getProduttore() + "\n");
        scrivi(txtFilm, "Distributore: " + f.getDistributore() + "\n");
        scrivi(txtFilm, "Budget: " + milioni(f.getBudget()) + "\n");
        scrivi(txtFilm, "Incasso domestico: " + milioni(f.getBoxOffice()) + "\n");
        scrivi(txtFilm, "Spettatori stimati: " + model.spettatoriStimati(f) + "\n\n");

        titolo(txtFilm, "Accordi: " + ap + " + " + ae + "\n", "#555555");
        evidenzia(txtFilm, "Utile del produttore: " + milioni(g.getUtileProduttore()), COL_PRODUTTORE);
        evidenzia(txtFilm, "Guadagno del distributore: " + milioni(g.getGuadagnoDistributore()), COL_DISTRIBUTORE);
    }

    @FXML
    void doGuadagnoProduttore(ActionEvent event) {
        Film f = controllaFilm();
        if (f == null) {
            return;
        }
        List<Film> film = model.filmDelProduttore(f);
        double totale = model.utileTotaleProduttore(film, cmbAccordoProduttore.getValue(), cmbAccordoEsercente.getValue());
        titolo(txtFilm, "Utile annuale di " + f.getProduttore() + " nel " + f.getAnno() + "\n", COL_PRODUTTORE);
        scrivi(txtFilm, "Accordi: " + cmbAccordoProduttore.getValue() + " + " + cmbAccordoEsercente.getValue() + "\n");
        scrivi(txtFilm, "Si sommano gli utili di tutti i film di questo produttore presenti nel database ("
                + film.size() + "):\n");
        for (Film x : film) {
            scrivi(txtFilm, "- " + x.getTitolo() + "\n");
        }
        scrivi(txtFilm, "\n");
        evidenzia(txtFilm, "Totale: " + milioni(totale), COL_PRODUTTORE);
    }

    @FXML
    void doGuadagnoDistributore(ActionEvent event) {
        Film f = controllaFilm();
        if (f == null) {
            return;
        }
        List<Film> film = model.filmDelDistributore(f);
        double totale = model.guadagnoTotaleDistributore(film, cmbAccordoProduttore.getValue(), cmbAccordoEsercente.getValue());
        titolo(txtFilm, "Guadagno annuale di " + f.getDistributore() + " nel " + f.getAnno() + "\n", COL_DISTRIBUTORE);
        scrivi(txtFilm, "Accordi: " + cmbAccordoProduttore.getValue() + " + " + cmbAccordoEsercente.getValue() + "\n");
        scrivi(txtFilm, "Si sommano i guadagni di tutti i film di questo distributore presenti nel database ("
                + film.size() + "):\n");
        for (Film x : film) {
            scrivi(txtFilm, "- " + x.getTitolo() + "\n");
        }
        scrivi(txtFilm, "\n");
        evidenzia(txtFilm, "Totale: " + milioni(totale), COL_DISTRIBUTORE);
    }

    @FXML
    void doReset(ActionEvent event) {
        sincronizzando = true;
        try {
            cmbAnno.setValue(null);
            cmbAnnoPortafoglio.setValue(null);
        } finally {
            sincronizzando = false;
        }
        lstFilm.getItems().clear();
        cmbAccordoProduttore.setValue(null);
        cmbAccordoEsercente.setValue(null);
        pulisci(txtFilm);
        txtBudget.clear();
        txtN.clear();
        pulisci(txtPortafoglio);
    }

    @FXML
    void doPortafoglio(ActionEvent event) {
        pulisci(txtPortafoglio);
        Integer anno = cmbAnno.getValue();
        if (anno == null) {
            scrivi(txtPortafoglio, "Seleziona un anno.");
            return;
        }
        long budgetMilioni;
        int maxFilm;
        try {
            budgetMilioni = Long.parseLong(txtBudget.getText().trim());
            maxFilm = Integer.parseInt(txtN.getText().trim());
        } catch (NumberFormatException e) {
            scrivi(txtPortafoglio, "Budget e numero di film devono essere numeri interi.");
            return;
        }
        if (budgetMilioni <= 0 || maxFilm <= 0) {
            scrivi(txtPortafoglio, "Budget e numero di film devono essere maggiori di zero.");
            return;
        }

        Portafoglio p = model.trovaPortafoglio(anno, budgetMilioni * 1_000_000L, maxFilm);
        if (p.getFilm().isEmpty()) {
            scrivi(txtPortafoglio, "Nessun film in utile entra in questo budget.");
            return;
        }
        titolo(txtPortafoglio, "Portafoglio migliore del " + anno + " (profit-sharing + sliding scale)\n", COL_PORTAFOGLIO);
        scrivi(txtPortafoglio, "Budget usato: " + milioni(p.getBudgetUsato()) + " su " + budgetMilioni
                + " milioni disponibili, con " + p.getFilm().size() + " film su un massimo di " + maxFilm + ".\n\n");
        evidenzia(txtPortafoglio, "Utile totale dei produttori: " + milioni(p.getUtileTotale()), COL_PORTAFOGLIO);
        scrivi(txtPortafoglio, "\nFilm scelti:\n");
        for (Film f : p.getFilm()) {
            titolo(txtPortafoglio, "- " + f.getTitolo(), COL_BORDEAUX);
            scrivi(txtPortafoglio, "  budget " + milioni(f.getBudget()) + ", utile "
                    + milioni(Calcolatore.utilePortafoglio(f)) + "\n");
        }
    }

    private static void rigaSpiegazione(TextFlow area, String grassetto, String normale, String colore, int dimensione) {
        if (!grassetto.isEmpty()) {
            Text g = new Text(grassetto);
            g.setFont(Font.font("System", FontWeight.BOLD, dimensione));
            g.setFill(Color.web(colore));
            area.getChildren().add(g);
        }
        if (!normale.isEmpty()) {
            Text n = new Text(normale);
            n.setFont(Font.font("System", FontWeight.NORMAL, dimensione));
            n.setFill(Color.web(colore));
            area.getChildren().add(n);
        }
    }

    private static void rigaSpiegazione(TextFlow area, String grassetto, String normale, String colore) {
        rigaSpiegazione(area, grassetto, normale, colore, 12);
    }

   
    private static Label rigaPopup(String testo, boolean grassetto) {
        Label l = new Label(testo);
        l.setFont(Font.font("System", grassetto ? FontWeight.BOLD : FontWeight.NORMAL, 11));
        l.setTextFill(Color.WHITE);
        l.setWrapText(true);
        l.setPrefWidth(190);
        l.setMaxWidth(190);
        l.setMinHeight(Region.USE_PREF_SIZE);
        return l;
    }

    
    private void popup(Label etichetta, String[][] voci) {
        VBox riquadro = new VBox(3);
        for (String[] v : voci) {
            riquadro.getChildren().add(rigaPopup(v[0], true));
            riquadro.getChildren().add(rigaPopup(v[1], false));
        }
        riquadro.setPadding(new Insets(8, 10, 8, 10));
        riquadro.setBackground(new Background(new BackgroundFill(Color.web("#2f3542"), new CornerRadii(6), Insets.EMPTY)));
        riquadro.setManaged(false);   // non sposta gli altri elementi
        riquadro.setVisible(false);
        pannelloFilm.getChildren().add(riquadro);

        etichetta.setOnMouseEntered(e -> {
            riquadro.autosize();
            Bounds b = pannelloFilm.sceneToLocal(etichetta.localToScene(etichetta.getBoundsInLocal()));
            riquadro.relocate(b.getMinX(), b.getMinY() - riquadro.getHeight() - 4);
            riquadro.toFront();
            riquadro.setVisible(true);
        });
        etichetta.setOnMouseExited(e -> riquadro.setVisible(false));

        Label i = new Label("i");
        i.setFont(Font.font("System", FontWeight.BOLD, 13));
        i.setTextFill(Color.WHITE);
        i.setAlignment(Pos.CENTER);
        i.setMinSize(20, 20);
        i.setPrefSize(20, 20);
        i.setMaxSize(20, 20);
        i.setBackground(new Background(new BackgroundFill(Color.web("#2b4c7e"), new CornerRadii(10), Insets.EMPTY)));
        etichetta.setGraphic(i);
        etichetta.setContentDisplay(ContentDisplay.RIGHT);
        etichetta.setGraphicTextGap(6);
        etichetta.setCursor(Cursor.HAND);
    }

   
    private void scriviSpiegazioni() {
        String scuro = "#3b1a28";
        lblSpiegazione.setBackground(sfondo("#fdf5f3", 6));
        lblSpiegazione.setPadding(new Insets(8, 12, 8, 12));
        lblSpiegazione.setLineSpacing(3);
        lblSpiegazione.getChildren().clear();
        rigaSpiegazione(lblSpiegazione, "", "Si tende a pensare che un film con incasso molto alto porti un proporzionale guadagno nelle casse "
                + "dei creatori dell'opera. Ma non e' cosi': l'incasso viene infatti suddiviso tra tre componenti attivi della filiera "
                + "cinematografica, ovvero produttori, distributori ed esercenti.\n\n", scuro);
        rigaSpiegazione(lblSpiegazione, "", "Secondo quattro combinazioni diverse di accordi (due che regolamentano il rapporto finanziario "
                + "tra produttore e distributore e due quello tra distributore ed esercente), budget del film e incasso settimanale "
                + "al botteghino scopriremo qual e' l'utile del produttore e l'effettivo guadagno del distributore.\n\n", scuro);
        rigaSpiegazione(lblSpiegazione, "Scegli un anno, un film e due accordi.", "", scuro);

        popup(lblAccordoProduttore, new String[][] {
            { "Leasing", "Il produttore riceve dal distributore un compenso corrispondente al 125% del budget." },
            { "Profit-sharing", "Il produttore riceve l'80% della quota del distributore." } });
        popup(lblAccordoEsercente, new String[][] {
            { "Sliding scale", "Al distributore resta il 95% dell'incasso della prima settimana, il 90% della seconda, l'85% della terza e il 50% dalla quarta in poi." },
            { "Bidding", "Al distributore resta il 95% dell'incasso totale." } });

        String blu = "#1f2f4d";
        lblSpiegazionePortafoglio.setBackground(sfondo("#f1f4fa", 6));
        lblSpiegazionePortafoglio.setPadding(new Insets(8, 12, 8, 12));
        lblSpiegazionePortafoglio.setLineSpacing(3);
        lblSpiegazionePortafoglio.getChildren().clear();
        rigaSpiegazione(lblSpiegazionePortafoglio, "", "Tra i film dell'anno scelto trova l'insieme di film che, "
                + "messi insieme, porta ai produttori l'utile totale piu' alto, senza superare il budget massimo e il numero massimo di film.\n\n", blu);
        rigaSpiegazione(lblSpiegazionePortafoglio, "", "Scegli l'anno, scrivi il budget massimo in milioni di dollari "
                + "e il numero massimo di film, poi premi \"Trova il portafoglio migliore\".\n\n", blu);
        rigaSpiegazione(lblSpiegazionePortafoglio, "", "Si usano gli accordi di profit-sharing + sliding scale e si considerano solo i film in utile. "
                + "Non basta prendere i film piu' redditizi uno per uno: due film piu' piccoli potrebbero valere di piu' di un film grande "
                + "che occupa quasi tutto il budget.", blu);
    }

    private static Background sfondo(String colore, double raggio) {
        return new Background(new BackgroundFill(Color.web(colore), new CornerRadii(raggio), Insets.EMPTY));
    }

    private static void coloraPulsante(Button b, String colore, String coloreSopra) {
        Background normale = sfondo(colore, 6);
        Background sopra = sfondo(coloreSopra, 6);
        b.setBackground(normale);
        b.setOnMouseEntered(e -> b.setBackground(sopra));
        b.setOnMouseExited(e -> b.setBackground(normale));
        b.setTextFill(Color.WHITE);
        b.setFont(Font.font("System", FontWeight.BOLD, 13));
        b.setPadding(new Insets(7, 12, 7, 12));
        b.setCursor(Cursor.HAND);
    }

    private void applicaColori() {
        barraAlto.setBackground(sfondo("#6d1a36", 8));
        barraAlto.setPadding(new Insets(10, 16, 10, 16));
        for (Node n : barraAlto.getChildren()) {
            if (n instanceof Label) {
                ((Label) n).setTextFill(Color.WHITE);
                ((Label) n).setFont(Font.font("System", FontWeight.BOLD, 13));
            }
        }
        lblTitolo.setTextFill(Color.web("#f7d6d0"));
        lblTitolo.setFont(Font.font("System", FontWeight.BOLD, 17));

        for (Label l : new Label[] { lblAnno1, lblAnno2 }) {
            l.setFont(Font.font("System", FontWeight.BOLD, 13));
        }

        pannelloFilm.setBackground(sfondo("#f9e9e7", 0));
        pannelloPortafoglio.setBackground(sfondo("#e6ecf6", 0));
        coloraPulsante(btnCalcolaFilm, "#7b2142", "#5e1832");
        coloraPulsante(btnGuadagnoProduttore, "#2b4c7e", "#1f3a63");
        coloraPulsante(btnGuadagnoDistributore, "#b76e79", "#9a5560");
        coloraPulsante(btnReset, "#6c7a99", "#56627d");
        coloraPulsante(btnPortafoglio, "#3e5c9a", "#2f4a7d");
    }

    public void setModel(Model model) {
        this.model = model;
        applicaColori();
        scriviSpiegazioni();
        cmbAnno.getItems().addAll(model.getAnni());
        cmbAnnoPortafoglio.getItems().addAll(model.getAnni());
        cmbAccordoProduttore.getItems().addAll(AccordoProduttore.values());
        cmbAccordoEsercente.getItems().addAll(AccordoEsercente.values());
    }
}