package bd_projeto2;

//Lista de importações necessárias para funcionamento do programa
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
import java.util.Scanner;

public class BD_Projeto2 {
    private static String url;
    private static String user;
    private static String senha;

    public static void main(String[] args) throws IOException {
        Statement stmt;
        ResultSet rs, rsBuffer = null;
        Connection connection;
        PreparedStatement pstmt;
        Cargo cargoTemp;
        boolean controller = true;
        int count = 1;
        
        ArrayList<Cargo> cargo = new ArrayList<Cargo>();

        try {
            // CONEXÃO
            Class.forName("org.postgresql.Driver");
            url = "jdbc:postgresql://localhost:5432/postgres";
            user = "postgres";
            senha = "senha";
            connection = DriverManager.getConnection(url,user,senha);
            stmt = connection.createStatement();

            while(controller)
            {
                System.out.println("GERENCIAMENTO DE SISTEMA ELEITORAL\n\nMENU");
                System.out.println("1-Listar e Remover todos os dados relativos ao problema.\n"
                        + "2-Listagem de candidaturas.\n"
                        + "3-Gerecao de relatorio de candidaturas.\n"
                        + "4-Lista de pessoas com ficha limpa.\n"
                        + "5-Finalizar.\n"
                        + "Digite uma das opcoes acima para executar a operacao desejada: ");

                Scanner sc = new Scanner(System.in).useDelimiter("\n");
               int option = sc.nextInt();
               switch(option)
               {
                    case 1 -> 
                    {
                        //  Listar (SELECT) e remover (DELETE) todos os dados relativos ao problema, graficamente,
                        //  considerando todas as entidades e todos os relacionamentos;

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
                        while (true) 
                        {
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

                                while (rs.next()) 
                                {
                                    System.out.print(rs.getString("COLUMN_NAME") + ": ");
                                    stringBuffer = bufferRead.readLine();

                                    if (stringBuffer.startsWith("empty_")) 
                                    {
                                        delete += rs.getString("COLUMN_NAME") + " = " + stringBuffer + " AND ";
                                    } 
                                    else 
                                    {
                                        delete += rs.getString("COLUMN_NAME") + " = '" + stringBuffer + "' AND ";
                                    }
                                }
                                // Retira última virgula e fecha parenteses
                                delete = delete.substring(0, delete.length() - 5);
                                System.out.println(delete);

                                pstmt = connection.prepareStatement(delete);
                                try 
                                {
                                    pstmt.executeUpdate();
                                } 
                                catch (SQLException e) 
                                {
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
                        break;
                    }
                    case 2 ->
                    {
                        //  Listagem de candidaturas, considerando ano, nome de candidato ou cargo, e combinações
                        //  destes, segundo diferentes ordenações;
                        System.out.print("Digite o ano desejado (digite 0 caso queira listar todos os anos): ");
                            String anoCandidatura = sc.next();
                        System.out.print("Digite o nome do candidato (digite 0 caso queira listar todos os candidatos): ");
                            String nomeCandidato = sc.next();
                        System.out.print("Digite o cargo (digite 0 caso queira listar todos os cargos): ");
                            String cargoCandidato = sc.next();
                        System.out.print("Escolha o tipo de ordenação que deseja: ");
                            String ordenacao = sc.next();

                        if ("nome".equals(ordenacao))
                            ordenacao = "candidato_nome";
                        if (!"0".equals(nomeCandidato) )
                            nomeCandidato = " AND I.nome =  '" +  nomeCandidato + "'";
                        else
                            nomeCandidato = " ";                
                        if (!"0".equals(cargoCandidato))
                            cargoCandidato = " AND C.cargo = '" + cargoCandidato + "'";
                        else
                            cargoCandidato = "";
                        if (!"0".equals(anoCandidatura))
                            anoCandidatura = " AND C.ano = " + anoCandidatura ;
                        else
                            anoCandidatura = "";
                        rs = stmt.executeQuery(
                                "SELECT candidato_nome ,cargo,local,partido, I.nome AS vice_nome, ano FROM individuo I RIGHT JOIN"
                                + "(SELECT I.nome  AS candidato_nome, ano, vice_candidato AS vice_cpf,cargo,local,partido  FROM candidatura C, individuo I WHERE C.candidato = I.cpf "
                                + nomeCandidato
                                + cargoCandidato
                                + anoCandidatura
                                + ") X ON I.cpf = vice_cpf "
                                + " ORDER BY " + ordenacao
                        );

                        System.out.println("\nCASO 2: Listagem Candidaturas:");
                        while (rs.next()) 
                        {
                           System.out.println("Candidato: " +rs.getString("candidato_nome") 
                                   + " - Vice: " + rs.getString("vice_nome") 
                                   + " - Ano: " + rs.getInt("ano")
                                   + " - Cargo: " + rs.getString("cargo")
                                   + " - Local: " + rs.getString("local")
                                   + " - Partido: " + rs.getString("partido")
                           );
                        }
                        break;
                    }
                    case 3 ->
                    {
                    //  Geração de relatório de candidaturas, indicando quais 
                    //  são os candidatos eleitos, inclusive os vices quando for o caso
                        System.out.println("\nCASO 3: Geracao de relatorio de candidaturas:");
                        rs = stmt.executeQuery("SELECT * FROM cargo ORDER BY nome");
                        count = 1;
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
                        System.out.print("\nEscolha um dos cargos que deseja ver quem foram os eleitos: ");
                        int cargoID = sc.nextInt();
                        System.out.print("De qual ano deseja : ");
                        int ano = sc.nextInt();

                        cargoTemp = cargo.get(cargoID-1);

                        rs = stmt.executeQuery(
                                        "SELECT I.nome AS vice_nome, num_votos,candidato_nome From individuo I RIGHT JOIN " +
                                        "(SELECT num_votos,nome AS candidato_nome, C.vice_candidato AS vice "
                                        + " FROM candidatura C, pleito P, individuo I WHERE C.candidato = P.candidato AND P.ano = "
                                        + ano + " AND C.cargo = '" + cargoTemp.getNome()
                                        + "' AND C.local = '" + cargoTemp.getLocal() 
                                        + "' AND C.tipoLocal = '" + cargoTemp.getTipoLocal() 
                                        + "' AND I.cpf = C.candidato ORDER BY num_votos DESC) X"
                                        + " ON X.vice = I.cpf "
                                    );

                        count = 1;
                        boolean hasColumn = false;
                        System.out.println("Eleitos: ");
                        while(rs.next() && count <= cargoTemp.getCadeiras())
                        {   

                            System.out.println(count + "  -  " 
                                    + "Total de votos: " + rs.getInt("num_votos")
                                    + "| Nome: " + rs.getString("candidato_nome")
                                    + "| Vice: " + rs.getString("vice_nome")
                            );          
                            count++;
                            hasColumn = true;
                        }
                        if(!hasColumn)
                            System.out.println("Não há eleitos no ano e cargo selecionados.");
                        cargo.clear();
                        break;
                    }


                    case 4 ->
                    { 
                        System.out.println("\nCASO 4: Listagem de individuos com ficha limpa:");
                        rs = stmt.executeQuery("SELECT * FROM individuo WHERE ficha_limpa = true ");
                        while (rs.next()) 
                        {
                            System.out.println("CPF: " +rs.getString("cpf") + " | Data_nascimento: "
                                    + rs.getDate("data_nascimento") + " | Nome:"
                                    + rs.getString("Nome")
                            );
                        }
                        break;
                    }
                    case 5 ->
                    {
                        System.out.println("Operação Finalizada");
                        controller = false;
                        break;
                    }
                    default ->
                    {   
                        System.out.println("Número inválido");
                        break;
                    }
               }
                System.out.println("-----------------------------------------------------------------------------");
           
            }
            connection.close();
            stmt.close();
        } 
        catch (ClassNotFoundException | SQLException ex) 
        {
            System.out.println("Error: "+ex.getMessage());
        }
    }
}