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

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.ArrayList;
import java.util.logging.Logger;

public class BD_Projeto2 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        Statement stmt;
        ResultSet rs;
        Connection connection;
        PreparedStatement pstmt;
        Cargo cargoTemp;
        int count = 1;
        int ano;
        String vice;
        ArrayList<Cargo> cargo = new ArrayList<Cargo>();
        ArrayList<Candidatura> candidatura = new ArrayList<Candidatura>();


        try {
            /*CONEXÃO*/
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres",
                    "postgres",
                    "senha");
            
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
            System.out.println("Escolha um dos cargos que deseja ver quem forams os eleitos: ");
            System.out.println("De qual ano deseja : ");
            cargoTemp = cargo.get(0);//TODO, depende da escolha do usuario o cargo
            ano = 2020;// TODO, valor a ser lido no snc
            rs = stmt.executeQuery(
                            "SELECT C.candidato AS CPF ,num_votos,nome, C.vice_candidato AS vice "
                            + " FROM candidatura C, pleito P, individuo I WHERE C.candidato = P.candidato AND P.ano = "
                            + ano + " AND C.cargo = '" + cargoTemp.getNome()
                            + "' AND C.local = '" + cargoTemp.getLocal() 
                            + "' AND C.tipoLocal = '" + cargoTemp.getTipoLocal() 
                            + "' AND I.cpf = C.candidato ORDER BY num_votos DESC"
                        );
           
            count = 1;
            System.out.println("Eleitos: ");
            while(rs.next() && count <= cargoTemp.getCadeiras())
            {   
               
                System.out.println(count + "  -  " 
                        + "Total de votos: " + rs.getInt("num_votos")
                        + "| CPF: " + rs.getString("CPF")
                        + "| Nome: " + rs.getString("nome")
                        + "| Vice: " 
                );          
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
        } catch (ClassNotFoundException | SQLException ex) {
            System.out.println("Error: "+ex.getMessage());
        }
        System.out.println("Fim");
    }
}

