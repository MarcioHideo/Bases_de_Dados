-- DROP TABLE individuo,empresa,processo_judicial,julgamento,cargo,partido,candidatura,pleito,doacao,doacao_juridica,membro_equipe
-- DROP TYPE cargo_tipo, local_tipo

--POSSIVEIS POBLEMAS NO MOMENTO:
--	(1)SE O INSERT NA TABELA DAR ERRO, DEVIDO A REPETICAO DO UNIQUE KEY, O SEQUENCE
--É INCREMETADO DE QUALQUER MODO, OU SEJA, SE FAZER INSERT DE NOVO, O ID QUE DEVERIA
--SER 2 POR EXEMPLO, VAI SER O VALOR DE 4, JA QUE CONTABILIZOU NO INSERT QUE HOUVE ERRO


--TODO triggers
--	Cada cargo deve ter uma quantidade de eleitos – por exemplo, a presidência só pode ter um único
--eleito; o cargo de deputado federal pode ter até 500 eleitos

--TODO no MER e CROWS FOOT
--	(1)Retirar da heranca no MER e CROWS FOOT
--  (2)Adicionar empresa no MER e Crows foot
--	(3)remover programa_partido
--	(4)adicionar atributo 'partido' na candidatura
-- 	(5)Nao ha entidade equipe mais, somente membro_equipe com relacao direta com a candidatura


CREATE TABLE IF NOT EXISTS individuo (
	cpf VARCHAR, -- TODO colocar condicao para inserir cpf_cnpj com digitos corretos
	nome VARCHAR NOT NULL,
	data_nascimento DATE NOT NULL,
	ficha_limpa BOOLEAN DEFAULT TRUE,
	
	CONSTRAINT individuo_pk PRIMARY KEY(cpf),
	CONSTRAINT individuo_un UNIQUE(nome)
);

CREATE TABLE IF NOT EXISTS empresa (
	cnpj VARCHAR,
	nome VARCHAR NOT NULL,
	
	CONSTRAINT empresa_cnpj PRIMARY KEY(cnpj),
	CONSTRAINT empresa_un UNIQUE(nome)
);

CREATE SEQUENCE processo_id;
CREATE TABLE IF NOT EXISTS processo_judicial (
	num_processo INTEGER NOT NULL DEFAULT nextval('processo_id'),
	crime VARCHAR NOT NULL,
	procedente BOOLEAN DEFAULT FALSE,
	
	CONSTRAINT processo_judicial_pk PRIMARY KEY(num_processo)
);
ALTER SEQUENCE processo_id OWNED BY processo_judicial.num_processo;

CREATE TABLE IF NOT EXISTS julgamento(
	cpf	 VARCHAR NOT NULL,
	num_processo INTEGER NOT NULL,
	data DATE  NOT NULL,
	
	CONSTRAINT julgamento_pk PRIMARY KEY(cpf,num_processo),
	CONSTRAINT julgamento_fk_cpf
		FOREIGN KEY (cpf)
		REFERENCES individuo(cpf)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT julgamento_fk_num_processo
		FOREIGN KEY (num_processo)
		REFERENCES processo_judicial(num_processo)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

--Cada candidatura deve ter um pleito associado;
--Um pleito deve indicar a quantidade de votos recebida por cada candidato para cada cargo, em
--cada ano; isto é, cada candidatura deve gerar uma votação para um dado candidato;
--Cada cargo deve ter uma quantidade de eleitos – por exemplo, a presidência só pode ter um único
--eleito; o cargo de deputado federal pode ter até 500 eleitos;

--Podemos criar um trigger que faz um SET na quantidade de cadeiras que podem ter no cargo, 
--que eh ativado tds vez que faz um INSERT

CREATE TYPE cargo_tipo AS ENUM('presidente','deputado');
CREATE TYPE local_tipo AS ENUM('pais','estado','cidade','distrito');

CREATE TABLE IF NOT EXISTS cargo (
	nome cargo_tipo NOT NULL,
	cadeiras INTEGER DEFAULT 0, --nao sei o que fazer com isso
	local VARCHAR NOT NULL,
	tipoLocal local_tipo NOT NULL,
	salario INTEGER NOT NULL, 
	
	CONSTRAINT cargo_pk PRIMARY KEY(nome,local,tipoLocal)
	-- ha algum check que precisa ser feito
);

--Todo candidato deve ter um partido, que deve ser único;
--Cada partido deve ter um programa (texto explicativo de suas intenções);
CREATE TABLE IF NOT EXISTS partido(
	nome VARCHAR NOT NULL,
	programa VARCHAR NOT NULL,
	
	CONSTRAINT partido_pk PRIMARY KEY(nome)
);


CREATE TABLE IF NOT EXISTS candidatura (
	candidato VARCHAR NOT NULL,
	vice_candidato VARCHAR DEFAULT NULL, 
	ano INTEGER NOT NULL,
	cargo cargo_tipo NOT NULL,
	local VARCHAR NOT NULL,
	tipoLocal local_tipo NOT NULL,
	partido VARCHAR NOT NULL,
	
	CONSTRAINT candidatura_pk PRIMARY KEY(candidato,ano),
	--So pode assumir um cargo num determinado ano uma vez so
	CONSTRAINT candidatura_cargo_un UNIQUE (cargo,local,tipoLocal,candidato,ano), 
	
	CONSTRAINT candidatura_fk_candidato
		FOREIGN KEY(candidato)
		REFERENCES individuo(cpf)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT candidatura_fk_vice_candidato
		FOREIGN KEY(vice_candidato)
		REFERENCES individuo(cpf)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT candidatura_fk_cargo
		FOREIGN KEY(cargo,local,tipoLocal)
		REFERENCES cargo(nome,local,tipoLocal)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT candidatura_fk_partido 
		FOREIGN KEY(partido)
		REFERENCES partido(nome)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	
	CONSTRAINT candidato_distinct_vice CHECK(candidato <> vice_candidato),
	CONSTRAINT candidatura_ano CHECK(ano > 1800 AND ano < 3000)
);

CREATE TABLE IF NOT EXISTS pleito (
	ano INTEGER NOT NULL,
	candidatura VARCHAR NOT NULL,
	num_votos INTEGER DEFAULT 0,
	
	CONSTRAINT pleito_pk PRIMARY KEY(ano,candidatura),
	CONSTRAINT pleito_fk_candidatura
		FOREIGN KEY(candidatura,ano)
		REFERENCES candidatura(candidato,ano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT num_votos_positive CHECK (num_votos > 0) 
);

CREATE SEQUENCE doacao_seq;
CREATE TABLE IF NOT EXISTS doacao(
	valor INTEGER NOT NULL,
	doador VARCHAR NOT NULL,
	candidatura VARCHAR NOT NULL,
	ano INTEGER NOT NULL,
	id INTEGER NOT NULL DEFAULT nextval('doacao_seq'), --pode doar varias vezes
	
	CONSTRAINT doacao_pk PRIMARY KEY(doador,candidatura,ano,id),
	CONSTRAINT doacao_fk_doador
		FOREIGN KEY(doador)
		REFERENCES individuo(cpf)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT doacao_fk_candidatura
		FOREIGN KEY(candidatura,ano)
		REFERENCES candidatura(candidato,ano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT doacao_ano CHECK(ano > 1800 AND ano < 3000),
	CONSTRAINT doacao_valor_positive CHECK(valor > 0)
);
ALTER SEQUENCE doacao_seq OWNED BY doacao.id;

CREATE TABLE IF NOT EXISTS doacao_juridica(
	valor INTEGER NOT NULL,
	doador VARCHAR NOT NULL,
	candidatura VARCHAR NOT NULL,
	ano INTEGER NOT NULL,
	
	CONSTRAINT doacao_juridica_pk PRIMARY KEY(doador,candidatura,ano),
	CONSTRAINT doacao_juridica_fk_doador
		FOREIGN KEY(doador)
		REFERENCES empresa(cnpj)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT doacao_juridica_fk_candidatura
		FOREIGN KEY(candidatura,ano)
		REFERENCES candidatura(candidato,ano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT doacao_juridica_ano CHECK(ano > 1800 AND ano < 3000),
	CONSTRAINT doacao_juridica_valor_positive CHECK(valor > 0)
);

CREATE TABLE IF NOT EXISTS equipe(
	nome VARCHAR NOT NULL,
	candidatura VARCHAR NOT NULL,
	ano INTEGER NOT NULL,
	
	CONSTRAINT equipe_pk PRIMARY KEY(nome),
	CONSTRAINT equipe_fk_candidatura
		FOREIGN KEY(candidatura,ano)
		REFERENCES candidatura(candidato,ano)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS membro_equipe (
	membro VARCHAR NOT NULL,
	candidatura VARCHAR NOT NULL,
	ano INTEGER NOT NULL,
	
	CONSTRAINT membro_equipe_pk PRIMARY KEY(membro,candidatura,ano),
	CONSTRAINT membro_equipe_fk_candidatura
		FOREIGN KEY(candidatura,ano)
		REFERENCES candidatura(candidato,ano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT membro_equipe_fk_membro 
		FOREIGN KEY(membro)
		REFERENCES individuo(cpf)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

--	Só podem se candidatar indivíduos ficha-limpa;
CREATE OR REPLACE FUNCTION rejeitar_candidato_sujo() RETURNS trigger AS $rejeitar_candidato_sujo$
DECLARE
	candidato_row individuo;
BEGIN
	SELECT INTO candidato_row * FROM individuo WHERE cpf = NEW.candidato;
	IF(candidato_row.ficha_limpa = FALSE) THEN
		RAISE EXCEPTION 'Não é possível candidatar-se o indivíduo, pois possui uma ficha não limpa.';
		ROLLBACK;
	END IF;
	RETURN NEW;
END;
$rejeitar_candidato_sujo$ LANGUAGE plpgsql;

-- 	Responsável em impedir o INSERT de candidatos com 
-- ficha suja na tabela de candidatura.
--DROP TRIGGER RejeitarCandidatoComFichaSuja ON CANDIDATURA
CREATE TRIGGER RejeitarCandidatoComFichaSuja
	AFTER INSERT OR UPDATE ON Candidatura
	FOR EACH ROW EXECUTE PROCEDURE rejeitar_candidato_sujo();
	
CREATE OR REPLACE FUNCTION update_candidatura() RETURNS trigger AS $update_candidatura$
DECLARE
	candidato_row candidatura;
BEGIN
	SELECT INTO candidato_row * FROM candidatura WHERE candidato = NEW.cpf;
	IF(NEW.ficha_limpa = FALSE) THEN
		RAISE NOTICE '% não pode candidatar-se, pois agora possui uma ficha suja.',NEW.nome;
		DELETE FROM candidatura WHERE candidato = NEW.cpf;
	END IF;
	RETURN NULL;
END;
$update_candidatura$ LANGUAGE plpgsql;

--	O trigger é somente utilizado em UPDATE na tabela de individuo
--para caso um dos individuos ,que são candidatos, alteram para uma 
--ficha suja .Desse modo, são removidos da tabela candidatura, pois
--é proibido ter candidatos com ficha não limpa
--DROP TRIGGER RemoverCandidatoComFichaSuja ON individuo
CREATE TRIGGER RemoverCandidatoComFichaSuja
	AFTER UPDATE ON individuo
	FOR EACH ROW EXECUTE PROCEDURE update_candidatura();

--TODO apagar depois, somente usado para testar triggers
SELECT I.CPF,I.NOME,I.FICHA_LIMPA FROM CANDIDATURA C, INDIVIDUO I WHERE I.CPF = C.CANDIDATO
INSERT INTO candidatura VALUES('86713773427',NULL,2019,'deputado','Mogi das Cruzes','cidade','Partido dos Padeiro');
DELETE FROM CANDIDATURA WHERE CANDIDATURA.CANDIDATO = '86713773427'
SELECT * FROM CANDIDATURA


