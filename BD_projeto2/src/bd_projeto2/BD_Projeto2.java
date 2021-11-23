/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 *
 * @author Marcio Hideo
 */
package bd_projeto2;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.ArrayList;
import java.util.logging.Logger;

/**
 *
 * @author Junio
 */
public class BD_Projeto2 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        Statement stmt;
        ResultSet rs;
        Connection connection;
        PreparedStatement pstmt;
        int count = 1;
        ArrayList<Cargo> cargo = new ArrayList<Cargo>();
        

        try {
            /*CONEXÃO*/
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres",
                    "postgres",
                    "senha");
            
//            stmt = connection.createStatement();
//            rs = stmt.executeQuery("SELECT * FROM individuo");
//            while (rs.next()) {
//                System.out.println(rs.getString("Nome") + "-"
//                        + rs.getString("cpf") 
//                );
//            }
            System.out.println("GERENCIAMENTO DE SISTEMA ELEITORAL\n\nMENU");
            System.out.println("1-Listar e Remover todos os dados relativos ao problema.\n2-Listagem de candidaturas.\n3-Gerecao de relatorio de candidaturas.\n4-Lista de pessoas com ficha limpa.\n5-Finalizar.\nDigite uma das opcoes acima para executar a operacao desejada: ");
//            TODO, adicionar as funcionalidades
//            TODO, adicionar o scanner com os cases para diferenciar cada caso
            stmt = connection.createStatement();
//        - Geração de relatório de candidaturas, indicando quais 
//        são os candidatos eleitos, inclusive os vices quando for o caso
            System.out.println("\nCASO 3: Gerecao de relatorio de candidaturas:");
            rs = stmt.executeQuery("SELECT * FROM cargo ORDER BY nome");
            while(rs.next())
            {   
                System.out.print(count + " - ");
                cargo.add(new Cargo(
                        rs.getString("nome"),
                        rs.getString("local"),
                        rs.getString("tipoLocal"),
                        rs.getInt("cadeiras"),
                        rs.getInt("salario")
               ));
                cargo.get(count-1).printCargo();
                count++;
            }

            System.out.println("\nCASO 4: Listagem de individuos com ficha limpa:");
            rs = stmt.executeQuery("SELECT * FROM individuo WHERE ficha_limpa = true ");
            while (rs.next()) 
            {
                System.out.println("CPF: " +rs.getString("cpf") + " | Data_nascimento: "
                        + rs.getDate("data_nascimento") + " | Nome:"
                        + rs.getString("Nome")
                );
            }
            connection.close();
        } catch (Exception ex) {
            System.out.println("Error: "+ex.getMessage());
        }
        System.out.println("Fim");
    }
}

