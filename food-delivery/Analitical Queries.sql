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
