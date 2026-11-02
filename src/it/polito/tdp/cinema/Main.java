package it.polito.tdp.cinema;

import it.polito.tdp.cinema.model.Model;
import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;

public class Main extends Application {

    @Override
    public void start(Stage stage) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("FXML.fxml"));
            BorderPane root = loader.load();
            FXMLController controller = loader.getController();
            controller.setModel(new Model());

            stage.setScene(new Scene(root));
            stage.setTitle("Portafoglio film");
            stage.show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        launch(args);
    }
}