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
public class Candidatura {
    private String candidato;
    private String vice_candidato;
    private int ano;
    private String cargo;
    private String local;
    private String tipoLocal;
    private String partido;

    public Candidatura(String candidato, String vice_candidato, int ano, String cargo, String local, String tipoLocal, String partido) {
        this.candidato = candidato;
        this.vice_candidato = vice_candidato;
        this.ano = ano;
        this.cargo = cargo;
        this.local = local;
        this.tipoLocal = tipoLocal;
        this.partido = partido;
    }

    public String getCandidato() {
        return candidato;
    }

    public String getVice_candidato() {
        return vice_candidato;
    }

    public int getAno() {
        return ano;
    }

    public String getCargo() {
        return cargo;
    } 

    public String getLocal() {
        return local;
    }

    public String getTipoLocal() {
        return tipoLocal;
    }

    public String getPartido() {
        return partido;
    }
    
    
}
