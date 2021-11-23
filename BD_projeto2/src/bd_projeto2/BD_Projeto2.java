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
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

public class BD_Projeto2 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException, SQLException {
        Statement stmt;
        ResultSet rs, rsBuffer = null;
        Connection connection;
        PreparedStatement pstmt;
        Cargo cargoTemp;
        int count = 1;
        int ano;
        String vice;
        ArrayList<Cargo> cargo = new ArrayList<Cargo>();
        ArrayList<Candidatura> candidatura = new ArrayList<Candidatura>();


        try {
            // CONEXÃO
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres",
                    "postgres",
                    "senha");
            
            System.out.println("GERENCIAMENTO DE SISTEMA ELEITORAL\n\nMENU");
            System.out.println(""
                    + "1-Listar e Remover todos os dados relativos ao problema.\n"
                    + "2-Listagem de candidaturas.\n"
                    + "3-Geracao de relatorio de candidaturas.\n"
                    + "4-Lista de pessoas com ficha limpa.\n"
                    + "5-Finalizar.\n"
                    + "Digite uma das opcoes acima para executar a operacao desejada: "
                    + "");
//            TODO, adicionar as funcionalidades
//            TODO, adicionar o scanner com os cases para diferenciar cada caso
            stmt = connection.createStatement();
            
            // A partir daqui é o caso 1
            Statement stmtBuffer = connection.createStatement();
            
            
            System.out.println("\nCASO 1: Listar e Remover todos os dados relativos ao problema.");
            BufferedReader bufferRead = new BufferedReader(new InputStreamReader(System.in));
            String reader, nomeTabela = null, select, delete, stringBuffer;
            
            System.out.println("Digite SAIR para interromper");
            System.out.println("Digite um nome de tabela:");
            reader = bufferRead.readLine(); 
                
            // Visto que não informamos a opção de deletar da primeira vez, 
            // fizemos o laço já permitindo a deleção para que a partir da segunda iteração
            // possamos usar a tabela listada anteriormente na delecao e solicitar os dados
            // que queremos excluir.
            while (true) {
                if (reader.compareTo("SAIR") == 0)
                    break;

                if (reader.compareTo("DELETAR") == 0)
                {
                    delete = "DELETE FROM " + nomeTabela + " WHERE ";
                    rs = stmt.executeQuery("SELECT column_name "
                            + "FROM information_schema.columns "
                            + "WHERE table_name='" + nomeTabela + "' "
                            + "ORDER BY ordinal_position");
                    System.out.println("Digite as informações da tupla que deseja deletar.");
                    while (rs.next()) {
                        System.out.print(rs.getString("COLUMN_NAME") + ": ");
                        stringBuffer = bufferRead.readLine();

                        if (stringBuffer.startsWith("empty_")) {
                            delete += rs.getString("COLUMN_NAME") + " = " + stringBuffer + " AND ";
                        } else {
                            delete += rs.getString("COLUMN_NAME") + " = '" + stringBuffer + "' AND ";
                        }
                    }
                    // Retira última virgula e fecha parenteses
                    delete = delete.substring(0, delete.length() - 5);
                    System.out.println(delete);
                    
                    pstmt = connection.prepareStatement(delete);
                    try {
                        pstmt.executeUpdate();
                    } catch (SQLException e) {
                        System.out.println("ERRO: dados NÃO deletados");
                        System.out.println(e.getMessage());
                    }
                    break;
                }
                
                // Aqui é o caso em que foi digitado, idealmente, o nome de uma tabela
                // e iremos imprimir todos os seus dados
                nomeTabela = reader;
                
                select = "SELECT * FROM " + nomeTabela;
                rs = stmt.executeQuery(select);
                
                // Usamos o rsBuffer para pegar os nomes dos atributos e solicitar ao 
                // usuário pelas informações da tupla que deseja deletar.
                rsBuffer = stmtBuffer.executeQuery("SELECT column_name "
                        + "FROM information_schema.columns "
                        + "WHERE table_name='" + nomeTabela + "' "
                        + "ORDER BY ordinal_position");
                
                while (rs.next()) 
                {
                    while (rsBuffer.next())
                    {
                        String nomeDoAtributo = rsBuffer.getString("COLUMN_NAME");
                        System.out.print(nomeDoAtributo + ": " + rs.getString(nomeDoAtributo) + " | ");
                    }
                    // Fazendo a consulta novamente no dicionario para que possamos iterar novamente 
                    // pelo rsBuffer na proxima vez
                    rsBuffer = stmtBuffer.executeQuery("SELECT column_name "
                        + "FROM information_schema.columns "
                        + "WHERE table_name='" + nomeTabela + "' "
                        + "ORDER BY ordinal_position");
                    System.out.println("");
                }
                System.out.println("");
                System.out.println("Digite SAIR para interromper. Digite o nome de outra tabela para listar.");
                System.out.println("Digite 'DELETAR' para excluir algum dado dessa tabela");
                reader = bufferRead.readLine(); 
            }
            
            
//        - Geração de relatório de candidaturas, indicando quais 
//        são os candidatos eleitos, inclusive os vices quando for o caso
            System.out.println("\nCASO 3: Geracao de relatorio de candidaturas:");
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
            System.out.println("Escolha um dos cargos que deseja ver quem foram os eleitos: ");
            System.out.println("De qual ano deseja : ");
            cargoTemp = cargo.get(0);//TODO, depende da escolha do usuario o cargo
            ano = 2020;// TODO, valor a ser lido no snc
            rs = stmt.executeQuery(
                            "SELECT I.nome AS vice_nome, num_votos,candidato_nome FROM individuo I, " +
                            "(SELECT num_votos,nome AS candidato_nome, C.vice_candidato AS vice "
                            + " FROM candidatura C, pleito P, individuo I WHERE C.candidato = P.candidato AND P.ano = "
                            + ano + " AND C.cargo = '" + cargoTemp.getNome()
                            + "' AND C.local = '" + cargoTemp.getLocal() 
                            + "' AND C.tipoLocal = '" + cargoTemp.getTipoLocal() 
                            + "' AND I.cpf = C.candidato ORDER BY num_votos DESC) X"
                            + " WHERE X.vice = I.cpf "
                        );
           
            count = 1;
            System.out.println("Eleitos: ");
            while(rs.next() && count <= cargoTemp.getCadeiras())
            {   
               
                System.out.println(count + "  -  " 
                        + "Total de votos: " + rs.getInt("num_votos")
                        + "| Nome: " + rs.getString("candidato_nome")
                        + "| Vice: " + rs.getString("vice_nome")
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
            stmt.close();
            stmtBuffer.close();
        } catch (ClassNotFoundException | SQLException ex) {
            System.out.println("Error: "+ex.getMessage());
        }
        System.out.println("Fim");
    }
}

