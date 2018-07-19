#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE TABLE users (
    id bigserial NOT NULL primary key,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    date_of_birth timestamp with time zone NOT NULL
);

INSERT INTO users (first_name, last_name, date_of_birth) VALUES
('Janice', 'Hansen', '1990-12-01'),
('Monica', 'Douglas', '1959-04-23'),
('Tyrone', 'Andrews', '1977-01-18');

CREATE TABLE delivery_methods (
    id bigserial NOT NULL PRIMARY KEY,
    name character varying(255) NOT NULL,
    cost numeric NOT NULL
);

INSERT INTO delivery_methods (name, cost) VALUES
('odbior osobisty', 0),
('poczta polska', 5.99),
('kurier', '20');

CREATE TYPE order_status AS ENUM ('NEW', 'PROCESSING', 'DISPATCHED');
CREATE TABLE orders (
    id bigserial NOT NULL PRIMARY KEY,
    user_id bigint REFERENCES users (id) NOT NULL,
    created_on timestamp with time zone NOT NULL,
    subtotal_items numeric NOT NULL,
    delivery_method_id bigint REFERENCES delivery_methods (id) NOT NULL,
    status order_status NOT NULL DEFAULT 'NEW'
);


CREATE TABLE items (
    id bigserial NOT NULL PRIMARY KEY,
    name character varying(255) NOT NULL,
    price numeric NOT NULL
);

INSERT INTO items (name, price) VALUES
('task', '2.1'),
('difference', '4.2'),
('wall', '3.2'),
('force', '2.8'),
('black', '8.5'),
('tough', '7.6'),
('door', '8.6'),
('rock', '5.2'),
('tree', '3.0'),
('issue', '0.8'),
('who', '6.4'),
('television', '0.5'),
('treat', '0.3'),
('view', '5.6'),
('whose', '9.9'),
('relationship', '4.6'),
('fight', '1.6'),
('even', '0.9'),
('action', '8.5'),
('tell', '5.8'),
('simply', '1.6'),
('interview', '0.8'),
('gun', '3.7'),
('impact', '7.5'),
('human', '1.5'),
('own', '9.7'),
('design', '4.9'),
('there', '7.9'),
('one', '7.4'),
('PM', '2.3'),
('this', '8.5'),
('support', '8.8'),
('through', '7.0'),
('people', '5.6'),
('yourself', '3.6'),
('race', '4.1'),
('like', '8.5'),
('little', '7.0'),
('event', '8.3'),
('follow', '5.2'),
('choose', '3.4'),
('well', '3.6'),
('world', '1.4'),
('eight', '9.0'),
('positive', '2.7'),
('activity', '8.5'),
('top', '5.1'),
('president', '6.3'),
('throughout', '3.0'),
('carry', '9.3'),
('surface', '9.1'),
('stand', '7.8'),
('ground', '4.0'),
('true', '1.9'),
('big', '7.7'),
('bad', '3.4'),
('question', '1.5'),
('several', '0.7'),
('hear', '7.0'),
('affect', '4.8'),
('us', '9.2'),
('ground', '6.9'),
('buy', '1.9'),
('require', '1.2'),
('near', '2.5'),
('bag', '0.7'),
('full', '1.5'),
('nation', '5.6'),
('item', '1.0'),
('hope', '4.5'),
('attention', '4.0'),
('federal', '6.0'),
('serious', '9.1'),
('Mrs', '2.4'),
('throughout', '4.3'),
('size', '4.4'),
('someone', '4.6'),
('power', '5.9'),
('number', '5.9'),
('better', '5.9'),
('part', '1.2'),
('first', '7.7'),
('term', '3.3'),
('big', '8.7'),
('gas', '6.9'),
('our', '9.9'),
('own', '5.4'),
('option', '2.1'),
('one', '4.9'),
('ball', '4.7'),
('view', '2.0'),
('manage', '4.8'),
('change', '0.9'),
('raise', '3.9'),
('lot', '4.2'),
('notice', '4.5'),
('in', '4.2'),
('see', '0.7'),
('spring', '2.2'),
('resource', '9.6');

CREATE TABLE orders_items (
    id bigserial NOT NULL PRIMARY KEY,
    item_id bigint REFERENCES items (id) NOT NULL,
    order_id bigint REFERENCES orders (id) NOT NULL,
	amount integer NOT NULL
);

CREATE FUNCTION fill_orders() RETURNS void AS \$\$
BEGIN
    FOR i IN 1..5000 LOOP
        INSERT INTO orders (user_id, created_on, subtotal_items, delivery_method_id, status) VALUES
        (
        	(SELECT id FROM users ORDER BY random() LIMIT 1),
        	NOW() - CASE WHEN random() > 0.5 THEN interval '1 year' ELSE interval '0 days' END,
        	0,
        	(SELECT id FROM delivery_methods ORDER BY random() LIMIT 1),
        	(SELECT CASE WHEN random() < 0.1 THEN 'NEW' WHEN random() < 0.2 THEN 'PROCESSING' ELSE 'DISPATCHED' END)::order_status
    	);
    END LOOP;

    FOR i IN 1..50000 LOOP
        INSERT INTO orders_items (item_id, order_id, amount) VALUES
        ((SELECT id FROM items ORDER BY random() LIMIT 1), (SELECT id FROM orders ORDER BY random() LIMIT 1), (SELECT trunc(random() * 9 + 1)));
    END LOOP;
END;
\$\$ LANGUAGE plpgsql;

SELECT fill_orders();

UPDATE orders AS o SET subtotal_items = COALESCE((SELECT sum(oi.amount * i.price) FROM orders_items as oi JOIN items AS i ON i.id = oi.item_id AND oi.order_id = o.id), 0);

EOSQL
