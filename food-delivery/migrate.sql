------------------ Schema ------------------
create type basket_status as enum ('unpaid', 'clean', 'paid');
create type order_status as enum ('pending', 'started', 'cooking', 'delivery', 'delivered');

create table if not exists basket
(
    id     serial not null,
    status basket_status,
    constraint pk_basket primary key (id)
);

create table if not exists city
(
    id   serial      not null,
    name varchar(32) not null unique,
    constraint pk_city primary key (id)
);

create table if not exists ingredient
(
    id   serial      not null,
    name varchar(32) not null,
    constraint pk_ingredient primary key (id)
);

create table if not exists location
(
    id    serial not null,
    point point  not null,
    constraint pk_location primary key (id)
);

create table if not exists locale
(
    id          serial       not null,
    address     varchar(128) not null unique,
    location_id int4         not null,
    city_id     int4         not null,
    constraint pk_locale primary key (id),
    constraint fk_locale_city_id__city_id foreign key (city_id) references city (id) on delete restrict on update cascade,
    constraint fk_location_id__location_id foreign key (location_id) references location (id) on delete restrict on update cascade
);

create table if not exists menu_item
(
    id        serial      not null,
    name      varchar(32) not null,
    cook_time int4        not null,
    cost      int4        not null,
    constraint pk_menu_item primary key (id)
);

create table if not exists ingredient_x_menu_item
(
    ingredient_id int4 not null,
    menu_item_id  int4 not null,
    constraint pk_ingredient_x_menu_item primary key (ingredient_id, menu_item_id),
    constraint fk_ingredient_id__ingredient_id foreign key (ingredient_id) references ingredient (id) on delete no action on update restrict,
    constraint fk_menu_item_id__menu_item_id foreign key (menu_item_id) references menu_item (id) on delete no action on update restrict
);

create table if not exists menu_item_x_basket
(
    id           serial not null,
    menu_item_id int4   not null,
    basket_id    int4   not null,
    count        int4   not null,
    constraint pk_menu_item_x_basket primary key (id),
    constraint fk_menu_item_x_basket_basket_id__basket_id foreign key (basket_id) references basket (id) on delete no action on update restrict,
    constraint fk_menu_item_x_basket_menu_item_id__menu_item_id foreign key (menu_item_id) references menu_item (id) on delete no action on update restrict
);

create table if not exists "user"
(
    id        serial      not null,
    email     varchar(64) not null unique,
    name      varchar(32),
    password  varchar(32) not null,
    lastname  varchar(32),
    address   varchar(64),
    basket_id int4        not null,
    city_id   int4        not null,
    locale_id int4,
    constraint pk_user primary key (id),
    constraint fk_city_id__city_id foreign key (city_id) references city (id),
    constraint fk_locale_id__locale_id foreign key (locale_id) references locale (id) on delete restrict,
    constraint fk_basket_id__basket_id foreign key (basket_id) references basket (id) on delete cascade
);

create table if not exists "order"
(
    id          serial       not null,
    created     timestamp    not null,
    status      order_status not null,
    paid        bool         not null,
    user_id     int4         not null,
    location_id int4         not null,
    constraint pk_order primary key (id),
    constraint fk_order_location_id__location_id foreign key (location_id) references location (id) on delete restrict on update restrict,
    constraint fk_user_id__user_id foreign key (user_id) references "user" (id) on delete restrict on update restrict
);

create table if not exists menu_item_x_order
(
    menu_item_id int4 not null,
    order_id     int4 not null,
    quantity     int4 not null,
    constraint pk_menu_item_x_order primary key (menu_item_id, order_id),
    constraint fk_menu_item_x_order_order_id__order_id foreign key (order_id) references "order" (id) on delete restrict on update restrict,
    constraint fk_menu_item_x_order_menu_item_id__menu_item_id FOREIGN KEY (menu_item_id) REFERENCES menu_item (id) on delete restrict on update restrict
);

create table if not exists order_x_locale
(
    order_id  int4 not null,
    locale_id int4 not null,
    constraint pk_order_locale primary key (order_id, locale_id),
    constraint fk_locale_id__locale_id foreign key (locale_id) references locale (id) on delete restrict on update restrict,
    constraint fk_order_id__order_id foreign key (order_id) references "order" (id) on delete restrict on update restrict
);

create table if not exists role
(
    id   serial      not null,
    name varchar(16) not null unique,
    constraint pk_role primary key (id)
);

create table if not exists user_x_role
(
    user_id int4 not null,
    role_id int4 not null,
    constraint pk_user_x_role primary key (user_id, role_id),
    constraint fk_user_x_role_role_id__role_id foreign key (role_id) references role (id) on delete restrict,
    constraint fk_user_x_role_user_id__user_id foreign key (user_id) references "user" (id) on delete restrict
);

------------------ Data ------------------
insert into role (name)
values ('admin'),
       ('customer'),
       ('manager'),
       ('waiter'),
       ('chef');

INSERT INTO city (name)
VALUES ('Bitola'),       -- 1
       ('Debar'),        -- 2
       ('Delcevo'),      -- 3
       ('Demir Hisar'),  -- 4
       ('Demir Kapija'), -- 5
       ('Gevgelija'),    -- 6
       ('Kumanovo'),     -- 7
       ('Ohrid'),        -- 8
       ('Prilep'),       -- 8
       ('Radovis'),      -- 9
       ('Resen'),        -- 10
       ('Skopje'),       -- 11
       ('Dojran'),       -- 12
       ('Stip'),         -- 13
       ('Struga'),       -- 14
       ('Strumica'),     -- 15
       ('Valandovo'),    -- 16
       ('Veles'); -- 17

insert into location (point)
values (point(41.030301, 21.332250)), --bitola 1
       (point(41.033457, 21.337260)), -- bitola 2
       (point(41.031895, 21.330780)), --bitola 3
       (point(41.120844, 20.787506)), --ohrid 4
       (point(41.437280, 22.643020)), --strumica 5
       (point(41.715159, 21.774335)), --veles 6
       (point(42.001257, 21.409925)), --skopje 7
       (point(41.999023, 21.416994)), --skopje 8
       (point(41.998202, 21.421897)); --skopje 9

insert into locale (address, location_id, city_id)
values ('bitola1', 1, 1),  -- 1
       ('bitola2', 2, 1),  -- 2
       ('bitola3', 3, 1),  -- 3
       ('skopje1', 7, 12), -- 4
       ('skopje2', 8, 12), -- 5
       ('skopje3', 9, 12);-- 6


insert into ingredient (name)
values ('tomatoes'),     -- 1
       ('cheese'),       -- 2
       ('chicken'),      -- 3
       ('eggs'),         -- 4
       ('peppers'),      -- 5
       ('onions'),       -- 6
       ('beef'),         -- 7
       ('potatoes'),     -- 8
       ('pork'),         -- 9
       ('curry'),        -- 10
       ('white cheese'), -- 11
       ('cucumbers'),    -- 12
       ('salad'),        -- 13
       ('cabbage'),      -- 14
       ('carrot'),       -- 15
       ('rice'),         -- 16
       ('peas'); -- 17

insert into menu_item (name, cook_time, cost)
values ('Pizza', 30, 300),                    -- 1
       ('Burger', 15, 150),                   -- 2
       ('Chicken Burger', 15, 130),           -- 3
       ('Whole Chicken', 45, 320),            -- 4
       ('Chicken Special', 25, 120),          -- 5
       ('Chicken wings', 15, 120),            -- 6
       ('Chicken wings with sauce', 15, 150), -- 7
       ('Mixed Salad', 15, 150),              -- 8
       ('Chicken Pizza', 30, 300),            -- 9
       ('Fries', 30, 300); -- 10

insert into ingredient_x_menu_item (ingredient_id, menu_item_id)
values (1, 1),
       (1, 2),
       (1, 3),
       (1, 9),
       (2, 1),
       (2, 2),
       (2, 3),
       (2, 9),
       (3, 3),
       (3, 5),
       (3, 6),
       (3, 7),
       (3, 9),
       (4, 1),
       (9, 2),
       (7, 2),
       (16, 5),
       (14, 9),
       (15, 9),
       (8, 2),
       (8, 3),
       (8, 10);

insert into basket (status)
select 'clean'
from generate_series(1, 500);

INSERT into "user" (email, name, lastname, password, address, basket_id, city_id, locale_id)
VALUES ('admin@admin.com', null, null, 'admin', null, 1, 1, null),
       ('arcu.eu@yahoo.ca', 'Forrest', 'Ferguson', 'neque', 'Ap #479-7452 Urna, Rd.', 1, 7, null),
       ('nulla.facilisis@protonmail.com', 'Felix', 'Sears', 'elit,', 'Ap #812-8388 Malesuada Av.', 2, 17, null),
       ('non.cursus@icloud.net', 'Hamish', 'Nguyen', 'vitae', '5062 Ornare, Road', 3, 7, 2),
       ('amet.consectetuer.adipiscing@yahoo.edu', 'Jeremy', 'Wheeler', 'nonummy', '709-5211 Mauris Road', 4, 16, 4),
       ('donec.feugiat@icloud.ca', 'Iris', 'Alexander', 'a,', 'P.O. Box 183, 1872 Purus. Road', 5, 8, null),
       ('purus@protonmail.couk', 'Brenden', 'Anthony', 'fringilla,', 'Ap #963-8435 Enim. Avenue', 6, 6, null),
       ('blandit.enim@yahoo.org', 'Mikayla', 'Patterson', 'at', '578-3890 Est Avenue', 7, 1, null),
       ('amet.ante.vivamus@aol.net', 'Nerea', 'Hamilton', 'ipsum', 'Ap #132-7568 Mi, St.', 8, 7, null),
       ('ac.mi@google.net', 'Inez', 'Ellison', 'et', 'P.O. Box 615, 3679 Euismod Avenue', 9, 4, null),
       ('et.rutrum@outlook.com', 'Victoria', 'Bruce', 'Duis', '742-7232 Duis Street', 10, 14, null),
       ('eget.metus.eu@icloud.com', 'Lyle', 'Wynn', 'porttitor', 'P.O. Box 707, 5808 Ut, St.', 11, 9, null),
       ('interdum.nunc.sollicitudin@protonmail.net', 'Oprah', 'Small', 'congue,', 'Ap #689-3421 Fusce Ave', 12, 14,
        null),
       ('lacus.varius@outlook.ca', 'Doris', 'Alvarez', 'Phasellus', '440-4624 Dolor Avenue', 13, 11, 4),
       ('donec.tempor@yahoo.ca', 'Denton', 'Bentley', 'enim.', '775-285 Quis Rd.', 14, 3, null),
       ('et.ultrices@outlook.ca', 'Yuli', 'Goodman', 'massa', '4435 Molestie St.', 15, 6, null),
       ('euismod@yahoo.ca', 'Cailin', 'Walton', 'rutrum.', 'P.O. Box 779, 1000 Arcu. Av.', 16, 11, null),
       ('nulla.tempor@icloud.net', 'Kieran', 'Barton', 'diam', '947-3895 Mi Av.', 17, 9, null),
       ('elit.pellentesque.a@hotmail.org', 'Samantha', 'Williamson', 'orci', '520-2551 Nec Road', 18, 14, null),
       ('felis.orci.adipiscing@google.com', 'Wallace', 'Rowland', 'consectetuer', 'P.O. Box 865, 9158 Nisi Avenue', 19,
        1, null),
       ('non.leo@hotmail.net', 'Brittany', 'Becker', 'Aliquam', 'Ap #516-3627 Ornare, St.', 20, 9, null),
       ('sem.elit@icloud.net', 'Robert', 'Elliott', 'eget', 'P.O. Box 165, 7202 Dictum Ave', 21, 4, null),
       ('erat.semper@yahoo.couk', 'Lenore', 'Wheeler', 'et', 'Ap #964-5174 Vel St.', 22, 5, 1),
       ('nulla.integer@hotmail.couk', 'Damon', 'Sharpe', 'magna.', '834-1031 Et St.', 23, 7, null),
       ('proin.mi@hotmail.edu', 'Gavin', 'Lowery', 'molestie', '565-1347 Enim Road', 24, 5, 3),
       ('euismod.est@icloud.couk', 'Tobias', 'Petty', 'accumsan', 'Ap #187-8386 Lobortis Street', 25, 7, 5),
       ('aliquam.iaculis@protonmail.net', 'Cassidy', 'Howe', 'aliquam,', 'Ap #308-4138 Sociis Av.', 26, 9, null),
       ('vel.venenatis@aol.ca', 'Thaddeus', 'Mccarty', 'est', '9939 Lacus Avenue', 27, 12, null),
       ('suspendisse.sagittis@icloud.com', 'Keiko', 'Deleon', 'lorem,', '4280 Mauris, Rd.', 28, 13, null),
       ('accumsan@icloud.edu', 'Audrey', 'Powers', 'fermentum', 'Ap #660-5732 Arcu. St.', 29, 6, null),
       ('est.ac@yahoo.edu', 'Naomi', 'Erickson', 'risus.', 'P.O. Box 730, 4360 Rutrum, Rd.', 30, 10, null),
       ('consectetuer@protonmail.ca', 'Ava', 'Wade', 'nec', '3198 Urna. Av.', 31, 17, null),
       ('odio.nam.interdum@hotmail.org', 'Jaden', 'Todd', 'ut,', '207-9239 Neque Street', 32, 8, null),
       ('libero@yahoo.net', 'Joel', 'Reyes', 'dolor', '8420 Ligula. Rd.', 33, 14, null),
       ('orci@hotmail.org', 'Inez', 'Maxwell', 'id,', '303-6315 Amet, St.', 34, 12, null),
       ('metus.eu@icloud.net', 'Leonard', 'Clay', 'neque.', '159-9968 At St.', 35, 13, 6),
       ('lobortis.ultrices@protonmail.com', 'Cara', 'Keith', 'Nunc', 'Ap #895-3703 Mauris. Ave', 36, 8, null),
       ('tempus.mauris@outlook.org', 'Ciaran', 'Kinney', 'nunc', '8297 Eros Road', 37, 10, null),
       ('ligula.aliquam@google.com', 'Bernard', 'Buck', 'Sed', 'Ap #289-3319 Blandit St.', 38, 2, 2),
       ('lorem.auctor.quis@yahoo.edu', 'Geraldine', 'English', 'dui.', '765-3858 Sit Street', 39, 11, null),
       ('euismod.in.dolor@google.couk', 'Dahlia', 'Perkins', 'consectetuer', 'P.O. Box 721, 5529 A Av.', 40, 14, null),
       ('ac@aol.org', 'Gray', 'Kent', 'Nulla', '252-1626 Dapibus Rd.', 41, 12, null),
       ('arcu.ac@yahoo.org', 'Brenden', 'Cooley', 'sodales.', '1483 Ipsum St.', 42, 15, 3),
       ('vestibulum@outlook.com', 'Arthur', 'Weber', 'mi', 'P.O. Box 676, 9261 Eget, Rd.', 43, 4, 3),
       ('donec.non.justo@aol.edu', 'May', 'Hinton', 'dolor', 'Ap #885-7291 Luctus Avenue', 44, 16, null),
       ('adipiscing@outlook.edu', 'Madonna', 'Shepherd', 'rutrum', '903-8498 Ut, Road', 45, 12, null),
       ('pharetra.felis@outlook.com', 'Kerry', 'Morse', 'lobortis', 'Ap #936-1757 Mollis. St.', 46, 15, null),
       ('ultrices.mauris@google.edu', 'Felix', 'Foreman', 'urna.', 'P.O. Box 136, 1896 Magna St.', 47, 4, 1),
       ('ipsum.donec.sollicitudin@outlook.com', 'Katelyn', 'Banks', 'nascetur', 'Ap #987-6907 Phasellus Street', 48, 6,
        null),
       ('dui.cras@outlook.ca', 'Alexa', 'Kramer', 'malesuada', '190-8643 Adipiscing Road', 49, 8, null),
       ('aliquam.adipiscing@outlook.edu', 'Thomas', 'Cotton', 'est.', '828-6874 Fermentum Avenue', 50, 11, null),
       ('mauris@icloud.com', 'Quintessa', 'Bailey', 'sem', '176-9340 Aliquet Street', 51, 2, null),
       ('quam.dignissim.pharetra@yahoo.org', 'Olga', 'Good', 'Nunc', '675-4302 Vitae Rd.', 52, 7, null),
       ('sapien@hotmail.com', 'Dominic', 'Reese', 'Nullam', 'Ap #926-5646 Sagittis Ave', 53, 4, 1),
       ('pede.ac.urna@icloud.net', 'Rama', 'Nielsen', 'vitae,', '720-2184 Mauris, St.', 54, 15, null),
       ('donec.est@protonmail.couk', 'Kenyon', 'Irwin', 'mi.', 'Ap #247-2407 Vitae Rd.', 55, 5, null),
       ('non.lorem@protonmail.com', 'Melodie', 'Jefferson', 'nibh', '954-7928 Sem, St.', 56, 13, 5),
       ('ipsum.nunc.id@aol.org', 'Hammett', 'Whitaker', 'feugiat', '175-4127 Sed St.', 57, 14, null),
       ('euismod.urna@icloud.com', 'Lars', 'Webb', 'amet,', '9423 Penatibus St.', 58, 15, null),
       ('a.auctor@aol.edu', 'Dexter', 'Olsen', 'odio.', '775-7636 Urna. Street', 59, 10, 3),
       ('dolor@google.couk', 'Gary', 'Hobbs', 'mollis.', 'Ap #985-1082 Nec, St.', 60, 8, 2),
       ('vitae.aliquet@icloud.net', 'Dillon', 'Conway', 'primis', '884-854 Ac St.', 61, 5, null),
       ('sociosqu.ad@protonmail.couk', 'Jeremy', 'Blevins', 'ultricies', '605-1469 Accumsan Av.', 62, 1, null),
       ('sed.consequat@aol.net', 'Rosalyn', 'Lamb', 'euismod', '483-5826 In Street', 63, 5, null),
       ('semper.pretium@hotmail.ca', 'Isabella', 'Mcneil', 'porttitor', '920-5552 Vulputate St.', 64, 15, null),
       ('phasellus@google.net', 'Adria', 'Nash', 'ornare,', 'Ap #525-2209 Odio Street', 65, 10, null),
       ('nulla@outlook.org', 'Caldwell', 'Barlow', 'Mauris', '243-4942 Venenatis Rd.', 66, 10, null),
       ('lobortis.tellus@icloud.couk', 'Sacha', 'Jennings', 'sagittis.', 'Ap #320-2878 Mattis Avenue', 67, 17, null),
       ('montes.nascetur.ridiculus@aol.ca', 'Kaseem', 'Buck', 'non,', 'P.O. Box 443, 216 Phasellus Road', 68, 15, null),
       ('quisque@icloud.edu', 'Barbara', 'Patel', 'est', '7522 Tincidunt Street', 69, 2, null),
       ('auctor.velit@icloud.com', 'Keiko', 'Grimes', 'vel', 'Ap #200-5514 Convallis Av.', 70, 17, null),
       ('velit.cras@google.couk', 'Amos', 'Mcdonald', 'commodo', 'Ap #619-8926 Adipiscing Rd.', 71, 2, null),
       ('sit@protonmail.com', 'Addison', 'Fox', 'quam', 'Ap #778-8323 Iaculis Avenue', 72, 7, null),
       ('duis.elementum@outlook.edu', 'Uriel', 'Rose', 'Sed', '806-9653 Nibh St.', 73, 11, null),
       ('lacus.nulla@icloud.ca', 'Donovan', 'Rocha', 'massa', 'Ap #863-5993 Imperdiet, Avenue', 74, 14, null),
       ('ligula.elit@protonmail.ca', 'Kessie', 'Frederick', 'montes,', '112-884 Erat, Road', 75, 17, null),
       ('id.sapien.cras@outlook.com', 'Gavin', 'Cruz', 'Proin', '153-1695 Natoque Street', 76, 2, null),
       ('vitae@outlook.org', 'Travis', 'Valencia', 'euismod', 'Ap #411-5581 Velit Avenue', 77, 4, null),
       ('enim.commodo@yahoo.org', 'Eagan', 'Gilbert', 'Nunc', '1296 Eu Rd.', 78, 7, null),
       ('mus@icloud.couk', 'Colette', 'Wilkinson', 'nec', '375-7503 Eu Rd.', 79, 3, null),
       ('lectus.ante@yahoo.couk', 'Hope', 'Anderson', 'commodo', 'Ap #432-6378 Magna, Rd.', 80, 14, 1),
       ('nibh@google.edu', 'Caryn', 'Arnold', 'Fusce', '3283 Ac, Avenue', 81, 12, null),
       ('et.tristique@outlook.org', 'Daniel', 'Berry', 'Phasellus', '904-4908 Eu Street', 82, 9, null),
       ('penatibus.et@protonmail.net', 'Audrey', 'Espinoza', 'sagittis', 'Ap #321-4912 Dictum. Street', 83, 8, null),
       ('orci.quis@yahoo.net', 'Elliott', 'Rose', 'a', 'Ap #758-1856 Eu Rd.', 84, 7, null),
       ('rutrum.non@icloud.org', 'Price', 'Burch', 'Vivamus', '799-1619 Mus. Avenue', 85, 6, null),
       ('vulputate@protonmail.couk', 'Piper', 'Summers', 'dui', 'Ap #119-5435 Lectus Road', 86, 10, 3),
       ('nulla.dignissim@protonmail.com', 'Timon', 'Cooke', 'facilisi.', '510-5479 Conubia Ave', 87, 2, null),
       ('justo@icloud.net', 'Reece', 'Ayala', 'pede.', '437-794 Mollis Road', 88, 16, null),
       ('viverra.donec@aol.edu', 'Harper', 'Ratliff', 'felis,', 'Ap #258-5167 Curabitur Rd.', 89, 3, null),
       ('eget@outlook.couk', 'Idona', 'Sloan', 'sed', 'P.O. Box 937, 7551 Sem Avenue', 90, 14, 3),
       ('quis.pede.suspendisse@protonmail.edu', 'Griffith', 'Mcgowan', 'Cras', '482-3242 Elementum, Rd.', 91, 10, null),
       ('sed.consequat@yahoo.edu', 'Colleen', 'Jacobs', 'malesuada', 'Ap #620-8290 Quisque Av.', 92, 6, null),
       ('nec.leo.morbi@icloud.edu', 'Ignatius', 'Reid', 'quis', 'Ap #402-4131 Pretium Avenue', 93, 13, null),
       ('egestas.lacinia@yahoo.couk', 'Holmes', 'Chavez', 'Nunc', '892-4994 Neque. St.', 94, 4, 1),
       ('libero.est@aol.edu', 'Vivian', 'Goodwin', 'cubilia', 'P.O. Box 928, 4648 Odio. Rd.', 95, 8, null),
       ('magnis.dis.parturient@hotmail.edu', 'Noelani', 'Montoya', 'enim,', '759-2239 Congue Rd.', 96, 7, null),
       ('vulputate.mauris@icloud.org', 'Julie', 'Douglas', 'sed', '429-3406 Erat. St.', 97, 3, 5),
       ('a.aliquet@google.couk', 'Chancellor', 'Blackwell', 'Sed', '333-6996 Mauris Road', 98, 4, null),
       ('tincidunt.nibh@icloud.edu', 'Wesley', 'Barr', 'tincidunt', '8127 Sagittis Avenue', 99, 6, null),
       ('rutrum.lorem@google.com', 'Farrah', 'Arnold', 'Proin', 'Ap #640-6840 Nulla Rd.', 100, 8, null),
       ('lectus.a@google.net', 'Felix', 'Bright', 'dolor.', '695 Pede. St.', 101, 7, 4),
       ('vel@aol.couk', 'Cailin', 'Gordon', 'netus', '656-6039 Tortor Av.', 102, 7, null),
       ('suspendisse.dui.fusce@yahoo.com', 'Brenda', 'Ortega', 'lectus', '494-4492 Augue Rd.', 103, 1, null),
       ('et@protonmail.couk', 'Cheyenne', 'Simpson', 'eget,', 'P.O. Box 427, 3000 At, Avenue', 104, 10, 3),
       ('luctus.curabitur@protonmail.org', 'Carolyn', 'Hodge', 'a,', '806-6110 Arcu. Av.', 105, 10, null),
       ('est.nunc.laoreet@aol.org', 'Wynter', 'Wong', 'convallis', 'Ap #878-7414 Ut Rd.', 106, 12, null),
       ('vivamus.non@google.ca', 'Ivor', 'Torres', 'vitae,', '9796 Id Street', 107, 11, null),
       ('lectus@outlook.com', 'Dylan', 'Farley', 'orci', '6079 Eget Rd.', 108, 10, 4),
       ('in.aliquet@aol.net', 'Baker', 'Bishop', 'ante', '916-424 Suspendisse St.', 109, 8, 3),
       ('in.ornare.sagittis@aol.edu', 'Salvador', 'Ratliff', 'facilisis', '253-355 Iaculis Ave', 110, 11, 4),
       ('euismod.est@yahoo.com', 'Sebastian', 'Parsons', 'fringilla', 'Ap #912-237 Eget, Avenue', 111, 12, null),
       ('placerat.velit.quisque@yahoo.com', 'Hayfa', 'Clayton', 'Cum', '1424 Elit, St.', 112, 14, null),
       ('varius.orci.in@aol.ca', 'Brynn', 'Eaton', 'Nulla', '563-9493 Dictum St.', 113, 15, 1),
       ('dolor@hotmail.net', 'Leila', 'Reid', 'Vivamus', '6636 Phasellus St.', 114, 7, null),
       ('consectetuer.ipsum@aol.ca', 'Lunea', 'Mcfadden', 'ad', 'P.O. Box 847, 8605 Quisque Ave', 115, 2, null),
       ('purus.nullam.scelerisque@aol.ca', 'Yardley', 'Stanton', 'conubia', 'P.O. Box 555, 4174 Diam St.', 116, 2,
        null),
       ('velit@yahoo.edu', 'Eagan', 'Gonzalez', 'non,', '733-5059 Aenean St.', 117, 8, null),
       ('vel.turpis@google.couk', 'Hasad', 'Snow', 'lorem,', '265-5202 Quis St.', 118, 12, null),
       ('purus.accumsan@icloud.ca', 'Britanney', 'Patrick', 'orci,', 'Ap #499-1932 Feugiat Rd.', 119, 16, null),
       ('consequat.nec.mollis@hotmail.net', 'Jerome', 'Stuart', 'vestibulum.', '9859 Lorem Rd.', 120, 3, null),
       ('condimentum.eget@aol.net', 'Cameron', 'Hubbard', 'tempor', '865-8338 Eu St.', 121, 13, null),
       ('dui.lectus@yahoo.ca', 'Nyssa', 'Peterson', 'turpis', 'P.O. Box 815, 9076 Inceptos St.', 122, 15, null),
       ('leo.morbi@icloud.net', 'Lyle', 'Burns', 'sit', 'Ap #577-6497 Quis Ave', 123, 15, null),
       ('elit.erat@protonmail.net', 'Alfreda', 'Hendrix', 'Praesent', '274-7796 Molestie St.', 124, 6, null),
       ('donec.at@icloud.ca', 'Mariam', 'Horn', 'ac,', 'Ap #587-973 Donec Street', 125, 3, null),
       ('aliquet.molestie@protonmail.org', 'Britanni', 'Mccarty', 'consectetuer', 'Ap #141-8256 Sed Av.', 126, 9, null),
       ('nunc.sed@outlook.ca', 'Buckminster', 'Pittman', 'feugiat.', '205-1704 Donec Ave', 127, 6, null),
       ('aliquam.enim.nec@protonmail.couk', 'Kameko', 'Jenkins', 'mi', '639-7494 Libero. Ave', 128, 9, 1),
       ('fermentum@protonmail.ca', 'Ryan', 'Estrada', 'Vivamus', 'P.O. Box 988, 6328 Aliquam Rd.', 129, 7, null),
       ('dui@yahoo.couk', 'Jemima', 'Sweet', 'nunc', 'Ap #604-9216 Elit St.', 130, 5, null),
       ('molestie.in@protonmail.org', 'Dexter', 'Chaney', 'vulputate', 'Ap #544-4466 Proin Street', 131, 5, null),
       ('neque.sed@hotmail.net', 'Quon', 'Brady', 'orci.', 'Ap #256-2656 Lectus Ave', 132, 17, null),
       ('dolor.tempus@hotmail.ca', 'Benedict', 'Sutton', 'eu', '852-7982 Laoreet Avenue', 133, 5, null),
       ('luctus.curabitur.egestas@aol.edu', 'Anika', 'Alvarado', 'erat', 'Ap #674-3016 Neque. Rd.', 134, 11, null),
       ('massa@icloud.com', 'Karleigh', 'Weeks', 'velit.', 'Ap #432-6226 Eget Avenue', 135, 14, null),
       ('malesuada@yahoo.net', 'Clio', 'Frazier', 'Morbi', 'Ap #667-6936 Diam Av.', 136, 9, null),
       ('nec.euismod@aol.com', 'Gary', 'Parks', 'enim.', '1383 Nibh. Road', 137, 13, null),
       ('tempor.est@icloud.net', 'Hayfa', 'Sherman', 'non', '683-1029 Pede. Rd.', 138, 7, null),
       ('eu.lacus.quisque@hotmail.edu', 'Jakeem', 'Baker', 'urna', '8764 Aenean Av.', 139, 16, null),
       ('senectus.et.netus@icloud.com', 'Lillith', 'Savage', 'neque', '391-1724 Magna. Rd.', 140, 11, null),
       ('aliquet.phasellus@yahoo.org', 'Ava', 'Rosales', 'commodo', '630-7024 Nibh Av.', 141, 7, null),
       ('massa.mauris@outlook.com', 'Sebastian', 'Bullock', 'Pellentesque', 'Ap #210-4621 Turpis. Street', 142, 12,
        null),
       ('mauris@yahoo.couk', 'Herrod', 'Ratliff', 'Integer', '3234 Pretium St.', 143, 15, null),
       ('nec.eleifend@aol.ca', 'Nicholas', 'Buckley', 'feugiat.', 'Ap #386-9702 Suspendisse Avenue', 144, 9, null),
       ('posuere.cubilia.curae@yahoo.org', 'Jasper', 'Nolan', 'nisl', 'Ap #834-9598 Mauris Ave', 145, 1, null),
       ('non.enim@protonmail.org', 'Buffy', 'Holland', 'mauris', 'Ap #974-1909 Pellentesque Street', 146, 1, null),
       ('lacus.quisque@outlook.ca', 'Jeanette', 'Gates', 'Aenean', '323-4335 Posuere, Ave', 147, 9, null),
       ('vulputate.posuere@icloud.net', 'Burton', 'Arnold', 'non,', '294-4885 Quisque St.', 148, 10, null),
       ('eu.tempor@icloud.com', 'Keely', 'Spencer', 'elit', '9456 Magna. Rd.', 149, 13, null),
       ('odio.nam.interdum@hotmail.couk', 'Marah', 'Palmer', 'diam', '118-9576 A, Street', 150, 11, null),
       ('cursus.diam@protonmail.edu', 'Gil', 'Chavez', 'accumsan', 'P.O. Box 317, 4920 Lobortis Rd.', 151, 10, 5),
       ('justo.nec@hotmail.edu', 'Adena', 'Frederick', 'sit', 'Ap #853-6470 Erat St.', 152, 15, null),
       ('donec.feugiat@google.net', 'Nathan', 'Day', 'sem.', 'Ap #564-179 Lectus, Avenue', 153, 7, null),
       ('tincidunt.aliquam@icloud.edu', 'Macey', 'Cooley', 'Aenean', 'P.O. Box 445, 3103 Sociis St.', 154, 3, null),
       ('a.mi@protonmail.edu', 'Plato', 'O''brien', 'Cras', 'Ap #361-791 Urna St.', 155, 9, 5),
       ('nulla.aliquet.proin@outlook.org', 'Chaney', 'Garrison', 'nibh.', '6124 Donec Ave', 156, 4, null),
       ('aliquet@protonmail.ca', 'Rigel', 'Campbell', 'ultricies', '373-2345 Feugiat Avenue', 157, 2, null),
       ('nunc@aol.edu', 'Aretha', 'Phillips', 'dolor.', 'P.O. Box 901, 1104 Ligula Ave', 158, 14, null),
       ('nulla@yahoo.edu', 'Graham', 'Mcclure', 'turpis.', 'P.O. Box 887, 9293 Massa. Rd.', 159, 15, null),
       ('velit.eu@aol.net', 'Aquila', 'Meyer', 'metus.', 'Ap #561-1978 Vulputate Ave', 160, 11, 1),
       ('nisi.a@aol.couk', 'Carlos', 'Rush', 'egestas', 'Ap #152-6266 Ipsum. Rd.', 161, 9, null),
       ('mi.tempor@protonmail.couk', 'Stuart', 'Steele', 'at,', '578-6489 Aliquet Avenue', 162, 14, 4),
       ('ornare.lectus.ante@icloud.ca', 'Tucker', 'Blanchard', 'ligula.', '8602 Odio. Road', 163, 14, null),
       ('at.pretium@icloud.edu', 'Genevieve', 'Terrell', 'orci,', '325 Ipsum Street', 164, 5, 2),
       ('ac.nulla@aol.ca', 'Adrienne', 'Holmes', 'ultrices', 'Ap #477-2169 Sed Av.', 165, 5, null),
       ('cum.sociis@protonmail.couk', 'Levi', 'Nixon', 'ipsum', 'Ap #129-2372 Eu St.', 166, 3, 5),
       ('est.vitae@outlook.couk', 'Fletcher', 'Brennan', 'dictum.', '7392 Mattis Rd.', 167, 7, null),
       ('dui.quis.accumsan@hotmail.net', 'Boris', 'Mcbride', 'placerat,', '590-1673 Tempor Street', 168, 2, null),
       ('a.mi@outlook.couk', 'Upton', 'Ryan', 'amet', 'Ap #753-5866 Ullamcorper, St.', 169, 15, null),
       ('integer.tincidunt@icloud.edu', 'Whoopi', 'Hoffman', 'tellus.', 'Ap #860-8496 Ipsum Rd.', 170, 15, null),
       ('amet.risus@protonmail.edu', 'Nasim', 'Roberts', 'enim', 'Ap #644-7687 Hendrerit Avenue', 171, 12, null),
       ('nec.eleifend.non@hotmail.edu', 'Connor', 'Watkins', 'Sed', '106-1671 Et Rd.', 172, 8, null),
       ('imperdiet.erat@outlook.ca', 'Melissa', 'Gonzales', 'Nunc', 'Ap #645-7470 Varius Road', 173, 4, 5),
       ('nostra.per@hotmail.org', 'Aline', 'Spence', 'ipsum', 'P.O. Box 973, 5598 Scelerisque Rd.', 174, 6, 1),
       ('nisi@yahoo.ca', 'Eric', 'Combs', 'Nunc', '947-1833 Purus. St.', 175, 3, null),
       ('pede.nec@hotmail.couk', 'Wendy', 'English', 'augue', 'P.O. Box 798, 9078 Risus. Av.', 176, 9, 1),
       ('ac.ipsum.phasellus@yahoo.com', 'Mark', 'Anderson', 'elit.', 'P.O. Box 899, 1320 Mauris Avenue', 177, 17, null),
       ('felis.purus@protonmail.edu', 'Geraldine', 'Barry', 'Donec', 'P.O. Box 209, 3899 Vel Av.', 178, 12, 6),
       ('dictum.ultricies@outlook.com', 'Zachery', 'Cunningham', 'nunc', '971-544 Diam Ave', 179, 1, 4),
       ('orci@protonmail.com', 'Kasper', 'Wooten', 'quam', 'Ap #854-363 Molestie Av.', 180, 9, null),
       ('ultrices@yahoo.com', 'Edward', 'Mccoy', 'lorem,', 'P.O. Box 514, 5075 Felis Rd.', 181, 8, null),
       ('mus.donec@protonmail.com', 'Devin', 'Melendez', 'dolor', '946-7834 Mus. Road', 182, 14, null),
       ('in.tempus@icloud.net', 'Otto', 'Crane', 'eget', 'Ap #450-2144 Vestibulum St.', 183, 15, null),
       ('venenatis.lacus@outlook.edu', 'Tiger', 'Haney', 'arcu', 'Ap #472-9187 Felis, Rd.', 184, 15, null),
       ('non.leo@protonmail.net', 'Felix', 'Herring', 'posuere,', 'Ap #826-8672 Mollis St.', 185, 10, null),
       ('orci.adipiscing@aol.org', 'Reece', 'Becker', 'libero', '991-3405 Mauris Av.', 186, 14, null),
       ('augue.ac@protonmail.ca', 'Haviva', 'Hurley', 'neque', '132-2929 Eros. Street', 187, 3, null),
       ('elementum.at.egestas@protonmail.org', 'Tamara', 'Sawyer', 'ultricies', '2478 Ultrices Rd.', 188, 3, null),
       ('tristique.aliquet.phasellus@google.ca', 'Kim', 'Pacheco', 'fringilla.', 'Ap #319-1207 Amet Ave', 189, 15,
        null),
       ('ante@hotmail.com', 'Jenna', 'Mays', 'elementum', '158-381 Aliquam St.', 190, 1, null),
       ('dignissim.tempor@icloud.edu', 'Isaiah', 'Jacobs', 'mattis', 'P.O. Box 828, 3767 Non, Avenue', 191, 12, null),
       ('est.tempor@yahoo.ca', 'Ann', 'Mcintosh', 'est', 'Ap #445-4326 Aliquam Street', 192, 16, null),
       ('nullam.nisl@hotmail.org', 'Travis', 'Walters', 'dolor.', 'P.O. Box 696, 8967 Ante St.', 193, 13, null),
       ('lorem.lorem@hotmail.org', 'Ingrid', 'Drake', 'risus', '950-6506 Non St.', 194, 11, null),
       ('quam.curabitur.vel@yahoo.couk', 'Nell', 'Moreno', 'tincidunt', '236-4301 Nunc Av.', 195, 5, null),
       ('eros@hotmail.ca', 'Nolan', 'Nielsen', 'sapien.', 'P.O. Box 974, 9668 Aliquam Av.', 196, 16, null),
       ('sed@hotmail.ca', 'Dahlia', 'Estrada', 'non,', '822-2631 Consectetuer Avenue', 197, 15, null),
       ('est.tempor@protonmail.edu', 'Urielle', 'Cooper', 'aliquet.', '809-9053 Risus. Rd.', 198, 9, null),
       ('aliquam.ornare@yahoo.net', 'Phoebe', 'Patterson', 'turpis', '6215 Nunc St.', 199, 5, null),
       ('nibh@hotmail.edu', 'Nathaniel', 'Walters', 'nec', '5725 Pede. St.', 200, 16, null),
       ('mauris.quis@hotmail.net', 'Aidan', 'Conley', 'diam', '4158 Aliquam Avenue', 201, 8, null),
       ('feugiat.metus@yahoo.com', 'Delilah', 'Sweeney', 'justo', '192-5649 Quam St.', 202, 7, null),
       ('aenean.eget@icloud.ca', 'Allistair', 'Pratt', 'ligula.', 'Ap #164-3672 Eleifend. Road', 203, 9, null),
       ('ac.urna.ut@yahoo.ca', 'Desirae', 'Graham', 'nonummy', 'P.O. Box 443, 953 Cras Street', 204, 4, null),
       ('nunc.id.enim@icloud.net', 'Tanya', 'Morrow', 'felis', '571-5575 Dolor. Avenue', 205, 6, null),
       ('mauris@icloud.edu', 'John', 'Woodard', 'orci', '6212 Et Road', 206, 3, 1),
       ('fringilla.purus.mauris@icloud.couk', 'Quinn', 'Donaldson', 'bibendum', 'P.O. Box 511, 9547 Amet Rd.', 207, 16,
        null),
       ('sem.pellentesque@google.couk', 'Steven', 'Young', 'Nullam', 'Ap #422-678 Augue Street', 208, 13, 3),
       ('semper.pretium@yahoo.org', 'Skyler', 'Cash', 'et', '566-1357 Adipiscing Road', 209, 14, null),
       ('sapien.cursus@google.com', 'Rajah', 'Carey', 'et,', 'Ap #245-391 Sed Av.', 210, 17, null),
       ('sem.eget.massa@aol.org', 'Ingrid', 'Garner', 'leo.', 'Ap #706-388 Sem Rd.', 211, 8, null),
       ('nulla.semper@protonmail.net', 'Joel', 'Rosales', 'ac,', '991-923 Lorem St.', 212, 16, null),
       ('eget@icloud.org', 'Bryar', 'Alford', 'facilisis', '134 A St.', 213, 2, null),
       ('eu.dolor@yahoo.org', 'Alec', 'Hood', 'eleifend,', 'P.O. Box 652, 7201 Quisque St.', 214, 9, null),
       ('a.neque.nullam@outlook.org', 'Venus', 'Craft', 'consectetuer', '152-9541 Amet, St.', 215, 6, null),
       ('nunc@google.ca', 'Sarah', 'Bryant', 'facilisis', 'Ap #959-790 Proin Rd.', 216, 12, null),
       ('ornare.sagittis@aol.ca', 'Travis', 'Carver', 'montes,', 'Ap #298-8751 Felis, Av.', 217, 15, null),
       ('maecenas@protonmail.net', 'Lacey', 'Cameron', 'orci', '2586 Eget, St.', 218, 9, null),
       ('leo.in.lobortis@google.couk', 'Brenden', 'Buckner', 'arcu.', 'P.O. Box 570, 5798 Nunc Rd.', 219, 17, null),
       ('dui@outlook.edu', 'Savannah', 'Holman', 'amet', '408-4881 Ornare, Av.', 220, 12, null),
       ('integer.sem.elit@yahoo.edu', 'Maggie', 'Little', 'Phasellus', '522-4460 Sem Av.', 221, 5, null),
       ('montes.nascetur@outlook.edu', 'Vivian', 'Wallace', 'mauris', 'P.O. Box 557, 1250 Ut St.', 222, 9, null),
       ('adipiscing.elit@icloud.com', 'Connor', 'Hoover', 'auctor', '633-9928 Ante Rd.', 223, 2, null),
       ('et@icloud.org', 'Martin', 'Mcguire', 'non', '508-4457 Dolor Rd.', 224, 7, null),
       ('in.dolor@hotmail.couk', 'Cheryl', 'Pennington', 'aliquam,', 'Ap #678-2450 Lacus. Avenue', 225, 6, 5),
       ('lectus@hotmail.couk', 'Laith', 'Howard', 'ipsum', 'Ap #907-7405 Leo. Ave', 226, 13, null),
       ('dui.nec@yahoo.org', 'Garrison', 'Snider', 'purus.', 'Ap #144-6923 Nec Av.', 227, 11, 3),
       ('nisl.elementum@yahoo.net', 'Regina', 'Leach', 'quis,', 'Ap #112-3215 Praesent Road', 228, 1, null),
       ('sit.amet@hotmail.edu', 'Maggie', 'Mcdaniel', 'diam', '395-2589 Egestas Rd.', 229, 11, null),
       ('luctus.ut@outlook.com', 'Belle', 'Mclaughlin', 'In', 'Ap #282-217 Interdum. Road', 231, 2, null),
       ('est.mollis@aol.com', 'Hyacinth', 'Guerra', 'tristique', '990 Dolor Road', 232, 16, null),
       ('sit@yahoo.ca', 'Phoebe', 'Barton', 'Curabitur', 'P.O. Box 740, 5862 Et Ave', 233, 12, 3),
       ('mattis.velit@protonmail.net', 'Macaulay', 'Wiggins', 'est,', '503-5341 Rutrum Rd.', 234, 10, null),
       ('nulla.aliquet@yahoo.org', 'Drake', 'Klein', 'ut,', '3072 At St.', 235, 8, null),
       ('est.ac@protonmail.com', 'William', 'Valentine', 'metus.', 'Ap #902-7027 Scelerisque Ave', 236, 12, null),
       ('nullam.scelerisque@icloud.net', 'Ima', 'Brennan', 'ipsum', '6137 Orci St.', 237, 7, null),
       ('vulputate.mauris@google.net', 'Yen', 'Norman', 'nisi.', '862-2800 Malesuada Road', 238, 15, null),
       ('sed.consequat@icloud.edu', 'Hayes', 'Holden', 'molestie', '3291 Augue Ave', 239, 7, 4),
       ('ipsum.donec.sollicitudin@hotmail.ca', 'Chelsea', 'Franks', 'pede,', 'P.O. Box 619, 7192 Libero Av.', 240, 14,
        null),
       ('etiam@google.ca', 'Noble', 'Ferguson', 'cursus', '986-2441 Ac Street', 241, 12, null),
       ('nam.interdum@aol.com', 'Orson', 'Tillman', 'vel,', '3770 Dui Av.', 242, 7, null),
       ('dui@protonmail.ca', 'Graiden', 'James', 'nec', 'P.O. Box 869, 3299 Integer St.', 243, 16, null),
       ('primis.in@yahoo.couk', 'Joel', 'Munoz', 'pretium', 'P.O. Box 663, 5060 Eget, St.', 244, 1, 2),
       ('vehicula@hotmail.ca', 'Rajah', 'Faulkner', 'Nunc', 'Ap #435-8998 Hendrerit St.', 245, 17, null),
       ('porttitor@hotmail.com', 'Summer', 'Bender', 'vehicula', 'P.O. Box 527, 369 Tortor Avenue', 246, 15, null),
       ('vestibulum.ut@icloud.net', 'Davis', 'Stewart', 'nec', 'P.O. Box 981, 9317 Massa. St.', 247, 14, null),
       ('dapibus.rutrum@yahoo.net', 'Warren', 'Burgess', 'consequat,', 'Ap #177-6118 Feugiat. St.', 248, 7, null),
       ('est.ac@google.org', 'Hadassah', 'Moss', 'erat', 'Ap #146-6024 Felis. Road', 249, 10, null),
       ('diam.pellentesque@outlook.org', 'Drew', 'Manning', 'Sed', 'P.O. Box 167, 1056 Ante St.', 250, 9, null),
       ('nunc.ac@hotmail.org', 'Ethan', 'Gilbert', 'a', '296-6134 Turpis Road', 252, 6, null),
       ('metus@google.com', 'Jaquelyn', 'Merrill', 'pharetra.', 'P.O. Box 597, 2764 In St.', 253, 10, null),
       ('lorem.tristique@outlook.com', 'Theodore', 'Emerson', 'sodales', '5523 Ligula. Rd.', 254, 6, 3),
       ('odio@protonmail.couk', 'Ava', 'Cardenas', 'Proin', '610-7607 Et St.', 255, 7, null),
       ('sed.consequat@outlook.ca', 'Aline', 'Howell', 'lacinia', 'Ap #515-6591 Dolor, Av.', 256, 14, 2),
       ('aliquam@yahoo.couk', 'Kieran', 'Clark', 'neque', '2118 Sed Ave', 257, 2, null),
       ('urna.ut@google.net', 'Emily', 'Garner', 'mollis.', 'Ap #972-3433 Et Av.', 258, 17, null),
       ('pretium.neque@protonmail.org', 'Mechelle', 'Downs', 'mi', '304-5805 Elit, Street', 259, 17, null),
       ('libero.donec.consectetuer@yahoo.edu', 'Brendan', 'Morris', 'tellus', 'Ap #859-9445 Hendrerit St.', 260, 3, 4),
       ('nunc.quisque.ornare@aol.edu', 'Armand', 'Santiago', 'libero', '2143 Tempus St.', 261, 16, null),
       ('sit@yahoo.edu', 'Ezekiel', 'Kaufman', 'gravida', 'P.O. Box 905, 9381 Amet, Road', 262, 7, null),
       ('imperdiet@yahoo.edu', 'Dara', 'Bell', 'elit.', 'P.O. Box 984, 4518 Turpis Road', 263, 11, null),
       ('metus.in@outlook.ca', 'Uma', 'Leach', 'condimentum', '243-1099 Diam Road', 264, 14, 5),
       ('augue@protonmail.com', 'Sierra', 'Travis', 'Lorem', '478-3578 Ligula Rd.', 265, 12, null),
       ('vivamus.euismod@protonmail.net', 'Stacey', 'Vazquez', 'pellentesque', 'Ap #103-1213 Euismod Street', 266, 4,
        null),
       ('erat@aol.ca', 'Nola', 'Cote', 'Suspendisse', '447-5825 Libero St.', 267, 12, null),
       ('eget.massa.suspendisse@yahoo.ca', 'Vance', 'Ross', 'consequat', '699-5953 Purus. St.', 268, 10, null),
       ('interdum@icloud.ca', 'Adam', 'Hardy', 'hendrerit', '641-381 Arcu. Ave', 269, 8, null),
       ('tristique@icloud.edu', 'Harper', 'Petty', 'Nunc', '424-116 Eu Av.', 270, 5, null),
       ('ipsum.dolor@outlook.couk', 'Yvette', 'Dickerson', 'ipsum', 'Ap #722-2825 Eu St.', 271, 2, null),
       ('fringilla.euismod@icloud.couk', 'Briar', 'Rios', 'Integer', '178-5950 Ultricies Avenue', 272, 14, null),
       ('cubilia.curae@icloud.com', 'Ralph', 'Nieves', 'bibendum', '7032 Pede Av.', 273, 17, null),
       ('nisi.dictum.augue@aol.ca', 'Gary', 'Mason', 'libero', '883-6121 Molestie Rd.', 274, 8, null),
       ('duis.dignissim.tempor@icloud.ca', 'Halee', 'Stevenson', 'auctor', '7710 Vivamus Avenue', 275, 3, 1),
       ('mauris@protonmail.couk', 'Dahlia', 'Cleveland', 'lectus', 'Ap #844-8467 Nullam Av.', 276, 2, 1),
       ('neque@protonmail.org', 'Ahmed', 'Patton', 'dictum', '871-4378 Arcu Av.', 277, 15, null),
       ('metus.eu.erat@hotmail.couk', 'Jolene', 'Brown', 'Lorem', 'Ap #345-4157 Elit, Avenue', 278, 4, null),
       ('ac.mattis@icloud.com', 'Vielka', 'Cox', 'turpis', 'P.O. Box 746, 9533 Aliquet St.', 279, 6, null),
       ('interdum.curabitur.dictum@aol.couk', 'Edan', 'Blevins', 'Donec', 'Ap #966-2648 Sed Rd.', 280, 4, null),
       ('sollicitudin@aol.org', 'Galvin', 'Patrick', 'gravida', '229-7970 Dolor, St.', 281, 9, null),
       ('dictum@protonmail.net', 'Brody', 'Peck', 'ac', 'P.O. Box 394, 126 Morbi Street', 282, 3, null),
       ('non.ante@yahoo.couk', 'Dillon', 'Justice', 'Donec', '3938 Augue. Ave', 283, 15, null),
       ('ac@yahoo.ca', 'Yeo', 'Good', 'natoque', 'P.O. Box 106, 349 Dis Road', 284, 17, null),
       ('magna.et@icloud.couk', 'Hedda', 'Daugherty', 'Curabitur', 'P.O. Box 887, 3171 Erat Ave', 285, 12, null),
       ('cras@aol.com', 'Autumn', 'Hatfield', 'elit,', 'Ap #895-4475 Velit Av.', 286, 3, null),
       ('sit.amet.lorem@protonmail.edu', 'Timothy', 'Drake', 'Aliquam', '112-5782 Vehicula Ave', 287, 8, null),
       ('nec.orci@yahoo.ca', 'Basia', 'Kline', 'non', 'P.O. Box 705, 1864 Est. Ave', 288, 6, null),
       ('elementum.lorem@icloud.edu', 'Brianna', 'Hutchinson', 'quis', 'P.O. Box 929, 5612 Rutrum St.', 289, 16, null),
       ('porttitor.interdum.sed@google.com', 'Wynne', 'Petty', 'montes,', 'Ap #874-9202 Ipsum Av.', 290, 3, null),
       ('nunc.interdum@google.edu', 'Kuame', 'Torres', 'Suspendisse', '961-3560 Sem, Rd.', 291, 5, null),
       ('eu@yahoo.org', 'Blossom', 'Colon', 'Nunc', '598-5896 Luctus Ave', 292, 3, null),
       ('vestibulum@icloud.net', 'Ursula', 'Warner', 'Aliquam', '6635 Ipsum Ave', 293, 14, 6),
       ('eget@protonmail.edu', 'Harriet', 'Valenzuela', 'auctor', '2193 Augue Ave', 294, 5, null),
       ('malesuada.id.erat@yahoo.edu', 'Acton', 'Savage', 'Quisque', 'P.O. Box 242, 7342 Accumsan Avenue', 295, 11,
        null),
       ('arcu.aliquam@protonmail.ca', 'Brady', 'Richard', 'velit', '509-775 Hendrerit Av.', 296, 3, null),
       ('pede.praesent.eu@aol.org', 'Stone', 'Walters', 'libero', 'Ap #619-5661 Duis Rd.', 297, 10, null),
       ('curabitur.dictum.phasellus@outlook.edu', 'Cain', 'Guerra', 'lobortis', 'P.O. Box 420, 9582 Mauris Street', 298,
        14, null),
       ('dictum.phasellus@yahoo.ca', 'Brock', 'Whitaker', 'malesuada', '145-7382 Curabitur Rd.', 299, 3, null),
       ('vel@outlook.edu', 'Cherokee', 'Riddle', 'amet', 'Ap #591-7910 Ipsum. Av.', 300, 15, null),
       ('orci@aol.edu', 'Celeste', 'Boyle', 'neque.', 'P.O. Box 376, 4407 Libero Street', 301, 5, null),
       ('eu.dui@outlook.com', 'Yael', 'Hester', 'metus.', '752-2890 Facilisis Street', 302, 12, null),
       ('interdum.feugiat.sed@google.ca', 'Aiko', 'Delaney', 'Praesent', 'Ap #219-5229 Nulla Avenue', 303, 3, null),
       ('fringilla.euismod.enim@google.edu', 'Indigo', 'Lara', 'Donec', '453-6604 Facilisis, Avenue', 304, 13, null),
       ('egestas.sed.pharetra@hotmail.org', 'Jael', 'Jones', 'arcu.', '813-2150 Auctor Rd.', 305, 13, null),
       ('duis.gravida@yahoo.net', 'Halla', 'Matthews', 'penatibus', '104-5696 Mauris. Avenue', 306, 10, null),
       ('sed@google.edu', 'Hop', 'Thomas', 'tincidunt', 'Ap #415-2759 Risus. Rd.', 307, 14, null),
       ('egestas@icloud.edu', 'Suki', 'Macias', 'per', 'Ap #800-8101 Mauris St.', 308, 7, null),
       ('cras.convallis.convallis@aol.com', 'Quemby', 'Mccullough', 'pellentesque', 'Ap #264-6615 Imperdiet Ave', 309,
        10, null),
       ('nec.urna@protonmail.ca', 'Felicia', 'Lynn', 'Curabitur', 'Ap #241-2060 Nisl Road', 310, 5, null),
       ('tellus.aenean@yahoo.couk', 'Orlando', 'Stein', 'Quisque', '151-2060 Integer Street', 311, 6, null),
       ('lacinia@hotmail.org', 'Jonah', 'Witt', 'lorem', '293-2849 Suscipit Road', 312, 13, null),
       ('praesent.interdum@hotmail.net', 'Hall', 'Weeks', 'Duis', '4707 In, Ave', 313, 16, null),
       ('eu@yahoo.edu', 'Darryl', 'Cross', 'taciti', '5001 Rhoncus. Rd.', 314, 14, null),
       ('nullam.velit@outlook.ca', 'Kai', 'Valenzuela', 'leo.', '289-8933 Facilisis Rd.', 315, 1, null),
       ('mauris.sapien@outlook.com', 'Tiger', 'Petty', 'consequat', '901-2036 Curabitur Rd.', 316, 7, null),
       ('aenean.euismod@aol.com', 'Keith', 'Guerra', 'euismod', 'Ap #352-8911 Ante Rd.', 317, 13, null),
       ('sem@aol.edu', 'Isadora', 'Fulton', 'luctus', 'Ap #882-1474 Morbi Ave', 318, 12, null),
       ('duis@protonmail.couk', 'Martin', 'Flores', 'Etiam', '552-133 Aliquam Av.', 319, 4, null),
       ('sed@yahoo.ca', 'TaShya', 'Tucker', 'libero.', 'P.O. Box 888, 973 Felis. Rd.', 320, 14, null),
       ('convallis@google.ca', 'September', 'Richardson', 'a', 'Ap #452-1879 Vel, Road', 321, 9, null),
       ('nulla@aol.org', 'Gail', 'Fields', 'semper,', '1848 Ultricies St.', 322, 11, null),
       ('arcu.sed@outlook.couk', 'Garrett', 'Allison', 'molestie.', 'P.O. Box 801, 5858 Litora Rd.', 323, 15, null),
       ('feugiat.lorem@outlook.net', 'Colt', 'Booth', 'nulla', '298-7353 Lobortis St.', 324, 3, null),
       ('tellus@outlook.net', 'Yen', 'Sheppard', 'velit', '154-2450 Duis Ave', 325, 16, 3),
       ('aliquet.nec@hotmail.edu', 'Neville', 'Ratliff', 'Pellentesque', '774-6908 Metus. Avenue', 326, 4, null),
       ('mauris@outlook.ca', 'Axel', 'Green', 'orci,', 'Ap #473-8857 Commodo Road', 327, 12, null),
       ('morbi.non@google.com', 'Honorato', 'Rogers', 'lacus.', '398-1909 Semper Road', 328, 12, null),
       ('ante.dictum@google.org', 'Peter', 'Vasquez', 'ipsum.', '3781 Pharetra Av.', 329, 11, null),
       ('vulputate.lacus.cras@icloud.org', 'Lance', 'Davis', 'sed', 'Ap #628-5141 Porttitor St.', 330, 15, null),
       ('consequat.purus.maecenas@outlook.net', 'Patience', 'Ortiz', 'risus.', 'P.O. Box 545, 7065 Ornare Road', 331,
        11, null),
       ('lectus.nullam.suscipit@icloud.com', 'Nasim', 'Valencia', 'risus', '106-1181 Est. Road', 332, 10, null),
       ('fringilla.ornare.placerat@protonmail.org', 'Thaddeus', 'Kinney', 'imperdiet', '6358 Amet, St.', 333, 3, null),
       ('rutrum.magna.cras@icloud.couk', 'Merrill', 'Ayala', 'vitae,', 'Ap #136-3770 Risus, St.', 334, 9, null),
       ('facilisis.non@icloud.ca', 'Drew', 'Moore', 'nec', 'Ap #737-9932 Egestas St.', 335, 12, null),
       ('diam.duis@protonmail.com', 'Coby', 'Justice', 'at', 'Ap #963-3166 Fusce Ave', 336, 13, null),
       ('dictum.mi@google.couk', 'Olga', 'Barnett', 'aliquam', '1061 Facilisis St.', 337, 9, null),
       ('dolor.dapibus@icloud.ca', 'Maxwell', 'Klein', 'mus.', '1403 Laoreet, Street', 338, 2, 3),
       ('lorem.vehicula.et@hotmail.net', 'Alisa', 'Prince', 'accumsan', '843-1635 Eu, Av.', 339, 13, null),
       ('tortor.nibh@icloud.org', 'Jonah', 'Lester', 'ultricies', 'Ap #414-1621 Mauris Ave', 340, 7, 1),
       ('aliquet.phasellus@hotmail.ca', 'Faith', 'Sims', 'metus', 'P.O. Box 957, 8933 Ultricies Ave', 341, 5, null),
       ('cras.dictum@protonmail.ca', 'Melinda', 'Barron', 'ut,', 'P.O. Box 766, 6718 Luctus Ave', 342, 15, null),
       ('eget.varius@protonmail.org', 'Irma', 'Hebert', 'orci', 'Ap #123-7168 Vestibulum Avenue', 343, 10, null),
       ('eu.augue@outlook.org', 'Travis', 'Kirkland', 'a,', 'Ap #958-1928 Auctor Av.', 344, 16, null),
       ('tincidunt@outlook.edu', 'Trevor', 'Haynes', 'neque', 'Ap #107-5237 Vulputate St.', 345, 5, null),
       ('lectus.ante@outlook.net', 'Lillith', 'Rich', 'nisi.', 'Ap #898-5498 Nisl Ave', 346, 6, null),
       ('vulputate.risus@aol.edu', 'Kylan', 'Tucker', 'arcu', 'Ap #894-4539 Vitae, Street', 347, 3, null),
       ('semper.tellus@hotmail.com', 'Basil', 'O''connor', 'enim.', '407-7555 Id Street', 348, 16, null),
       ('consequat.lectus.sit@aol.couk', 'Preston', 'Beard', 'magna.', '3045 Nulla Avenue', 349, 2, null),
       ('aliquam.auctor@aol.com', 'Ciara', 'Petersen', 'posuere', '158-909 Praesent St.', 350, 13, null),
       ('lorem.lorem@outlook.org', 'Eugenia', 'Boone', 'lacus.', '3712 Amet Road', 351, 3, null),
       ('ad.litora@protonmail.edu', 'Angelica', 'Macias', 'eleifend', '917-4284 Donec Avenue', 352, 11, null),
       ('luctus.et@protonmail.ca', 'Deanna', 'Cooper', 'ut', '879-995 Ut St.', 353, 11, null),
       ('eget.metus@aol.net', 'Skyler', 'Dixon', 'Pellentesque', 'Ap #508-1401 Aliquet, Avenue', 354, 14, 5),
       ('donec.nibh.enim@outlook.couk', 'Zeph', 'Lang', 'Nulla', 'Ap #992-8239 Velit Street', 355, 17, null),
       ('turpis.egestas@yahoo.ca', 'Myra', 'Rodriguez', 'feugiat', 'Ap #731-2111 Id, Rd.', 356, 3, null),
       ('consequat@yahoo.couk', 'Zachery', 'Chang', 'pretium', 'Ap #898-7390 Luctus St.', 357, 2, 4),
       ('curabitur@yahoo.ca', 'Benedict', 'Moon', 'volutpat.', '272-955 Litora St.', 358, 16, null),
       ('ornare.in.faucibus@outlook.edu', 'Risa', 'Gilliam', 'molestie.', 'Ap #734-6466 Sed Street', 359, 17, null),
       ('sapien.imperdiet@outlook.couk', 'Nichole', 'Compton', 'a,', 'Ap #590-7757 Consectetuer Rd.', 360, 15, 2),
       ('eu@protonmail.com', 'Frances', 'Sparks', 'aliquet', 'P.O. Box 222, 4787 Rhoncus. Road', 361, 5, null),
       ('nulla.aliquet@icloud.org', 'Beck', 'Byrd', 'Integer', '759-8299 Tincidunt St.', 362, 3, 3),
       ('sodales.purus.in@outlook.org', 'Buckminster', 'Vaughan', 'lectus', '715-7646 At, Av.', 363, 2, null),
       ('vestibulum.lorem.sit@protonmail.edu', 'Kato', 'Ortiz', 'faucibus.', '405-2992 Nulla. Av.', 364, 4, null),
       ('consequat.auctor.nunc@protonmail.couk', 'Elizabeth', 'Maxwell', 'tristique', 'Ap #529-5679 Eu, Road', 365, 3,
        null),
       ('placerat.velit.quisque@aol.org', 'Mary', 'Stone', 'Vivamus', '609-4251 Vitae St.', 366, 2, null),
       ('eu@outlook.couk', 'Gretchen', 'Chavez', 'mauris', '491-3634 Convallis St.', 367, 15, null),
       ('egestas.aliquam.nec@outlook.org', 'Adam', 'Elliott', 'cursus', 'Ap #735-7429 Ridiculus Road', 368, 11, 1),
       ('eu.tellus@hotmail.edu', 'Keiko', 'Joyner', 'Etiam', '284-8425 A, St.', 369, 8, null),
       ('nisl.nulla@outlook.org', 'Sarah', 'Sellers', 'magna,', 'Ap #876-9565 Lacinia Rd.', 370, 16, null),
       ('fermentum.vel@icloud.edu', 'Kenyon', 'Newton', 'Ut', '5258 Nunc Rd.', 371, 11, 4),
       ('ornare@hotmail.net', 'Ashely', 'Williams', 'id,', 'Ap #790-7050 Vel Rd.', 372, 10, null),
       ('nonummy.ac@outlook.couk', 'Ruby', 'Coffey', 'nunc,', 'Ap #263-1140 Enim. Rd.', 373, 14, null),
       ('sit.amet@icloud.org', 'Evelyn', 'Mcdaniel', 'turpis.', 'P.O. Box 722, 9654 Pede, Av.', 374, 3, null),
       ('nam.consequat@google.ca', 'Stacey', 'Hancock', 'mi', 'Ap #927-6583 Egestas. Street', 375, 2, null),
       ('nunc@yahoo.edu', 'Graiden', 'Buchanan', 'Nullam', '593-2096 Sit St.', 376, 6, null),
       ('cum.sociis@yahoo.com', 'Simon', 'Raymond', 'scelerisque', 'Ap #431-1797 Eu Rd.', 377, 3, null),
       ('erat.neque@google.ca', 'Prescott', 'Murray', 'Proin', 'P.O. Box 456, 3126 Ligula. Ave', 378, 2, 1),
       ('urna.vivamus.molestie@outlook.couk', 'Valentine', 'Moss', 'ut', 'P.O. Box 627, 3326 Feugiat Street', 379, 13,
        5),
       ('sit.amet.metus@yahoo.org', 'Jenna', 'Herring', 'rutrum', 'Ap #783-8744 Sed, Street', 380, 3, 4),
       ('facilisis@protonmail.com', 'Mara', 'Benton', 'Nulla', 'P.O. Box 984, 8990 Egestas. St.', 381, 14, null),
       ('dapibus.quam@google.ca', 'Justin', 'Foreman', 'ut', '169-9604 Vestibulum St.', 382, 12, 2),
       ('vitae@google.com', 'Gary', 'Benson', 'adipiscing', 'P.O. Box 294, 8964 Erat Road', 383, 15, null),
       ('cubilia.curae@aol.net', 'Xandra', 'Hanson', 'vitae', 'Ap #227-450 Pede. Ave', 384, 10, null),
       ('sollicitudin.commodo.ipsum@hotmail.ca', 'Wade', 'Nelson', 'neque', '830-1184 Luctus Ave', 385, 6, null),
       ('nunc.quis@protonmail.edu', 'Melissa', 'Stein', 'pretium', 'Ap #609-6093 Blandit Avenue', 386, 4, null),
       ('laoreet.ipsum@aol.org', 'Ora', 'Church', 'risus', 'Ap #385-8686 Est, Road', 387, 17, 4),
       ('ullamcorper.velit.in@aol.couk', 'Cairo', 'Key', 'tincidunt', 'Ap #494-6367 Purus St.', 388, 13, 2),
       ('convallis@outlook.edu', 'Francis', 'Gonzalez', 'augue', 'P.O. Box 878, 101 Sapien, Rd.', 389, 10, null),
       ('semper.rutrum.fusce@google.com', 'Victoria', 'Rhodes', 'ac', '959-5446 Molestie Ave', 390, 3, 1),
       ('egestas.rhoncus@yahoo.net', 'Melyssa', 'Brown', 'eu,', 'Ap #624-5769 Sit Av.', 391, 11, null),
       ('orci.adipiscing.non@icloud.com', 'Sasha', 'Benjamin', 'ridiculus', '985-5287 Curae Av.', 392, 11, null),
       ('magnis.dis@protonmail.net', 'Kadeem', 'Key', 'nec,', 'P.O. Box 947, 4047 Mollis Ave', 393, 10, null),
       ('aliquam.ultrices@outlook.couk', 'Phyllis', 'Wynn', 'aliquet', '436-977 Ullamcorper. St.', 394, 6, 3),
       ('nonummy.ultricies@aol.ca', 'Aimee', 'Wells', 'cubilia', '801-534 Aliquam Rd.', 395, 1, null),
       ('enim.nec.tempus@google.edu', 'Karleigh', 'Hull', 'eu', '3525 Enim. Ave', 396, 7, null),
       ('libero@icloud.org', 'Blaze', 'Whitney', 'non,', 'P.O. Box 857, 5439 Etiam Street', 397, 14, 2),
       ('molestie.tortor@google.ca', 'Porter', 'Mckay', 'ac', 'Ap #240-6376 Parturient Rd.', 398, 10, null),
       ('lectus.a.sollicitudin@hotmail.ca', 'Marah', 'Dodson', 'quis', '682-4637 Semper Rd.', 399, 9, 1),
       ('duis.a.mi@outlook.ca', 'Adele', 'Shepard', 'id', 'P.O. Box 232, 7286 Vel Rd.', 400, 1, null),
       ('natoque.penatibus.et@hotmail.com', 'Sandra', 'Logan', 'dapibus', 'P.O. Box 310, 5954 Habitant Road', 401, 9,
        null),
       ('imperdiet.nec.leo@yahoo.edu', 'Rosalyn', 'Murphy', 'Cras', 'P.O. Box 305, 8772 Etiam Av.', 402, 10, null),
       ('malesuada.fringilla@yahoo.ca', 'Edan', 'Lynn', 'egestas.', 'Ap #390-8170 Neque St.', 403, 5, null),
       ('ac.mattis@aol.ca', 'Clarke', 'Tyson', 'Donec', '556-525 Diam Road', 404, 5, null),
       ('ornare.libero@icloud.com', 'Sacha', 'Blackburn', 'Quisque', '617-3203 Dui. Rd.', 405, 10, null),
       ('eget.massa.suspendisse@yahoo.org', 'Uriah', 'Henderson', 'Nunc', '6966 Vitae Ave', 406, 17, null),
       ('euismod.ac@icloud.org', 'Charity', 'Blackburn', 'sit', '7428 Cras Street', 407, 5, null),
       ('risus.at@icloud.couk', 'Haley', 'Tate', 'interdum', 'Ap #788-6728 Dolor St.', 408, 3, null),
       ('a.purus@google.edu', 'Uriel', 'Marquez', 'sit', 'Ap #877-9256 Neque. Avenue', 409, 12, null),
       ('nullam@outlook.couk', 'Chantale', 'Adkins', 'Phasellus', '4277 Lorem, Ave', 410, 15, null),
       ('egestas.duis@protonmail.couk', 'Aphrodite', 'Flynn', 'ullamcorper.', 'P.O. Box 293, 8812 Mauris Road', 411, 15,
        null),
       ('ante@icloud.couk', 'Eve', 'England', 'Duis', 'P.O. Box 365, 6189 Diam Rd.', 412, 17, null),
       ('ligula.nullam@aol.net', 'Hall', 'Logan', 'Cras', 'Ap #153-4496 Aliquam Rd.', 413, 2, null),
       ('nibh.phasellus.nulla@icloud.net', 'Keane', 'Lopez', 'Nunc', '894-394 Non Rd.', 414, 2, null),
       ('magna.nam@outlook.org', 'Risa', 'Mcmillan', 'arcu.', '461-8386 Et, Ave', 415, 16, null),
       ('nec.tellus@protonmail.ca', 'Griffith', 'Kirkland', 'lorem', '994-2932 Vehicula. Road', 416, 2, null),
       ('cras@aol.ca', 'Sacha', 'Levy', 'posuere,', '357-9024 Ultrices. Road', 417, 13, null),
       ('massa.quisque@outlook.com', 'Honorato', 'Perez', 'Donec', 'Ap #170-6365 Massa Street', 418, 16, 5),
       ('est.nunc.ullamcorper@google.couk', 'Lamar', 'Burks', 'congue', '690-8424 In St.', 419, 17, null),
       ('nec@yahoo.net', 'Olivia', 'Black', 'ut', '342-1473 Non, Avenue', 420, 16, null),
       ('etiam@hotmail.edu', 'Garrett', 'Jones', 'nibh.', '3684 Pellentesque Av.', 421, 2, null),
       ('nam.ligula@aol.edu', 'Jolene', 'Morin', 'Nunc', '768-8189 Nec St.', 422, 11, null),
       ('egestas.urna@aol.com', 'Salvador', 'Daniels', 'vulputate', '985-7957 Maecenas Street', 423, 12, null),
       ('enim.non@hotmail.org', 'Lael', 'Kline', 'euismod', '968-6781 Ullamcorper, Rd.', 424, 13, null),
       ('nisi@hotmail.ca', 'Ora', 'Beck', 'pretium', '125-8747 Maecenas Ave', 425, 10, null),
       ('ligula.tortor.dictum@icloud.com', 'Calvin', 'Rosales', 'risus', 'P.O. Box 532, 7357 Integer Street', 426, 8,
        4),
       ('tellus.non@aol.net', 'Brendan', 'Herring', 'Nullam', '471-5508 Fringilla Rd.', 427, 11, null),
       ('donec.tempor@aol.couk', 'Athena', 'Schneider', 'elementum,', 'P.O. Box 881, 6967 Fermentum Street', 428, 4,
        null),
       ('ut.sagittis@yahoo.com', 'Berk', 'Sweet', 'dui,', '635-4106 Proin St.', 429, 12, null),
       ('et.malesuada@outlook.org', 'May', 'Pacheco', 'interdum', 'Ap #530-1783 Amet Ave', 430, 4, null),
       ('tortor.dictum@outlook.couk', 'Hollee', 'Contreras', 'dictum', 'P.O. Box 314, 7278 Hendrerit Ave', 431, 11,
        null),
       ('enim.etiam.gravida@icloud.net', 'Idona', 'Strong', 'vulputate', '544-8117 Magna. St.', 432, 7, null),
       ('lorem.luctus.ut@icloud.ca', 'Kato', 'Pugh', 'a', 'Ap #271-9592 Orci Ave', 433, 6, null),
       ('nec.leo@aol.net', 'Zelenia', 'Myers', 'ut', 'Ap #944-2440 Volutpat Rd.', 434, 5, null),
       ('et.malesuada@hotmail.com', 'MacKenzie', 'Griffin', 'natoque', '3075 Quisque Street', 435, 3, null),
       ('mi@protonmail.couk', 'Chandler', 'Guzman', 'eu', 'Ap #475-7367 Mattis Road', 436, 3, 1),
       ('phasellus.dolor.elit@google.edu', 'Bethany', 'Lawrence', 'sem.', 'P.O. Box 844, 374 Vitae, Rd.', 437, 11,
        null),
       ('varius@protonmail.net', 'Carson', 'Cruz', 'eu', 'Ap #778-4550 Suspendisse Avenue', 438, 5, null),
       ('sagittis.duis@hotmail.couk', 'Lunea', 'Montgomery', 'ante', '398-2621 Donec St.', 439, 2, null),
       ('proin@yahoo.edu', 'Wanda', 'Snyder', 'In', '643-3584 Suspendisse Av.', 440, 10, null),
       ('orci.phasellus@aol.edu', 'Rhona', 'Byers', 'venenatis', '508-2141 Tellus Avenue', 441, 3, null),
       ('sociis.natoque@aol.org', 'Zenaida', 'Baird', 'vel', 'Ap #948-6574 Sit Av.', 442, 5, null),
       ('convallis.est@protonmail.org', 'Micah', 'Weber', 'ipsum.', '993-367 Nunc Av.', 443, 7, null),
       ('eget.venenatis@protonmail.com', 'Dorothy', 'Workman', 'auctor', 'Ap #951-9254 Nulla St.', 444, 4, null),
       ('malesuada@outlook.edu', 'Reagan', 'Berg', 'sed', 'P.O. Box 674, 1120 Eget Rd.', 445, 2, null),
       ('aliquam.fringilla@aol.edu', 'Cora', 'Bartlett', 'consequat', 'Ap #782-7709 Eu Street', 447, 7, null),
       ('vitae.nibh.donec@protonmail.com', 'Beverly', 'Bowers', 'risus', '3728 Pede. St.', 448, 16, 1),
       ('id.magna@aol.net', 'Macey', 'Miranda', 'eu', '8999 Magna Av.', 450, 9, 4),
       ('erat.neque@hotmail.edu', 'Mufutau', 'Farmer', 'porttitor', 'P.O. Box 545, 1798 Velit Rd.', 451, 12, null),
       ('metus.in@hotmail.org', 'Upton', 'Barlow', 'libero', '998-5615 Id Rd.', 452, 7, 4),
       ('cubilia.curae@google.com', 'Vladimir', 'Donovan', 'mauris', 'P.O. Box 147, 4473 Et Rd.', 453, 16, null),
       ('vitae.aliquet@protonmail.org', 'Kasimir', 'Vega', 'pretium', '667-971 Mauris Road', 454, 10, null),
       ('mollis.dui.in@icloud.edu', 'Alyssa', 'Buck', 'in', 'Ap #655-1570 Mi. Street', 455, 15, null),
       ('ac@hotmail.org', 'Perry', 'Nichols', 'eleifend', '805-9797 Vel St.', 456, 3, null),
       ('magna@google.net', 'Ashton', 'Mccarty', 'arcu.', 'Ap #699-1765 Massa St.', 457, 3, null),
       ('sit.amet@hotmail.ca', 'Ezra', 'Cooley', 'est', 'Ap #591-1452 Placerat. Road', 458, 13, null),
       ('quis@hotmail.net', 'Brenna', 'Mckay', 'non,', 'Ap #660-7064 Lacinia Street', 459, 11, 5),
       ('libero.integer.in@protonmail.org', 'Bell', 'Hull', 'blandit', 'Ap #445-8909 Faucibus Av.', 460, 12, null),
       ('proin.vel.nisl@icloud.org', 'Quinlan', 'Todd', 'conubia', '683-672 Phasellus Rd.', 461, 6, null),
       ('commodo.ipsum@protonmail.couk', 'Merrill', 'Berger', 'Duis', 'Ap #769-2832 Sit Avenue', 462, 5, null),
       ('gravida.non.sollicitudin@aol.org', 'Yeo', 'Velez', 'Mauris', '951-1137 Interdum St.', 463, 4, null),
       ('donec.at@outlook.ca', 'Brianna', 'Lambert', 'vestibulum.', 'Ap #224-7003 Facilisis. Rd.', 464, 8, null),
       ('mauris.eu.elit@protonmail.org', 'Kathleen', 'Miller', 'accumsan', 'Ap #944-9582 Quam, St.', 465, 3, null),
       ('integer.sem@google.com', 'Lucius', 'Lambert', 'netus', 'Ap #544-282 Mauris Av.', 466, 2, null),
       ('tincidunt.aliquam.arcu@outlook.edu', 'Cade', 'Flowers', 'nec', '752-3331 Ante St.', 467, 12, null),
       ('maecenas.mi.felis@google.org', 'Amethyst', 'Blair', 'quis', '427-8619 Eleifend Road', 468, 2, 6),
       ('mollis@protonmail.org', 'Sierra', 'Craft', 'magna', 'Ap #661-3711 Arcu Avenue', 469, 4, null),
       ('a.magna.lorem@hotmail.org', 'Macy', 'Vance', 'convallis', '468-5529 Enim, Av.', 470, 12, 6),
       ('tempus.risus.donec@outlook.couk', 'Alan', 'Rosales', 'est.', '616-4239 Blandit Road', 471, 16, 3),
       ('auctor.mauris.vel@google.edu', 'Mannix', 'Richmond', 'libero.', 'P.O. Box 696, 6805 Egestas. Av.', 472, 7,
        null),
       ('turpis@outlook.couk', 'Rhonda', 'Good', 'nec', 'P.O. Box 706, 8945 Natoque Road', 473, 15, null),
       ('ornare.fusce@icloud.net', 'Maia', 'Travis', 'blandit', '7037 Leo St.', 474, 10, null),
       ('at.iaculis.quis@protonmail.org', 'Byron', 'Jefferson', 'penatibus', '245-3815 In, Rd.', 475, 12, null),
       ('egestas@outlook.org', 'Boris', 'Watts', 'vehicula.', '457-1055 Ridiculus Avenue', 476, 12, null),
       ('curabitur.vel@icloud.net', 'Ria', 'Nunez', 'urna.', 'P.O. Box 664, 3957 Volutpat. Av.', 477, 14, 4),
       ('luctus.ut.pellentesque@yahoo.ca', 'Rahim', 'Higgins', 'magna.', '3494 Urna Road', 478, 3, null),
       ('interdum.ligula@icloud.org', 'Maggy', 'Hansen', 'Maecenas', '143-516 Libero Ave', 479, 16, null),
       ('in.hendrerit.consectetuer@icloud.ca', 'Gray', 'Waller', 'ac', 'Ap #179-5988 Risus. Avenue', 480, 4, null),
       ('aenean.eget@protonmail.couk', 'Holmes', 'Yang', 'ultricies', 'Ap #440-6137 Lacinia Avenue', 481, 9, null),
       ('velit.eu@protonmail.org', 'Wang', 'Holmes', 'lobortis', '4011 Pede Avenue', 482, 11, null),
       ('non.luctus.sit@protonmail.com', 'Tanya', 'Porter', 'primis', '936-6400 Aliquam Road', 483, 3, null),
       ('eros.proin@outlook.net', 'Dorothy', 'Chase', 'penatibus', 'Ap #176-4809 In Ave', 484, 1, null),
       ('porta.elit.a@protonmail.com', 'September', 'Wolf', 'egestas', '1369 Dolor Road', 485, 15, null),
       ('ut.molestie@icloud.com', 'Rama', 'Massey', 'est.', 'P.O. Box 864, 2918 Leo, Rd.', 486, 10, null),
       ('aenean.eget@yahoo.net', 'Dahlia', 'Myers', 'velit.', 'Ap #276-4494 Augue Rd.', 487, 1, null),
       ('ut@yahoo.ca', 'Eric', 'Mcbride', 'sem', 'Ap #747-7823 Sodales Road', 488, 5, null),
       ('fusce@google.net', 'Orson', 'Swanson', 'In', 'P.O. Box 951, 8380 Fusce Rd.', 489, 11, null),
       ('massa.vestibulum@outlook.edu', 'Octavia', 'Buckner', 'Morbi', '142-7843 Nulla Ave', 490, 12, 4),
       ('varius.nam@hotmail.org', 'Flavia', 'Merritt', 'massa.', 'Ap #983-2690 Rutrum Road', 491, 9, null),
       ('aliquet.phasellus@outlook.org', 'Fletcher', 'West', 'Integer', '488-250 Quisque Av.', 492, 1, null),
       ('enim@outlook.edu', 'Yoshio', 'Richardson', 'dui,', 'P.O. Box 215, 2112 Vestibulum. St.', 493, 8, null),
       ('eget.tincidunt@google.couk', 'Felicia', 'Knight', 'In', '1734 Aliquam Ave', 494, 11, null),
       ('pede@aol.org', 'Bo', 'Kramer', 'sociis', '127-1883 Accumsan Ave', 495, 2, null),
       ('mattis.velit.justo@protonmail.org', 'Christopher', 'Lawson', 'Cras', '114-9912 Nullam St.', 496, 15, 2),
       ('volutpat.nulla.dignissim@aol.org', 'Brett', 'Howard', 'elit,', '741-5454 Arcu Street', 497, 10, null),
       ('massa.rutrum@icloud.ca', 'Graham', 'Talley', 'nonummy', 'P.O. Box 851, 5237 Lectus Street', 498, 2, null),
       ('egestas.lacinia@icloud.net', 'Farrah', 'Guerrero', 'Suspendisse', '2026 Mauris Street', 499, 10, null),
       ('lorem@yahoo.edu', 'Vivien', 'Cameron', 'orci', '119-6586 Laoreet St.', 500, 12, null);


insert into user_x_role (user_id, role_id)
    (select 1 as user_id, 1 as role_id
     union all
     select "user".id as user_id, (floor(random() * ((select max(id) from role) - 2 + 1)) + 2)::int as role_id
     from "user"
     where "user".id != 1
       and "user".locale_id is not null
     union all
     select "user".id as user_id, 2 as role_id
     from "user"
     where "user".id != 1
       and "user".locale_id is null) order by user_id;

insert into location (point)
select point(41.030301 - (random() * 2 - 1), 21.332250 - (random() * 2 - 1))
from generate_series(1, 5000);

insert into "order" (created, status, paid, user_id, location_id)
with generated_status as (select unnest(enum_range(null::order_status)) as status
                          from generate_series(1, 5000)
                          order by random())
select now() + trunc((random() * 1000000) - 1000000) * '1 minute'::interval as created,
       generated_status.status                                              as status,
       random()::int::boolean                                               as paid,
       round(random() * (497 - 1) + 1)                                      as user_id,
       round(random() * (5000 - 1) + 10)                                    as location_id
from generate_series(1, 100), generated_status;


insert into menu_item_x_order (menu_item_id, order_id, quantity)
with menu_items as (select distinct round(random() * (10 - 1) + 1) as menu_item_id
                    from generate_series(1, 10))
select mi.menu_item_id                as menu_item_id,
       sr                             as order_id,
       round(random() * (10 - 1) + 1) as quantity
from generate_series(1, 2500000) as sr,
     menu_items as mi;

insert into menu_item_x_basket (menu_item_id, basket_id, count)
with menu_items as (select distinct round(random() * (10 - 1) + 1) as menu_item_id
                    from generate_series(1, 10))
select mi.menu_item_id                as menu_item_id,
       (sr % 500) + 1                 as order_id,
       round(random() * (10 - 1) + 1) as quantity
from generate_series(1, 250000) as sr,
     menu_items as mi;

insert into order_x_locale (order_id, locale_id)
select sr as order_id, round(random() * (6 - 1) + 1)
from generate_series(1, 2500000) as sr;

------------------ Views & Functions ------------------

---------------- views ----------------

create or replace view user_basket as
select u.id         as user_id,
       b.id         as basket_id,
       b.status     as basket_status,
       mixb.count   as count,
       mi.id        as menu_item_id,
       mi.cost      as menu_item_cost,
       mi.name      as menu_item_name,
       mi.cook_time as menu_item_cook_time
from "user" as u
         inner join basket b on b.id = u.basket_id
         full join menu_item_x_basket mixb on b.id = mixb.basket_id
         full join menu_item mi on mixb.menu_item_id = mi.id;

create or replace view orders as
select o.id      as id,
       o.created as created,
       o.status  as status,
       o.paid    as paid,
       o.user_id as user_id,
       l.id      as locale_id,
       l.address as locale_address,
       l2.point  as location_point
from "order" as o
         join order_x_locale oxl on o.id = oxl.order_id
         join locale l on oxl.locale_id = l.id
         join location l2 on o.location_id = l2.id;

create or replace view order_with_items as
select o.id         as id,
       o.created    as created,
       mi.name      as menu_item_name,
       mi.cost      as menu_item_cost,
       mi.cook_time as menu_item_cook_time,
       mi.id        as menu_item_id
from "order" as o
         join menu_item_x_order mixo on o.id = mixo.order_id
         join menu_item mi on mixo.menu_item_id = mi.id;

create or replace view locale_order as
select o.id          as id,
       o.status      as status,
       o.created     as created,
       o.paid        as paid,
       o.location_id as location_id,
       l.id          as locale_id,
       l.address     as address,
       l.city_id     as city_id,
       c.name        as city_name
from order_x_locale as ol
         join "order" o on o.id = ol.order_id
         join locale l on l.id = ol.locale_id
         join city c on l.city_id = c.id;

create or replace view cities as
select *
from city;

create materialized view if not exists menu as
select *
from menu_item;


---------------- procedures ----------------

create or replace function create_or_update_menu()
    returns trigger
    language plpgsql
as
$$
begin
    drop materialized view if exists menu;
    create materialized view if not exists menu as
    select *
    from menu_item;
end;
$$;

create or replace procedure insert_in_basket(mid integer, uid integer, qty integer)
    language plpgsql
as
$$
declare
    user_basket_id record;
begin
    if mid is null or uid is null or qty <= 0 then
        return;
    end if;

    if mid not in (select id from menu_item) then
        return;
    end if;

    select basket_id
    into user_basket_id
    from user_basket_by_id(uid)
    limit 1;

    if mid in (select menu_item_id from user_basket_by_id(uid)) then
        update menu_item_x_basket
        set count = count + qty
        where menu_item_id = mid
          and basket_id = user_basket_id.basket_id;
    else
        insert into menu_item_x_basket (menu_item_id, basket_id, count)
        values (mid, user_basket_id.basket_id, qty);
    end if;
end;
$$;


create or replace procedure create_order(uid integer, lon double precision, lat double precision)
    language plpgsql
as
$$
declare
    user_basket_id     integer;
    user_basket_status basket_status;
begin
    if uid is null then
        return;
    end if;

    if not exists(select * from menu_item_x_basket where basket_id = user_basket_id) then
        return;
    end if;

    select basket_id, basket_status
    into user_basket_id, user_basket_status
    from user_basket_by_id(uid)
    limit 1;

    insert into location (point)
    values (point(lon, lat));

    insert into "order" (created, status, paid, user_id, location_id)
    values (now(), 'pending', user_basket_status = 'paid', uid, currval('location_id_seq'));

    insert into menu_item_x_order (menu_item_id, order_id, quantity)
    select menu_item_id, currval('order_id_seq'), count
    from menu_item_x_basket
    where basket_id = user_basket_id;

    delete from menu_item_x_basket where basket_id = user_basket_id;

    update basket
    set status = 'clean'
    where id = user_basket_id;
end;
$$;

create or replace procedure complete_order(o_id integer, o_status order_status)
    language plpgsql
as
$$
begin
    if o_id is null or o_status is null then
        return;
    end if;

    update "order"
    set status = o_status,
        paid   = true
    where id = o_id;
end;
$$;

---------------- functions ----------------

create or replace function search_menu(m_id integer = null, m_name varchar(32) = null, m_cook_time integer = null,
                                       m_cost integer = null)
    returns setof menu
    language plpgsql
as
$$
begin
    return query
        select *
        from menu
        where (m_id is null or id = m_id)
          and (m_name is null or name ilike concat('%', m_name, '%'))
          and (m_cook_time is null or cook_time = m_cook_time)
          and (m_cost is null or cost = m_cost);
end
$$;

create or replace function menu_item_by_id(m_id integer = null)
    returns table
            (
                id              integer,
                name            varchar(32),
                cook_time       integer,
                cost            integer,
                ingredient_id   integer,
                ingredient_name varchar(32)
            )
    language plpgsql
as
$$
begin
    return query
        select mi.id        as id,
               mi.name      as name,
               mi.cook_time as cook_time,
               mi.cost      as cost,
               i.id         as ingredient_id,
               i.name       as ingredient_name
        from ingredient_x_menu_item as imi
                 join menu_item mi on imi.menu_item_id = mi.id
                 join ingredient i on i.id = imi.ingredient_id
        where (m_id is null or mi.id = m_id);
end;
$$;

create or replace function user_basket_by_id(id integer)
    returns setof user_basket
    language plpgsql
as
$$
begin
    return query
        select *
        from user_basket as ub
        where ub.user_id = id;
end
$$;

create or replace function search_orders(
    u_id integer = null,
    o_id integer = null,
    o_status order_status = null,
    o_locale integer = null,
    page integer = null,
    size integer = null
)
    returns setof orders
    language plpgsql
as
$$
begin
    if page is not null and size is not null then
        return query
            select *
            from orders as uo
            where (u_id is null or uo.user_id = u_id)
              and (o_status is null or o_status = uo.status)
              and (o_locale is null or o_locale = uo.locale_id)
              and (o_id is null or o_id = uo.id)
            offset (page - 1) * size limit size;
    else
        return query
            select *
            from orders as uo
            where (u_id is null or uo.user_id = u_id)
              and (o_status is null or o_status = uo.status);
    end if;
end
$$;

create or replace function order_items_by_id(oid integer = null)
    returns setof order_with_items
    language plpgsql
as
$$
begin
    return query
        select *
        from order_with_items as oi
        where (oid is null or oi.id = oid);
end
$$;

create or replace function locale_orders_by_id(lid integer = null)
    returns setof locale_order
    language plpgsql
as
$$
begin
    return query
        select *
        from locale_order as lo
        where (lid is null or lo.locale_id = lid);
end
$$;

---------------- triggers ----------------
drop trigger if exists update_menu_view on menu_item;
create trigger update_menu_view
    after update
    on menu_item
execute procedure create_or_update_menu();

drop trigger if exists update_menu_view_ingredient on ingredient_x_menu_item;
create trigger update_menu_view_ingredient
    after update
    on ingredient_x_menu_item
execute procedure create_or_update_menu();


---------------- analytical data ----------------
create or replace function orders_per_user(top_n integer)
    returns table
            (
                user_id integer,
                payed   bigint,
                orders  bigint
            )
    language plpgsql
as
$$
begin
    return query
        select o.user_id as user_id, sum(mi.cost) as payed, count(*) orders
        from "order" as o
                 join menu_item_x_order mixo on o.id = mixo.order_id
                 join menu_item mi on mixo.menu_item_id = mi.id
        group by o.user_id
        order by payed desc
        limit top_n;
end;
$$;

create or replace function orders_per_year(until interval, page integer = null, size integer = 50)
    returns table
            (
                year   double precision,
                orders bigint,
                profit bigint
            )
    language plpgsql
as
$$
begin

    if page is null then
        return query
            select date_part('year', o.created) as year,
                   count(*)                     as orders,
                   sum(mi.cost)                 as profit
            from "order" as o
                     join menu_item_x_order mixo on o.id = mixo.order_id
                     join menu_item mi on mixo.menu_item_id = mi.id
            where o.created > now() - until
            group by year
            order by year;
    end if;

    return query
        select date_part('year', o.created) as year,
               count(*)                     as orders,
               sum(mi.cost)                 as profit
        from "order" as o
                 join menu_item_x_order mixo on o.id = mixo.order_id
                 join menu_item mi on mixo.menu_item_id = mi.id
        where o.created > now() - until
        group by year
        order by year
        offset (page - 1) * size limit size;
end;
$$;


create or replace function orders_per_month(until interval, page integer = null, size integer = 50)
    returns table
            (
                month  double precision,
                year   double precision,
                orders bigint,
                profit bigint
            )
    language plpgsql
as
$$
begin

    if page is null then
        return query
            select date_part('month', o.created) as month,
                   date_part('year', o.created)  as year,
                   count(*)                      as orders,
                   sum(mi.cost)                  as profit
            from "order" as o
                     join menu_item_x_order mixo on o.id = mixo.order_id
                     join menu_item mi on mixo.menu_item_id = mi.id
            where o.created > now() - until
            group by month, year
            order by year, month;
    end if;

    return query
        select date_part('month', o.created) as month,
               date_part('year', o.created)  as year,
               count(*)                      as orders,
               sum(mi.cost)                  as profit
        from "order" as o
                 join menu_item_x_order mixo on o.id = mixo.order_id
                 join menu_item mi on mixo.menu_item_id = mi.id
        where o.created > now() - until
        group by month, year
        order by year, month
        offset (page - 1) * size limit size;
end;
$$;



create or replace function menu_item_popularity()
    returns table
            (
                id        integer,
                name      varchar(52),
                cost      integer,
                cook_time integer,
                orders    bigint
            )
    language plpgsql
as
$$
begin
    return query
        select mi.id as id, mi.name as name, mi.cost as cost, mi.cook_time as cook_time, count(mi.id) as orders
        from menu_item as mi
                 join menu_item_x_order mixo on mi.id = mixo.menu_item_id
        group by mi.id
        order by orders desc;
end;
$$;