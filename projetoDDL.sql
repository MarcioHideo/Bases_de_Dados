-- DROP TABLE individuo,empresa,processo_judicial,julgamento,cargo,partido,candidatura,pleito,doacao,doacao_juridica,membro_equipe,equipe
-- DROP TYPE cargo_tipo, local_tipo

CREATE TABLE IF NOT EXISTS individuo (
	cpf VARCHAR(11),
	nome VARCHAR NOT NULL,
	data_nascimento DATE NOT NULL,
	ficha_limpa BOOLEAN DEFAULT TRUE,
	
	CONSTRAINT individuo_pk PRIMARY KEY(cpf),
	CONSTRAINT individuo_un UNIQUE(nome)
);

CREATE TABLE IF NOT EXISTS empresa (
	cnpj VARCHAR(14),
	nome VARCHAR NOT NULL,
	
	CONSTRAINT empresa_cnpj PRIMARY KEY(cnpj),
	CONSTRAINT empresa_un UNIQUE(nome)
);

CREATE TABLE IF NOT EXISTS processo_judicial (
	num_processo SERIAL,
	crime VARCHAR NOT NULL,
	
	CONSTRAINT processo_judicial_pk PRIMARY KEY(num_processo)
);

CREATE TABLE IF NOT EXISTS julgamento(
	cpf	 VARCHAR NOT NULL,
	num_processo INTEGER NOT NULL,
	procedente BOOLEAN DEFAULT FALSE,
	data DATE,
	
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

CREATE TYPE cargo_tipo AS ENUM('presidente','deputado','prefeito');
CREATE TYPE local_tipo AS ENUM('pais','estado','cidade','distrito');

CREATE TABLE IF NOT EXISTS cargo (
	nome cargo_tipo NOT NULL,
	cadeiras INTEGER DEFAULT 0,
	local VARCHAR NOT NULL,
	tipoLocal local_tipo NOT NULL,
	salario INTEGER NOT NULL, 
	
	CONSTRAINT cargo_pk PRIMARY KEY(nome,local,tipoLocal)
);

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
	candidato VARCHAR NOT NULL,
	num_votos INTEGER DEFAULT 0,
	
	CONSTRAINT pleito_pk PRIMARY KEY(ano,candidato),
	CONSTRAINT pleito_fk_candidato
		FOREIGN KEY(candidato,ano)
		REFERENCES candidatura(candidato,ano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT num_votos_positive CHECK (num_votos > 0),
	CONSTRAINT pleito_ano CHECK(ano > 1800 AND ano < 3000)
);

CREATE TABLE IF NOT EXISTS doacao(
	valor INTEGER NOT NULL,
	doador VARCHAR NOT NULL,
	candidato VARCHAR NOT NULL,
	ano INTEGER NOT NULL,
	id SERIAL, 
	
	CONSTRAINT doacao_pk PRIMARY KEY(id),
	CONSTRAINT doacao_fk_doador
		FOREIGN KEY(doador)
		REFERENCES individuo(cpf)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT doacao_fk_candidatura
		FOREIGN KEY(candidato,ano)
		REFERENCES candidatura(candidato,ano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT doacao_ano CHECK(ano > 1800 AND ano < 3000),
	CONSTRAINT doacao_valor_positive CHECK(valor > 0)
);

CREATE TABLE IF NOT EXISTS doacao_juridica(
	valor INTEGER NOT NULL,
	doador VARCHAR NOT NULL,
	candidato VARCHAR NOT NULL,
	ano INTEGER NOT NULL,
	
	CONSTRAINT doacao_juridica_pk PRIMARY KEY(doador,candidato,ano),
	CONSTRAINT doacao_juridica_fk_doador
		FOREIGN KEY(doador)
		REFERENCES empresa(cnpj)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT doacao_juridica_fk_candidatura
		FOREIGN KEY(candidato,ano)
		REFERENCES candidatura(candidato,ano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT doacao_juridica_ano CHECK(ano > 1800 AND ano < 3000),
	CONSTRAINT doacao_juridica_valor_positive CHECK(valor > 0)
);

CREATE TABLE IF NOT EXISTS equipe(
	nome VARCHAR NOT NULL,
	candidato VARCHAR NOT NULL,
	ano INTEGER NOT NULL,
	
	CONSTRAINT equipe_pk PRIMARY KEY(nome,ano),
	CONSTRAINT equipe_fk_candidatura
		FOREIGN KEY(candidato,ano)
		REFERENCES candidatura(candidato,ano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT equipe_ano CHECK(ano > 1800 AND ano < 3000)
);

CREATE TABLE IF NOT EXISTS membro_equipe (
	membro VARCHAR NOT NULL,
	equipe VARCHAR NOT NULL,
	ano INTEGER NOT NULL,
	
	CONSTRAINT membro_equipe_pk PRIMARY KEY(membro,ano),
	CONSTRAINT membro_equipe_fk_equipe
		FOREIGN KEY(equipe,ano)
		REFERENCES equipe(nome,ano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT membro_equipe_fk_membro 
		FOREIGN KEY(membro)
		REFERENCES individuo(cpf)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT membro_equipe_ano CHECK(ano > 1800 AND ano < 3000)
);

--	Só podem se candidatar indivíduos ficha-limpa;
CREATE OR REPLACE FUNCTION rejeitar_candidato_sujo() RETURNS trigger AS $rejeitar_candidato_sujo$
DECLARE
	candidato_row individuo;
BEGIN
	SELECT INTO candidato_row * FROM individuo WHERE cpf = NEW.candidato;
	IF(candidato_row.ficha_limpa = FALSE) THEN
		RAISE EXCEPTION 'Não é possível candidatar-se o indivíduo, pois possui uma ficha não limpa.';
	END IF;
	RETURN NEW;
END;
$rejeitar_candidato_sujo$ LANGUAGE plpgsql;

-- 	Responsável em impedir o INSERT de candidatos com 
-- ficha suja na tabela de candidatura.
--DROP TRIGGER RejeitarCandidatoComFichaSuja ON CANDIDATURA
CREATE TRIGGER RejeitarCandidatoComFichaSuja
	BEFORE INSERT OR UPDATE ON Candidatura
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

CREATE OR REPLACE FUNCTION update_individuos_ficha() RETURNS trigger AS $update_individuos_ficha$
DECLARE
	years_difference integer;
	individuo_row individuo;
BEGIN
	SELECT INTO individuo_row * FROM individuo WHERE cpf = NEW.cpf; 
	SELECT INTO years_difference DATE_PART('year', AGE(current_date, NEW.data));
	IF(NEW.procedente <> OLD.procedente OR OLD.procedente IS NULL) THEN 
		IF(NEW.procedente = true AND years_difference <= 5 AND individuo_row.ficha_limpa = true) THEN
			UPDATE individuo SET ficha_limpa = false WHERE cpf = NEW.cpf;
		ELSEIF(NEW.procedente = false AND individuo_row.ficha_limpa = false) THEN
			RAISE NOTICE'% possui uma ficha limpa agora.',individuo_row.nome;
			UPDATE individuo SET ficha_limpa = true WHERE cpf = NEW.cpf;
		END IF;
	END IF;
	RETURN NEW;
END;
$update_individuos_ficha$ LANGUAGE plpgsql;

-- 	Para toda vez que haver um julgamento novo ou atualizado
-- com o procedente alterado,verificar-se a necessidade de alterar
-- a ficha do individuo
--DROP TRIGGER AtualizarFichaDosIndividuos ON julgamento
CREATE TRIGGER AtualizarFichaDosIndividuos
	AFTER UPDATE OR INSERT ON julgamento
	FOR EACH ROW EXECUTE PROCEDURE update_individuos_ficha();

CREATE OR REPLACE FUNCTION update_individuos_ficha_for_deleted_cases() RETURNS trigger AS $update_individuos_ficha_for_deleted_cases$
DECLARE
	years_difference integer;
	individuo_row individuo;
BEGIN
	SELECT INTO individuo_row * FROM individuo WHERE cpf = OLD.cpf; 
	SELECT INTO years_difference DATE_PART('year', AGE(current_date, OLD.data));
	IF(individuo_row.ficha_limpa = false AND OLD.procedente = true AND years_difference <= 5) THEN 
		RAISE NOTICE'% possui uma ficha limpa agora.',individuo_row.nome;
		UPDATE individuo SET ficha_limpa = true WHERE cpf = OLD.cpf;
	END IF;
	RETURN NEW;
END;
$update_individuos_ficha_for_deleted_cases$ LANGUAGE plpgsql;

--	Quando deletar um julgamento que culpava um individuo é deletado,
--retira a ficha suja do individuo que era culpado.
--DROP TRIGGER AtualizarFichaDosIndividuosAposRemocaoDeJulgamento ON julgamento
CREATE TRIGGER AtualizarFichaDosIndividuosAposRemocaoDeJulgamento
	AFTER DELETE ON julgamento
	FOR EACH ROW EXECUTE PROCEDURE update_individuos_ficha_for_deleted_cases();
