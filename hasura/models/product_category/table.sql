/* TABLE */

CREATE TABLE product_category (
    product_id int NOT NULL,
    category_id int NOT NULL
);

/* FOREIGN KEYS */

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_product_id_fkey
    FOREIGN KEY (product_id) REFERENCES public.product (id);

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_category_id_fkey
    FOREIGN KEY (category_id) REFERENCES public.category (id);

/* TRIGGERS */
