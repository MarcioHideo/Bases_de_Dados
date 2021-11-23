/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package bd_projeto2;

/**
 *
 * @author marcio
 */
public class Cargo {
    private String nome;
    private String local;
    private String tipoLocal;
    private int cadeiras;
    private int salario;
    
    public Cargo(String nome, String local, String tipoLocal,int cadeiras, int salario)
    {
        this.nome = nome;
        this.local = local;
        this.tipoLocal = tipoLocal;
        this.cadeiras = cadeiras;
        this.salario = salario;
    } 
    
    public void printCargo()
    {
        System.out.println(nome + "| Local: "
                        + local + "| Cadeiras disponiveis: "
                        + cadeiras +  "| Salario: "
                        + salario);
    }

    public String getNome() {
        return nome;
    }

    public String getLocal() {
        return local;
    }

    public String getTipoLocal() {
        return tipoLocal;
    }

    public int getCadeiras() {
        return cadeiras;
    }

    public int getSalario() {
        return salario;
    }
    
    
    
}
