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

