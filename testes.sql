-- DROP TABLE individuo,empresa,processo_judicial,julgamento,cargo,partido,candidatura,pleito,doacao,doacao_juridica,equipe,membro_equipe
-- DROP TYPE cargo_tipo, local_tipo
-- INSERT INTO individuo VALUES('cpf','nome',data_nascimento,fichaLimpa)
-- INSERT INTO empresa VALUES('cnpj','nome')
-- INSERT INTO processo_judicial(crime,procedente) VALUES('crime',boolean)
-- INSERT INTO julgamento VALUES('individuo',num_processo,data)
-- INSERT INTO cargo VALUES(cargo_tipo,cadeiras,local,tipoLocal,salario)
-- INSERT INTO partido VALUES('nome', 'programa')
-- INSERT INTO candidatura VALUES('candidato','vice',ano,cargo,local,tipoLocal,partido)
-- INSERT INTO pleito VALUES(ano,candidatura,num_votos)
-- INSERT INTO doacao VALUES(valor,'doador','candidato',ano)
-- INSERT INTO doacao_juridica VALUES(valor,'doador','candidato',ano)
-- INSERT INTO membro_equipe VALUES('membro','candidatura',ano)

--individuos
INSERT INTO individuo VALUES('81387911600','Manuel Manual','1990-12-09',true); --Cand_pres_PI
INSERT INTO individuo VALUES('22126173135','Ednaldo Pereira','1970-09-02',true);--Cand_pres_PJ
INSERT INTO individuo VALUES('12750152470','Eduardo Santos','2000-10-23',true);--Cand_pres_PP
INSERT INTO individuo VALUES('42758176726','Leandro Gomes','1990-10-23',true);--Cand_vice_pres_PJ
INSERT INTO individuo VALUES('26338856086','Karen Sakiyama','1980-06-18',true);--Cand_vice_pres_PP
INSERT INTO individuo VALUES('68005813724','Gabriela Pereira','1960-07-29',true);--Dep_Mog_PI
INSERT INTO individuo VALUES('80623351358','Paulo Tanaka','1976-01-20',true);--Dep_Mog_PP
INSERT INTO individuo VALUES('59119856598','Silvio Santos','1963-11-30',true);--Dep_Sanca_PJ
INSERT INTO individuo VALUES('79548301288','Ana Paula','1968-03-01',true);--Dep_Sanca_PI
INSERT INTO individuo VALUES('13874257142','Walt Disney','1959-10-23',true);--membro_PI
INSERT INTO individuo VALUES('16126941446','Roger Walker','1978-09-12',true);--membro_PI
INSERT INTO individuo VALUES('30741724286','Rodrigo Rodrigues','1963-07-16',true);--membro_PI
INSERT INTO individuo VALUES('86713773427','Paula Ferreira','1980-07-03',true);--membro_PJ
INSERT INTO individuo VALUES('78384158614','Mauricio de Souza','1984-09-08',true);--membro_PJ
INSERT INTO individuo VALUES('54363931876','Lucas Alves','1966-12-25',true);--membro_PP
INSERT INTO individuo VALUES('48515177420','Pedro Pereira','1965-06-02',true);--membro_PP
INSERT INTO individuo VALUES('38523575430','Vanderlei Gomes','1973-01-14',true);--membro_PP
INSERT INTO individuo VALUES('39031644293','Ronaldo Ribeiro','1975-11-12',false);--ficha_suja-Doador
INSERT INTO individuo VALUES('83784243673','Francisco Criminoso','1980-06-15',false);--ficha_suja-Doador
INSERT INTO individuo VALUES('22364784964','Priscila Lima','1968-08-19',false);--ficha_suja
INSERT INTO individuo VALUES('42425489150','Henrique Oliveira','1964-12-29',false);--ficha_suja
INSERT INTO individuo VALUES('44216533302','Raysa Gomes','1986-04-16',false);--ficha_suja




--empresas
INSERT INTO empresa VALUES('23178074000118','Ford');
INSERT INTO empresa VALUES('95896247000144','Sony');
INSERT INTO empresa VALUES('90714175000153','Facebook');
INSERT INTO empresa VALUES('89236358000121','Google');
INSERT INTO empresa VALUES('90043287000120','Tesla');

--processo_judicial
INSERT INTO processo_judicial(crime,procedente) VALUES('Homicidio ocorrido em 9 de Julho de 2000 em ...',true);
INSERT INTO processo_judicial(crime,procedente) VALUES('Corrupcao, gastou 1000L de gasolina no corsa.',false);
INSERT INTO processo_judicial(crime,procedente) VALUES('Corrupcao, usou o dinheiro em leite condensado.',true);
INSERT INTO processo_judicial(crime,procedente) VALUES('Assalto o banco.',false);
INSERT INTO processo_judicial(crime,procedente) VALUES('Assalto a padaria.',true);

--julgamento
INSERT INTO julgamento VALUES('44216533302',1,'2000-10-12');
INSERT INTO julgamento VALUES('42425489150',2,'2020-12-11');
INSERT INTO julgamento VALUES('22364784964',3,'2017-03-28');
INSERT INTO julgamento VALUES('39031644293',4,'2018-09-05');
INSERT INTO julgamento VALUES('83784243673',5,'2020-01-11');

--cargo 
--TODO, nao entendi o que fazer com as cadeiras
INSERT INTO cargo VALUES('presidente',0,'Brasil','pais',200000);
INSERT INTO cargo VALUES('deputado',0,'Mogi das Cruzes','cidade',12000);
INSERT INTO cargo VALUES('deputado',0,'Sao Carlos','cidade',21000);

-- INSERT INTO partido VALUES('nome', 'programa')
INSERT INTO partido VALUES('Partido dos Idosos', 'Construir asilos na beira da praia, bingo todos finais de semana, etc.');
INSERT INTO partido VALUES('Partido dos Jovens', 'Melhorar a educaçao, a alimentação, a higienização, etc.');
INSERT INTO partido VALUES('Partido dos Padeiro', 'Abaixar os preços do trigo, farinha, desconto nos fornos eletricos, etc.');

-- INSERT INTO candidatura VALUES('candidato','vice',ano,cargo,local,tipoLocal,partido)
INSERT INTO candidatura VALUES('81387911600',NULL,2020,'presidente','Brasil','pais','Partido dos Idosos');
INSERT INTO candidatura VALUES('22126173135','42758176726',2020,'presidente','Brasil','pais','Partido dos Jovens');
INSERT INTO candidatura VALUES('12750152470','26338856086',2021,'presidente','Brasil','pais','Partido dos Padeiro');
INSERT INTO candidatura VALUES('68005813724',NULL,2019,'deputado','Mogi das Cruzes','cidade','Partido dos Idosos');
INSERT INTO candidatura VALUES('80623351358',NULL,2019,'deputado','Mogi das Cruzes','cidade','Partido dos Jovens');
INSERT INTO candidatura VALUES('59119856598',NULL,2018,'deputado','Sao Carlos','cidade','Partido dos Jovens');
INSERT INTO candidatura VALUES('79548301288',NULL,2018,'deputado','Sao Carlos','cidade','Partido dos Idosos');

-- INSERT INTO pleito VALUES(ano,candidatura,num_votos)
INSERT INTO pleito VALUES(2020,'81387911600',6543210);
INSERT INTO pleito VALUES(2020,'22126173135',7005000);
INSERT INTO pleito VALUES(2021,'12750152470',8000000);
INSERT INTO pleito VALUES(2019,'68005813724',123000);
INSERT INTO pleito VALUES(2019,'80623351358',230980);
INSERT INTO pleito VALUES(2018,'59119856598',120920);
INSERT INTO pleito VALUES(2018,'79548301288',140250);

-- INSERT INTO doacao VALUES(valor,'doador','candidato',ano)
INSERT INTO doacao VALUES(1200,'39031644293','81387911600',2020);
INSERT INTO doacao VALUES(800,'83784243673','22126173135',2020);

-- INSERT INTO doacao_juridica VALUES(valor,'doador','candidato',ano)
INSERT INTO doacao_juridica VALUES(1200900,'23178074000118','81387911600',2020);
INSERT INTO doacao_juridica VALUES(1500000,'95896247000144','81387911600',2020);
INSERT INTO doacao_juridica VALUES(2000000,'90714175000153','22126173135',2020);
INSERT INTO doacao_juridica VALUES(2500000,'89236358000121','59119856598',2018);
INSERT INTO doacao_juridica VALUES(1800000,'90043287000120','79548301288',2018);

-- INSERT INTO membro_equipe VALUES('membro','candidatura',ano)
INSERT INTO membro_equipe VALUES('13874257142','81387911600',2020);
INSERT INTO membro_equipe VALUES('16126941446','81387911600',2020);
INSERT INTO membro_equipe VALUES('30741724286','22126173135',2020);
INSERT INTO membro_equipe VALUES('86713773427','22126173135',2020);
INSERT INTO membro_equipe VALUES('78384158614','68005813724',2019);
INSERT INTO membro_equipe VALUES('54363931876','80623351358',2019);
INSERT INTO membro_equipe VALUES('48515177420','12750152470',2021);
INSERT INTO membro_equipe VALUES('38523575430','79548301288',2018);


--ALGUNS DML

--CANDIDATOS COM FICHA SUJA / nao podem se candidatar
SELECT * 
FROM INDIVIDUO
	WHERE ficha_limpa = false