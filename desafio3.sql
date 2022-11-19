--Desafío 3 - Consultas en Múltiples Tablas--

--Setup--

--Se crea tabla de Usuarios--
  CREATE TABLE users(
  id SERIAL,
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  rol VARCHAR
);

--Se ingresan 5 usuarios en donde debe haber al menos un usuario con el rol de administrador.
INSERT INTO users(email, name, last_name, rol) VALUES 
('juan@mail.com', 'juan', 'perez', 'administrador'),
('diego@mail.com', 'diego', 'munoz', 'usuario'),
('maria@mail.com', 'maria', 'meza', 'usuario'),
('roxana@mail.com','roxana', 'diaz', 'usuario'),
('pedro@mail.com', 'pedro', 'diaz', 'usuario');




--Se crea tabla Post (articulos)
CREATE TABLE posts(
  id SERIAL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  outstanding BOOLEAN NOT NULL DEFAULT FALSE,
  user_id BIGINT
);

--Se ingresan 5 post en donde: 
--* el post 1 y 2 deben pertenecer al administrador.
--* el post 3 y 4 asignarlos al usuario que prefieras (no puede ser el admin)
--* el post 5 no debe tener  un usuario_id asignado
  INSERT INTO posts (title, content, created_at, updated_at, outstanding, user_id) VALUES 
  ('prueba', 'contenido prueba', '01/01/2021', '01/02/2021', true, 1),
  ('prueba2', 'contenido prueba2', '01/03/2021', '01/03/2021', true, 1),
  ('ejercicios', 'contenido ejercicios', '02/05/2021', '03/04/2021', true, 2),
  ('ejercicios2', 'contenido ejercicios2', '03/05/2021', '04/04/2021', false, 2),
  ('random', 'contenido random', '03/06/2021', '04/05/2021', false, null);




--Se crea Tabla Comentarios.
CREATE TABLE comments(
  id SERIAL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  user_id BIGINT,
  post_id BIGINT
);

--Se ingresan 5 comentarios 
--* Los comentarios con id 1,2 y 3 deben estar asociado al post 1, a los usuarios 1, 2 y 3 respectivamente.
--* Los comentarios 4 y 5 deben estar asociado al post 2, a los usuarios 1 y 2 respectivamente.
INSERT INTO comments (content, created_at, user_id, post_id) VALUES 
('comentario 1', '03/06/2021', 1, 1),
('comentario 2', '03/06/2021', 2, 1),
('comentario 3', '04/06/2021', 3, 1),
('comentario 4', '04/06/2021', 1, 2);

-- DESARROLLO

--1) Crea y agrega al entregable las consultas para completar el setup de acuerdo a lo pedido. 
--R: Setup OK 


--2) Cruza los datos de la tabla usuarios y posts mostrando las siguientes columnas nombre e email del usuario junto al título y contenido del post.
--R:
SELECT users.name, users.email, posts.title, posts.content FROM users INNER JOIN posts ON users.id = posts.user_id;
 name  |     email      |    title    |        content
-------+----------------+-------------+-----------------------
 juan  | juan@mail.com  | prueba      | contenido prueba
 juan  | juan@mail.com  | prueba2     | contenido prueba2
 diego | diego@mail.com | ejercicios  | contenido ejercicios
 diego | diego@mail.com | ejercicios2 | contenido ejercicios2


--3) Muestra el id, título y contenido de los posts de los administradores. El administrador puede ser cualquier id y debe ser seleccionado dinámicamente.
--R:
SELECT posts.id, posts.title, posts.content FROM posts INNER JOIN users ON posts.user_id = users.id WHERE users.rol = 'administrador';
 id |  title  |      content
----+---------+-------------------
  1 | prueba  | contenido prueba
  2 | prueba2 | contenido prueba2


--4) Cuenta la cantidad de posts de cada usuario. La tabla resultante debe mostrar el id e email del usuario junto con la cantidad de posts de cada usuario.
--R:
 SELECT COUNT(posts), users.id, users.email FROM posts RIGHT JOIN users ON posts.user_id = users.id GROUP BY users.id, users.email ORDER BY users.id ASC;
 count | id |      email
-------+----+-----------------
     2 |  1 | juan@mail.com
     2 |  2 | diego@mail.com
     0 |  3 | maria@mail.com
     0 |  4 | roxana@mail.com
     0 |  5 | pedro@mail.com


--5) Muestra el email del usuario que ha creado más posts. Aquí la tabla resultante tiene un único registro y muestra solo el email.
--R:
SELECT users.email FROM posts JOIN users ON posts.user_id = users.id GROUP BY users.id, users.email ORDER BY COUNT(posts.id) DESC;
     email
----------------
 diego@mail.com
 juan@mail.com


--6) Muestra la fecha del último post de cada usuario.
--R:
SELECT users.name, max(created_at) FROM posts INNER JOIN users ON posts.user_id = users.id GROUP BY posts.user_id,users.name;
 name  |         max
-------+---------------------
 diego | 2021-05-03 00:00:00
 juan  | 2021-03-01 00:00:00


--7) Muestra el título y contenido del post (artículo) con más comentarios.
--R:
SELECT posts.title,posts.content FROM comments INNER JOIN posts ON comments.post_id = posts.id GROUP BY comments.post_id, posts.title, posts.content order by post_id asc limit 1;
 title  |     content
--------+------------------
 prueba | contenido prueba


--8) Muestra en una tabla el título de cada post, el contenido de cada post y el contenido de cada comentario asociado a los posts mostrados, junto con el email
--   del usuario que lo escribió.
--R:
SELECT posts.title,posts.content,comments.content AS comment_content ,users.email FROM posts INNER JOIN comments ON posts.id = comments.post_id INNER JOIN users ON comments.user_id = users.id;
  title  |      content      | comment_content |     email
---------+-------------------+-----------------+----------------
 prueba  | contenido prueba  | comentario 1    | juan@mail.com
 prueba  | contenido prueba  | comentario 2    | diego@mail.com
 prueba  | contenido prueba  | comentario 3    | maria@mail.com
 prueba2 | contenido prueba2 | comentario 4    | juan@mail.com


--9) Muestra el contenido del último comentario de cada usuario.
--R:
SELECT comments.created_at, comments.content, comments.user_id FROM comments INNER JOIN (SELECT max(comments.id) as max_id_max FROM comments GROUP BY user_id) as max_result on comments.id = max_result.max_id_max order by comments.user_id;
     created_at      |   content    | user_id
---------------------+--------------+---------
 2021-06-04 00:00:00 | comentario 4 |       1
 2021-06-03 00:00:00 | comentario 2 |       2
 2021-06-04 00:00:00 | comentario 3 |       3


--10) Muestra los emails de los usuarios que no han escrito ningún comentario.
--R:
SELECT users.email FROM users LEFT JOIN comments ON users.id = comments.user_id GROUP BY users.email, comments.content HAVING comments.content IS NULL order by email DESC;
      email
-----------------
 roxana@mail.com
 pedro@mail.com



 --Vista de las tablas

postgres=# SELECT * FROM users;
 id |      email      |  name  | last_name |      rol
----+-----------------+--------+-----------+---------------
  1 | juan@mail.com   | juan   | perez     | administrador
  2 | diego@mail.com  | diego  | munoz     | usuario
  3 | maria@mail.com  | maria  | meza      | usuario
  4 | roxana@mail.com | roxana | diaz      | usuario
  5 | pedro@mail.com  | pedro  | diaz      | usuario
(5 filas)


postgres=# SELECT * FROM posts;
 id |    title    |        content        |     created_at      |     updated_at      | outstanding | user_id
----+-------------+-----------------------+---------------------+---------------------+-------------+---------
  1 | prueba      | contenido prueba      | 2021-01-01 00:00:00 | 2021-02-01 00:00:00 | t           |       1
  2 | prueba2     | contenido prueba2     | 2021-03-01 00:00:00 | 2021-03-01 00:00:00 | t           |       1
  3 | ejercicios  | contenido ejercicios  | 2021-05-02 00:00:00 | 2021-04-03 00:00:00 | t           |       2
  4 | ejercicios2 | contenido ejercicios2 | 2021-05-03 00:00:00 | 2021-04-04 00:00:00 | f           |       2
  5 | random      | contenido random      | 2021-06-03 00:00:00 | 2021-05-04 00:00:00 | f           |
(5 filas)


postgres=# SELECT * FROM comments;
 id |   content    |     created_at      | user_id | post_id
----+--------------+---------------------+---------+---------
  1 | comentario 1 | 2021-06-03 00:00:00 |       1 |       1
  2 | comentario 2 | 2021-06-03 00:00:00 |       2 |       1
  3 | comentario 3 | 2021-06-04 00:00:00 |       3 |       1
  4 | comentario 4 | 2021-06-04 00:00:00 |       1 |       2
(4 filas)