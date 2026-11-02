module FalconeLudovica {
    requires java.sql;
    requires javafx.controls;
    requires javafx.fxml;

    opens it.polito.tdp.cinema to javafx.fxml;
    exports it.polito.tdp.cinema;
}