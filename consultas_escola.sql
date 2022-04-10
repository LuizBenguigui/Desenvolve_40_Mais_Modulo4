-- RELATÓRIO 1
-- Produza um relatório que contenha os dados dos alunos matriculados em todos os cursos oferecidos pela escola
--
-- Este RELATÓRIO 1 contém os dados dos Cursos em que os alunos estão matriculados
-- Portanto, os alunos são listados quantas vezes quantos cursos estejam matriculados
use escola;
SELECT 
    Al.Nome AS Aluno,
    Al.CPF AS CPF,
    Al.Endereco AS Endereço,
    Al.Telefone AS Fone,
    Al.Data_Nasc AS Nascimento,
    Mat.Data_Matricula AS 'Matriculado em',
    Crs.Nome AS Curso
FROM
    Aluno AS Al
        LEFT JOIN
    Matricula AS Mat ON Al.CPF = Mat.CPF_Aluno
        LEFT JOIN
    Curso AS Crs ON Mat.Codigo_Curso = Crs.Codigo
ORDER BY Al.Nome;
--
-- RELATÓRIO 2
-- Produza um relatório com os dados de todos os cursos, com suas respectivas disciplinas, oferecidos pela escola
use escola;
SELECT 
    Crs.Codigo AS Cód,
    Crs.Nome AS Curso,
    Crs.Descricao AS Descrição,
    Dpt.Nome AS Departamento,
    Dsc.Nome AS Disciplina,
    Dsc.Qtd_Creditos AS Créditos,
    Prof.Nome AS Professor
FROM
    Curso AS Crs
        LEFT JOIN
    Departamento AS Dpt ON Crs.Codigo_Depto = Dpt.Codigo
        LEFT JOIN
    Compoe ON Crs.Codigo = Compoe.Codigo_Curso
        LEFT JOIN
    Disciplina AS Dsc ON Compoe.Codigo_Disc = Dsc.Codigo
        LEFT JOIN
    Professor AS Prof ON Dsc.Matricula_Prof = Prof.Matricula
ORDER BY Curso; 
--
-- RELATÓRIO 3
-- Produza um relatório que contenha o nome dos alunos e as disciplinas em que estão matriculados
use escola;
SELECT 
    Al.Nome AS Aluno,
    Dsc.Nome AS Disciplina,
    Dsc.Qtd_Creditos AS Créditos
FROM
    Aluno AS Al
        inner JOIN
    Cursa as Cursa ON Al.CPF = Cursa.CPF_Aluno
        inner JOIN
    Disciplina AS Dsc ON cursa.Codigo_Disc = Dsc.Codigo
ORDER BY Aluno , Disciplina;
--
-- RELATÓRIO 4
-- Produza um relatório com os dados dos professores e as disciplinas que ministram
use escola;
SELECT 
    Prof.Matricula AS Matrícula,
    Prof.Nome AS Professor,
    Prof.Endereco AS Endereço,
    Prof.Telefone AS Fone,
    Prof.Data_Nasc AS Nascimento,
    Prof.Data_Contratacao AS 'Contratado em',
    COALESCE(Dsc.Nome, '') AS Ministra,
    COALESCE(Dsc.Qtd_Creditos, 0) AS Créditos
FROM
    Professor AS Prof
        LEFT JOIN
    Disciplina AS Dsc ON Prof.Matricula = Dsc.Matricula_Prof
ORDER BY Professor;
--
-- ALTERNATIVA ao RELATÓRIO 4, incluindo Informação do Curso ao qual a Disciplina é Ministrada
-- Observando que uma mesma Disciplina é ministrada em mais de um curso
use escola;
SELECT 
    Prof.Matricula AS Matrícula,
    Prof.Nome AS Professor,
    Prof.Endereco AS Endereço,
    Prof.Telefone AS Fone,
    Prof.Data_Nasc AS Nascimento,
    Prof.Data_Contratacao AS 'Contratado em',
    COALESCE(Dsc.Nome, '') AS Ministra,
    COALESCE(Dsc.Qtd_Creditos, 0) AS Créditos,
    Tags.Tag_Curso AS 'No Curso'
FROM
    Professor AS Prof
        LEFT JOIN
    Disciplina AS Dsc ON Prof.Matricula = Dsc.Matricula_Prof
        LEFT JOIN
    (SELECT 
        Cmp.Codigo_Disc AS Tag_Disc, Crs.Nome AS Tag_Curso
    FROM
        Compoe AS Cmp
    INNER JOIN Curso AS Crs ON Cmp.Codigo_Curso = Crs.Codigo) AS Tags ON Dsc.Codigo = Tags.Tag_Disc
ORDER BY Professor;
--
-- RELATÓRIO 5
-- Produza um relatório com os nomes das disciplinas e seus pré-requisitos
-- Criada uma View para reutilização no RELATÓRIO 7 Alternativo
use escola;
-- Drop View Dependencias;
CREATE OR REPLACE VIEW Dependencias AS
    SELECT 
        Dsc.Codigo AS Código,
        Dsc.Nome AS Disciplina,
        Dsc.Qtd_Creditos AS Creditos,
        COALESCE(Pre.Codigo_Disc_Dependencia, '') AS Cod_Pre,
        COALESCE(Pre_1.Nome, '') AS Disciplina_Pre,
        COALESCE(Pre_1.Qtd_Creditos, '') AS Creditos_Pre,
        Prof.Nome AS Professor
    FROM
        Disciplina AS Dsc
            LEFT JOIN
        Professor AS Prof ON Dsc.Matricula_Prof = Prof.Matricula
            LEFT JOIN
        Pre_Req AS Pre ON Pre.Codigo_Disc = Dsc.Codigo
            LEFT JOIN
        (SELECT 
            Dsc_1.Codigo AS Codigo,
                Dsc_1.Nome AS Nome,
                Dsc_1.Qtd_Creditos AS Qtd_Creditos
        FROM
            Disciplina AS Dsc_1) AS Pre_1 ON Pre.Codigo_Disc_Dependencia = Pre_1.Codigo
    ORDER BY Dsc.Nome;
SELECT 
    *
FROM
    Dependencias
ORDER BY Disciplina;
--
-- RELATÓRIO 6
-- Produza um relatório com a média de idade dos alunos matriculados em cada curso
use escola;
SELECT 
    Tag_Curso.Nome,
    FORMAT(AVG(TIMESTAMPDIFF(YEAR, Al.Data_Nasc, NOW())),
        2) AS Média
FROM
    Aluno AS Al
        LEFT JOIN
    Matricula AS Mat ON Al.CPF = Mat.CPF_Aluno
        LEFT JOIN
    (SELECT 
        Crs.Codigo AS Codigo, Crs.Nome AS Nome
    FROM
        Curso AS Crs) AS Tag_Curso ON Mat.Codigo_Curso = Tag_Curso.Codigo
GROUP BY Tag_Curso.Nome
ORDER BY Tag_Curso.Nome;
--
-- RELATÓRIO 7
-- Produza um relatório com os cursos oferecidos por cada departamento
SELECT 
    Dept.Nome AS Departamento,
    Crs.Nome AS Curso,
    Crs.Descricao AS Descrição
FROM
    Departamento AS Dept
        INNER JOIN
    Curso AS Crs ON Dept.Codigo = Crs.Codigo_Depto
ORDER BY Departamento , Curso;
-- 
-- ALTERNATIVA AO RELATÓRIO 7
-- INCLUINDO AS DISCIPLINAS DOS CURSOS E PRÉ REQUISITOS
SELECT 
    Dept.Nome AS Departamento,
    Crs.Nome AS Curso,
    Crs.Descricao AS Descrição,
    Dpnd.Disciplina AS Disciplina,
    Dpnd.Professor AS Professor,
    Dpnd.Creditos AS Créditos,
    Dpnd.Disciplina_Pre AS 'Pré Requisito',
    Dpnd.Creditos_Pre AS 'Créditos Pré Requisito'
FROM
    Departamento AS Dept
        INNER JOIN
    Curso AS Crs ON Dept.Codigo = Crs.Codigo_Depto
        INNER JOIN
    Compoe AS Cmp ON Crs.Codigo = Cmp.Codigo_Curso
        INNER JOIN
    Dependencias AS Dpnd ON Cmp.Codigo_Disc = Dpnd.Código
ORDER BY Departamento , Curso , Disciplina;

