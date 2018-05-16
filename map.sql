DROP TABLE IF EXISTS map;

CREATE TABLE map (
    hash INT UNSIGNED PRIMARY KEY,
    name VARCHAR(255)
);

-- These hashes sourced from https://github.com/LtHummus/SclManager/blob/master/src/main/scala/com/lthummus/sclmanager/parsing/Level.scala
INSERT INTO map VALUES
    (441894305, 'High-Rise'),
    (1870767448, 'Veranda'),
    (1903409343, 'Gallery'),
    (775418203, 'Moderne'),
    (2646981470, 'Courtyard'),
    (2419248674, 'Terrace'),
    (1527912741, 'Ballroom'),
    (1503066794, 'BvB Ballroom'),
    (976274214, 'BvB High-Rise'),
    (682863198, 'Old Gallery'),
    (688524405, 'Old Courtyard 2'),
    (915797379, 'Panopticon'),
    (2831065233, 'Old Veranda'),
    (3095994300, 'Old Balcony'),
    (218264384, 'Crowded Pub'),
    (163768240, 'Old Ballroom'),
    (3033491563, 'Old Courtyard 1'),
    (1886839695, 'Double Modern'),
    (4091941985, 'Modern'),
    (998637555, 'Pub'),
    (378490722, 'Library'),
    (498961985, 'Balcony');

