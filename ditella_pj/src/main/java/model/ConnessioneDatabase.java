package model;

import org.apache.tomcat.jdbc.pool.DataSource;
import org.apache.tomcat.jdbc.pool.PoolProperties;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.TimeZone;

public class ConnessioneDatabase {
    private static DataSource dataSource;

    public static Connection getConnection() throws SQLException {
        if(dataSource == null) {
            PoolProperties poolProperties = new PoolProperties();

            poolProperties.setUrl("jdbc:mysql://localhost:3306/autoquest?serverTimezone=" + TimeZone.getDefault().getID());
            poolProperties.setDriverClassName("com.mysql.cj.jdbc.Driver");
            poolProperties.setUsername("root");
            poolProperties.setPassword("74739.Sara");

            //Parametri per la gestione della pool
            poolProperties.setInitialSize(5); //Connessioni iniziali
            poolProperties.setMaxActive(50); //Massimo numero di connessioni contemporanee
            poolProperties.setMinIdle(2); //Minimo numero connessioni inattive
            poolProperties.setMaxIdle(10); //Massimo numero di connessioni inattive

            //Recupero connessioni abbandonate
            poolProperties.setRemoveAbandoned(true);
            poolProperties.setRemoveAbandonedTimeout(60);


            dataSource = new DataSource();
            dataSource.setPoolProperties(poolProperties);

        }
        return dataSource.getConnection();
    }
}
