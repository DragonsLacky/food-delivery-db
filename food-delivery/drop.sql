-- procedures
drop procedure if exists insert_in_basket(mid integer);
drop procedure if exists complete_order(o_id integer, o_status order_status);
drop procedure if exists create_order(uid integer, lon double precision, lat double precision);
drop function if exists orders_per_month(until interval, page integer, size integer);

-- triggers
drop trigger if exists update_menu_view on menu_item;
drop trigger if exists update_menu_view_ingredient on ingredient_x_menu_item;

-- functions
drop function if exists create_or_update_menu();
drop function if exists orders_per_year(until interval, page integer, size integer);
drop function if exists orders_per_user(top_n integer);
drop function if exists menu_item_popularity();
drop function if exists search_menu(m_id integer, m_name varchar, m_cook_time integer, m_cost integer);
drop function if exists menu_item_by_id(mid integer);
drop function if exists user_basket_by_id(id integer);
drop function if exists search_orders(u_id integer, o_id integer, o_status order_status, o_locale integer, page integer, size integer);
drop function if exists user_orders_by_id(uid integer, page integer, size integer, os order_status);
drop function if exists order_items_by_id(oid integer);
drop function if exists locale_orders_by_id(lid integer);


-- drop view
drop view if exists user_basket;
drop view if exists user_order;
drop view if exists order_with_items;
drop view if exists locale_order;
drop view if exists cities;
drop view if exists orders;
drop materialized view if exists menu;

-- tables
drop table if exists ingredient_x_menu_item;
drop table if exists ingredient;
drop table if exists menu_item_x_basket;
drop table if exists menu_item_x_order;
drop table if exists menu_item;
drop table if exists order_x_locale;
drop table if exists "order";
drop table if exists user_x_role;
drop table if exists "user";
drop table if exists basket;
drop table if exists locale;
drop table if exists city;
drop table if exists location;
drop table if exists role;

-- enums
drop type if exists basket_status;
drop type if exists order_status;