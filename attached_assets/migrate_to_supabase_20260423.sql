--
-- PostgreSQL database dump
--

\restrict krbRTqvbrDP7flK1ohu5eC2KrB1UTSefIIjbguM9Mg0cbnNiFw8NKSsXesF4oDN

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
    id integer NOT NULL,
    nom_prenom text NOT NULL,
    numero_telephone text DEFAULT ''::text NOT NULL,
    numero_telephone_2 text DEFAULT ''::text,
    email text DEFAULT ''::text,
    fax text DEFAULT ''::text,
    nom_sub_client text DEFAULT ''::text,
    adresse text DEFAULT ''::text,
    cin text DEFAULT ''::text,
    type_company text DEFAULT ''::text,
    code_postal text DEFAULT ''::text,
    unique_number text DEFAULT ''::text,
    categorie text DEFAULT ''::text,
    famille text DEFAULT ''::text,
    civilite text DEFAULT ''::text,
    mode_reglement text DEFAULT ''::text,
    banque text DEFAULT ''::text,
    remarque text DEFAULT ''::text NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clients_id_seq OWNED BY public.clients.id;


--
-- Name: deferred_sales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deferred_sales (
    id integer NOT NULL,
    date text NOT NULL,
    nom_prenom text NOT NULL,
    numero_telephone text DEFAULT ''::text NOT NULL,
    type_moto text DEFAULT ''::text NOT NULL,
    designation text NOT NULL,
    quantite integer DEFAULT 1 NOT NULL,
    montant double precision DEFAULT 0 NOT NULL,
    is_settled boolean DEFAULT false NOT NULL,
    confirmed_by_staff text,
    confirmed_by_manager text,
    calculation_timestamp bigint,
    amount_handed double precision DEFAULT 0,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: deferred_sales_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deferred_sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deferred_sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deferred_sales_id_seq OWNED BY public.deferred_sales.id;


--
-- Name: divers_purchases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.divers_purchases (
    id integer NOT NULL,
    date text NOT NULL,
    designation text NOT NULL,
    quantite integer DEFAULT 0 NOT NULL,
    fournisseur text DEFAULT ''::text NOT NULL,
    prix double precision DEFAULT 0 NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: divers_purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.divers_purchases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: divers_purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.divers_purchases_id_seq OWNED BY public.divers_purchases.id;


--
-- Name: facture_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.facture_lines (
    id integer NOT NULL,
    facture_id integer,
    facture_number text NOT NULL,
    bon_ref text DEFAULT ''::text NOT NULL,
    date text NOT NULL,
    commercial text DEFAULT ''::text NOT NULL,
    client text DEFAULT ''::text NOT NULL,
    id_client text DEFAULT ''::text NOT NULL,
    matricule_fiscal text DEFAULT ''::text NOT NULL,
    adresse_client text DEFAULT ''::text NOT NULL,
    phone_client text DEFAULT ''::text NOT NULL,
    ref text DEFAULT ''::text NOT NULL,
    designation text DEFAULT ''::text NOT NULL,
    qte double precision DEFAULT 1 NOT NULL,
    prix double precision DEFAULT 0 NOT NULL,
    tva text DEFAULT '19%'::text NOT NULL,
    remise double precision DEFAULT 0 NOT NULL,
    prix_ttc double precision DEFAULT 0 NOT NULL,
    montant_ht double precision DEFAULT 0 NOT NULL,
    montant_tva double precision DEFAULT 0 NOT NULL,
    montant_ttc double precision DEFAULT 0 NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: facture_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.facture_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facture_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.facture_lines_id_seq OWNED BY public.facture_lines.id;


--
-- Name: factures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.factures (
    id integer NOT NULL,
    facture_number text NOT NULL,
    bon_ref text DEFAULT ''::text NOT NULL,
    date text NOT NULL,
    commercial text DEFAULT ''::text NOT NULL,
    client_id integer,
    client_name text DEFAULT ''::text NOT NULL,
    id_client text DEFAULT ''::text NOT NULL,
    matricule_fiscal text DEFAULT ''::text NOT NULL,
    adresse_client text DEFAULT ''::text NOT NULL,
    phone_client text DEFAULT ''::text NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: factures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.factures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: factures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.factures_id_seq OWNED BY public.factures.id;


--
-- Name: helmet_purchases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.helmet_purchases (
    id integer NOT NULL,
    date text NOT NULL,
    designation text NOT NULL,
    quantite integer DEFAULT 0 NOT NULL,
    fournisseur text DEFAULT ''::text NOT NULL,
    prix double precision DEFAULT 0 NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: helmet_purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.helmet_purchases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: helmet_purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.helmet_purchases_id_seq OWNED BY public.helmet_purchases.id;


--
-- Name: helmet_sales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.helmet_sales (
    id integer NOT NULL,
    numero_facture text DEFAULT ''::text NOT NULL,
    date text NOT NULL,
    designation text NOT NULL,
    type_client text NOT NULL,
    nom_prenom text NOT NULL,
    quantite integer DEFAULT 1 NOT NULL,
    montant double precision DEFAULT 0 NOT NULL,
    remarque text DEFAULT ''::text NOT NULL,
    confirmed_by_staff text,
    confirmed_by_manager text,
    calculation_timestamp bigint,
    amount_handed double precision DEFAULT 0,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: helmet_sales_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.helmet_sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: helmet_sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.helmet_sales_id_seq OWNED BY public.helmet_sales.id;


--
-- Name: livraison_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.livraison_lines (
    id integer NOT NULL,
    livraison_id integer NOT NULL,
    product_serial_id integer,
    product_id integer,
    ref text DEFAULT ''::text NOT NULL,
    designation text DEFAULT ''::text NOT NULL,
    serial_number text DEFAULT ''::text NOT NULL,
    prix double precision DEFAULT 0 NOT NULL,
    tva_pct double precision DEFAULT 19 NOT NULL,
    remise double precision DEFAULT 0 NOT NULL,
    prix_ttc double precision DEFAULT 0 NOT NULL,
    montant_ht double precision DEFAULT 0 NOT NULL,
    montant_tva double precision DEFAULT 0 NOT NULL,
    montant_ttc double precision DEFAULT 0 NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: livraison_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.livraison_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: livraison_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.livraison_lines_id_seq OWNED BY public.livraison_lines.id;


--
-- Name: livraisons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.livraisons (
    id integer NOT NULL,
    bon_number text NOT NULL,
    date text NOT NULL,
    commercial text DEFAULT ''::text NOT NULL,
    client_id integer,
    client_name text DEFAULT ''::text NOT NULL,
    id_client text DEFAULT ''::text NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    facture_number text DEFAULT ''::text NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: livraisons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.livraisons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: livraisons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.livraisons_id_seq OWNED BY public.livraisons.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    action text NOT NULL,
    target text NOT NULL,
    details text,
    "timestamp" bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: oil_purchases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oil_purchases (
    id integer NOT NULL,
    date text NOT NULL,
    huile_10w40 integer DEFAULT 0 NOT NULL,
    huile_20w50 integer DEFAULT 0 NOT NULL,
    gear_oil integer DEFAULT 0,
    brake_oil integer DEFAULT 0,
    fournisseur text DEFAULT ''::text NOT NULL,
    prix double precision DEFAULT 0 NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: oil_purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oil_purchases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oil_purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oil_purchases_id_seq OWNED BY public.oil_purchases.id;


--
-- Name: oil_sales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oil_sales (
    id integer NOT NULL,
    date text NOT NULL,
    huile_10w40 integer DEFAULT 0 NOT NULL,
    huile_20w50 integer DEFAULT 0 NOT NULL,
    gear_oil integer DEFAULT 0,
    brake_oil integer DEFAULT 0,
    prix double precision DEFAULT 0 NOT NULL,
    encaissement text NOT NULL,
    client text DEFAULT ''::text NOT NULL,
    confirmed_by_staff text,
    confirmed_by_manager text,
    calculation_timestamp bigint,
    amount_handed double precision DEFAULT 0,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: oil_sales_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oil_sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oil_sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oil_sales_id_seq OWNED BY public.oil_sales.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    nom_prenom text NOT NULL,
    designation text NOT NULL,
    avance double precision DEFAULT 0 NOT NULL,
    date text NOT NULL,
    numero_telephone text DEFAULT ''::text NOT NULL,
    remarque text DEFAULT ''::text NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: product_families; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_families (
    id integer NOT NULL,
    name text NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: product_families_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_families_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_families_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_families_id_seq OWNED BY public.product_families.id;


--
-- Name: product_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_prices (
    id integer NOT NULL,
    number integer NOT NULL,
    designation text NOT NULL,
    prix_vente_ttc double precision NOT NULL
);


--
-- Name: product_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_prices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_prices_id_seq OWNED BY public.product_prices.id;


--
-- Name: product_serials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_serials (
    id integer NOT NULL,
    product_id integer NOT NULL,
    serial_number text NOT NULL,
    purchase_price double precision DEFAULT 0,
    status text DEFAULT 'available'::text NOT NULL,
    reception_id integer,
    livraison_id integer,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: product_serials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_serials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_serials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_serials_id_seq OWNED BY public.product_serials.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    reference text NOT NULL,
    designation text NOT NULL,
    family_id integer,
    default_price double precision DEFAULT 0,
    tva_pct double precision DEFAULT 19,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: reception_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reception_lines (
    id integer NOT NULL,
    reception_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    prix double precision DEFAULT 0 NOT NULL,
    tva_pct double precision DEFAULT 19 NOT NULL,
    remise double precision DEFAULT 0 NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: reception_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reception_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reception_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reception_lines_id_seq OWNED BY public.reception_lines.id;


--
-- Name: receptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.receptions (
    id integer NOT NULL,
    bon_number text NOT NULL,
    date text NOT NULL,
    fournisseur text DEFAULT ''::text NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: receptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.receptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: receptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.receptions_id_seq OWNED BY public.receptions.id;


--
-- Name: reservations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reservations (
    id integer NOT NULL,
    nom_prenom text NOT NULL,
    designation text NOT NULL,
    avance double precision DEFAULT 0 NOT NULL,
    date text NOT NULL,
    numero text DEFAULT ''::text NOT NULL,
    remarque text DEFAULT ''::text NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: reservations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reservations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reservations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reservations_id_seq OWNED BY public.reservations.id;


--
-- Name: saddle_purchases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saddle_purchases (
    id integer NOT NULL,
    date text NOT NULL,
    taille_xl integer DEFAULT 0 NOT NULL,
    taille_xxl integer DEFAULT 0 NOT NULL,
    fournisseur text DEFAULT ''::text NOT NULL,
    prix double precision DEFAULT 0 NOT NULL,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: saddle_purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.saddle_purchases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saddle_purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.saddle_purchases_id_seq OWNED BY public.saddle_purchases.id;


--
-- Name: saddle_sales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saddle_sales (
    id integer NOT NULL,
    date text NOT NULL,
    taille_xl integer DEFAULT 0 NOT NULL,
    taille_xxl integer DEFAULT 0 NOT NULL,
    prix double precision DEFAULT 0 NOT NULL,
    encaissement text NOT NULL,
    client text DEFAULT ''::text NOT NULL,
    confirmed_by_staff text,
    confirmed_by_manager text,
    calculation_timestamp bigint,
    amount_handed double precision DEFAULT 0,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: saddle_sales_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.saddle_sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saddle_sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.saddle_sales_id_seq OWNED BY public.saddle_sales.id;


--
-- Name: sales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales (
    id integer NOT NULL,
    invoice_number text NOT NULL,
    date text NOT NULL,
    designation text NOT NULL,
    client_type text NOT NULL,
    client_name text NOT NULL,
    convention_name text,
    chassis_number text,
    registration_number text,
    gray_card_status text DEFAULT 'En cours'::text,
    total_to_pay integer DEFAULT 0,
    advance integer DEFAULT 0,
    payments jsonb DEFAULT '{}'::jsonb,
    payment_day integer DEFAULT 1,
    created_at bigint DEFAULT ((EXTRACT(epoch FROM now()))::bigint * 1000)
);


--
-- Name: sales_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sales_id_seq OWNED BY public.sales.id;


--
-- Name: user_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    notification_id integer NOT NULL,
    is_read boolean DEFAULT false,
    dismissed boolean DEFAULT false
);


--
-- Name: user_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_notifications_id_seq OWNED BY public.user_notifications.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    role text NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients ALTER COLUMN id SET DEFAULT nextval('public.clients_id_seq'::regclass);


--
-- Name: deferred_sales id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deferred_sales ALTER COLUMN id SET DEFAULT nextval('public.deferred_sales_id_seq'::regclass);


--
-- Name: divers_purchases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.divers_purchases ALTER COLUMN id SET DEFAULT nextval('public.divers_purchases_id_seq'::regclass);


--
-- Name: facture_lines id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facture_lines ALTER COLUMN id SET DEFAULT nextval('public.facture_lines_id_seq'::regclass);


--
-- Name: factures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factures ALTER COLUMN id SET DEFAULT nextval('public.factures_id_seq'::regclass);


--
-- Name: helmet_purchases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.helmet_purchases ALTER COLUMN id SET DEFAULT nextval('public.helmet_purchases_id_seq'::regclass);


--
-- Name: helmet_sales id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.helmet_sales ALTER COLUMN id SET DEFAULT nextval('public.helmet_sales_id_seq'::regclass);


--
-- Name: livraison_lines id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraison_lines ALTER COLUMN id SET DEFAULT nextval('public.livraison_lines_id_seq'::regclass);


--
-- Name: livraisons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraisons ALTER COLUMN id SET DEFAULT nextval('public.livraisons_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: oil_purchases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oil_purchases ALTER COLUMN id SET DEFAULT nextval('public.oil_purchases_id_seq'::regclass);


--
-- Name: oil_sales id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oil_sales ALTER COLUMN id SET DEFAULT nextval('public.oil_sales_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: product_families id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_families ALTER COLUMN id SET DEFAULT nextval('public.product_families_id_seq'::regclass);


--
-- Name: product_prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_prices ALTER COLUMN id SET DEFAULT nextval('public.product_prices_id_seq'::regclass);


--
-- Name: product_serials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_serials ALTER COLUMN id SET DEFAULT nextval('public.product_serials_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: reception_lines id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reception_lines ALTER COLUMN id SET DEFAULT nextval('public.reception_lines_id_seq'::regclass);


--
-- Name: receptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receptions ALTER COLUMN id SET DEFAULT nextval('public.receptions_id_seq'::regclass);


--
-- Name: reservations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservations ALTER COLUMN id SET DEFAULT nextval('public.reservations_id_seq'::regclass);


--
-- Name: saddle_purchases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saddle_purchases ALTER COLUMN id SET DEFAULT nextval('public.saddle_purchases_id_seq'::regclass);


--
-- Name: saddle_sales id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saddle_sales ALTER COLUMN id SET DEFAULT nextval('public.saddle_sales_id_seq'::regclass);


--
-- Name: sales id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales ALTER COLUMN id SET DEFAULT nextval('public.sales_id_seq'::regclass);


--
-- Name: user_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications ALTER COLUMN id SET DEFAULT nextval('public.user_notifications_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clients (id, nom_prenom, numero_telephone, numero_telephone_2, email, fax, nom_sub_client, adresse, cin, type_company, code_postal, unique_number, categorie, famille, civilite, mode_reglement, banque, remarque, created_at) FROM stdin;
152	EMEB	50467642					AV, 7 Novembre N°22 BOUMHAL	1052236N	Physical Person	2097	411100001	PME/PMI	CLIENT B2B	Choisir une civilité...				1772806829862
153	DARDOUR ET COMPAGNIE SDC	50467642					Av ABOUELAATAHIA, CITE ESSALAM, BOUMHAL EL BASATINE	1871796B	Physical Person	2097	411100002	PME/PMI	CLIENT B2B	S.A.R.L				1772806829864
154	STE AKRAM DE COMMERCE ET SERICES	22800800					Av 8604, N°10 BIS, ZI CHARGUIA1, Tunis, TUNISIE	0996170C	Company	2035	411100003	Grand Compte	CLIENT B2B	S.A.R.L				1772806829865
155	ZIED BOUAFIA	93001596					LOTISSEMENT EL FOURATI, EL MENCHEYA, KAIROUAN, TUNISIE	11980031	Physical Person	3120	411100004	B2C	Client B2C	Pers.Phys.				1772806829865
156	MED MAROUEN EL HAJRI	29038669					8 Av ABDERRAHMEN BEN AOUF, CARTHAGE BIRSA, TUNIS	054770267	Physical Person	2016	411100005	B2C	Client B2C	Pers.Phys.				1772806829865
157	ALI CHEBBI	29531118					HENCHIR KHELIL, MORNAG, BEN AROUS, TUNISIE	05157343	Physical Person	2090	411100006	B2C	Client B2C	Pers.Phys.				1772806829865
158	OUSSEMA BEN AISSA	29495069					06 AV FATMA EZZAHRA, KSAR SAIID, TUNIS	10013316	Physical Person	2009	411100007	B2C	Client B2C	Pers.Phys.				1772806829865
159	MALEK JBELI	26438291					38 AV10096 EL KABBARIA? TUNIS	14657240	Physical Person	2053	411100008	B2C	Client B2C	Pers.Phys.				1772806829865
160	MOUJIB ALLAH EL JENDOUBI	22003801					5 AV 10447 EL WARDIA 6, TUNIS	07168496	Physical Person		411100009	B2C	Client B2C	Pers.Phys.				1772806829865
161	MOHAMED HAMROUNI	20245787					DOUAR EDDAKHLAOUI EL MARJA, SLIMANE NABEUL	06369417	Physical Person	8020	411100010	B2C	Client B2C	Pers.Phys.				1772806829865
162	AZIZA ABIDI	58841323	52329560				21 AV ECCHIKH SALAH EL MALKI EL OUARDIA1? TUNIS	00596284	Physical Person	1009	411100011	B2C	Client B2C	Pers.Phys.				1772806829865
163	DHAKER KHADRAOUI	24686485					AV EL IMEM BAKRAHI HACHED 2, MHAMDIA, BEN AROUS, TUNIS	07230199	Physical Person	1145	411100012	B2C	Client B2C	Pers.Phys.				1772806829865
164	MOHAMED SNOUN	26445298					20 AV KELIBIA CITE TAIEB MHIRI EL AOUINA, TUNIS	150039316	Physical Person	2045	411100013	B2C	Client B2C	Pers.Phys.				1772806829865
165	IBRAHIM ABID	55116745					JBAL ERRSAS, MORNAG, BEN AROUS	07101252	Physical Person	2090	411100014	B2C	Client B2C	Pers.Phys.				1772806829865
166	Mourad GHRAIRI	90113526					BOUJARDGA, MORNAG, BEN AROUS	07226667	Physical Person	2090	411100015	B2C	Client B2C	Pers.Phys.				1772806829865
167	Sami ESSID	26027442					FERME ENNABLI, CHELA, BOUMHAL EL BASATINE, BEN AROUS	07095405	Physical Person		411100016	B2C	Client B2C	Pers.Phys.				1772806829865
168	HASSEN ARFAOUI	29957529					32 AV DE L'EVACUATION, CITE ENNASR, MORNAGUIA, LA MANOUBA	09166039	Physical Person	1110	411100017	Grand Compte	CONVENTION STEG	Etat				1772806829865
169	Jamel AAROURI	22515996					IMPASSE SIDI AMEUR CITE MONGI SLIM EL AOUINA TUNIS	05991474	Company	2046	411100018	B2C	Client B2C	Etranger				1772806829865
170	Ahmed FARHAT	22124594					Av EL IMEM AL BOUKHARI, KHZEMA NORD, SOUSSE? TUNISIE	12931321	Physical Person		411100019	B2C	Client B2C	Pers.Phys.				1772806829865
171	Abdelhmid CHAOUATI	26079266					Cité FARHAT EL AANNABI, EL KHELIDIA, BEN AROUS	05055278	Physical Person	2054	411100020	Grand Compte	CONVENTION STEG	Etat				1772806829865
172	STE MGF	53840036					ZAOUIET MORNAG KM 1 ROUTE MC 34, BEN AROUS, TUNISIE	1660535H	Company	2090	411100021	Grand Compte	CLIENT B2B	S.A.R.L				1772806829865
173	Nader CHAOUACHI	51501401					01 AV, ZAGHOUAN 4émz Etage, APT N° 5, Tunis	04741009	Physical Person	1076	411100022	Grand Compte	CONVENTION STEG	Etat				1772806829865
174	Nizar SALHI	29689758					BORJ SALHI, EL HAOUARIA, NABEUL	06423990	Physical Person		411100023	B2C	Client B2C	Pers.Phys.				1772806829865
175	Hssan HARWAK	22977476					10 Av 42233, GHEDIR EL KOLLA, EL HRAIRIA , Tunis	00735227	Physical Person		411100024	Grand Compte	CONVENTION STEG	Etat				1772806829865
176	Youssef BEN YOUNES	98132794					16 Av AHMED CHAOUKI, CITE TAHER SFAR, HAMMAM LIF, BEN AROUS, TUNIS	09656480	Physical Person	2050	411100025	B2C	Client B2C	Pers.Phys.				1772806829865
177	Wahid LABIDI	97368729					ZARET EZZAOUIA, BAZINA, BIZERT, TUNISIE	11366864	Physical Person	7012	411100026	B2C	Client B2C	Pers.Phys.				1772806829865
178	Mokhtar NAHHALI	29692978					Av 4056, Route EL AATTAR SIDI HASSINE TUNIS	11658930	Physical Person	1095	411100027	B2C	Client B2C	Pers.Phys.				1772806829865
179	Chaker LOUNISSI	97152902					EZZRIBA SIDI MORCHED SELIANA SUD, SELIANA	09915126	Physical Person	6100	411100028	B2C	Client B2C	Pers.Phys.				1772806829865
180	K INDUSTRIAL MOTORS						JBEL DJELOUD, TUNIS		Physical Person		411100029	Groupe De Sociétés	CLIENT B2B	S.A.R.L				1772806829865
181	Abdelkader HEDFI	99393093					TORZA NORD, EL AALA, KAIROUAN	07578802	Physical Person	3150	411100030	B2C	Client B2C	Pers.Phys.				1772806829865
182	Naoufel EL HAMZI	21481718					5 AV HABIB BOURGUIBA, CHEBBA, MAHDIA, TUNISIE	03972010	Physical Person	5170	411100031	B2C	Client B2C	Pers.Phys.				1772806829865
183	Abdelkrim BEN MAATOUG	22126691					BIR EZZANGUA, EZZAOUIA, MORNAG, BEN AROUS, TUNISIE	00646772	Physical Person	2090	411100032	B2C	Client B2C	Pers.Phys.				1772806829865
184	Ahmed TRABELSI	98351734					EL BIR EL AZRRAK, TEBORBA, MANNOUBA	07295264	Physical Person	1130	411100033	B2C	Client B2C	Pers.Phys.				1772806829866
185	ASSARYA						TRIPOLIE, LIBYA		Company		411100034	PME/PMI	CLIENT B2B	Etranger				1772806829866
186	Hassen KASDAOUI	97161217					EL KWASDIA VILLE, DAHMANI, LE KEF	08050491	Physical Person	1201	411100035	B2C	Client B2C	Pers.Phys.				1772806829866
187	STE SOTAM	79350650					ROUTE C35, BOUJARDGUA, MORNAG	707452C/N/M/000	Company	2090	411100036	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
188	Souhail BEN REJEB	22137873					18 Rue 1, cité SOUISSI EZZAHROUNI, TUNIS	08726479	Physical Person	2017	411100037	Grand Compte	CONVENTION STEG	Etat				1772806829866
189	Mustapha ZOUAGHI	20510199					HENCHIR ENNECHMAIA EDKHAYLIA WED MELIZ, JENDOUBA	07752011	Physical Person		411100038	B2C	Client B2C	Pers.Phys.				1772806829866
190	MOD	27878992					jbal ouest		Physical Person		411100039	PME/PMI	CLIENT B2B	Choisir une civilité...				1772806829866
191	Fathia DHAHRI	97152217					Siliana	09939739	Physical Person	6100	411100040	B2C	Client B2C	Pers.Phys.				1772806829866
192	Adel IBN EL ASOUED	98267861					10 Av, 7441 EL MANAR 1, TUNIS	02986927	Physical Person	2041	411100041	Grand Compte	CONVENTION STEG	Pers.Phys.				1772806829866
193	STE LE CLUB	24356699					Tunis, TUNISIE	1600961Q	Company		411100042	Micro Entreprise	CLIENT B2B	S.A.R.L				1772806829866
194	Bilel AHMED	21919680					EL GONNA , MORNAG	07149886	Physical Person	2054	411100043	B2C	Client B2C	Pers.Phys.				1772806829866
195	Hichem BOUZIDI						MORNEG BEN AROUS	07060233	Physical Person	2090	411100044	B2C	Client B2C	Pers.Phys.				1772806829866
196	Ghassen BALTI	28575676					Av Mohamed KASSAB, EJJAYARA,	11665700	Physical Person	1095	411100045	B2C	Client B2C	Pers.Phys.				1772806829866
197	Moez JBELI	22255199					EL MORNAGIA MANOUBA	07311158	Physical Person	1110	411100046	B2C	Client B2C	Pers.Phys.				1772806829866
198	Mohamed DAOUTHI	96000786					AHWAZ NASRALLAH KAIROUAN	11879549	Physical Person	3100	411100047	B2C	Client B2C	Pers.Phys.				1772806829866
199	Khemaies JANDOUBI	25532988					Av AMOR IBN EL KHATTAB, CITE ENNASIM NAASEN, BEN AROUS	04625990	Physical Person		411100048	B2C	Client B2C	Pers.Phys.				1772806829866
200	Ezzedine TBORBI	28098454					HAY BASATINE BOUMHEL	00429510	Physical Person	2097	411100049	B2C	Client B2C	Pers.Phys.				1772806829866
201	STE TUNISIENNE DE DISTRIBUTION DES PRODUITS	52854555					EL BASATINE BOUMHEL	1404643H	Company	2097	411100050	PME/PMI	CLIENT B2B	S.U.A.R.L				1772806829866
202	Sami BEN DHAW	93420530					CITE KOUROUM MORNEG	05156425	Physical Person	2090	411100051	B2C	Client B2C	Pers.Phys.				1772806829866
203	Foued EL AALLAGUI	53361603					EL AALELGUA, MONAG	07192951	Physical Person	2090	411100052	B2C	Client B2C	Pers.Phys.				1772806829866
204	BIG SHOP TECHNOLOGY						ARIANA		Physical Person		411100053	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
205	Kais KASDAOUI	93295601					Av ZAMAKHCHARI, BIR EZZANGUA, MORNAG, BEN AROUS	08058321	Physical Person	2090	411100054	B2C	Client B2C	Pers.Phys.				1772806829866
206	Wissal BEN HAMZA	93229131					EZZAOUIA MORNAG, BEN AROUS	xxxxxxxxxx	Physical Person	2090	411100055	B2C	Client B2C	Pers.Phys.				1772806829866
207	Mohamed AZIZ KESIBI	56017466					MINISTERE DE DEFENSE NATIONALE, TUNIS	09640611	Physical Person	2087	411100056	B2C	Client B2C	Pers.Phys.				1772806829866
208	Kamel JELASSI	98641516					CITE EL AMAL, EL KHELIDIA, BEN AROUS	07180891	Physical Person	2054	411100057	B2C	Client B2C	Pers.Phys.				1772806829866
209	Sadok SALHI	98936922					CITE SALAM MORNEG BEN AROUS	02763545	Physical Person	2090	411100058	B2C	Client B2C	Pers.Phys.				1772806829866
210	Khmais DRIDI	22922920					EL KSIBI MORNEG	05151669	Physical Person	2090	411100059	B2C	Client B2C	Pers.Phys.				1772806829866
211	Adem BEN HSSIN	24153382					FOUCHANA BEN AROUS	14671337	Physical Person	2082	411100060	B2C	Client B2C	Pers.Phys.				1772806829866
212	Zied MLOUH	20528570					MORNAG BEN AROUS	07087581	Physical Person	2090	411100061	B2C	Client B2C	Pers.Phys.				1772806829866
213	Mohamed BOUHDIDA	55572906					MORNAG BEN AROUS	05183143	Physical Person	2090	411100062	B2C	Client B2C	Pers.Phys.				1772806829866
214	Mohamed BEJAOUI	27000635					CITE MAHRAJAN BOUMHAL BEN AROUS	09642241	Physical Person	2097	411100063	B2C	Client B2C	Pers.Phys.				1772806829866
215	Wassef GHARBI	28162902					CITE JABER MORNAG	07237838	Physical Person	2090	411100064	B2C	Client B2C	Pers.Phys.				1772806829866
216	Yosri MAHWACHI	96384930					AL AROUSA SILIANA	07201069	Physical Person	6100	411100065	B2C	Client B2C	Pers.Phys.				1772806829866
217	Skander BEN MRIDA	56300423					Résidence AIDA, Cité ERRAFEHA, ARIANA, Tunis	13010780	Physical Person	2080	411100066	B2C	Client B2C	Pers.Phys.				1772806829866
218	Abderrazek EL AJIMI	22224220					CITE NASSER MORNEG BEN AROUS	07038898	Physical Person	2090	411100067	B2C	Client B2C	Pers.Phys.				1772806829866
219	AALIA SAMIA	29058345					Cité ELLOUZ, CHERIFET, SLIMANE, NABEUL	06463740	Physical Person		411100068	B2C	Client B2C	Pers.Phys.				1772806829866
220	Nassima THAMRI						BOUMHEL BEN AROUS	08589746	Physical Person	2097	411100069	B2C	Client B2C	Pers.Phys.				1772806829866
221	STE LE CLUB	24356699					081, FARHAT HACHED, TUNIS	1600961Q	Company	1001	411100070	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
222	HASANINE REBII	24227620					Résidence OMNIA APT B, LA MANOUBA	08217234	Physical Person		411100071	B2C	Client B2C	Pers.Phys.				1772806829866
223	Mahdi SASSI	90096340					MORNEG BEN AROUS	07158668	Physical Person	2090	411100072	B2C	Client B2C	Pers.Phys.				1772806829866
224	Achref GHARBI	92956092					MOUROUJ 4 BEN AROUS	14671729	Physical Person	2074	411100073	B2C	Client B2C	Pers.Phys.				1772806829866
225	SOCIETE WAFRA AGRICOLE SWA	20525317					EL MANAR	1891046D	Company		411100074	PME/PMI	CLIENT B2B	S.U.A.R.L				1772806829866
226	MOHAMED EL AMDOUNI	54232625					AIIN JEMALA TEBOURSOK, BEJA, TUNISIE	14257030	Physical Person	9040	411100075	B2C	Client B2C	Pers.Phys.				1772806829866
227	STE TULIPE TECHNOLOGY						IBN KHALDOUN BOUMHAL	1408057M	Company	2097	411100076	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
228	STE SAFAS	58345268					MEGRINE	1695813/Z	Company		411100077	PME/PMI	CLIENT B2B	S.U.A.R.L				1772806829866
229	Abderrazek ARAARI	95270670					MOUROUJ 4 BEN AROUS	04595703	Physical Person	2074	411100078	B2C	Client B2C	Pers.Phys.				1772806829866
230	Omar KANZARI	23280273					CITE SNID MORNAG		Physical Person	2090	411100079	B2C	Client B2C	Pers.Phys.				1772806829866
231	STE PAP PLUS	20525317					ZI SIDI DAOUED, LA MARSA	1724728S	Company	1002	411100080	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
232	Med Ayoub GOUADER	94128304					Cité PTT, EL GSAR, GAFSA	14324842	Physical Person	2111	411100081	B2C	Client B2C	Pers.Phys.				1772806829866
233	Wassim ABBESSI	90208110					MORNEG  BEN AROUS	14677825	Physical Person	2090	411100082	B2C	Client B2C	Pers.Phys.				1772806829866
234	Fraj BOUKHRIS	22542250					MORNEG  BEN AROUS	07041697	Physical Person	2090	411100083	B2C	Client B2C	Pers.Phys.				1772806829866
235	MED Amine EL FRADI	27812832					SIDI SAAD MORNAG, 2090, BEN AROUS	07247322	Physical Person		411100084	B2C	Client B2C	Pers.Phys.				1772806829866
236	STE SOHAM	27652000					MORNEG	1191336QNM000	Company	2090	411100085	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
237	Fraj BEN AMMAR	29015097					AL RISALA MORNEG BEN AROUS	07144556	Physical Person	2090	411100086	B2C	Client B2C	Pers.Phys.				1772806829866
238	MED EL ARBI CHABKA	58149248					EZZAOUIA, MORNAG, BEN AROUS	07074285	Physical Person	2090	411100087	B2C	Client B2C	Pers.Phys.				1772806829866
239	Ahmed KANZARI	96281556					44 AV Des jardins, Cité EL HDHILI, NAASSAN, BEN AROUS	07096785	Physical Person	1135	411100088	B2C	Client B2C	Pers.Phys.				1772806829866
240	MED ADNENE CHAMTOURI	92588208					ABDI KHOUJA EL BASATINE, BOUMHAL, BEN AROUS	07016909	Physical Person	2080	411100089	B2C	Client B2C	Pers.Phys.				1772806829866
241	Fawzi TLILI		26444233			Abdesllem Mani	HAJB LAAYOUN KAIRAOUEN	11979410	Physical Person	3100	411100090	B2C	Client B2C	Pers.Phys.				1772806829866
242	STE SMC BAHRIA	29849324					RADES	Mf0891199N/A	Company	2040	411100091	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
243	Amine NAFFETI	99282212					Cité EL MEZIENE, MORNAG	07240299	Physical Person	2090	411100092	B2C	Client B2C	Pers.Phys.				1772806829866
244	Skander SHILI	29424863	51950830 		22347806 	Wael	JBAL RSAS MORNEG BEN AROUS	07027878	Physical Person	2064	411100093	B2C	Client B2C	Pers.Phys.				1772806829866
245	Mohamed RAYEN MATHLOUTHI	23748659	50961426			Zakaria	OUZRA MORNEG BEN AROUS	14667874	Physical Person	2090	411100094	B2C	Client B2C	Pers.Phys.				1772806829866
246	Mohamed Ali EL GHRAIRI	21439697					JBAL RSAS MORNEG	07152705	Physical Person	2064	411100095	B2C	Client B2C	Pers.Phys.				1772806829866
247	Abd Raouf EL MELHMI	20258055					RUE MANZEL BOURGUIBA ARIANA	05211236	Physical Person	2080	411100096	B2C	Client B2C	Pers.Phys.				1772806829866
248	Bilel MANNAII	22340594					EL KHELIJ EL BASSATINE, BOUMHAL, BEN AROUS	09623898	Physical Person	2097	411100097	B2C	Client B2C	Pers.Phys.				1772806829866
249	Iyed EL HAMADI	55534040					ZAWIA MORNEG	09735516	Physical Person	2090	411100098	B2C	Client B2C	Pers.Phys.				1772806829866
250	Ahmed WERGHEMI	22277808					HENCHIR ALIGA MORNEG BEN AROUS	07214868	Physical Person	2090	411100099	B2C	Client B2C	Pers.Phys.				1772806829866
251	SAPORI ITALIA						KSIBI MORNAG		Physical Person		411100100	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
252	Slim HAMROUNI	29393671					JBAL RSAS MORNEG	07165401	Physical Person		411100101	B2C	Client B2C	Pers.Phys.				1772806829866
253	Mohamed AZIZ SAADAOUI	50751907	48353552				YASMINET MEDINA JEDIDA BEN AROUS	07245749	Physical Person	2043	411100102	B2C	Client B2C	Pers.Phys.				1772806829866
254	Omar FERGENI	21097839					Cité EL HANA MHAMDEYA BEN AROUS	14682485	Physical Person	1145	411100103	B2C	Client B2C	Pers.Phys.				1772806829866
255	Seifeddine BEN ZEKRI	92624032					Cité des collines, FOUCHENE, BEN AROUS	07149400	Physical Person		411100104	B2C	Client B2C	Pers.Phys.				1772806829866
256	STE SOTUCHOC	58551719					KHLIDIA NAASEEN BEN AROUS	11825/W/A/M/000	Company	1135	411100105	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
257	Zaid BAILI	98582810					EL BASSATINE BOUMHAL BEN AROUS	08309484	Physical Person	2097	411100106	B2C	Client B2C	Pers.Phys.				1772806829866
258	Moataz BOUAADILA	52683780					EZZAOUIA MORNAG, BEN AROUS	07247400	Physical Person	2090	411100107	B2C	Client B2C	Pers.Phys.				1772806829866
259	Ihsen LARIANI	27000880	20720023				BOUJARDGA, MORNAG, BEN AROUS		Physical Person	2090	411100108	B2C	Client B2C	Pers.Phys.				1772806829866
260	Kais HADDAGI	26388334					BOUJARDGA, MORNAG, BEN AROUS	07140274	Physical Person	2090	411100109	B2C	Client B2C	Pers.Phys.				1772806829866
261	WIN WIN ADS						SOUSSE		Physical Person		411100110	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
262	Idriss HMADA	29176446	29133945				Cité AMOR MOUROUJ 4 BEN AROUS	06346484	Physical Person	2074	411100111	B2C	Client B2C	Pers.Phys.				1772806829866
263	Yassine RIAHI	54498598					FAHS ZAGHOUAN	10844961	Physical Person	1140	411100112	B2C	Client B2C	Pers.Phys.				1772806829866
264	Abdessalem BOUSEDRA	97842580					Cité municipalité MORNEG BEN AROUS	07054562	Physical Person	2090	411100113	B2C	Client B2C	Pers.Phys.				1772806829866
265	Wissem ROMDHANI	40275724					SLIMEN KAHIA MANOUBA	11922467	Physical Person	2010	411100114	B2C	Client B2C	Pers.Phys.				1772806829866
266	Saida FAZAII	28163382					EL BASSATINE BOUMHAL BEN AROUS	12686021	Physical Person	2097	411100115	B2C	Client B2C	Pers.Phys.				1772806829866
267	Mohamed AZIZ BEN AHMED	29793522					BOUMHEL BEN AROUS	09641994	Physical Person	2097	411100116	B2C	Client B2C	Pers.Phys.				1772806829866
268	Med HEDI TOUATI	53807122					EL BASSATINE BOUMHAL BEN AROUS	09647908	Physical Person	2097	411100117	B2C	Client B2C	Pers.Phys.				1772806829866
269	Ramzi BALOUTI	24611640					AHMED ZAYED MORNAG	7199260	Physical Person	2090	411100118	B2C	Client B2C	Pers.Phys.				1772806829866
270	Walid BENCHIKH	90460015					ABDI KHOUJA BOUMHAL	9656662	Physical Person	2097	411100119	B2C	Client B2C	Pers.Phys.				1772806829866
271	Lassaad GOUIDER	26056244	97847704				EZWAWIN KHLIDIA	7091243	Physical Person	2054	411100120	B2C	Client B2C	Pers.Phys.				1772806829866
272	STE Manuella						La Soukra		Company	2036	411100121	PME/PMI	Client B2B	S.A.R.L				1772806829866
273	Alae NAJEM	55529339					Sidi ETTOUMI BENI KHALED, NABEUL	9832545	Physical Person	8021	411100122	B2C	Client B2C	Pers.Phys.				1772806829866
274	Mohamed Aziz DALLAJI	98350998					2 Mars ALBASSATIN BOUMHAL BEN AROUS	9651750	Physical Person	2097	411100123	B2C	Client B2C	Pers.Phys.				1772806829866
275	Hamza HASSNAOUI	94697869					BIR ALZANGUA MORNAG	4529091	Physical Person	2090	411100124	B2C	Client B2C	Pers.Phys.				1772806829866
276	Mohamed Slim ABID	22873434					RUE BOURGUIBA ALZAHRA BEN AROUS	9606255	Physical Person	2034	411100125	B2C	Client B2C	Pers.Phys.				1772806829866
277	Hamza BADR	29305671					MATHEF ELJAM MONFLEURI	13031402	Physical Person	1089	411100126	B2C	Client B2C	Pers.Phys.				1772806829866
278	Saber BADR	42582030					MATHEF ELJAM SAIDA	7026119	Physical Person	1089	411100127	B2C	Client B2C	Pers.Phys.				1772806829866
279	NIZAR BOU DHAOWIA	99341020					AHMED ZAYED MORNAG	7229484	Physical Person	2090	411100128	B2C	Client B2C	Pers.Phys.				1772806829866
280	Amir KIRAT	55361123					BOUJARDGUA MORNAG	7185340	Physical Person	2090	411100129	B2C	Client B2C	Pers.Phys.				1772806829866
281	Mohamed Ali NASRALLAH	24437937					AHMED ZEYED MORNAG	7202287	Physical Person	2090	411100130	B2C	Client B2C	Pers.Phys.				1772806829866
282	Iptissem MANSOURI	22137763					ALBACHIA MANZEL JMIL BENZART	8138297	Physical Person	7080	411100131	B2C	Client B2C	Pers.Phys.				1772806829866
283	Ali HATHROUBI	29107682					TONKAR AAROUSSIA BATTAN MANNOUBA	7317527	Physical Person	1114	411100132	B2C	Client B2C	Pers.Phys.				1772806829866
284	CharfE Eddin ALAAMRI	20330542					20 NAHJ ALBACHIR NAJI HAY IBN KHALDOUN	4794647	Physical Person	2062	411100133	B2C	Client B2C	Pers.Phys.				1772806829866
285	STT	29760888					MEGRINE		Company	2033	411100134	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
286	Protest Engineering	50090466					Rue Abdi Khouja Zaouia Mornag	1586648XAM000	Company	2090	411100135	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
287	Yassin AALAGUI	92291096					MORNAG	14678238	Physical Person	2090	411100136	B2C	Client B2C	Pers.Phys.				1772806829866
288	Hazem BEN AALAYET	51953865					CHELA BOUMHAL BEN AROUS	9648725	Physical Person	2097	411100137	B2C	Client B2C	Pers.Phys.				1772806829866
289	Hajer MOHSEN	23252721					1 AV IBN ABD RABHA AL HADAEK BELVEDERE TUNIS	298817	Physical Person	1002	411100138	B2C	Client B2C	Pers.Phys.				1772806829866
290	FSIC	29166687	29975608				Avenue Fattouma Bourguiba, La Soukra, Tunis, Tunisie.		PME/PMI	2036	411100139	Micro Entreprise	CLIENT B2B	S.A.R.L	Virement			1772806829866
291	Aniss TIAHI	21118948					HAY LFERCHICHI BASSATIN BOUMHAL BEN AROUS	9604640	Physical Person	2097	411100140	B2C	Client B2C	Pers.Phys.				1772806829866
292	Kilani FERCHICHI	58899024					SIDI OMAR BOU KHTIWA RAWED ARIANA NORD ARIANA	8332076	Physical Person	2081	411100141	B2C	Client B2C	Pers.Phys.				1772806829866
293	Bilel GHRAIRI	21118948					NAHJ AHMAD TAKEY EDDIN ALBASSATIN BOUMHAL BEN AROUS	9629456	Physical Person	2097	411100142	B2C	Client B2C	Pers.Phys.				1772806829866
294	Issam NAWALI	22399989					KSIBI HAY SALEM MORNAG BEN AROUS	7098817	Physical Person	2090	411100143	B2C	Client B2C	Pers.Phys.				1772806829866
295	Bilel TRABELSSI	21506824					NAHJH IRAK HAY HADAEK MORNAG BEN AROUS	14652445	Physical Person	2090	411100144	B2C	Client B2C	Pers.Phys.				1772806829866
296	STE GREPSYS	55494316					Av De La Bourse, IMM EQUINOX	1125060K	Company	2045	411100145	Micro Entreprise	CLIENT B2B	S.A.R.L				1772806829866
297	STE ATLAS AUTO	22134593					ROUTE SOUSSE KM6 5, Ben Arous Ouest		Company	2013	411100146	Grand Compte	CLIENT B2B	S.A.R.L				1772806829866
298	STE SOPREM	22134593					Route N°1, Zone Industrielle de Boumhel, Tunisie	0499213BAM	Company	2090	411100147	Grand Compte	CLIENT B2B	S.A.R.L				1772806829866
299	Ouarda TERS HALLOUMI	22399989					FONDOK EJDID	648059R	Company	8012	411100148	PME/PMI	CLIENT B2B	S.A.R.L				1772806829866
300	Anouar ABDALLAH	21048348					AIIN ERRAKKAD, EL KHELIDIA, BEN AROUS	7232342	Physical Person	2054	411100149	B2C	Client B2C	Pers.Phys.				1772806829866
301	Hajer NAFFETI	55016793	58679507			Anass	62 Nahj IMEM ALCHAFEII MORNAG BEN AROUS	7077005	Physical Person	2090	411100150	B2C	Client B2C	Pers-Phys				1772806829866
308	Bachir BALLOUMI	24345802					Rue MAHDIA HAY ALAAHED ALJADID NAASEN BEN AROUS			2013	411100151	B2C	Client B2C	Pers.Phys.				1773842397630
309	Ahmed AAGRBI	97134020					CHELA BOUMHAL BEN AROUS			2097	411100152	B2C	Client B2C	Pers.Phys.				1773842401751
310	Taieb KACHOUB	98588753	58916936				10 Av MUSTAPHA HJAIEJ, Nelle ARIANA, ARIANA			2080	411100153	B2C	Client B2C	Pers.Phys.				1773842405590
311	Saber JBALI	27551842					IKAMET ABILIA 3 CHATRANA 01 ROUTE 1 SOKRA ARANA			2036	411100154	B2C	Client B2C	Pers.Phys.				1773842409408
312	Mohamed Mouheb WASSTI	93513412					ALAALAGUA MORNAG			2090	411100155	B2C	Client B2C	Pers.Phys.				1773842413306
313	Mohamed Amine BEN SALAH	25999429					07 rue 6289 ALOMRAN ALAALA TUNIS	11682432		1005	411100156	B2C	Client B2C	Pers-Phys				1774256511000
314	Ali RIAHI	52423916					HAY ALMALLAAB ALAAROUSSA SELIANA	04392701		6116	411100157	B2C	Client B2C	Pers-Phys				1774364088000
315	Ayoub ALMAHMOUDI	28434629					HENCHIR ALKALIAA MORNAG BEN AROUS	14689693		2090	411100158	B2C	Client B2C	Pers-Phys				1774525529000
316	Salem BEN MAATOUK	26135624					EZZAOUIA MORNAG, BEN AROUS	00941137		2090	411100159	B2C	Client B2C	Pers-Phys				1776682400000
317	Fares BOUKARI	53124228					RUE IBN KHALDOUN BARDO TUNIS	14774090		2000	411100160	B2C	Client B2C	Pers-Phys				1776682471000
\.


--
-- Data for Name: deferred_sales; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deferred_sales (id, date, nom_prenom, numero_telephone, type_moto, designation, quantite, montant, is_settled, confirmed_by_staff, confirmed_by_manager, calculation_timestamp, amount_handed, created_at) FROM stdin;
3	2025-10-11	Wahid AKACHA	51831158	Spring ST	Kite chaine	1	41	f	YASSIN	KARIM	1773137841562	0	1772280448000
4	2025-09-19	Wahid AKACHA	51831158	Spring ST	\tFiltre à air	1	40	f	\N	\N	\N	0	1772280543000
5	2026-03-09	Skander SHILI	29424863	Spring ST Bleu Ciel	Jante Spring ST Bleu Ciel	2	299	f	\N	\N	\N	0	1773046991000
6	2026-03-13	Naoufel EL HAMZI		HR	Filtre	1	19	f	\N	\N	\N	0	1773837990000
7	2026-03-13	Naoufel EL HAMZI		HR	plaquette frein	2	29	f	\N	\N	\N	0	1773838106000
\.


--
-- Data for Name: divers_purchases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.divers_purchases (id, date, designation, quantite, fournisseur, prix, created_at) FROM stdin;
5	2025-07-01	\tFiltre à air	1		0	1772280388000
6	2025-07-01	Kite chaine	1		0	1772280407000
7	2026-03-01	Jante Spring ST Bleu Ciel	2		299	1773046856000
8	2026-01-01	plaquette frein	2		28	1773837895000
9	2026-01-01	Filtre	1		19	1773837938000
\.


--
-- Data for Name: facture_lines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.facture_lines (id, facture_id, facture_number, bon_ref, date, commercial, client, id_client, matricule_fiscal, adresse_client, phone_client, ref, designation, qte, prix, tva, remise, prix_ttc, montant_ht, montant_tva, montant_ttc, created_at) FROM stdin;
1	1	25/000001	25/000001	2025-06-16	HADJ SALEM Karim	ZIED BOUAFIA	411100004				007	PISTA VCX NOIRE NOIRE	1	3445	19%	0	4099.55	3445	654.55	4099.55	1776955635000
2	2	25/000002	25/000002	2025-06-17	HADJ SALEM Karim	MED MAROUEN EL HAJRI	411100005				151	GHOST V7 124CC BLEUE JAUNE	1	4874	19%	0	5800.06	4874	926.06	5800.06	1776955635000
3	3	25/000003	25/000003	2025-06-17	HADJ SALEM Karim	STE AKRAM DE COMMERCE ET SERVICES	411100003				050	SPRING ST 124CC VERT PISTACHE	1	3446	19%	0	4100.74	3446	654.74	4100.74	1776955635000
4	4	25/000004	25/000004	2025-06-19	HADJ SALEM Karim	EMEB	411100001				007	PISTA VCX NOIRE NOIRE	1	3490	19%	0	4153.1	3490	663.1	4153.1	1776955635000
5	5	25/000005	25/000005	2025-06-19	HADJ SALEM Karim	DARDOUR ET COMPAGNIE SDC	411100002				050	SPRING ST 124CC VERT PISTACHE	1	3405	19%	0	4051.95	3405	646.95	4051.95	1776955635000
6	6	25/000006	25/000006	2025-06-21	HADJ SALEM Karim	ALI CHEBBI	411100006				101	FORZA POWER 107CC GRIS	1	2353	19%	0	2800.07	2353	447.07	2800.07	1776955635000
7	7	25/000007	25/000007	2025-06-21	HADJ SALEM Karim	OUSSEMA BEN AISSA	411100007				003	PISTA VCX VERT PISTACHE	1	3445	19%	0	4099.55	3445	654.55	4099.55	1776955635000
8	8	25/000008	25/000008	2025-06-21	HADJ SALEM Karim	MALEK JBELI	411100008				150	GHOST V7 124CC VERT NOIRE	1	4840	19%	0	5759.6	4840	919.6	5759.6	1776955635000
9	9	25/000009	25/000009	2025-06-22	HADJ SALEM Karim	MOUJIB ALLAH EL JENDOUBI	411100009				052	SPRING ST 124CC BLEUE CIEL	1	3403	19%	0	4049.57	3403	646.57	4049.57	1776955635000
10	10	25/000010	25/000010	2025-06-22	HADJ SALEM Karim	MOHAMED HAMROUNI	411100010				102	FORZA POWER 107CC NOIRE	1	2353	19%	0	2800.07	2353	447.07	2800.07	1776955635000
11	11	25/000011	25/000011	2025-06-25	HADJ SALEM Karim	AZIZA ABIDI	411100011				151	GHOST V7 124CC BLEUE JAUNE	1	4775	19%	0	5682.25	4775	907.25	5682.25	1776955635000
12	12	25/000012	25/000012	2025-06-30	HADJ SALEM Karim	DHAKER KHADRAOUI	411100012				008	PISTA VCX BLANC NOIRE	1	3445	19%	0	4099.55	3445	654.55	4099.55	1776955635000
13	13	25/000013	25/000013	2025-01-07	HADJ SALEM Karim	MOHAMED SNOUN	411100013				008	PISTA VCX BLANC NOIRE	1	3445	19%	0	4099.55	3445	654.55	4099.55	1776955635000
14	14	25/000014	25/000014	2025-03-07	HADJ SALEM Karim	IBRAHIM ABID	411100014				051	SPRING ST 124CC JAUNE NOIRE	1	3361	19%	0	3999.59	3361	638.59	3999.59	1776955635000
15	15	25/000015	25/000015	2025-10-07	HADJ SALEM Karim	Mourad GHRAIRI	411100015				003	PISTA VCX VERT PISTACHE	1	3445	19%	0	4099.55	3445	654.55	4099.55	1776955635000
16	16	25/000016	25/000016	2025-10-07	HADJ SALEM Karim	Sami ESSID	411100016				101	FORZA POWER 107CC GRIS	1	2353	19%	0	2800.07	2353	447.07	2800.07	1776955635000
17	17	25/000017	25/000017	2025-11-07	HADJ SALEM Karim	HASSEN ARFAOUI	411100017				102	FORZA POWER 107CC NOIRE	1	2395	19%	0	2850.05	2395	455.05	2850.05	1776955635000
18	18	25/000018	25/000018	2025-12-07	HADJ SALEM Karim	Jamel AAROURI	411100018				005	PISTA VCX BLEUE JAUNE	1	3445	19%	0	4099.55	3445	654.55	4099.55	1776955635000
19	19	25/000019	25/000019	2025-12-07	HADJ SALEM Karim	Ahmed FARHAT	411100019				152	GHOST V7 124CC NOIRE	1	4958	19%	0	5900.02	4958	942.02	5900.02	1776955635000
20	20	25/000020	25/000020	2025-07-14	HADJ SALEM Karim	Abdelhmid CHAOUATI	411100020				052	SPRING ST 124CC BLEUE CIEL	1	3446	19%	0	4100.74	3446	654.74	4100.74	1776955635000
21	21	25/000021	25/000021	2025-07-15	HADJ SALEM Karim	Nader CHAOUACHI	411100022				002	PISTA VCX VERT NOIRE	1	3530	19%	0	4200.7	3530	670.7	4200.7	1776955635000
22	22	25/000022	25/000022	2025-07-24	HADJ SALEM Karim	Nizar SALHI	411100023				101	FORZA POWER 107CC GRIS	1	2353	19%	0	2800.07	2353	447.07	2800.07	1776955635000
23	23	25/000023	25/000023	2025-07-16	HADJ SALEM Karim	Hssan HARWAK	411100024				102	FORZA POWER 107CC NOIRE	1	2395	19%	0	2850.05	2395	455.05	2850.05	1776955635000
24	24	25/000024	25/000024	2025-07-17	HADJ SALEM Karim	Youssef BEN YOUNES	411100025				100	FORZA POWER 107CC BLEUE	1	2395	19%	0	2850.05	2395	455.05	2850.05	1776955635000
25	25	25/000025	25/000025	2025-07-16	HADJ SALEM Karim	Wahid LABIDI	411100026				052	SPRING ST 124CC BLEUE CIEL	1	3446	19%	0	4100.74	3446	654.74	4100.74	1776955635000
26	26	25/000026	25/000026	2025-07-19	HADJ SALEM Karim	Mokhtar NAHHALI	411100027				151	GHOST V7 124CC BLEUE JAUNE	1	4932	19%	0	5869.08	4932	937.08	5869.08	1776955635000
27	27	25/000027	25/000027	2025-07-20	HADJ SALEM Karim	Fathia DHAHRI	411100040				100	FORZA POWER 107CC BLEUE	1	2353	19%	0	2800.07	2353	447.07	2800.07	1776955635000
28	28	25/000028	25/000028	2025-07-22	HADJ SALEM Karim	Abdelkader HEDFI	411100030				102	FORZA POWER 107CC NOIRE	1	2353	19%	0	2800.07	2353	447.07	2800.07	1776955635000
29	29	25/000029	25/000029	2025-07-23	HADJ SALEM Karim	Naoufel EL HAMZI	411100031				006	PISTA VCX BLEUE NOIRE	1	3488	19%	0	4150.72	3488	662.72	4150.72	1776955635000
30	30	25/000030	25/000030	2025-07-23	HADJ SALEM Karim	STE MGF	411100021				102	FORZA POWER 107CC NOIRE	1	2395	19%	0	2850.05	2395	455.05	2850.05	1776955635000
31	31	25/000031	25/000031	2025-07-26	HADJ SALEM Karim	Abdelkrim BEN MAATOUG	411100032				052	SPRING ST 124CC BLEUE CIEL	1	3403	19%	0	4049.57	3403	646.57	4049.57	1776955635000
32	32	25/000032	25/000032	2025-07-31	HADJ SALEM Karim	Ahmed TRABELSI	411100033				102	FORZA POWER 107CC NOIRE	1	2353	19%	0	2800.07	2353	447.07	2800.07	1776955635000
33	33	25/000033	25/000033	2025-05-08	HADJ SALEM Karim	Hassen KASDAOUI	411100035				106	FORZA POWER 124CC NOIRE	1	2521	19%	0	2999.99	2521	478.99	2999.99	1776955635000
34	34	25/000034	25/000034	2025-02-08	HADJ SALEM Karim	Mustapha ZOUAGHI	411100038				101	FORZA POWER 107CC GRIS	1	2345	19%	0	2790.55	2345	445.55	2790.55	1776955636000
35	35	25/000035	25/000035	2025-02-08	HADJ SALEM Karim	Souhail BEN REJEB	411100037				151	GHOST V7 124CC BLEUE JAUNE	1	4958	19%	0	5900.02	4958	942.02	5900.02	1776955636000
36	36	25/000036	25/000036	2025-06-08	HADJ SALEM Karim	Adel IBN EL ASOUED	411100041				153	GHOST V7 124CC GRIS BLEU	1	4958	19%	0	5900.02	4958	942.02	5900.02	1776955636000
37	37	25/000037	25/000037	2025-11-08	HADJ SALEM Karim	Bilel AHMED	411100043				050	SPRING ST 124CC VERT PISTACHE	1	3360	19%	0	3998.4	3360	638.4	3998.4	1776955636000
38	38	25/000038	25/000038	2025-08-16	HADJ SALEM Karim	Ghassen BALTI	411100045				002	PISTA VCX VERT NOIRE	1	3487	19%	0	4149.53	3487	662.53	4149.53	1776955636000
39	39	25/000039	25/000039	2025-08-18	HADJ SALEM Karim	Moez JBELI	411100046				150	GHOST V7 124CC VERT NOIRE	1	4958	19%	0	5900.02	4958	942.02	5900.02	1776955636000
40	40	25/000040	25/000040	2025-08-18	HADJ SALEM Karim	Mohamed DAOUTHI	411100047				107	FORZA POWER 124CC ROUGE	1	2521	19%	0	2999.99	2521	478.99	2999.99	1776955636000
41	41	25/000041	25/000041	2025-08-21	HADJ SALEM Karim	STE TUNISIENNE DE DISTRIBUTION DES PRODUITS	411100050				006	PISTA VCX BLEUE NOIRE	1	3487	19%	0	4149.53	3487	662.53	4149.53	1776955636000
42	42	25/000042	25/000042	2025-08-21	HADJ SALEM Karim	Sami BEN DHAW	411100051				106	FORZA POWER 124CC NOIRE	1	2563	19%	0	3049.97	2563	486.97	3049.97	1776955636000
43	43	25/000043	25/000043	2025-08-21	HADJ SALEM Karim	Foued EL AALLAGUI	411100052				052	SPRING ST 124CC BLEUE CIEL	1	3530	19%	0	4200.7	3530	670.7	4200.7	1776955636000
44	44	25/000044	25/000044	2025-08-23	HADJ SALEM Karim	Kais KASDAOUI	411100054				101	FORZA POWER 107CC GRIS	1	2437	19%	0	2900.03	2437	463.03	2900.03	1776955636000
45	45	25/000045	25/000045	2025-08-25	HADJ SALEM Karim	Mohamed AZIZ KESIBI	411100056				001	PISTA VCX ROUGE NOIRE	1	3487	19%	0	4149.53	3487	662.53	4149.53	1776955636000
46	46	25/000046	25/000046	2025-08-25	HADJ SALEM Karim	Kamel JELASSI	411100057				005	PISTA VCX BLEUE JAUNE	1	3487	19%	0	4149.53	3487	662.53	4149.53	1776955636000
47	47	25/000047	25/000047	2025-08-30	HADJ SALEM Karim	Sadok SALHI	411100058				004	PISTA VCX DORE NOIRE	1	3487	19%	0	4149.53	3487	662.53	4149.53	1776955636000
48	48	25/000048	25/000048	2025-01-09	HADJ SALEM Karim	Khmais DRIDI	411100059				102	FORZA POWER 107CC NOIRE	1	2395	19%	0	2850.05	2395	455.05	2850.05	1776955636000
49	49	25/000049	25/000049	2025-03-09	HADJ SALEM Karim	Adem BEN HSSIN	411100060				001	PISTA VCX ROUGE NOIRE	1	3488	19%	0	4150.72	3488	662.72	4150.72	1776955636000
50	50	25/000050	25/000050	2025-08-09	HADJ SALEM Karim	Zied MLOUH	411100061				050	SPRING ST 124CC VERT PISTACHE	1	3613	19%	0	4299.47	3613	686.47	4299.47	1776955636000
51	51	25/000051	25/000051	2025-08-09	HADJ SALEM Karim	Hajer NAFFETI	411100150				052	SPRING ST 124CC BLEUE CIEL	1	3613	19%	0	4299.47	3613	686.47	4299.47	1776955636000
52	52	25/000052	25/000052	2025-11-09	HADJ SALEM Karim	Yosri MAHWACHI	411100065				106	FORZA POWER 124CC NOIRE	1	2563	19%	0	3049.97	2563	486.97	3049.97	1776955636000
53	53	25/000085	25/000053	2025-09-18	HADJ SALEM Karim	Skander BEN MRIDA	411100066				004	PISTA VCX NOIRE NOIRE	1	3530	19%	0	4200.7	3530	670.7	4200.7	1776955636000
54	54	25/000053	25/000054	2025-09-19	HADJ SALEM Karim	Abderrazek EL AJIMI	411100067				050	SPRING ST 124CC VERT PISTACHE	1	3529	19%	0	4199.51	3529	670.51	4199.51	1776955636000
55	55	25/000070	25/000055	2025-09-19	HADJ SALEM Karim	AALIA SAMIA	411100068				105	FORZA POWER 124CC GRIS	1	2650	19%	0	3153.5	2650	503.5	3153.5	1776955636000
56	56	25/000054	25/000056	2025-09-22	HADJ SALEM Karim	Nassima THAMRI	411100069				050	SPRING ST 124CC VERT PISTACHE	1	3529	19%	0	4199.51	3529	670.51	4199.51	1776955636000
57	57	25/000055	25/000057	2025-09-23	HADJ SALEM Karim	STE LE CLUB	411100070				12	PISTA HR+ NOIRE BLEU	1	4033	19%	0	4799.27	4033	766.27	4799.27	1776955636000
58	58	25/000056	25/000058	2025-09-23	HADJ SALEM Karim	HASANINE REBII	411100071				13	PISTA HR+ CARBONE	1	3990	19%	0	4748.1	3990	758.1	4748.1	1776955636000
59	59	25/000057	25/000059	2025-09-24	HADJ SALEM Karim	Mahdi SASSI	411100072				102	FORZA POWER 107CC NOIRE	1	2395	19%	0	2850.05	2395	455.05	2850.05	1776955636000
60	60	25/000058	25/000060	2025-09-24	HADJ SALEM Karim	SOCIETE WAFRA AGRICOLE SWA	411100074				051	SPRING ST 124CC JAUNE NOIRE	1	3739	19%	0	4449.41	3739	710.41	4449.41	1776955636000
61	61	25/000059	25/000061	2025-09-25	HADJ SALEM Karim	MOHAMED EL AMDOUNI	411100075				11	PISTA HR+ GRIS VERT	1	4033	19%	0	4799.27	4033	766.27	4799.27	1776955636000
62	62	25/000060	25/000062	2025-09-25	HADJ SALEM Karim	Achref GHARBI	411100073				052	SPRING ST 124CC BLEUE CIEL	1	3613	19%	0	4299.47	3613	686.47	4299.47	1776955636000
63	63	25/000061	25/000063	2025-09-26	HADJ SALEM Karim	STE TULIPE TECHNOLOGY	411100076				10	PISTA HR+ NOIRE MARRON	1	3949	19%	0	4699.31	3949	750.31	4699.31	1776955636000
64	64	25/000062	25/000064	2025-09-29	HADJ SALEM Karim	Abderrazek ARAARI	411100078				9	PISTA HR+ VERT JAUNE	1	4033	19%	0	4799.27	4033	766.27	4799.27	1776955636000
65	65	25/000063	25/000065	2025-09-30	HADJ SALEM Karim	Naoufel EL HAMZI	411100031				052	SPRING ST 124CC BLEUE CIEL	1	3571	19%	0	4249.49	3571	678.49	4249.49	1776955636000
66	66	25/000064	25/000066	2025-06-10	HADJ SALEM Karim	Med Ayoub GOUADER	411100081				105	FORZA POWER 124CC GRIS	1	2563	19%	0	3049.97	2563	486.97	3049.97	1776955636000
67	67	25/000065	25/000067	2025-06-10	HADJ SALEM Karim	Wassim ABBESSI	411100082				107	FORZA POWER 124CC ROUGE	1	2647	19%	0	3149.93	2647	502.93	3149.93	1776955636000
68	68	25/000066	25/000068	2025-08-10	HADJ SALEM Karim	Fraj BOUKHRIS	411100083				102	FORZA POWER 107CC NOIRE	1	2370	19%	0	2820.3	2370	450.3	2820.3	1776955636000
69	69	25/000067	25/000069	2025-08-10	HADJ SALEM Karim	MED Amine EL FRADI	411100084				051	SPRING ST 124CC JAUNE NOIRE	1	3530	19%	0	4200.7	3530	670.7	4200.7	1776955636000
70	70	25/000068	25/000070	2025-10-13	HADJ SALEM Karim	Fraj BEN AMMAR	411100086				103	FORZA POWER 107CC ROUGE	1	2395	19%	0	2850.05	2395	455.05	2850.05	1776955636000
71	71	25/000069	25/000071	2025-10-22	HADJ SALEM Karim	Ahmed KANZARI	411100088				017	PISTA HR NOIR / MARRON	1	3780	19%	0	4498.2	3780	718.2	4498.2	1776955636000
72	72	25/000071	25/000072	2025-10-27	HADJ SALEM Karim	MED ADNENE CHAMTOURI	411100089				100	FORZA POWER 107CC BLEUE	1	2479	19%	0	2950.01	2479	471.01	2950.01	1776955636000
73	73	25/000072	25/000073	2025-10-28	HADJ SALEM Karim	Fawzi TLILI	411100090				053	SPRING ST 124CC NOIR	1	3530	19%	0	4200.7	3530	670.7	4200.7	1776955636000
74	74	25/000073	25/000074	2025-06-11	HADJ SALEM Karim	Skander SHILI	411100093				054	SPRING ST 124CC BLEU FONCE	1	3530	19%	0	4200.7	3530	670.7	4200.7	1776955636000
75	75	25/000074	25/000075	2025-10-11	HADJ SALEM Karim	Mohamed RAYEN MATHLOUTHI	411100094				053	SPRING ST 124CC NOIR	1	3530	19%	0	4200.7	3530	670.7	4200.7	1776955636000
76	76	25/000075	25/000076	2025-08-11	HADJ SALEM Karim	Mohamed Ali EL GHRAIRI	411100095				055	SPRING ST 124CC VERT	1	3530	19%	0	4200.7	3530	670.7	4200.7	1776955636000
77	77	25/000076	25/000077	2025-10-11	HADJ SALEM Karim	Abd Raouf EL MELHMI	411100096				051	SPRING ST 124CC JAUNE NOIRE	1	3613	19%	0	4299.47	3613	686.47	4299.47	1776955636000
78	78	25/000077	25/000078	2025-10-11	HADJ SALEM Karim	Bilel MANNAII	411100097				014	PISTA HR CARBON	1	3740	19%	0	4450.6	3740	710.6	4450.6	1776955636000
79	79	25/000078	25/000079	2025-10-11	HADJ SALEM Karim	Iyed EL HAMADI	411100098				100	FORZA POWER 107CC BLEUE	1	2395	19%	0	2850.05	2395	455.05	2850.05	1776955636000
80	80	25/000079	25/000080	2025-10-11	HADJ SALEM Karim	Ahmed WERGHEMI	411100099				104	FORZA POWER 124CC BLEU	1	2647	19%	0	3149.93	2647	502.93	3149.93	1776955636000
81	81	25/000080	25/000081	2025-11-14	HADJ SALEM Karim	Mohamed AZIZ SAADAOUI	411100102				9	PISTA HR+ VERT JAUNE	1	3950	19%	0	4700.5	3950	750.5	4700.5	1776955636000
82	82	25/000081	25/000082	2025-11-17	HADJ SALEM Karim	STE AKRAM DE COMMERCE ET SERICES	411100003				905	CASQUE LS2 AIRFLOW MATT-Taille XXL	1	324	19%	0	385.56	324	61.56	385.56	1776955636000
83	83	25/000082	25/000083	2025-11-17	HADJ SALEM Karim	Skander SHILI	411100093				911	CASQUE LS2 AIRFLOW GLOSS -Taille L	1	324	19%	0	385.56	324	61.56	385.56	1776955636000
84	84	25/000083	25/000084	2025-11-18	HADJ SALEM Karim	Omar FERGENI	411100103				11	PISTA HR+ GRIS VERT	1	3950	19%	0	4700.5	3950	750.5	4700.5	1776955636000
85	85	25/000084	25/000085	2025-11-20	HADJ SALEM Karim	Seifeddine BEN ZEKRI	411100104				13	PISTA HR+ CARBONE	1	3950	19%	0	4700.5	3950	750.5	4700.5	1776955636000
86	86	25/000086	25/000086	2025-11-25	HADJ SALEM Karim	Zaid BAILI	411100106				10	PISTA HR+ NOIRE MARRON	1	3950	19%	0	4700.5	3950	750.5	4700.5	1776955636000
87	87	25/000087	25/000087	2025-11-25	HADJ SALEM Karim	Zaid BAILI	411100106				903	CASQUE LS2 AIRFLOW MATT-Taille XXL	1	294	19%	0	349.86	294	55.86	349.86	1776955636000
88	88	25/000088	25/000088	2025-04-12	HADJ SALEM Karim	Moataz BOUAADILA	411100107				016	PISTA HR NOIR / GRIS	1	3697	19%	0	4399.43	3697	702.43	4399.43	1776955636000
89	89	25/000089	25/000089	2025-09-12	HADJ SALEM Karim	Mohamed RAYEN MATHLOUTHI	411100094				911	CASQUE LS2 AIRFLOW GLOSS -Taille L	1	323.5	19%	0	384.965	323.5	61.465	384.965	1776955636000
90	90	25/000090	25/000090	2025-12-15	HADJ SALEM Karim	Ihsen LARIANI	411100108				103	FORZA POWER 107CC ROUGE	1	2479	19%	0	2950.01	2479	471.01	2950.01	1776955636000
91	91	25/000091	25/000091	2025-12-16	HADJ SALEM Karim	Kais HADDAGI	411100109				107	FORZA POWER 124CC ROUGE	1	2647	19%	0	3149.93	2647	502.93	3149.93	1776955636000
92	92	25/000092	25/000092	2025-12-19	HADJ SALEM Karim	Idriss HMADA	411100111				11	PISTA HR+ GRIS VERT	1	4033	19%	0	4799.27	4033	766.27	4799.27	1776955636000
93	93	25/000093	25/000093	2025-12-19	HADJ SALEM Karim	Yassine RIAHI	411100112				102	FORZA POWER 107CC NOIRE	1	2479	19%	0	2950.01	2479	471.01	2950.01	1776955636000
94	94	25/000094	25/000094	2025-12-20	HADJ SALEM Karim	Moataz BOUAADILA	411100107				902	CASQUE LS2 AIRFLOW MATT-Taille M	1	315	19%	0	374.85	315	59.85	374.85	1776955636000
95	95	25/000095	25/000095	2025-12-22	HADJ SALEM Karim	Abdessalem BOUSEDRA	411100113				101	FORZA POWER 107CC GRIS	1	2478	19%	0	2948.82	2478	470.82	2948.82	1776955636000
96	96	25/000096	25/000096	2025-12-22	HADJ SALEM Karim	Wissem ROMDHANI	411100114				055	SPRING ST 124CC VERT	1	3613	19%	0	4299.47	3613	686.47	4299.47	1776955637000
97	97	25/000097	25/000097	2025-12-24	HADJ SALEM Karim	Saida FAZAII	411100115				102	FORZA POWER 107CC NOIRE	1	2395	19%	0	2850.05	2395	455.05	2850.05	1776955637000
98	98	25/000098	25/000098	2025-12-29	HADJ SALEM Karim	Mohamed AZIZ BEN AHMED	411100116				12	PISTA HR+ NOIRE BLEU	1	4033	19%	0	4799.27	4033	766.27	4799.27	1776955637000
99	99	26/000001	25/000099	2026-02-01	HADJ SALEM Karim	Skander SHILI	411100093				050	SPRING ST 124CC VERT PISTACHE	1	3613	19%	0	4299.47	3613	686.47	4299.47	1776955637000
100	100	26/000002	26/000001	2026-02-01	HADJ SALEM Karim	Skander SHILI	411100093				920	CASQUE MT HELMETS MATT-Taille L	1	231	19%	0	274.89	231	43.89	274.89	1776955637000
101	101	26/000003	26/000002	2026-05-01	HADJ SALEM Karim	Kais HADDAGI	411100109				101	FORZA POWER 107CC GRIS	1	2479	19%	0	2950.01	2479	471.01	2950.01	1776955637000
102	102	26/000004	26/000003	2026-09-01	HADJ SALEM Karim	Ramzi BALOUTI	411100118				106	FORZA POWER 124CC NOIRE	1	2647	19%	0	3149.93	2479	502.93	3149.93	1776955637000
103	103	26/000005	26/000004	2026-09-01	HADJ SALEM Karim	Walid BENCHIKH	411100119				55	SPRING ST 124CC VERT	1	3613	19%	0	4299.47	3613	686.47	4299.47	1776955637000
104	104	26/000006	26/000005	2026-01-13	HADJ SALEM Karim	Ihsen LARIANI	411100108				102	FORZA POWER 107CC NOIRE	1	2479	19%	0	2950.01	2479	471.01	2950.01	1776955637000
105	105	26/000007	26/000006	2026-01-14	HADJ SALEM Karim	Lassaad GOUIDER	411100120				55	SPRING ST 124CC VERT	1	3614	19%	0	4300.66	3614	686.66	4300.66	1776955637000
106	106	26/000008	26/000007	2026-01-15	HADJ SALEM Karim	Skander SHILI	411100093				54	SPRING ST 124CC BLEU FONCE	1	3613	19%	0	4299.47	3613	686.47	4299.47	1776955637000
107	107	26/000009	26/000008	2026-01-22	HADJ SALEM Karim	Alae NAJEM	411100122				102	FORZA POWER 107CC NOIRE	1	2478	19%	0	2948.82	2478	470.82	2948.82	1776955637000
108	108	26/000010	26/000009	2026-01-26	HADJ SALEM Karim	Mohamed Aziz DALLAJI	411100123				12	PISTA HR+ NOIRE BLEU	1	3992	19%	0	4750.48	3992	758.48	4750.48	1776955637000
109	109	26/000011	26/000011	2026-01-26	HADJ SALEM Karim	Hamza HASSNAOUI	411100124				102	FORZA POWER 107CC NOIRE	1	2479	19%	0	2950.01	2479	471.01	2950.01	1776955637000
110	110	26/000012	26/000012	2026-01-27	HADJ SALEM Karim	Mohamed Slim ABID	411100125				9	PISTA HR+ VERT JAUNE	1	3992	19%	0	4750.48	3992	758.48	4750.48	1776955637000
111	111	26/000013	26/000013	2026-01-28	HADJ SALEM Karim	Saber BADR	411100127				14	PISTA HR CARBON	1	3782	19%	0	4500.58	3782	718.58	4500.58	1776955637000
112	112	26/000014	26/000014	2026-02-03	HADJ SALEM Karim	NIZAR BOU DHAOWIA	411100128				100	FORZA POWER 107CC BLEUE	1	2479	19%	0	2950.01	2479	471.01	2950.01	1776955637000
113	113	26/000015	26/000015	2026-02-06	HADJ SALEM Karim	Yassine RIAHI	411100112				100	FORZA POWER 107CC BLEUE	1	2479	19%	0	2950.01	2479	471.01	2950.01	1776955637000
114	114	26/000016	26/000016	2026-02-07	HADJ SALEM Karim	Amir KIRAT	411100129				16	PISTA HR NOIR / GRIS	1	3782	19%	0	4500.58	3782	718.58	4500.58	1776955637000
115	115	26/000017	26/000017	2026-02-07	HADJ SALEM Karim	Mohamed Ali NASRALLAH	411100130				54	SPRING ST 124CC BLEU FONCE	1	3488	19%	0	4150.72	3488	662.72	4150.72	1776955637000
116	116	26/000018	26/000018	2026-02-10	HADJ SALEM Karim	Iptissem MANSOURI	411100131				106	FORZA POWER 124CC NOIRE	1	2648	19%	0	3151.12	2648	503.12	3151.12	1776955637000
117	117	26/000019	26/000019	2026-02-10	HADJ SALEM Karim	Ali HATHROUBI	411100132				106	FORZA POWER 124CC NOIRE	1	2564	19%	0	3051.16	2564	487.16	3051.16	1776955637000
118	118	26/000020	26/000020	2026-02-11	HADJ SALEM Karim	CharfE Eddin ALAAMRI	411100133				14	PISTA HR CARBON	1	3782	19%	0	4500.58	3782	718.58	4500.58	1776955637000
119	119	26/000021	26/000021	2026-02-16	HADJ SALEM Karim	Hazem BEN AALAYET	411100137				55	SPRING ST 124CC VERT + Casque TNL	1	3612	19%	0	4298.28	3612	686.28	4298.28	1776955637000
120	120	26/000022	26/000022	2026-02-17	HADJ SALEM Karim	Protest Engineering	411100135				106	FORZA POWER 124CC NOIRE	1	2606	19%	0	3101.14	2606	495.14	3101.14	1776955637000
121	121	26/000023	26/000023	2026-02-17	HADJ SALEM Karim	Protest Engineering	411100135				666A	Casque TNL	1	124	19%	0	147.56	124	23.56	147.56	1776955637000
122	122	26/000024	26/000025	2026-02-17	HADJ SALEM Karim	Adem BEN HSSIN	411100060				14	PISTA HR+ VERT MARRON	1	4033	19%	0	4799.27	4033	766.27	4799.27	1776955637000
123	123	26/000025	26/000026	2026-02-18	HADJ SALEM Karim	Aniss TIAHI	411100140				21	PISTA HR+ ROUGE NOIRE	1	4033	19%	0	4799.27	4033	766.27	4799.27	1776955637000
124	124	26/000026	26/000027	2026-02-18	HADJ SALEM Karim	Kilani FERCHICHI	411100141				55	SPRING ST 124CC VERT	1	3530	19%	0	4200.7	3530	670.7	4200.7	1776955637000
125	125	26/000027	26/000028	2026-02-18	HADJ SALEM Karim	Bilel GHRAIRI	411100142				13	PISTA HR+ CARBONE	1	4033	19%	0	4799.27	4033	766.27	4799.27	1776955637000
126	126	26/000028	26/000029	2026-02-19	HADJ SALEM Karim	Issam NAWALI	411100143				15	PISTA HR+ NOIR ROUGE	1	4033	19%	0	4799.27	4033	766.27	4799.27	1776955637000
127	127	26/000029	26/000030	2026-02-19	HADJ SALEM Karim	Hajer MOHSEN	411100138				20	PISTA HR+ BLEU BEIGE	1	4033	19%	0	4799.27	4033	766.27	4799.27	1776955637000
128	128	26/000030	26/000031	2026-02-23	HADJ SALEM Karim	FSIC	411100139				104	FORZA POWER 124CC BLEU	1	2661	19%	0	3166.59	2661	505.59	3166.59	1776955637000
129	129	26/000031	26/000032	2026-02-21	HADJ SALEM Karim	STE GREPSYS	411100145				18	PISTA HR VERT JAUNE 107 CC	1	3700	19%	0	4403	3700	703	4403	1776955637000
130	130	26/000032	26/000033	2026-02-25	HADJ SALEM Karim	Anouar ABDALLAH	411100149				54	SPRING ST 124CC BLEU FONCE	1	3445	19%	0	4099.55	3445	654.55	4099.55	1776955637000
131	131	26/000033	26/000034	2026-03-02	HADJ SALEM Karim	STE SOPREM	411100147				15	PISTA HR+ NOIR ROUGE 124 cc	1	3980	19%	0	4736.2	3980	756.2	4736.2	1776955637000
132	131	26/000033	26/000034	2026-03-02	HADJ SALEM Karim	STE SOPREM	411100147				20	PISTA HR+ BLEU BEIGE 124 cc	1	3980	19%	0	4736.2	3980	756.2	4736.2	1776955637000
133	131	26/000033	26/000034	2026-03-02	HADJ SALEM Karim	STE SOPREM	411100147				21	PISTA HR+ ROUGE NOIRE 124 cc	1	3980	19%	0	4736.2	3980	756.2	4736.2	1776955637000
134	131	26/000033	26/000034	2026-03-02	HADJ SALEM Karim	STE SOPREM	411100147				22	PISTA HR+ CARBONE ROUGE 124 cc	1	3980	19%	0	4736.2	3980	756.2	4736.2	1776955637000
135	132	26/000034	26/000035	2026-03-11	HADJ SALEM Karim	Bachir BALLOUMI	411100151				54	SPRING ST 124CC BLEU FONCE	1	3488	19%	0	4150.72	3488	662.72	4150.72	1776955637000
136	133	26/000035	26/000036	2026-03-11	HADJ SALEM Karim	Zaid BAILI	411100106				72	BLASTER GRIS 125cc	1	5799	19%	0	6900.81	5799	1101.81	6900.81	1776955637000
137	134	26/000036	26/000037	2026-03-12	HADJ SALEM Karim	Ahmed AAGRBI	411100152				104	FORZA POWER 124CC BLEU	1	2520	19%	0	2998.8	2520	478.8	2998.8	1776955637000
138	135	26/000037	26/000038	2026-03-12	HADJ SALEM Karim	Taieb KACHOUB	411100153				71	BLASTER VERT 125cc	1	5800	19%	0	6902	5800	1102	6902	1776955637000
139	136	26/000038	26/000039	2026-03-13	HADJ SALEM Karim	Fares BOUKARI	411100160				73	BLASTER NOIR 125cc	1	5799	19%	0	6900.81	5799	1101.81	6900.81	1776955637000
140	137	26/000039	26/000040	2026-03-16	HADJ SALEM Karim	STE SOTUCHOC	411100105				14	PISTA HR+ VERT MARRON 124 cc	1	3990	19%	0	4748.1	3990	758.1	4748.1	1776955637000
141	137	26/000039	26/000040	2026-03-16	HADJ SALEM Karim	STE SOTUCHOC	411100105				15	PISTA HR+ NOIR ROUGE 124 cc	1	3990	19%	0	4748.1	3990	758.1	4748.1	1776955637000
142	137	26/000039	26/000040	2026-03-16	HADJ SALEM Karim	STE SOTUCHOC	411100105				20	PISTA HR+ BLEU BEIGE 124 cc	1	3990	19%	0	4748.1	3990	758.1	4748.1	1776955637000
143	138	26/000040	26/000041	2026-03-19	HADJ SALEM Karim	Mohamed Amine BEN SALAH	411100156				54	SPRING ST 124CC BLEU FONCE	1	3530	19%	0	4200.7	3530	670.7	4200.7	1776955637000
144	139	26/000041	26/000042	2026-03-24	HADJ SALEM Karim	Ali RIAHI	411100157				105	FORZA POWER 124CC GRIS	1	2563	19%	0	3049.97	2563	486.97	3049.97	1776955637000
145	140	26/000042	26/000043	2026-03-26	HADJ SALEM Karim	Ayoub ALMAHMOUDI	411100158				54	SPRING ST 124CC BLEU FONCE	1	3613	19%	0	4299.47	3613	686.47	4299.47	1776955637000
146	141	26/000043	26/000044	2026-03-30	HADJ SALEM Karim	STE SOPREM	411100147				927	CASQUE MT HELMETS GLOSS -Taille L	4	230	19%	0	1094.8	920	174.8	1094.8	1776955637000
147	142	26/000044	26/000045	2026-04-06	HADJ SALEM Karim	Sami ESSID	411100016				105	FORZA POWER 124CC GRIS	1	2521	19%	0	3000.109	2521.1	479.009	3000.109	1776955637000
148	143	26/000045	26/000046	2026-04-07	HADJ SALEM Karim	STE SOPREM	411100147				500	HUILE MOTOS 10W40	24	16.5	19%%	0	471.24	396	75.24	471.24	1776955637000
149	144	26/000046	26/000048	2026-04-18	HADJ SALEM Karim	Yassine RIAHI	411100112				18	PISTA HR VERT JAUNE 107 CC	1	3697.5	19%	0	4400.025	3697.5	702.525	4400.025	1776955637000
\.


--
-- Data for Name: factures; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.factures (id, facture_number, bon_ref, date, commercial, client_id, client_name, id_client, matricule_fiscal, adresse_client, phone_client, status, created_at) FROM stdin;
1	25/000001	25/000001	2025-06-16	HADJ SALEM Karim	155	ZIED BOUAFIA	411100004				validated	1776955635000
2	25/000002	25/000002	2025-06-17	HADJ SALEM Karim	156	MED MAROUEN EL HAJRI	411100005				validated	1776955635000
3	25/000003	25/000003	2025-06-17	HADJ SALEM Karim	154	STE AKRAM DE COMMERCE ET SERVICES	411100003				validated	1776955635000
4	25/000004	25/000004	2025-06-19	HADJ SALEM Karim	152	EMEB	411100001				validated	1776955635000
5	25/000005	25/000005	2025-06-19	HADJ SALEM Karim	153	DARDOUR ET COMPAGNIE SDC	411100002				validated	1776955635000
6	25/000006	25/000006	2025-06-21	HADJ SALEM Karim	157	ALI CHEBBI	411100006				validated	1776955635000
7	25/000007	25/000007	2025-06-21	HADJ SALEM Karim	158	OUSSEMA BEN AISSA	411100007				validated	1776955635000
8	25/000008	25/000008	2025-06-21	HADJ SALEM Karim	159	MALEK JBELI	411100008				validated	1776955635000
9	25/000009	25/000009	2025-06-22	HADJ SALEM Karim	160	MOUJIB ALLAH EL JENDOUBI	411100009				validated	1776955635000
10	25/000010	25/000010	2025-06-22	HADJ SALEM Karim	161	MOHAMED HAMROUNI	411100010				validated	1776955635000
11	25/000011	25/000011	2025-06-25	HADJ SALEM Karim	162	AZIZA ABIDI	411100011				validated	1776955635000
12	25/000012	25/000012	2025-06-30	HADJ SALEM Karim	163	DHAKER KHADRAOUI	411100012				validated	1776955635000
13	25/000013	25/000013	2025-01-07	HADJ SALEM Karim	164	MOHAMED SNOUN	411100013				validated	1776955635000
14	25/000014	25/000014	2025-03-07	HADJ SALEM Karim	165	IBRAHIM ABID	411100014				validated	1776955635000
15	25/000015	25/000015	2025-10-07	HADJ SALEM Karim	166	Mourad GHRAIRI	411100015				validated	1776955635000
16	25/000016	25/000016	2025-10-07	HADJ SALEM Karim	167	Sami ESSID	411100016				validated	1776955635000
17	25/000017	25/000017	2025-11-07	HADJ SALEM Karim	168	HASSEN ARFAOUI	411100017				validated	1776955635000
18	25/000018	25/000018	2025-12-07	HADJ SALEM Karim	169	Jamel AAROURI	411100018				validated	1776955635000
19	25/000019	25/000019	2025-12-07	HADJ SALEM Karim	170	Ahmed FARHAT	411100019				validated	1776955635000
20	25/000020	25/000020	2025-07-14	HADJ SALEM Karim	171	Abdelhmid CHAOUATI	411100020				validated	1776955635000
21	25/000021	25/000021	2025-07-15	HADJ SALEM Karim	173	Nader CHAOUACHI	411100022				validated	1776955635000
22	25/000022	25/000022	2025-07-24	HADJ SALEM Karim	174	Nizar SALHI	411100023				validated	1776955635000
23	25/000023	25/000023	2025-07-16	HADJ SALEM Karim	175	Hssan HARWAK	411100024				validated	1776955635000
24	25/000024	25/000024	2025-07-17	HADJ SALEM Karim	176	Youssef BEN YOUNES	411100025				validated	1776955635000
25	25/000025	25/000025	2025-07-16	HADJ SALEM Karim	177	Wahid LABIDI	411100026				validated	1776955635000
26	25/000026	25/000026	2025-07-19	HADJ SALEM Karim	178	Mokhtar NAHHALI	411100027				validated	1776955635000
27	25/000027	25/000027	2025-07-20	HADJ SALEM Karim	191	Fathia DHAHRI	411100040				validated	1776955635000
28	25/000028	25/000028	2025-07-22	HADJ SALEM Karim	181	Abdelkader HEDFI	411100030				validated	1776955635000
29	25/000029	25/000029	2025-07-23	HADJ SALEM Karim	182	Naoufel EL HAMZI	411100031				validated	1776955635000
30	25/000030	25/000030	2025-07-23	HADJ SALEM Karim	172	STE MGF	411100021				validated	1776955635000
31	25/000031	25/000031	2025-07-26	HADJ SALEM Karim	183	Abdelkrim BEN MAATOUG	411100032				validated	1776955635000
32	25/000032	25/000032	2025-07-31	HADJ SALEM Karim	184	Ahmed TRABELSI	411100033				validated	1776955635000
33	25/000033	25/000033	2025-05-08	HADJ SALEM Karim	186	Hassen KASDAOUI	411100035				validated	1776955635000
34	25/000034	25/000034	2025-02-08	HADJ SALEM Karim	189	Mustapha ZOUAGHI	411100038				validated	1776955636000
35	25/000035	25/000035	2025-02-08	HADJ SALEM Karim	188	Souhail BEN REJEB	411100037				validated	1776955636000
36	25/000036	25/000036	2025-06-08	HADJ SALEM Karim	192	Adel IBN EL ASOUED	411100041				validated	1776955636000
37	25/000037	25/000037	2025-11-08	HADJ SALEM Karim	194	Bilel AHMED	411100043				validated	1776955636000
38	25/000038	25/000038	2025-08-16	HADJ SALEM Karim	196	Ghassen BALTI	411100045				validated	1776955636000
39	25/000039	25/000039	2025-08-18	HADJ SALEM Karim	197	Moez JBELI	411100046				validated	1776955636000
40	25/000040	25/000040	2025-08-18	HADJ SALEM Karim	198	Mohamed DAOUTHI	411100047				validated	1776955636000
41	25/000041	25/000041	2025-08-21	HADJ SALEM Karim	201	STE TUNISIENNE DE DISTRIBUTION DES PRODUITS	411100050				validated	1776955636000
42	25/000042	25/000042	2025-08-21	HADJ SALEM Karim	202	Sami BEN DHAW	411100051				validated	1776955636000
43	25/000043	25/000043	2025-08-21	HADJ SALEM Karim	203	Foued EL AALLAGUI	411100052				validated	1776955636000
44	25/000044	25/000044	2025-08-23	HADJ SALEM Karim	205	Kais KASDAOUI	411100054				validated	1776955636000
45	25/000045	25/000045	2025-08-25	HADJ SALEM Karim	207	Mohamed AZIZ KESIBI	411100056				validated	1776955636000
46	25/000046	25/000046	2025-08-25	HADJ SALEM Karim	208	Kamel JELASSI	411100057				validated	1776955636000
47	25/000047	25/000047	2025-08-30	HADJ SALEM Karim	209	Sadok SALHI	411100058				validated	1776955636000
48	25/000048	25/000048	2025-01-09	HADJ SALEM Karim	210	Khmais DRIDI	411100059				validated	1776955636000
49	25/000049	25/000049	2025-03-09	HADJ SALEM Karim	211	Adem BEN HSSIN	411100060				validated	1776955636000
50	25/000050	25/000050	2025-08-09	HADJ SALEM Karim	212	Zied MLOUH	411100061				validated	1776955636000
51	25/000051	25/000051	2025-08-09	HADJ SALEM Karim	301	Hajer NAFFETI	411100150				validated	1776955636000
52	25/000052	25/000052	2025-11-09	HADJ SALEM Karim	216	Yosri MAHWACHI	411100065				validated	1776955636000
53	25/000085	25/000053	2025-09-18	HADJ SALEM Karim	217	Skander BEN MRIDA	411100066				validated	1776955636000
54	25/000053	25/000054	2025-09-19	HADJ SALEM Karim	218	Abderrazek EL AJIMI	411100067				validated	1776955636000
55	25/000070	25/000055	2025-09-19	HADJ SALEM Karim	219	AALIA SAMIA	411100068				validated	1776955636000
56	25/000054	25/000056	2025-09-22	HADJ SALEM Karim	220	Nassima THAMRI	411100069				validated	1776955636000
57	25/000055	25/000057	2025-09-23	HADJ SALEM Karim	221	STE LE CLUB	411100070				validated	1776955636000
58	25/000056	25/000058	2025-09-23	HADJ SALEM Karim	222	HASANINE REBII	411100071				validated	1776955636000
59	25/000057	25/000059	2025-09-24	HADJ SALEM Karim	223	Mahdi SASSI	411100072				validated	1776955636000
60	25/000058	25/000060	2025-09-24	HADJ SALEM Karim	225	SOCIETE WAFRA AGRICOLE SWA	411100074				validated	1776955636000
61	25/000059	25/000061	2025-09-25	HADJ SALEM Karim	226	MOHAMED EL AMDOUNI	411100075				validated	1776955636000
62	25/000060	25/000062	2025-09-25	HADJ SALEM Karim	224	Achref GHARBI	411100073				validated	1776955636000
63	25/000061	25/000063	2025-09-26	HADJ SALEM Karim	227	STE TULIPE TECHNOLOGY	411100076				validated	1776955636000
64	25/000062	25/000064	2025-09-29	HADJ SALEM Karim	229	Abderrazek ARAARI	411100078				validated	1776955636000
65	25/000063	25/000065	2025-09-30	HADJ SALEM Karim	182	Naoufel EL HAMZI	411100031				validated	1776955636000
66	25/000064	25/000066	2025-06-10	HADJ SALEM Karim	232	Med Ayoub GOUADER	411100081				validated	1776955636000
67	25/000065	25/000067	2025-06-10	HADJ SALEM Karim	233	Wassim ABBESSI	411100082				validated	1776955636000
68	25/000066	25/000068	2025-08-10	HADJ SALEM Karim	234	Fraj BOUKHRIS	411100083				validated	1776955636000
69	25/000067	25/000069	2025-08-10	HADJ SALEM Karim	235	MED Amine EL FRADI	411100084				validated	1776955636000
70	25/000068	25/000070	2025-10-13	HADJ SALEM Karim	237	Fraj BEN AMMAR	411100086				validated	1776955636000
71	25/000069	25/000071	2025-10-22	HADJ SALEM Karim	239	Ahmed KANZARI	411100088				validated	1776955636000
72	25/000071	25/000072	2025-10-27	HADJ SALEM Karim	240	MED ADNENE CHAMTOURI	411100089				validated	1776955636000
73	25/000072	25/000073	2025-10-28	HADJ SALEM Karim	241	Fawzi TLILI	411100090				validated	1776955636000
74	25/000073	25/000074	2025-06-11	HADJ SALEM Karim	244	Skander SHILI	411100093				validated	1776955636000
75	25/000074	25/000075	2025-10-11	HADJ SALEM Karim	245	Mohamed RAYEN MATHLOUTHI	411100094				validated	1776955636000
76	25/000075	25/000076	2025-08-11	HADJ SALEM Karim	246	Mohamed Ali EL GHRAIRI	411100095				validated	1776955636000
77	25/000076	25/000077	2025-10-11	HADJ SALEM Karim	247	Abd Raouf EL MELHMI	411100096				validated	1776955636000
78	25/000077	25/000078	2025-10-11	HADJ SALEM Karim	248	Bilel MANNAII	411100097				validated	1776955636000
79	25/000078	25/000079	2025-10-11	HADJ SALEM Karim	249	Iyed EL HAMADI	411100098				validated	1776955636000
80	25/000079	25/000080	2025-10-11	HADJ SALEM Karim	250	Ahmed WERGHEMI	411100099				validated	1776955636000
81	25/000080	25/000081	2025-11-14	HADJ SALEM Karim	253	Mohamed AZIZ SAADAOUI	411100102				validated	1776955636000
82	25/000081	25/000082	2025-11-17	HADJ SALEM Karim	154	STE AKRAM DE COMMERCE ET SERICES	411100003				validated	1776955636000
83	25/000082	25/000083	2025-11-17	HADJ SALEM Karim	244	Skander SHILI	411100093				validated	1776955636000
84	25/000083	25/000084	2025-11-18	HADJ SALEM Karim	254	Omar FERGENI	411100103				validated	1776955636000
85	25/000084	25/000085	2025-11-20	HADJ SALEM Karim	255	Seifeddine BEN ZEKRI	411100104				validated	1776955636000
86	25/000086	25/000086	2025-11-25	HADJ SALEM Karim	257	Zaid BAILI	411100106				validated	1776955636000
87	25/000087	25/000087	2025-11-25	HADJ SALEM Karim	257	Zaid BAILI	411100106				validated	1776955636000
88	25/000088	25/000088	2025-04-12	HADJ SALEM Karim	258	Moataz BOUAADILA	411100107				validated	1776955636000
89	25/000089	25/000089	2025-09-12	HADJ SALEM Karim	245	Mohamed RAYEN MATHLOUTHI	411100094				validated	1776955636000
90	25/000090	25/000090	2025-12-15	HADJ SALEM Karim	259	Ihsen LARIANI	411100108				validated	1776955636000
91	25/000091	25/000091	2025-12-16	HADJ SALEM Karim	260	Kais HADDAGI	411100109				validated	1776955636000
92	25/000092	25/000092	2025-12-19	HADJ SALEM Karim	262	Idriss HMADA	411100111				validated	1776955636000
93	25/000093	25/000093	2025-12-19	HADJ SALEM Karim	263	Yassine RIAHI	411100112				validated	1776955636000
94	25/000094	25/000094	2025-12-20	HADJ SALEM Karim	258	Moataz BOUAADILA	411100107				validated	1776955636000
95	25/000095	25/000095	2025-12-22	HADJ SALEM Karim	264	Abdessalem BOUSEDRA	411100113				validated	1776955636000
96	25/000096	25/000096	2025-12-22	HADJ SALEM Karim	265	Wissem ROMDHANI	411100114				validated	1776955636000
97	25/000097	25/000097	2025-12-24	HADJ SALEM Karim	266	Saida FAZAII	411100115				validated	1776955637000
98	25/000098	25/000098	2025-12-29	HADJ SALEM Karim	267	Mohamed AZIZ BEN AHMED	411100116				validated	1776955637000
99	26/000001	25/000099	2026-02-01	HADJ SALEM Karim	244	Skander SHILI	411100093				validated	1776955637000
100	26/000002	26/000001	2026-02-01	HADJ SALEM Karim	244	Skander SHILI	411100093				validated	1776955637000
101	26/000003	26/000002	2026-05-01	HADJ SALEM Karim	260	Kais HADDAGI	411100109				validated	1776955637000
102	26/000004	26/000003	2026-09-01	HADJ SALEM Karim	269	Ramzi BALOUTI	411100118				validated	1776955637000
103	26/000005	26/000004	2026-09-01	HADJ SALEM Karim	270	Walid BENCHIKH	411100119				validated	1776955637000
104	26/000006	26/000005	2026-01-13	HADJ SALEM Karim	259	Ihsen LARIANI	411100108				validated	1776955637000
105	26/000007	26/000006	2026-01-14	HADJ SALEM Karim	271	Lassaad GOUIDER	411100120				validated	1776955637000
106	26/000008	26/000007	2026-01-15	HADJ SALEM Karim	244	Skander SHILI	411100093				validated	1776955637000
107	26/000009	26/000008	2026-01-22	HADJ SALEM Karim	273	Alae NAJEM	411100122				validated	1776955637000
108	26/000010	26/000009	2026-01-26	HADJ SALEM Karim	274	Mohamed Aziz DALLAJI	411100123				validated	1776955637000
109	26/000011	26/000011	2026-01-26	HADJ SALEM Karim	275	Hamza HASSNAOUI	411100124				validated	1776955637000
110	26/000012	26/000012	2026-01-27	HADJ SALEM Karim	276	Mohamed Slim ABID	411100125				validated	1776955637000
111	26/000013	26/000013	2026-01-28	HADJ SALEM Karim	278	Saber BADR	411100127				validated	1776955637000
112	26/000014	26/000014	2026-02-03	HADJ SALEM Karim	279	NIZAR BOU DHAOWIA	411100128				validated	1776955637000
113	26/000015	26/000015	2026-02-06	HADJ SALEM Karim	263	Yassine RIAHI	411100112				validated	1776955637000
114	26/000016	26/000016	2026-02-07	HADJ SALEM Karim	280	Amir KIRAT	411100129				validated	1776955637000
115	26/000017	26/000017	2026-02-07	HADJ SALEM Karim	281	Mohamed Ali NASRALLAH	411100130				validated	1776955637000
116	26/000018	26/000018	2026-02-10	HADJ SALEM Karim	282	Iptissem MANSOURI	411100131				validated	1776955637000
117	26/000019	26/000019	2026-02-10	HADJ SALEM Karim	283	Ali HATHROUBI	411100132				validated	1776955637000
118	26/000020	26/000020	2026-02-11	HADJ SALEM Karim	284	CharfE Eddin ALAAMRI	411100133				validated	1776955637000
119	26/000021	26/000021	2026-02-16	HADJ SALEM Karim	288	Hazem BEN AALAYET	411100137				validated	1776955637000
120	26/000022	26/000022	2026-02-17	HADJ SALEM Karim	286	Protest Engineering	411100135				validated	1776955637000
121	26/000023	26/000023	2026-02-17	HADJ SALEM Karim	286	Protest Engineering	411100135				validated	1776955637000
122	26/000024	26/000025	2026-02-17	HADJ SALEM Karim	211	Adem BEN HSSIN	411100060				validated	1776955637000
123	26/000025	26/000026	2026-02-18	HADJ SALEM Karim	291	Aniss TIAHI	411100140				validated	1776955637000
124	26/000026	26/000027	2026-02-18	HADJ SALEM Karim	292	Kilani FERCHICHI	411100141				validated	1776955637000
125	26/000027	26/000028	2026-02-18	HADJ SALEM Karim	293	Bilel GHRAIRI	411100142				validated	1776955637000
126	26/000028	26/000029	2026-02-19	HADJ SALEM Karim	294	Issam NAWALI	411100143				validated	1776955637000
127	26/000029	26/000030	2026-02-19	HADJ SALEM Karim	289	Hajer MOHSEN	411100138				validated	1776955637000
128	26/000030	26/000031	2026-02-23	HADJ SALEM Karim	290	FSIC	411100139				validated	1776955637000
129	26/000031	26/000032	2026-02-21	HADJ SALEM Karim	296	STE GREPSYS	411100145				validated	1776955637000
130	26/000032	26/000033	2026-02-25	HADJ SALEM Karim	300	Anouar ABDALLAH	411100149				validated	1776955637000
131	26/000033	26/000034	2026-03-02	HADJ SALEM Karim	298	STE SOPREM	411100147				validated	1776955637000
132	26/000034	26/000035	2026-03-11	HADJ SALEM Karim	308	Bachir BALLOUMI	411100151				validated	1776955637000
133	26/000035	26/000036	2026-03-11	HADJ SALEM Karim	257	Zaid BAILI	411100106				validated	1776955637000
134	26/000036	26/000037	2026-03-12	HADJ SALEM Karim	309	Ahmed AAGRBI	411100152				validated	1776955637000
135	26/000037	26/000038	2026-03-12	HADJ SALEM Karim	310	Taieb KACHOUB	411100153				validated	1776955637000
136	26/000038	26/000039	2026-03-13	HADJ SALEM Karim	317	Fares BOUKARI	411100160				validated	1776955637000
137	26/000039	26/000040	2026-03-16	HADJ SALEM Karim	256	STE SOTUCHOC	411100105				validated	1776955637000
138	26/000040	26/000041	2026-03-19	HADJ SALEM Karim	313	Mohamed Amine BEN SALAH	411100156				validated	1776955637000
139	26/000041	26/000042	2026-03-24	HADJ SALEM Karim	314	Ali RIAHI	411100157				validated	1776955637000
140	26/000042	26/000043	2026-03-26	HADJ SALEM Karim	315	Ayoub ALMAHMOUDI	411100158				validated	1776955637000
141	26/000043	26/000044	2026-03-30	HADJ SALEM Karim	298	STE SOPREM	411100147				validated	1776955637000
142	26/000044	26/000045	2026-04-06	HADJ SALEM Karim	167	Sami ESSID	411100016				validated	1776955637000
143	26/000045	26/000046	2026-04-07	HADJ SALEM Karim	298	STE SOPREM	411100147				validated	1776955637000
144	26/000046	26/000048	2026-04-18	HADJ SALEM Karim	263	Yassine RIAHI	411100112				validated	1776955637000
\.


--
-- Data for Name: helmet_purchases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.helmet_purchases (id, date, designation, quantite, fournisseur, prix, created_at) FROM stdin;
1	2025-07-10	CASQUE LS2 AIRFLOW GLOSS -Taille L	2		0	1772271148000
2	2025-07-10	CASQUE LS2 AIRFLOW MATT-Taille XXL	1		0	1772271182000
3	2025-07-11	CASQUE LS2 AIRFLOW MATT-Taille L	1		0	1772271210000
4	2025-07-10	CASQUE LS2 AIRFLOW MATT-Taille M	1		0	1772271231000
5	2025-07-10	CASQUE MT Taille M MATT	1		0	1772271420000
6	2025-07-10	CASQUE MT Taille L MATT	1		0	1772271478000
7	2025-10-07	CASQUE MT Taille L GLOSS	5		0	1772271558000
8	2026-02-28	CASQUE MT Taille XL GLOSS	2		0	1772271590000
9	2025-07-10	CASQUE LS2 AIRFLOW GLOSS -Taille M	1		0	1772271660000
11	2025-07-10	CASQUE TNL Gris-Taille XL	1		0	1772272185000
12	2025-07-10	CASQUE TNL Gris-Taille L	4		0	1772272261000
13	2025-07-10	CASQUE TNL Noir-Taille XL	2		0	1772272294000
14	2025-07-10	CASQUE TNL Noir-Taille L	1		0	1772272307000
\.


--
-- Data for Name: helmet_sales; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.helmet_sales (id, numero_facture, date, designation, type_client, nom_prenom, quantite, montant, remarque, confirmed_by_staff, confirmed_by_manager, calculation_timestamp, amount_handed, created_at) FROM stdin;
1	25/000081	2025-11-17	CASQUE LS2 AIRFLOW MATT-Taille XXL	B2B	STE AKRAM DE COMMERCE ET SERVICES	1	385		\N	\N	\N	0	1772196129000
2	25/000082	2025-11-17	CASQUE LS2 AIRFLOW GLOSS -Taille L	B2C	Skander SHILI	1	375		\N	\N	\N	0	1772196129000
3	25/000087	2025-11-25	CASQUE LS2 AIRFLOW MATT-Taille L	B2C	Zaid BAILI	1	350		\N	\N	\N	0	1772196129000
4	25/000089	2025-12-09	CASQUE LS2 AIRFLOW GLOSS -Taille L	B2C	Mohamed RAYEN MATHLOUTHI	1	385		\N	\N	\N	0	1772196129000
5	25/000094	2025-12-20	CASQUE LS2 AIRFLOW MATT-Taille M	B2C	Moataz BOUAADILA	1	375		\N	\N	\N	0	1772196129000
6	26/000002	2026-01-02	CASQUE MT Taille M MATT	B2C	Skander SHILI	1	275		\N	\N	\N	0	1772196129000
7	1	2026-02-07	CASQUE TNL Gris-Taille XL	B2C	Mohamed Ali NASRALLAH	1	140		\N	\N	\N	0	1772196129000
8	2	2026-02-11	CASQUE TNL Noir-Taille L	B2B	Charef Eddin ALAAMRI	1	148	Credit	\N	\N	\N	0	1772196129000
9	3	2026-02-14	CASQUE TNL Noir-Taille XL	B2B	Dhia Bouaadila	1	148	70+20+40 Rest 18	\N	\N	\N	0	1772196129000
10	26/000021	2026-02-16	CASQUE TNL Gris-Taille L	B2B	Hazem BEN AALAYET	1	148		\N	\N	\N	0	1772196129000
11	26/000023	2026-02-17	CASQUE TNL Gris-Taille L	B2C	Protest Engineering	1	148		\N	\N	\N	0	1772272343000
12	4	2026-02-18	CASQUE TNL Gris-Taille L	B2C	Iptissem MANSOURI	1	148	80 avance reste 68	\N	\N	\N	0	1772272413000
13	5	2026-02-18	CASQUE TNL Noir-Taille XL	B2C	        Kilani FERCHICHI	1	148		\N	\N	\N	0	1772272466000
14	26/000030	2026-02-23	CASQUE TNL Gris-Taille L	B2C	FSIC	1	148		YASSIN	KARIM	1773137804594	0	1772272534000
15	6	2026-03-07	CASQUE LS2 AIRFLOW GLOSS -Taille M	B2C	Hajer NAFFETI	1	385	Credit Baaed l3id	\N	\N	\N	0	1772889361000
16	26/000043	2026-03-30	CASQUE MT Taille L GLOSS	B2B	STE SOPREM	4	1095.8	Mode Paiement Chèque	YASSIN	KARIM	1774969929701	153	1774876254000
\.


--
-- Data for Name: livraison_lines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.livraison_lines (id, livraison_id, product_serial_id, product_id, ref, designation, serial_number, prix, tva_pct, remise, prix_ttc, montant_ht, montant_tva, montant_ttc, created_at) FROM stdin;
1	1	1	1	007	PISTA VCX NOIRE NOIRE	LCS4BGN60S1E00784	3445	19	0	4099.55	3445	654.55	4099.55	1776955635000
2	2	2	2	151	GHOST V7 124CC BLEUE JAUNE	LEHTCJ015RRM00155	4874	19	0	5800.06	4874	926.06	5800.06	1776955635000
3	3	3	3	050	SPRING ST 124CC VERT PISTACHE	LYFXCJL07R7001152	3446	19	0	4100.74	3446	654.74	4100.74	1776955635000
4	4	4	1	007	PISTA VCX NOIRE NOIRE	LCS4BGN69S1E00783	3490	19	0	4153.1	3490	663.1	4153.1	1776955635000
5	5	5	3	050	SPRING ST 124CC VERT PISTACHE	LYFXCJL00R7001137	3405	19	0	4051.95	3405	646.95	4051.95	1776955635000
6	6	6	4	101	FORZA POWER 107CC GRIS	LC4XCHL02R0D03351	2353	19	0	2800.07	2353	447.07	2800.07	1776955635000
7	7	7	5	003	PISTA VCX VERT PISTACHE	LCS4BGN69S1E00749	3445	19	0	4099.55	3445	654.55	4099.55	1776955635000
8	8	8	6	150	GHOST V7 124CC VERT NOIRE	LEHTCJ014RRM00003	4840	19	0	5759.6	4840	919.6	5759.6	1776955635000
9	9	9	7	052	SPRING ST 124CC BLEUE CIEL	LYFXCJL08R7001015	3403	19	0	4049.57	3403	646.57	4049.57	1776955635000
10	10	10	8	102	FORZA POWER 107CC NOIRE	LC4XCHL05R0D03604	2353	19	0	2800.07	2353	447.07	2800.07	1776955635000
11	11	11	2	151	GHOST V7 124CC BLEUE JAUNE	LEHTCJ015RRM00141	4775	19	0	5682.25	4775	907.25	5682.25	1776955635000
12	12	12	9	008	PISTA VCX BLANC NOIRE	LCS4BGN65S1E00697	3445	19	0	4099.55	3445	654.55	4099.55	1776955635000
13	13	13	9	008	PISTA VCX BLANC NOIRE	LCS4BGN65S1E00702	3445	19	0	4099.55	3445	654.55	4099.55	1776955635000
14	14	14	10	051	SPRING ST 124CC JAUNE NOIRE	LYFCXJL02R7001429	3361	19	0	3999.59	3361	638.59	3999.59	1776955635000
15	15	15	5	003	PISTA VCX VERT PISTACHE	LCS4BGN69S1E00752	3445	19	0	4099.55	3445	654.55	4099.55	1776955635000
16	16	16	4	101	FORZA POWER 107CC GRIS	LC4XCHL01R0D03339	2353	19	0	2800.07	2353	447.07	2800.07	1776955635000
17	17	17	8	102	FORZA POWER 107CC NOIRE	LC4XCHL03R0D03665	2395	19	0	2850.05	2395	455.05	2850.05	1776955635000
18	18	18	11	005	PISTA VCX BLEUE JAUNE	LCS4BGN68S1E00533	3445	19	0	4099.55	3445	654.55	4099.55	1776955635000
19	19	19	12	152	GHOST V7 124CC NOIRE	LEHTCJ011RRM00413	4958	19	0	5900.02	4958	942.02	5900.02	1776955635000
20	20	20	7	052	SPRING ST 124CC BLEUE CIEL	LYFXCJL04R7001030	3446	19	0	4100.74	3446	654.74	4100.74	1776955635000
21	21	21	13	002	PISTA VCX VERT NOIRE	LCS4BGN62S1E00768	3530	19	0	4200.7	3530	670.7	4200.7	1776955635000
22	22	22	4	101	FORZA POWER 107CC GRIS	LC4XCHL02R0D03348	2353	19	0	2800.07	2353	447.07	2800.07	1776955635000
23	23	23	8	102	FORZA POWER 107CC NOIRE	LC4XCHL0XR0D03646	2395	19	0	2850.05	2395	455.05	2850.05	1776955635000
24	24	24	14	100	FORZA POWER 107CC BLEUE	LC4XCHL08R0D03564	2395	19	0	2850.05	2395	455.05	2850.05	1776955635000
25	25	25	7	052	SPRING ST 124CC BLEUE CIEL	LYFXCJL04R7001013	3446	19	0	4100.74	3446	654.74	4100.74	1776955635000
26	26	26	2	151	GHOST V7 124CC BLEUE JAUNE	LEHTCJ016RRM00472	4932	19	0	5869.08	4932	937.08	5869.08	1776955635000
27	27	27	14	100	FORZA POWER 107CC BLEUE	LC4XCHL02R0D03592	2353	19	0	2800.07	2353	447.07	2800.07	1776955635000
28	28	28	8	102	FORZA POWER 107CC NOIRE	LC4XCHL00R0D03414	2353	19	0	2800.07	2353	447.07	2800.07	1776955635000
29	29	29	15	006	PISTA VCX BLEUE NOIRE	LSC4BGN67S1E00586	3488	19	0	4150.72	3488	662.72	4150.72	1776955635000
30	30	30	8	102	FORZA POWER 107CC NOIRE	LC4XCHL03S0D01355	2395	19	0	2850.05	2395	455.05	2850.05	1776955635000
31	31	31	7	052	SPRING ST 124CC BLEUE CIEL	LYFXCJL08R7001046	3403	19	0	4049.57	3403	646.57	4049.57	1776955635000
32	32	32	8	102	FORZA POWER 107CC NOIRE	LC4XCHL0XS0D00171	2353	19	0	2800.07	2353	447.07	2800.07	1776955635000
33	33	33	16	106	FORZA POWER 124CC NOIRE	LC4XCJL03S0D00732	2521	19	0	2999.99	2521	478.99	2999.99	1776955635000
34	34	34	4	101	FORZA POWER 107CC GRIS	LC4XCHL03S0D00058	2345	19	0	2790.55	2345	445.55	2790.55	1776955636000
35	35	35	2	151	GHOST V7 124CC BLEUE JAUNE	LEHTCJ014RRM00471	4958	19	0	5900.02	4958	942.02	5900.02	1776955636000
36	36	36	17	153	GHOST V7 124CC GRIS BLEU	LEHTCJ014RRM00311	4958	19	0	5900.02	4958	942.02	5900.02	1776955636000
37	37	37	3	050	SPRING ST 124CC VERT PISTACHE	LYFXCJL00R7001140	3360	19	0	3998.4	3360	638.4	3998.4	1776955636000
38	38	38	13	002	PISTA VCX VERT NOIRE	LCS4BGN61S1E00762	3487	19	0	4149.53	3487	662.53	4149.53	1776955636000
39	39	39	6	150	GHOST V7 124CC VERT NOIRE	LEHTCJ012RRM00064	4958	19	0	5900.02	4958	942.02	5900.02	1776955636000
40	40	40	18	107	FORZA POWER 124CC ROUGE	LC4XCJL06S0D00627	2521	19	0	2999.99	2521	478.99	2999.99	1776955636000
41	41	41	15	006	PISTA VCX BLEUE NOIRE	LSC4BGN66S1E00708	3487	19	0	4149.53	3487	662.53	4149.53	1776955636000
42	42	42	16	106	FORZA POWER 124CC NOIRE	LC4XCJL08S0D00712	2563	19	0	3049.97	2563	486.97	3049.97	1776955636000
43	43	43	7	052	SPRING ST 124CC BLEUE CIEL	LYFXCJL05R7001229	3530	19	0	4200.7	3530	670.7	4200.7	1776955636000
44	44	44	4	101	FORZA POWER 107CC GRIS	LC4XCHL08S0D00041	2437	19	0	2900.03	2437	463.03	2900.03	1776955636000
45	45	45	19	001	PISTA VCX ROUGE NOIRE	LCS4BGN68S1E00452	3487	19	0	4149.53	3487	662.53	4149.53	1776955636000
46	46	46	11	005	PISTA VCX BLEUE JAUNE	LCS4BGN6XS1E00520	3487	19	0	4149.53	3487	662.53	4149.53	1776955636000
47	47	47	20	004	PISTA VCX DORE NOIRE	LCS4BGN65S1E00134	3487	19	0	4149.53	3487	662.53	4149.53	1776955636000
48	48	48	8	102	FORZA POWER 107CC NOIRE	LC4XCHL04S0D00117	2395	19	0	2850.05	2395	455.05	2850.05	1776955636000
49	49	49	19	001	PISTA VCX ROUGE NOIRE	LCS4BGN63S1E00326	3488	19	0	4150.72	3488	662.72	4150.72	1776955636000
50	50	50	3	050	SPRING ST 124CC VERT PISTACHE	LYFXCJL08R7001337	3613	19	0	4299.47	3613	686.47	4299.47	1776955636000
51	51	51	7	052	SPRING ST 124CC BLEUE CIEL	LYFXCJL04R7001223	3613	19	0	4299.47	3613	686.47	4299.47	1776955636000
52	52	52	16	106	FORZA POWER 124CC NOIRE	LC4XCJL07S0D00779	2563	19	0	3049.97	2563	486.97	3049.97	1776955636000
53	53	53	21	004	PISTA VCX NOIRE NOIRE	LCS4BGN69S1E00539	3530	19	0	4200.7	3530	670.7	4200.7	1776955636000
54	54	54	3	050	SPRING ST 124CC VERT PISTACHE	LYFXCJL09R7001170	3529	19	0	4199.51	3529	670.51	4199.51	1776955636000
55	55	55	22	105	FORZA POWER 124CC GRIS	LC4XCJL02S0D00673	2650	19	0	3153.5	2650	503.5	3153.5	1776955636000
56	56	56	3	050	SPRING ST 124CC VERT PISTACHE	LYFXCJL08R7001306	3529	19	0	4199.51	3529	670.51	4199.51	1776955636000
57	57	57	23	12	PISTA HR+ NOIRE BLEU	LCS4BJN87S1700138	4033	19	0	4799.27	4033	766.27	4799.27	1776955636000
58	58	58	24	13	PISTA HR+ CARBONE	LCS4BJN88S1700259	3990	19	0	4748.1	3990	758.1	4748.1	1776955636000
59	59	59	8	102	FORZA POWER 107CC NOIRE	LC4XCHL06S0D00197	2395	19	0	2850.05	2395	455.05	2850.05	1776955636000
60	60	60	10	051	SPRING ST 124CC JAUNE NOIRE	LYFXCJL01R7001082	3739	19	0	4449.41	3739	710.41	4449.41	1776955636000
61	61	61	25	11	PISTA HR+ GRIS VERT	LCS4BJN81S1700037	4033	19	0	4799.27	4033	766.27	4799.27	1776955636000
62	62	62	7	052	SPRING ST 124CC BLEUE CIEL	LYFXCJL03R7001360	3613	19	0	4299.47	3613	686.47	4299.47	1776955636000
63	63	63	26	10	PISTA HR+ NOIRE MARRON	LCS4BJN84S1700209	3949	19	0	4699.31	3949	750.31	4699.31	1776955636000
64	64	64	27	9	PISTA HR+ VERT JAUNE	LCS4BJN88S1700083	4033	19	0	4799.27	4033	766.27	4799.27	1776955636000
65	65	65	7	052	SPRING ST 124CC BLEUE CIEL	LYFXCJL04R7001397	3571	19	0	4249.49	3571	678.49	4249.49	1776955636000
66	66	66	22	105	FORZA POWER 124CC GRIS	LC4XCJL00S0D00641	2563	19	0	3049.97	2563	486.97	3049.97	1776955636000
67	67	67	18	107	FORZA POWER 124CC ROUGE	LC4XCJL07S0D00622	2647	19	0	3149.93	2647	502.93	3149.93	1776955636000
68	68	68	8	102	FORZA POWER 107CC NOIRE	LC4XCHL09S0D00176	2370	19	0	2820.3	2370	450.3	2820.3	1776955636000
69	69	69	10	051	SPRING ST 124CC JAUNE NOIRE	LYFXCJL01R7001079	3530	19	0	4200.7	3530	670.7	4200.7	1776955636000
70	70	70	28	103	FORZA POWER 107CC ROUGE	LC4XCHL00S0D00003	2395	19	0	2850.05	2395	455.05	2850.05	1776955636000
71	71	71	29	017	PISTA HR NOIR / MARRON	LCS4BGN6XS1700491	3780	19	0	4498.2	3780	718.2	4498.2	1776955636000
72	72	72	14	100	FORZA POWER 107CC BLEUE	LC4XCHL06S0D00085	2479	19	0	2950.01	2479	471.01	2950.01	1776955636000
73	73	73	30	053	SPRING ST 124CC NOIR	LYFXCJL0XR7000657	3530	19	0	4200.7	3530	670.7	4200.7	1776955636000
74	74	74	31	054	SPRING ST 124CC BLEU FONCE	LYFXCJL03R7000595	3530	19	0	4200.7	3530	670.7	4200.7	1776955636000
75	75	75	30	053	SPRING ST 124CC NOIR	LYFXCJL09R7000956	3530	19	0	4200.7	3530	670.7	4200.7	1776955636000
76	76	76	32	055	SPRING ST 124CC VERT	LYFXCJL02R7000507	3530	19	0	4200.7	3530	670.7	4200.7	1776955636000
77	77	77	10	051	SPRING ST 124CC JAUNE NOIRE	LYFXCJL08R7001435	3613	19	0	4299.47	3613	686.47	4299.47	1776955636000
78	78	78	33	014	PISTA HR CARBON	LCS4BGN67S1700366	3740	19	0	4450.6	3740	710.6	4450.6	1776955636000
79	79	79	14	100	FORZA POWER 107CC BLEUE	LC4XCHL02S0D00083	2395	19	0	2850.05	2395	455.05	2850.05	1776955636000
80	80	80	34	104	FORZA POWER 124CC BLEU	LC4XCJL00S0D00686	2647	19	0	3149.93	2647	502.93	3149.93	1776955636000
81	81	81	27	9	PISTA HR+ VERT JAUNE	LCS4BJN88S1700665	3950	19	0	4700.5	3950	750.5	4700.5	1776955636000
82	82	\N	35	905	CASQUE LS2 AIRFLOW MATT-Taille XXL		324	19	0	385.56	324	61.56	385.56	1776955636000
83	83	\N	36	911	CASQUE LS2 AIRFLOW GLOSS -Taille L		324	19	0	385.56	324	61.56	385.56	1776955636000
84	84	82	25	11	PISTA HR+ GRIS VERT	LCS4BJN87S1700611	3950	19	0	4700.5	3950	750.5	4700.5	1776955636000
85	85	83	24	13	PISTA HR+ CARBONE	LCS4BJN84S1700792	3950	19	0	4700.5	3950	750.5	4700.5	1776955636000
86	86	84	26	10	PISTA HR+ NOIRE MARRON	LCS4BJN8XS1700781	3950	19	0	4700.5	3950	750.5	4700.5	1776955636000
87	87	\N	37	903	CASQUE LS2 AIRFLOW MATT-Taille XXL		294	19	0	349.86	294	55.86	349.86	1776955636000
88	88	85	38	016	PISTA HR NOIR / GRIS	LCS4BGN69S1700479	3697	19	0	4399.43	3697	702.43	4399.43	1776955636000
89	89	\N	36	911	CASQUE LS2 AIRFLOW GLOSS -Taille L		323.5	19	0	384.965	323.5	61.465	384.965	1776955636000
90	90	86	28	103	FORZA POWER 107CC ROUGE	LC4XCHL01S0D01239	2479	19	0	2950.01	2479	471.01	2950.01	1776955636000
91	91	87	18	107	FORZA POWER 124CC ROUGE	LC4XCJL01S0D01426	2647	19	0	3149.93	2647	502.93	3149.93	1776955636000
92	92	88	25	11	PISTA HR+ GRIS VERT	LCS4BJN84S1700596	4033	19	0	4799.27	4033	766.27	4799.27	1776955636000
93	93	89	8	102	FORZA POWER 107CC NOIRE	LC4XCHL06S0D01365	2479	19	0	2950.01	2479	471.01	2950.01	1776955636000
94	94	\N	39	902	CASQUE LS2 AIRFLOW MATT-Taille M		315	19	0	374.85	315	59.85	374.85	1776955636000
95	95	90	4	101	FORZA POWER 107CC GRIS	LC4XCHL00S0D01264	2478	19	0	2948.82	2478	470.82	2948.82	1776955636000
96	96	91	32	055	SPRING ST 124CC VERT	LYFXCJL0XR7000724	3613	19	0	4299.47	3613	686.47	4299.47	1776955637000
97	97	92	8	102	FORZA POWER 107CC NOIRE	LC4XCHL07S0D01357	2395	19	0	2850.05	2395	455.05	2850.05	1776955637000
98	98	93	23	12	PISTA HR+ NOIRE BLEU	LCS4BJN82S1700709	4033	19	0	4799.27	4033	766.27	4799.27	1776955637000
99	99	94	3	050	SPRING ST 124CC VERT PISTACHE	LYFXCJL04R7001125	3613	19	0	4299.47	3613	686.47	4299.47	1776955637000
100	100	\N	40	920	CASQUE MT HELMETS MATT-Taille L		231	19	0	274.89	231	43.89	274.89	1776955637000
101	101	95	4	101	FORZA POWER 107CC GRIS	LC4XCHL02S0D01248	2479	19	0	2950.01	2479	471.01	2950.01	1776955637000
102	102	96	16	106	FORZA POWER 124CC NOIRE	LC4XCJL0XS0D01733	2647	19	0	3149.93	2479	502.93	3149.93	1776955637000
103	103	97	41	55	SPRING ST 124CC VERT	LYFXCJL01R7000689	3613	19	0	4299.47	3613	686.47	4299.47	1776955637000
104	104	98	8	102	FORZA POWER 107CC NOIRE	LC4XCHL04S0D01364	2479	19	0	2950.01	2479	471.01	2950.01	1776955637000
105	105	99	41	55	SPRING ST 124CC VERT	LYFXCJL02R7000703	3614	19	0	4300.66	3614	686.66	4300.66	1776955637000
106	106	100	42	54	SPRING ST 124CC BLEU FONCE	LYFXCJL04R7000783	3613	19	0	4299.47	3613	686.47	4299.47	1776955637000
107	107	101	8	102	FORZA POWER 107CC NOIRE	LC4XCHL00S0D01345	2478	19	0	2948.82	2478	470.82	2948.82	1776955637000
108	108	102	23	12	PISTA HR+ NOIRE BLEU	LCS4BJN80S1700708	3992	19	0	4750.48	3992	758.48	4750.48	1776955637000
109	109	103	8	102	FORZA POWER 107CC NOIRE	LC4XCHL07S0D01374	2479	19	0	2950.01	2479	471.01	2950.01	1776955637000
110	110	104	27	9	PISTA HR+ VERT JAUNE	LCS4BJN84S1700663	3992	19	0	4750.48	3992	758.48	4750.48	1776955637000
111	111	105	43	14	PISTA HR CARBON	LCS4BGN69S1000624	3782	19	0	4500.58	3782	718.58	4500.58	1776955637000
112	112	106	14	100	FORZA POWER 107CC BLEUE	LC4XCHL09S0D01294	2479	19	0	2950.01	2479	471.01	2950.01	1776955637000
113	113	107	14	100	FORZA POWER 107CC BLEUE	LC4XCHL02S0D01301	2479	19	0	2950.01	2479	471.01	2950.01	1776955637000
114	114	108	44	16	PISTA HR NOIR / GRIS	LCS4BGN63S1000585	3782	19	0	4500.58	3782	718.58	4500.58	1776955637000
115	115	109	42	54	SPRING ST 124CC BLEU FONCE	LYFXCJL08R7000771	3488	19	0	4150.72	3488	662.72	4150.72	1776955637000
116	116	110	16	106	FORZA POWER 124CC NOIRE	LC4XCJL07S0D01821	2648	19	0	3151.12	2648	503.12	3151.12	1776955637000
117	117	111	16	106	FORZA POWER 124CC NOIRE	LC4XCJL08S0D01729	2564	19	0	3051.16	2564	487.16	3051.16	1776955637000
118	118	112	43	14	PISTA HR CARBON	LCS4BGN60S1700418	3782	19	0	4500.58	3782	718.58	4500.58	1776955637000
119	119	113	45	55	SPRING ST 124CC VERT + Casque TNL	LYFXCJL05R7000677	3612	19	0	4298.28	3612	686.28	4298.28	1776955637000
120	120	114	16	106	FORZA POWER 124CC NOIRE	LC4XCJL07S0D01768	2606	19	0	3101.14	2606	495.14	3101.14	1776955637000
121	121	\N	46	666A	Casque TNL		124	19	0	147.56	124	23.56	147.56	1776955637000
122	122	115	47	14	PISTA HR+ VERT MARRON	LCS4BJN81T1104041	4033	19	0	4799.27	4033	766.27	4799.27	1776955637000
123	123	116	48	21	PISTA HR+ ROUGE NOIRE	LCS4BJN8XT1103891	4033	19	0	4799.27	4033	766.27	4799.27	1776955637000
124	124	117	41	55	SPRING ST 124CC VERT	LYFXCJL08R7000690	3530	19	0	4200.7	3530	670.7	4200.7	1776955637000
125	125	118	24	13	PISTA HR+ CARBONE	LCS4BJN83T1104123	4033	19	0	4799.27	4033	766.27	4799.27	1776955637000
126	126	119	49	15	PISTA HR+ NOIR ROUGE	LCS4BJN8XT1104006	4033	19	0	4799.27	4033	766.27	4799.27	1776955637000
127	127	120	50	20	PISTA HR+ BLEU BEIGE	LCS4BJN8XT1103941	4033	19	0	4799.27	4033	766.27	4799.27	1776955637000
128	128	121	34	104	FORZA POWER 124CC BLEU	LC4XCJL01S0D00681	2661	19	0	3166.59	2661	505.59	3166.59	1776955637000
129	129	122	51	18	PISTA HR VERT JAUNE 107 CC	LCS4BGN64S1700549	3700	19	0	4403	3700	703	4403	1776955637000
130	130	123	42	54	SPRING ST 124CC BLEU FONCE	LYFXCJL02R7000751	3445	19	0	4099.55	3445	654.55	4099.55	1776955637000
131	131	124	52	15	PISTA HR+ NOIR ROUGE 124 cc	LCS4BJN8XT1103860	3980	19	0	4736.2	3980	756.2	4736.2	1776955637000
132	131	125	53	20	PISTA HR+ BLEU BEIGE 124 cc	LCS4BJN80T1103933	3980	19	0	4736.2	3980	756.2	4736.2	1776955637000
133	131	126	54	21	PISTA HR+ ROUGE NOIRE 124 cc	LCS4BJN86T1103886	3980	19	0	4736.2	3980	756.2	4736.2	1776955637000
134	131	127	55	22	PISTA HR+ CARBONE ROUGE 124 cc	LCS4BJN85T1103958	3980	19	0	4736.2	3980	756.2	4736.2	1776955637000
135	132	128	42	54	SPRING ST 124CC BLEU FONCE	LYFXCJL05R7000775	3488	19	0	4150.72	3488	662.72	4150.72	1776955637000
136	133	129	56	72	BLASTER GRIS 125cc	LEHTDJ041TRA00126	5799	19	0	6900.81	5799	1101.81	6900.81	1776955637000
137	134	130	34	104	FORZA POWER 124CC BLEU	LC4XCJL08S0D01486	2520	19	0	2998.8	2520	478.8	2998.8	1776955637000
138	135	131	57	71	BLASTER VERT 125cc	LEHTDJ04XTRA00089	5800	19	0	6902	5800	1102	6902	1776955637000
139	136	132	58	73	BLASTER NOIR 125cc	LEHTDJ042TRA00037	5799	19	0	6900.81	5799	1101.81	6900.81	1776955637000
140	137	133	59	14	PISTA HR+ VERT MARRON 124 cc	LCS4BJN82T1103917	3990	19	0	4748.1	3990	758.1	4748.1	1776955637000
141	137	134	52	15	PISTA HR+ NOIR ROUGE 124 cc	LCS4BJN85T1103863	3990	19	0	4748.1	3990	758.1	4748.1	1776955637000
142	137	135	53	20	PISTA HR+ BLEU BEIGE 124 cc	LCS4BJN82T1103951	3990	19	0	4748.1	3990	758.1	4748.1	1776955637000
143	138	136	42	54	SPRING ST 124CC BLEU FONCE	LYFXCJL08R7000768	3530	19	0	4200.7	3530	670.7	4200.7	1776955637000
144	139	137	22	105	FORZA POWER 124CC GRIS	LC4XCJL06S0D01485	2563	19	0	3049.97	2563	486.97	3049.97	1776955637000
145	140	138	42	54	SPRING ST 124CC BLEU FONCE	LYFXCJL0XR7000769	3613	19	0	4299.47	3613	686.47	4299.47	1776955637000
146	141	\N	60	927	CASQUE MT HELMETS GLOSS -Taille L		230	19	0	1094.8	920	174.8	1094.8	1776955637000
147	142	139	22	105	FORZA POWER 124CC GRIS	LC4XCJL00S0D01479	2521	19	0	3000.109	2521.1	479.009	3000.109	1776955637000
148	143	\N	61	500	HUILE MOTOS 10W40		16.5	19	0	471.24	396	75.24	471.24	1776955637000
149	144	140	51	18	PISTA HR VERT JAUNE 107 CC	LCS4BGN66S1000824	3697.5	19	0	4400.025	3697.5	702.525	4400.025	1776955637000
\.


--
-- Data for Name: livraisons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.livraisons (id, bon_number, date, commercial, client_id, client_name, id_client, status, facture_number, created_at) FROM stdin;
22	25/000022	2025-07-24	HADJ SALEM Karim	174	Nizar SALHI	411100023	validated	25/000022	1776955635000
23	25/000023	2025-07-16	HADJ SALEM Karim	175	Hssan HARWAK	411100024	validated	25/000023	1776955635000
24	25/000024	2025-07-17	HADJ SALEM Karim	176	Youssef BEN YOUNES	411100025	validated	25/000024	1776955635000
25	25/000025	2025-07-16	HADJ SALEM Karim	177	Wahid LABIDI	411100026	validated	25/000025	1776955635000
26	25/000026	2025-07-19	HADJ SALEM Karim	178	Mokhtar NAHHALI	411100027	validated	25/000026	1776955635000
27	25/000027	2025-07-20	HADJ SALEM Karim	191	Fathia DHAHRI	411100040	validated	25/000027	1776955635000
28	25/000028	2025-07-22	HADJ SALEM Karim	181	Abdelkader HEDFI	411100030	validated	25/000028	1776955635000
29	25/000029	2025-07-23	HADJ SALEM Karim	182	Naoufel EL HAMZI	411100031	validated	25/000029	1776955635000
30	25/000030	2025-07-23	HADJ SALEM Karim	172	STE MGF	411100021	validated	25/000030	1776955635000
31	25/000031	2025-07-26	HADJ SALEM Karim	183	Abdelkrim BEN MAATOUG	411100032	validated	25/000031	1776955635000
32	25/000032	2025-07-31	HADJ SALEM Karim	184	Ahmed TRABELSI	411100033	validated	25/000032	1776955635000
33	25/000033	2025-05-08	HADJ SALEM Karim	186	Hassen KASDAOUI	411100035	validated	25/000033	1776955635000
34	25/000034	2025-02-08	HADJ SALEM Karim	189	Mustapha ZOUAGHI	411100038	validated	25/000034	1776955636000
35	25/000035	2025-02-08	HADJ SALEM Karim	188	Souhail BEN REJEB	411100037	validated	25/000035	1776955636000
36	25/000036	2025-06-08	HADJ SALEM Karim	192	Adel IBN EL ASOUED	411100041	validated	25/000036	1776955636000
37	25/000037	2025-11-08	HADJ SALEM Karim	194	Bilel AHMED	411100043	validated	25/000037	1776955636000
38	25/000038	2025-08-16	HADJ SALEM Karim	196	Ghassen BALTI	411100045	validated	25/000038	1776955636000
39	25/000039	2025-08-18	HADJ SALEM Karim	197	Moez JBELI	411100046	validated	25/000039	1776955636000
40	25/000040	2025-08-18	HADJ SALEM Karim	198	Mohamed DAOUTHI	411100047	validated	25/000040	1776955636000
41	25/000041	2025-08-21	HADJ SALEM Karim	201	STE TUNISIENNE DE DISTRIBUTION DES PRODUITS	411100050	validated	25/000041	1776955636000
42	25/000042	2025-08-21	HADJ SALEM Karim	202	Sami BEN DHAW	411100051	validated	25/000042	1776955636000
43	25/000043	2025-08-21	HADJ SALEM Karim	203	Foued EL AALLAGUI	411100052	validated	25/000043	1776955636000
44	25/000044	2025-08-23	HADJ SALEM Karim	205	Kais KASDAOUI	411100054	validated	25/000044	1776955636000
45	25/000045	2025-08-25	HADJ SALEM Karim	207	Mohamed AZIZ KESIBI	411100056	validated	25/000045	1776955636000
46	25/000046	2025-08-25	HADJ SALEM Karim	208	Kamel JELASSI	411100057	validated	25/000046	1776955636000
47	25/000047	2025-08-30	HADJ SALEM Karim	209	Sadok SALHI	411100058	validated	25/000047	1776955636000
48	25/000048	2025-01-09	HADJ SALEM Karim	210	Khmais DRIDI	411100059	validated	25/000048	1776955636000
49	25/000049	2025-03-09	HADJ SALEM Karim	211	Adem BEN HSSIN	411100060	validated	25/000049	1776955636000
50	25/000050	2025-08-09	HADJ SALEM Karim	212	Zied MLOUH	411100061	validated	25/000050	1776955636000
51	25/000051	2025-08-09	HADJ SALEM Karim	301	Hajer NAFFETI	411100150	validated	25/000051	1776955636000
52	25/000052	2025-11-09	HADJ SALEM Karim	216	Yosri MAHWACHI	411100065	validated	25/000052	1776955636000
53	25/000053	2025-09-18	HADJ SALEM Karim	217	Skander BEN MRIDA	411100066	validated	25/000085	1776955636000
54	25/000054	2025-09-19	HADJ SALEM Karim	218	Abderrazek EL AJIMI	411100067	validated	25/000053	1776955636000
55	25/000055	2025-09-19	HADJ SALEM Karim	219	AALIA SAMIA	411100068	validated	25/000070	1776955636000
56	25/000056	2025-09-22	HADJ SALEM Karim	220	Nassima THAMRI	411100069	validated	25/000054	1776955636000
57	25/000057	2025-09-23	HADJ SALEM Karim	221	STE LE CLUB	411100070	validated	25/000055	1776955636000
58	25/000058	2025-09-23	HADJ SALEM Karim	222	HASANINE REBII	411100071	validated	25/000056	1776955636000
59	25/000059	2025-09-24	HADJ SALEM Karim	223	Mahdi SASSI	411100072	validated	25/000057	1776955636000
60	25/000060	2025-09-24	HADJ SALEM Karim	225	SOCIETE WAFRA AGRICOLE SWA	411100074	validated	25/000058	1776955636000
61	25/000061	2025-09-25	HADJ SALEM Karim	226	MOHAMED EL AMDOUNI	411100075	validated	25/000059	1776955636000
62	25/000062	2025-09-25	HADJ SALEM Karim	224	Achref GHARBI	411100073	validated	25/000060	1776955636000
63	25/000063	2025-09-26	HADJ SALEM Karim	227	STE TULIPE TECHNOLOGY	411100076	validated	25/000061	1776955636000
64	25/000064	2025-09-29	HADJ SALEM Karim	229	Abderrazek ARAARI	411100078	validated	25/000062	1776955636000
65	25/000065	2025-09-30	HADJ SALEM Karim	182	Naoufel EL HAMZI	411100031	validated	25/000063	1776955636000
66	25/000066	2025-06-10	HADJ SALEM Karim	232	Med Ayoub GOUADER	411100081	validated	25/000064	1776955636000
67	25/000067	2025-06-10	HADJ SALEM Karim	233	Wassim ABBESSI	411100082	validated	25/000065	1776955636000
68	25/000068	2025-08-10	HADJ SALEM Karim	234	Fraj BOUKHRIS	411100083	validated	25/000066	1776955636000
69	25/000069	2025-08-10	HADJ SALEM Karim	235	MED Amine EL FRADI	411100084	validated	25/000067	1776955636000
70	25/000070	2025-10-13	HADJ SALEM Karim	237	Fraj BEN AMMAR	411100086	validated	25/000068	1776955636000
71	25/000071	2025-10-22	HADJ SALEM Karim	239	Ahmed KANZARI	411100088	validated	25/000069	1776955636000
72	25/000072	2025-10-27	HADJ SALEM Karim	240	MED ADNENE CHAMTOURI	411100089	validated	25/000071	1776955636000
73	25/000073	2025-10-28	HADJ SALEM Karim	241	Fawzi TLILI	411100090	validated	25/000072	1776955636000
74	25/000074	2025-06-11	HADJ SALEM Karim	244	Skander SHILI	411100093	validated	25/000073	1776955636000
75	25/000075	2025-10-11	HADJ SALEM Karim	245	Mohamed RAYEN MATHLOUTHI	411100094	validated	25/000074	1776955636000
76	25/000076	2025-08-11	HADJ SALEM Karim	246	Mohamed Ali EL GHRAIRI	411100095	validated	25/000075	1776955636000
77	25/000077	2025-10-11	HADJ SALEM Karim	247	Abd Raouf EL MELHMI	411100096	validated	25/000076	1776955636000
78	25/000078	2025-10-11	HADJ SALEM Karim	248	Bilel MANNAII	411100097	validated	25/000077	1776955636000
79	25/000079	2025-10-11	HADJ SALEM Karim	249	Iyed EL HAMADI	411100098	validated	25/000078	1776955636000
80	25/000080	2025-10-11	HADJ SALEM Karim	250	Ahmed WERGHEMI	411100099	validated	25/000079	1776955636000
81	25/000081	2025-11-14	HADJ SALEM Karim	253	Mohamed AZIZ SAADAOUI	411100102	validated	25/000080	1776955636000
82	25/000082	2025-11-17	HADJ SALEM Karim	154	STE AKRAM DE COMMERCE ET SERICES	411100003	validated	25/000081	1776955636000
83	25/000083	2025-11-17	HADJ SALEM Karim	244	Skander SHILI	411100093	validated	25/000082	1776955636000
84	25/000084	2025-11-18	HADJ SALEM Karim	254	Omar FERGENI	411100103	validated	25/000083	1776955636000
85	25/000085	2025-11-20	HADJ SALEM Karim	255	Seifeddine BEN ZEKRI	411100104	validated	25/000084	1776955636000
86	25/000086	2025-11-25	HADJ SALEM Karim	257	Zaid BAILI	411100106	validated	25/000086	1776955636000
87	25/000087	2025-11-25	HADJ SALEM Karim	257	Zaid BAILI	411100106	validated	25/000087	1776955636000
88	25/000088	2025-04-12	HADJ SALEM Karim	258	Moataz BOUAADILA	411100107	validated	25/000088	1776955636000
89	25/000089	2025-09-12	HADJ SALEM Karim	245	Mohamed RAYEN MATHLOUTHI	411100094	validated	25/000089	1776955636000
90	25/000090	2025-12-15	HADJ SALEM Karim	259	Ihsen LARIANI	411100108	validated	25/000090	1776955636000
91	25/000091	2025-12-16	HADJ SALEM Karim	260	Kais HADDAGI	411100109	validated	25/000091	1776955636000
92	25/000092	2025-12-19	HADJ SALEM Karim	262	Idriss HMADA	411100111	validated	25/000092	1776955636000
93	25/000093	2025-12-19	HADJ SALEM Karim	263	Yassine RIAHI	411100112	validated	25/000093	1776955636000
94	25/000094	2025-12-20	HADJ SALEM Karim	258	Moataz BOUAADILA	411100107	validated	25/000094	1776955636000
95	25/000095	2025-12-22	HADJ SALEM Karim	264	Abdessalem BOUSEDRA	411100113	validated	25/000095	1776955636000
96	25/000096	2025-12-22	HADJ SALEM Karim	265	Wissem ROMDHANI	411100114	validated	25/000096	1776955636000
97	25/000097	2025-12-24	HADJ SALEM Karim	266	Saida FAZAII	411100115	validated	25/000097	1776955637000
98	25/000098	2025-12-29	HADJ SALEM Karim	267	Mohamed AZIZ BEN AHMED	411100116	validated	25/000098	1776955637000
99	25/000099	2026-02-01	HADJ SALEM Karim	244	Skander SHILI	411100093	validated	26/000001	1776955637000
100	26/000001	2026-02-01	HADJ SALEM Karim	244	Skander SHILI	411100093	validated	26/000002	1776955637000
118	26/000020	2026-02-11	HADJ SALEM Karim	284	CharfE Eddin ALAAMRI	411100133	validated	26/000020	1776955637000
119	26/000021	2026-02-16	HADJ SALEM Karim	288	Hazem BEN AALAYET	411100137	validated	26/000021	1776955637000
120	26/000022	2026-02-17	HADJ SALEM Karim	286	Protest Engineering	411100135	validated	26/000022	1776955637000
121	26/000023	2026-02-17	HADJ SALEM Karim	286	Protest Engineering	411100135	validated	26/000023	1776955637000
122	26/000025	2026-02-17	HADJ SALEM Karim	211	Adem BEN HSSIN	411100060	validated	26/000024	1776955637000
123	26/000026	2026-02-18	HADJ SALEM Karim	291	Aniss TIAHI	411100140	validated	26/000025	1776955637000
124	26/000027	2026-02-18	HADJ SALEM Karim	292	Kilani FERCHICHI	411100141	validated	26/000026	1776955637000
125	26/000028	2026-02-18	HADJ SALEM Karim	293	Bilel GHRAIRI	411100142	validated	26/000027	1776955637000
126	26/000029	2026-02-19	HADJ SALEM Karim	294	Issam NAWALI	411100143	validated	26/000028	1776955637000
127	26/000030	2026-02-19	HADJ SALEM Karim	289	Hajer MOHSEN	411100138	validated	26/000029	1776955637000
128	26/000031	2026-02-23	HADJ SALEM Karim	290	FSIC	411100139	validated	26/000030	1776955637000
129	26/000032	2026-02-21	HADJ SALEM Karim	296	STE GREPSYS	411100145	validated	26/000031	1776955637000
130	26/000033	2026-02-25	HADJ SALEM Karim	300	Anouar ABDALLAH	411100149	validated	26/000032	1776955637000
131	26/000034	2026-03-02	HADJ SALEM Karim	298	STE SOPREM	411100147	validated	26/000033	1776955637000
132	26/000035	2026-03-11	HADJ SALEM Karim	308	Bachir BALLOUMI	411100151	validated	26/000034	1776955637000
133	26/000036	2026-03-11	HADJ SALEM Karim	257	Zaid BAILI	411100106	validated	26/000035	1776955637000
134	26/000037	2026-03-12	HADJ SALEM Karim	309	Ahmed AAGRBI	411100152	validated	26/000036	1776955637000
135	26/000038	2026-03-12	HADJ SALEM Karim	310	Taieb KACHOUB	411100153	validated	26/000037	1776955637000
136	26/000039	2026-03-13	HADJ SALEM Karim	317	Fares BOUKARI	411100160	validated	26/000038	1776955637000
137	26/000040	2026-03-16	HADJ SALEM Karim	256	STE SOTUCHOC	411100105	validated	26/000039	1776955637000
138	26/000041	2026-03-19	HADJ SALEM Karim	313	Mohamed Amine BEN SALAH	411100156	validated	26/000040	1776955637000
139	26/000042	2026-03-24	HADJ SALEM Karim	314	Ali RIAHI	411100157	validated	26/000041	1776955637000
140	26/000043	2026-03-26	HADJ SALEM Karim	315	Ayoub ALMAHMOUDI	411100158	validated	26/000042	1776955637000
141	26/000044	2026-03-30	HADJ SALEM Karim	298	STE SOPREM	411100147	validated	26/000043	1776955637000
142	26/000045	2026-04-06	HADJ SALEM Karim	167	Sami ESSID	411100016	validated	26/000044	1776955637000
143	26/000046	2026-04-07	HADJ SALEM Karim	298	STE SOPREM	411100147	validated	26/000045	1776955637000
144	26/000048	2026-04-18	HADJ SALEM Karim	263	Yassine RIAHI	411100112	validated	26/000046	1776955637000
1	25/000001	2025-06-16	HADJ SALEM Karim	155	ZIED BOUAFIA	411100004	validated	25/000001	1776955635000
2	25/000002	2025-06-17	HADJ SALEM Karim	156	MED MAROUEN EL HAJRI	411100005	validated	25/000002	1776955635000
3	25/000003	2025-06-17	HADJ SALEM Karim	154	STE AKRAM DE COMMERCE ET SERVICES	411100003	validated	25/000003	1776955635000
4	25/000004	2025-06-19	HADJ SALEM Karim	152	EMEB	411100001	validated	25/000004	1776955635000
5	25/000005	2025-06-19	HADJ SALEM Karim	153	DARDOUR ET COMPAGNIE SDC	411100002	validated	25/000005	1776955635000
6	25/000006	2025-06-21	HADJ SALEM Karim	157	ALI CHEBBI	411100006	validated	25/000006	1776955635000
7	25/000007	2025-06-21	HADJ SALEM Karim	158	OUSSEMA BEN AISSA	411100007	validated	25/000007	1776955635000
8	25/000008	2025-06-21	HADJ SALEM Karim	159	MALEK JBELI	411100008	validated	25/000008	1776955635000
9	25/000009	2025-06-22	HADJ SALEM Karim	160	MOUJIB ALLAH EL JENDOUBI	411100009	validated	25/000009	1776955635000
10	25/000010	2025-06-22	HADJ SALEM Karim	161	MOHAMED HAMROUNI	411100010	validated	25/000010	1776955635000
11	25/000011	2025-06-25	HADJ SALEM Karim	162	AZIZA ABIDI	411100011	validated	25/000011	1776955635000
12	25/000012	2025-06-30	HADJ SALEM Karim	163	DHAKER KHADRAOUI	411100012	validated	25/000012	1776955635000
13	25/000013	2025-01-07	HADJ SALEM Karim	164	MOHAMED SNOUN	411100013	validated	25/000013	1776955635000
14	25/000014	2025-03-07	HADJ SALEM Karim	165	IBRAHIM ABID	411100014	validated	25/000014	1776955635000
15	25/000015	2025-10-07	HADJ SALEM Karim	166	Mourad GHRAIRI	411100015	validated	25/000015	1776955635000
16	25/000016	2025-10-07	HADJ SALEM Karim	167	Sami ESSID	411100016	validated	25/000016	1776955635000
17	25/000017	2025-11-07	HADJ SALEM Karim	168	HASSEN ARFAOUI	411100017	validated	25/000017	1776955635000
18	25/000018	2025-12-07	HADJ SALEM Karim	169	Jamel AAROURI	411100018	validated	25/000018	1776955635000
19	25/000019	2025-12-07	HADJ SALEM Karim	170	Ahmed FARHAT	411100019	validated	25/000019	1776955635000
20	25/000020	2025-07-14	HADJ SALEM Karim	171	Abdelhmid CHAOUATI	411100020	validated	25/000020	1776955635000
21	25/000021	2025-07-15	HADJ SALEM Karim	173	Nader CHAOUACHI	411100022	validated	25/000021	1776955635000
101	26/000002	2026-05-01	HADJ SALEM Karim	260	Kais HADDAGI	411100109	validated	26/000003	1776955637000
102	26/000003	2026-09-01	HADJ SALEM Karim	269	Ramzi BALOUTI	411100118	validated	26/000004	1776955637000
103	26/000004	2026-09-01	HADJ SALEM Karim	270	Walid BENCHIKH	411100119	validated	26/000005	1776955637000
104	26/000005	2026-01-13	HADJ SALEM Karim	259	Ihsen LARIANI	411100108	validated	26/000006	1776955637000
105	26/000006	2026-01-14	HADJ SALEM Karim	271	Lassaad GOUIDER	411100120	validated	26/000007	1776955637000
106	26/000007	2026-01-15	HADJ SALEM Karim	244	Skander SHILI	411100093	validated	26/000008	1776955637000
107	26/000008	2026-01-22	HADJ SALEM Karim	273	Alae NAJEM	411100122	validated	26/000009	1776955637000
108	26/000009	2026-01-26	HADJ SALEM Karim	274	Mohamed Aziz DALLAJI	411100123	validated	26/000010	1776955637000
109	26/000011	2026-01-26	HADJ SALEM Karim	275	Hamza HASSNAOUI	411100124	validated	26/000011	1776955637000
110	26/000012	2026-01-27	HADJ SALEM Karim	276	Mohamed Slim ABID	411100125	validated	26/000012	1776955637000
111	26/000013	2026-01-28	HADJ SALEM Karim	278	Saber BADR	411100127	validated	26/000013	1776955637000
112	26/000014	2026-02-03	HADJ SALEM Karim	279	NIZAR BOU DHAOWIA	411100128	validated	26/000014	1776955637000
113	26/000015	2026-02-06	HADJ SALEM Karim	263	Yassine RIAHI	411100112	validated	26/000015	1776955637000
114	26/000016	2026-02-07	HADJ SALEM Karim	280	Amir KIRAT	411100129	validated	26/000016	1776955637000
115	26/000017	2026-02-07	HADJ SALEM Karim	281	Mohamed Ali NASRALLAH	411100130	validated	26/000017	1776955637000
116	26/000018	2026-02-10	HADJ SALEM Karim	282	Iptissem MANSOURI	411100131	validated	26/000018	1776955637000
117	26/000019	2026-02-10	HADJ SALEM Karim	283	Ali HATHROUBI	411100132	validated	26/000019	1776955637000
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, action, target, details, "timestamp") FROM stdin;
1	2	MODIFICATION	Filtre	Client: Naoufel EL HAMZI — modifié	1773913704000
2	2	MODIFICATION	plaquette frein	Client: Naoufel EL HAMZI — modifié	1773913728000
3	2	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1774256205000
4	2	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1774256215000
5	2	PAIEMENT	Facture 26/000013	Client: Saber BADR — mars_2026	1774256291000
6	2	PAIEMENT	Facture 26/000013	Client: Saber BADR — avril_2026	1774256292000
7	2	PAIEMENT	Facture 26/000013	Client: Saber BADR — mai_2026	1774256293000
8	2	PAIEMENT	Facture 26/000013	Client: Saber BADR — juin_2026	1774256294000
9	2	PAIEMENT	Facture 25/000017	Client: Mr HASSEN ARFAOUI — octobre_2025	1774256350000
10	2	PAIEMENT	Facture 25/000020	Client: Mr Abdelhmid CHAOUATI — octobre_2025	1774256352000
11	2	PAIEMENT	Facture 25/000021	Client: Mr Nader CHAOUACHI — septembre_2025	1774256353000
12	2	PAIEMENT	Facture 25/000023	Client: Mr Hssan HARWAK — septembre_2025	1774256355000
13	2	PAIEMENT	Facture 25/000035	Client: Mr Souhail BEN REJEB — octobre_2025	1774256359000
14	2	PAIEMENT	Facture 25/000036	Client: Mr Adel IBN EL ASOUED — octobre_2025	1774256360000
15	2	NOUVEAU CLIENT	Mohamed Amine BEN SALAH	Tél: 25999429 — #411100156	1774256511000
16	2	VENTE SELLE	Vente selle du 2026-03-20	Client: passager (yheb aala carénage FORZZA FTM)  — 15 TND	1774256587000
17	2	PAIEMENT	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI — novembre_2025	1774280099000
18	2	MODIFICATION	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI	1774280100000
19	2	PAIEMENT	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI — novembre_2025	1774280100000
20	2	MODIFICATION	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI	1774280101000
21	2	MODIFICATION	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI	1774280104000
22	2	PAIEMENT	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI — novembre_2025	1774280133000
23	2	MODIFICATION	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI	1774280133000
24	2	MODIFICATION	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI	1774280136000
25	2	PAIEMENT	Facture 26/000020	Client: CharfE Eddin ALAAMRI — mars_2026	1774280156000
26	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280157000
27	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280159000
28	2	PAIEMENT	Facture 26/000020	Client: CharfE Eddin ALAAMRI — avril_2026	1774280160000
29	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280160000
30	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280162000
31	2	PAIEMENT	Facture 26/000020	Client: CharfE Eddin ALAAMRI — mai_2026	1774280164000
32	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280164000
33	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280166000
34	2	PAIEMENT	Facture 26/000020	Client: CharfE Eddin ALAAMRI — juin_2026	1774280167000
35	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280167000
36	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280169000
37	2	PAIEMENT	Facture 26/000020	Client: CharfE Eddin ALAAMRI — juillet_2026	1774280170000
38	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280170000
39	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280171000
40	2	PAIEMENT	Facture 26/000020	Client: CharfE Eddin ALAAMRI — aout_2026	1774280173000
41	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280173000
42	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280174000
43	2	PAIEMENT	Facture 26/000020	Client: CharfE Eddin ALAAMRI — septembre_2026	1774280177000
44	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280177000
45	2	MODIFICATION	Facture 26/000020	Client: CharfE Eddin ALAAMRI	1774280179000
46	2	PAIEMENT	Facture 26/000020	Client: CharfE Eddin ALAAMRI — mars_2026	1774280181000
47	2	VENTE HUILE	Vente huile du 2026-03-24	Client: Adem BEN HSSIN — 17.998 TND	1774338049000
48	2	NOUVEAU CLIENT	Ali RIAHI	Tél: — — #411100157	1774364088000
49	2	VENTE MOTO	Facture 26/000041	Client: Ali RIAHI	1774364134000
50	2	PAIEMENT	Facture 26/000041	Client: Ali RIAHI — avril_2026	1774364152000
51	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774364152000
52	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774364157000
53	2	PAIEMENT	Facture 26/000041	Client: Ali RIAHI — mai_2026	1774364169000
54	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774364169000
55	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774364171000
56	2	PAIEMENT	Facture 26/000040	Client: Mohamed Amine BEN SALAH — avril_2026	1774365617000
57	2	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1774365618000
58	2	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1774365620000
59	2	PAIEMENT	Facture 26/000040	Client: Mohamed Amine BEN SALAH — aout_2026	1774365627000
60	2	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1774365628000
61	2	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1774365630000
62	2	PAIEMENT	Facture 25/000076	Client: Mr Abd Raouf EL MELHMI — mars_2026	1774365664000
63	2	PAIEMENT	Facture 25/000093	Client: Mr Yassine RIAHI — mars_2026	1774365674000
64	2	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1774442201000
65	2	PAIEMENT	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI — mars_2026	1774442214000
66	2	MODIFICATION	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI	1774442214000
67	2	MODIFICATION	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI	1774442217000
68	2	PAIEMENT	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI — avril_2026	1774442218000
69	2	MODIFICATION	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI	1774442218000
70	2	MODIFICATION	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI	1774442220000
71	2	PAIEMENT	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI — mars_2026	1774442221000
72	2	MODIFICATION	Facture 26/000034	Client: Bachir BALLOUMI	1774453677000
73	2	MODIFICATION	Facture 26/000034	Client: Bachir BALLOUMI	1774453696000
74	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774453731000
75	2	MODIFICATION	Facture 26/000037	Client: Taieb KACHOUB	1774453758000
76	2	MODIFICATION	Facture 26/000037	Client: Taieb KACHOUB	1774453773000
77	2	MODIFICATION	Facture 26/000037	Client: Taieb KACHOUB	1774454127000
78	2	SAUVEGARDE	Sauvegarde manuelle	3 fichiers générés : Complète + Clients + Bons de Livraison	1774454544000
79	2	SAUVEGARDE	Sauvegarde manuelle	3 fichiers générés : Complète + Clients + Bons de Livraison	1774509770000
80	2	MODIFICATION	Facture 26/000037	Client: Taieb KACHOUB	1774512545000
81	1	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1774512649000
82	1	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1774512657000
83	1	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1774512666000
84	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774512731000
85	2	SAUVEGARDE	Sauvegarde manuelle	3 fichiers générés : Complète + Clients + Bons de Livraison	1774512744000
86	2	SAUVEGARDE	Sauvegarde manuelle	3 fichiers générés : Complète + Clients + Bons de Livraison	1774513434000
87	2	MODIFICATION CLIENT	MED ADNENE CHAMTOURI	Client #411100089 modifié	1774525053000
88	2	MODIFICATION CLIENT	Fawzi TLILI	Client #411100090 modifié	1774525079000
89	2	MODIFICATION CLIENT	Nizar SALHI	Client #411100023 modifié	1774525300000
90	2	MODIFICATION CLIENT	Ali RIAHI	Client #411100157 modifié	1774525468000
91	2	NOUVEAU CLIENT	Ayoub ALMAHMOUDI	Tél: 28434629 — #411100158	1774525529000
92	2	VENTE MOTO	Facture 26/000042	Client: Ayoub ALMAHMOUDI	1774525627000
93	2	MODIFICATION	Facture 26/000042	Client: Ayoub ALMAHMOUDI	1774525634000
94	2	PAIEMENT	Facture 26/000035	Client: Zaid BAILI — juillet_2026	1774525739000
95	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774525739000
96	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774525740000
97	2	PAIEMENT	Facture 26/000035	Client: Zaid BAILI — juin_2026	1774525741000
98	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774525741000
99	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774525742000
100	2	PAIEMENT	Facture 26/000035	Client: Zaid BAILI — mai_2026	1774525742000
101	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774525742000
102	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774525744000
103	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774525745000
104	2	PAIEMENT	Facture 26/000035	Client: Zaid BAILI — avril_2026	1774525746000
105	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774525746000
106	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1774525748000
107	2	PAIEMENT	Facture 26/000035	Client: Zaid BAILI — avril_2026	1774525749000
108	2	MODIFICATION	Facture 25/000087	Client: Mr Zaid BAILI	1774525768000
109	2	MODIFICATION	Facture 26/000023	Client: Protest Engineering	1774525785000
110	2	MODIFICATION	Facture 25/000089	Client: Mr Mohamed RAYEN MATHLOUTHI	1774525787000
111	2	MODIFICATION	Facture 25/000081	Client: STE AKRAM DE COMMERCE ET SERICES	1774525788000
112	2	MODIFICATION	Facture 25/000082	Client: Mr Skander SHILI	1774525790000
113	2	MODIFICATION	Facture 25/000094	Client: Mr Moataz BOUAADILA	1774525792000
114	2	MODIFICATION	Facture 26/000002	Client: Mr Skander SHILI	1774525794000
115	2	MODIFICATION	Facture 26/000034	Client: Bachir BALLOUMI	1774525810000
116	1	NOUVEAU CLIENT	test	Tél: 123 — #411100159	1774602705000
117	1	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1774602722000
118	1	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774602726000
119	2	SUPPRESSION CLIENT	Client #316	Client supprimé	1774603141000
120	2	NOUVEAU CLIENT	test	Tél: 123 — #411100159	1774603490000
121	1	NOUVEAU CLIENT	test2	Tél: 456 — #411100160	1774603523000
122	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774603640000
123	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774603646000
124	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774603654000
125	2	SUPPRESSION CLIENT	Client #318	Client supprimé	1774603697000
126	2	SUPPRESSION CLIENT	Client #317	Client supprimé	1774603700000
127	2	MODIFICATION	Facture 26/000037	Client: Taieb KACHOUB	1774625902000
128	2	MODIFICATION	Vente huile du 2026-03-14	Client: Adem BEN HSSIN — modifiée	1774684592000
129	2	MODIFICATION	Vente huile du 2026-03-24	Client: Adem BEN HSSIN — modifiée	1774684638000
130	2	NOUVEAU CLIENT	test	Tél: 987 — #411100159	1774697350000
131	2	SUPPRESSION CLIENT	Client #316	Client supprimé	1774697388000
132	1	NOUVEAU CLIENT	testino	Tél: 258 — #411100159	1774697846000
133	1	MODIFICATION	Facture 26/000036	Client: Ahmed AAGRBI	1774697902000
134	2	SUPPRESSION CLIENT	Client #317	Client supprimé	1774698129000
135	2	VENTE HUILE	Vente huile du 2026-03-28	Client: Abdelkader HEDFI — 18 TND	1774700883000
136	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774702740000
137	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774702746000
138	1	VENTE SELLE	Vente selle du 2026-03-30	Client: passager — 15 TND	1774856402000
139	1	MODIFICATION	Vente selle du 2026-03-28	Client: passager — modifiée	1774856455000
140	2	PAIEMENT	Facture 25/000060	Client: Mr Achref GHARBI — fevrier_2026	1774867178000
141	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1774867217000
142	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1774867241000
143	2	PAIEMENT	Facture 26/000014	Client: NIZAR BOU DHAOWIA — avril_2026	1774868722000
144	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — mars_2027	1774868803000
145	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1774868803000
146	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1774868805000
147	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — fevrier_2027	1774868806000
148	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — fevrier_2027	1774868806000
149	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1774868807000
150	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1774868809000
151	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — fevrier_2027	1774868811000
152	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1774868811000
153	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — fevrier_2027	1774868812000
154	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1774868816000
155	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1774868820000
156	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — fevrier_2026	1774868821000
157	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1774868823000
158	2	VENTE CASQUE	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — 1095.8 TND	1774876254000
159	2	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774876294000
160	2	SAUVEGARDE	Sauvegarde manuelle	3 fichiers générés : Complète + Clients + Bons de Livraison	1774945604000
161	2	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1774954197000
162	2	PAIEMENT	Facture 25/000092	Client: Mr Idriss HAMADA — avril_2026	1774954202000
163	2	MODIFICATION	Vente huile du 2026-03-18	Client: Lassaad GOUIDER — modifiée	1774968900000
164	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969125000
165	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969125000
166	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969125000
167	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969126000
168	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969126000
169	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969127000
170	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969129000
171	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969129000
172	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969130000
173	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969130000
174	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969131000
175	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969131000
176	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969132000
177	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969133000
178	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969133000
179	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969133000
180	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969134000
181	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969135000
182	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969141000
183	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969143000
184	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969146000
185	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969153000
186	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969153000
187	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969156000
188	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969158000
189	2	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969165000
190	1	MODIFICATION	Vente huile du 2026-02-23	Client: Adem Ben Hssin — modifiée	1774969179000
191	2	MODIFICATION	Vente huile du 2026-03-28	Client: Abdelkader HEDFI — modifiée	1774969281000
192	2	MODIFICATION	Casque — CASQUE TNL Gris-Taille L	Client: Iptissem MANSOURI — modifié	1774969526000
193	2	VENTE HUILE	Vente huile du 2026-03-31	Client: — — 1 TND	1774969849000
194	2	MODIFICATION	Vente huile du 2026-03-31	Client: — — modifiée	1774969859000
195	2	MODIFICATION	Vente huile du 2026-03-31	Client: — — modifiée	1774969859000
196	2	MODIFICATION	Vente huile du 2026-03-31	Client: — — modifiée	1774969860000
197	2	MODIFICATION	Vente huile du 2026-03-31	Client: — — modifiée	1774969863000
198	2	MODIFICATION	Vente huile du 2026-03-31	Client: — — modifiée	1774969866000
199	2	MODIFICATION	Vente huile du 2026-03-31	Client: — — modifiée	1774969868000
200	2	MODIFICATION	Vente huile du 2026-03-31	Client: — — modifiée	1774969872000
201	2	MODIFICATION	Vente huile du 2026-03-31	Client: — — modifiée	1774969881000
202	2	MODIFICATION	Vente huile du 2026-03-31	Client: — — modifiée	1774969881000
203	1	MODIFICATION	Vente huile du 2026-03-31	Client: — — modifiée	1774969892000
204	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969920000
205	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969920000
206	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969921000
207	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969924000
208	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969924000
209	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969931000
210	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969934000
211	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969935000
212	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969936000
213	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969939000
214	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969942000
215	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969947000
216	1	MODIFICATION	Casque — CASQUE MT Taille L GLOSS	Client: STE SOPREM — modifié	1774969967000
217	1	MODIFICATION	Vente selle du 2026-03-28	Client: passager — modifiée	1774970807000
218	1	MODIFICATION	Vente selle du 2026-03-28	Client: passager — modifiée	1774970809000
219	1	MODIFICATION	Vente selle du 2026-03-28	Client: passager — modifiée	1774970812000
220	1	MODIFICATION	Vente selle du 2026-03-28	Client: passager — modifiée	1774970824000
221	2	MODIFICATION	plaquette frein	Client: Naoufel EL HAMZI — modifié	1774971296000
222	2	MODIFICATION	plaquette frein	Client: Naoufel EL HAMZI — modifié	1774971298000
223	2	MODIFICATION	plaquette frein	Client: Naoufel EL HAMZI — modifié	1774971300000
224	2	MODIFICATION	plaquette frein	Client: Naoufel EL HAMZI — modifié	1774971304000
225	1	MODIFICATION	plaquette frein	Client: Naoufel EL HAMZI — modifié	1774971316000
226	2	PAIEMENT	Facture 25/000050	Client: Mr Zied MLAOUH — avril_2026	1774974625000
227	2	VENTE HUILE	Vente huile du 2026-04-01	Client: Adem BEN HSSIN — 18 TND	1775028398000
228	2	PAIEMENT	Facture 26/000010	Client: Mohamed Aziz DALLAJI — avril_2026	1775057527000
229	2	VENTE HUILE	Vente huile du 2026-04-03	Client: Ramzi BALOUTI — 18 TND	1775202281000
230	2	PAIEMENT	Facture 26/000004	Client: Mr Ramzi BALOUTI — mars_2026	1775202297000
231	2	MODIFICATION	Facture 25/000095	Client: Mr Abdessalem BOUSEDRA	1775203032000
232	2	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1775208463000
233	2	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1775208469000
234	2	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1775208473000
235	2	PAIEMENT	Facture 26/000011	Client: Hamza HASSNAOUI — mars_2026	1775208926000
236	2	PAIEMENT	Facture 25/000072	Client: Mr Fawzi TLILI — avril_2026	1775211600000
237	2	MODIFICATION	Casque — CASQUE LS2 AIRFLOW GLOSS -Taille M	Client: Hajer NAFFETI — modifié	1775214740000
238	2	PAIEMENT	Facture 25/000083	Client: Mr Omar FERGENI — avril_2026	1775305144000
239	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — janvier_2027	1775472376000
240	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472376000
241	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472378000
242	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — decembre_2026	1775472379000
243	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472379000
244	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472380000
245	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — novembre_2026	1775472381000
246	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472382000
247	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472383000
248	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — octobre_2026	1775472384000
249	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472384000
250	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472385000
251	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — septembre_2026	1775472453000
252	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472454000
253	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472455000
254	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — aout_2026	1775472456000
255	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472457000
256	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — aout_2026	1775472458000
257	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — juillet_2026	1775472458000
258	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — juillet_2026	1775472459000
259	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472459000
260	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — juin_2026	1775472460000
261	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472461000
262	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472461000
263	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472462000
264	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — juillet_2026	1775472463000
265	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — aout_2026	1775472464000
266	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472467000
267	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — juin_2026	1775472467000
268	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472468000
269	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472469000
270	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — mai_2026	1775472471000
271	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472471000
272	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472472000
273	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — avril_2026	1775472473000
274	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472473000
275	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472474000
276	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472476000
277	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472477000
278	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472478000
279	2	PAIEMENT	Facture 26/000016	Client: Amir KIRAT — mai_2026	1775472481000
280	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472481000
281	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775472483000
282	2	PAIEMENT	Facture 25/000098	Client: Mr Mohamed AZIZ BEN AHMED — avril_2026	1775472503000
283	2	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1775480860000
284	2	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1775480893000
285	2	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1775480906000
286	2	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1775481002000
287	2	MODIFICATION	Facture 26/000016	Client: Amir KIRAT	1775481055000
288	2	MODIFICATION	Facture 25/000095	Client: Mr Abdessalem BOUSEDRA	1775481063000
289	2	VENTE MOTO	Facture 26/000044	Client: Sami ESSID	1775549533000
290	2	PAIEMENT	Facture 26/000015	Client: Yassine RIAHI — avril_2026	1775555320000
291	2	MODIFICATION	Facture 26/000040	Client: Mohamed Amine BEN SALAH	1775643013000
292	2	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1775643040000
293	2	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1775643043000
294	2	MODIFICATION	Facture 26/000039	Client: STE SOTUCHOC	1775643049000
295	2	MODIFICATION	Facture 26/000042	Client: Ayoub ALMAHMOUDI	1775646250000
296	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1775646260000
297	2	MODIFICATION	Facture 26/000036	Client: Ahmed AAGRBI	1775646287000
298	2	VENTE HUILE	Vente huile du 2026-04-08	Client: Ahmed AAGRBI — 18 TND	1775647274000
299	2	VENTE HUILE	Vente huile du 2026-04-06	Client: STE SOPREM — 471 TND	1775810158000
300	2	MODIFICATION	Vente huile du 2026-04-08	Client: Ahmed AAGRBI — modifiée	1775810604000
301	2	PAIEMENT	Facture 26/000009	Client: Alae NAJEM — mars_2026	1775811217000
302	2	VENTE HUILE	Vente huile du 2026-04-10	Client: passager — 18 TND	1775892417000
303	2	VENTE HUILE	Vente huile du 2026-04-11	Client: Adem BEN HSSIN — 18 TND	1775892450000
304	2	MODIFICATION	Facture 26/000042	Client: Ayoub ALMAHMOUDI	1776067621000
305	2	MODIFICATION	Facture 26/000041	Client: Ali RIAHI	1776067626000
306	2	MODIFICATION	Facture 26/000036	Client: Ahmed AAGRBI	1776067634000
307	2	PAIEMENT	Facture 26/000008	Client: Mr Skander SHILI — avril_2026	1776068012000
308	2	MODIFICATION	Facture 26/000008	Client: Mr Skander SHILI	1776068012000
309	2	MODIFICATION	Facture 26/000008	Client: Mr Skander SHILI	1776068015000
310	2	PAIEMENT	Facture 26/000008	Client: Mr Skander SHILI — avril_2026	1776068017000
311	2	PAIEMENT	Facture 26/000008	Client: Mr Skander SHILI — septembre_2026	1776068024000
312	2	MODIFICATION	Facture 26/000008	Client: Mr Skander SHILI	1776068024000
313	2	MODIFICATION	Facture 26/000008	Client: Mr Skander SHILI	1776068027000
314	2	MODIFICATION	Facture 26/000044	Client: Sami ESSID	1776070130000
315	2	PAIEMENT	Facture 26/000001	Client: Mr Skander SHILI — mai_2026	1776331726000
316	2	MODIFICATION	Facture 26/000001	Client: Mr Skander SHILI	1776331726000
317	2	MODIFICATION	Facture 26/000001	Client: Mr Skander SHILI	1776331728000
318	2	PAIEMENT	Facture 26/000001	Client: Mr Skander SHILI — avril_2026	1776331729000
319	2	MODIFICATION	Facture 26/000001	Client: Mr Skander SHILI	1776331729000
320	2	MODIFICATION	Facture 26/000001	Client: Mr Skander SHILI	1776331732000
321	2	PAIEMENT	Facture 26/000001	Client: Mr Skander SHILI — avril_2026	1776331732000
322	2	MODIFICATION	Facture 26/000001	Client: Mr Skander SHILI	1776331734000
323	2	PAIEMENT	Facture 26/000001	Client: Mr Skander SHILI — avril_2026	1776331735000
324	2	PAIEMENT	Facture 26/000012	Client: Mohamed Slim ABID  — avril_2026	1776430372000
325	2	MODIFICATION	Facture 26/000012	Client: Mohamed Slim ABID 	1776430372000
326	2	MODIFICATION	Facture 26/000012	Client: Mohamed Slim ABID 	1776430374000
327	2	PAIEMENT	Facture 26/000012	Client: Mohamed Slim ABID  — avril_2026	1776430375000
328	2	MODIFICATION	Facture 26/000012	Client: Mohamed Slim ABID 	1776430376000
329	2	PAIEMENT	Facture 26/000012	Client: Mohamed Slim ABID  — avril_2026	1776430377000
330	2	PAIEMENT	Facture 26/000012	Client: Mohamed Slim ABID  — mai_2026	1776430395000
331	2	MODIFICATION	Facture 26/000012	Client: Mohamed Slim ABID 	1776430395000
332	2	MODIFICATION	Facture 26/000012	Client: Mohamed Slim ABID 	1776430398000
333	2	PAIEMENT	Facture 26/000035	Client: Zaid BAILI — mars_2026	1776439618000
334	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1776439618000
335	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1776439620000
336	2	PAIEMENT	Facture 26/000035	Client: Zaid BAILI — mars_2026	1776439621000
337	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1776439622000
338	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1776439622000
339	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1776439625000
340	2	PAIEMENT	Facture 26/000035	Client: Zaid BAILI — mai_2026	1776439626000
341	2	PAIEMENT	Facture 26/000035	Client: Zaid BAILI — mai_2026	1776439626000
342	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1776439629000
343	2	MODIFICATION	Facture 26/000035	Client: Zaid BAILI	1776439630000
344	2	VENTE MOTO	Facture 26/000047	Client: Yassine RIAHI	1776520486000
345	2	MODIFICATION	Facture 26/000047	Client: Yassine RIAHI	1776520492000
346	2	PAIEMENT	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI — octobre_2025	1776676677000
347	2	MODIFICATION	Facture 25/000074	Client: Mr Mohamed RAYEN MATHLOUTHI	1776676679000
348	2	MODIFICATION	Facture 26/000046	Client: Yassine RIAHI	1776681903000
349	2	MODIFICATION	Facture 26/000046	Client: Yassine RIAHI	1776681913000
350	2	VENTE MOTO	Facture 26/000045	Client: 	1776681923000
351	2	MODIFICATION	Facture 26/000038	Client: Fares BOUKARI	1776682017000
352	2	MODIFICATION	Facture 26/000038	Client: Fares BOUKARI	1776682025000
353	2	SUPPRESSION	Facture 26/000045	Client:  — Vente moto supprimée	1776682220000
354	2	NOUVEAU CLIENT	Salem BEN MAATOUK	Tél: 26135624 — #411100159	1776682401000
355	2	NOUVEAU CLIENT	Fares BOUKARI	Tél: 53124228 — #411100160	1776682471000
356	2	PAIEMENT	Facture 26/000044	Client: Sami ESSID — mai_2026	1776695821000
357	2	MODIFICATION	Facture 26/000044	Client: Sami ESSID	1776695821000
358	2	MODIFICATION	Facture 26/000044	Client: Sami ESSID	1776695829000
359	2	PAIEMENT	Facture 26/000044	Client: Sami ESSID — juin_2026	1776695829000
360	2	PAIEMENT	Facture 26/000044	Client: Sami ESSID — mai_2026	1776695830000
361	2	MODIFICATION	Facture 26/000044	Client: Sami ESSID	1776695832000
362	2	PAIEMENT	Facture 26/000044	Client: Sami ESSID — juin_2026	1776695833000
363	2	MODIFICATION	Facture 26/000044	Client: Sami ESSID	1776695836000
364	2	MODIFICATION	Facture 26/000044	Client: Sami ESSID	1776695837000
365	2	MODIFICATION	Facture 26/000044	Client: Sami ESSID	1776695838000
366	2	PAIEMENT	Facture 26/000044	Client: Sami ESSID — juin_2026	1776695838000
367	2	MODIFICATION	Facture 26/000044	Client: Sami ESSID	1776695838000
368	2	PAIEMENT	Facture 26/000044	Client: Sami ESSID — juin_2026	1776695839000
369	2	MODIFICATION	Facture 26/000044	Client: Sami ESSID	1776695839000
370	2	PAIEMENT	Facture 26/000044	Client: Sami ESSID — juin_2026	1776695839000
371	2	MODIFICATION	Facture 26/000044	Client: Sami ESSID	1776695843000
372	2	PAIEMENT	Facture 25/000096	Client: Mr Wissem ROMDHANI — avril_2026	1776843889000
\.


--
-- Data for Name: oil_purchases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.oil_purchases (id, date, huile_10w40, huile_20w50, gear_oil, brake_oil, fournisseur, prix, created_at) FROM stdin;
4	2026-02-20	0	0	24	24		0	1772456294000
6	2025-07-17	36	36	0	0		996	1774972706000
7	2025-11-29	24	24	0	0		664	1774972737000
10	2026-02-03	12	12	0	0		332	1774973105000
11	2026-04-08	36	36	0	0		947	1775646164000
\.


--
-- Data for Name: oil_sales; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.oil_sales (id, date, huile_10w40, huile_20w50, gear_oil, brake_oil, prix, encaissement, client, confirmed_by_staff, confirmed_by_manager, calculation_timestamp, amount_handed, created_at) FROM stdin;
2	2025-07-15	1	0	0	0	18	KARIM	WAHID	\N	\N	\N	0	1772196129000
3	2025-07-16	1	0	0	0	18	ANAS		\N	\N	\N	0	1772196129000
4	2025-07-20	0	1	0	0	18	KARIM	WAHID	\N	\N	\N	0	1772196129000
5	2025-07-28	0	1	0	0	18	KARIM	ANAS	\N	\N	\N	0	1772196129000
6	2025-07-30	1	0	0	0	18	KARIM		\N	\N	\N	0	1772196129000
7	2025-07-29	0	2	0	0	36	ANAS	HM+KR	\N	\N	\N	0	1772196129000
8	2025-07-31	0	1	0	0	18	BASSEM	Abdelkader	\N	\N	\N	0	1772196129000
9	2025-08-02	0	1	0	0	18	ANAS	???	\N	\N	\N	0	1772196129000
10	2025-08-05	0	1	0	0	18	ANAS	KARIM	\N	\N	\N	0	1772196129000
11	2025-08-13	0	2	0	0	36	KARIM	HASSEN	\N	\N	\N	0	1772196129000
12	2025-08-16	1	0	0	0	18	KARIM	Ghassen	\N	\N	\N	0	1772196129000
13	2025-08-18	0	2	0	0	36	KARIM		\N	\N	\N	0	1772196129000
14	2025-08-19	0	1	0	0	18	KARIM		\N	\N	\N	0	1772196129000
15	2025-08-20	1	0	0	0	18	KARIM		\N	\N	\N	0	1772196129000
16	2025-08-21	0	1	0	0	18	ANAS		\N	\N	\N	0	1772196129000
17	2025-08-27	1	0	0	0	18	ANAS	Jlassi	\N	\N	\N	0	1772196129000
18	2025-09-01	0	1	0	0	18	ANAS	Bilel	\N	\N	\N	0	1772196129000
19	2025-09-03	1	0	0	0	18	ANAS	Adem	\N	\N	\N	0	1772196129000
20	2025-09-08	0	1	0	0	18	BASSEM	??	\N	\N	\N	0	1772196129000
21	2025-09-10	1	0	0	0	18	KARIM	WAEL	\N	\N	\N	0	1772196129000
22	2025-09-15	1	0	0	0	18	KARIM	WAEL	\N	\N	\N	0	1772196129000
23	2025-09-18	0	1	0	0	18	BASSEM	IBRAHIM	\N	\N	\N	0	1772196129000
24	2025-09-19	1	0	0	0	18	KARIM		\N	\N	\N	0	1772196129000
25	2025-09-19	0	1	0	0	18	KARIM	ABDERAZEK	\N	\N	\N	0	1772196129000
26	2025-09-23	0	1	0	0	18	BASSEM	YOSRI	\N	\N	\N	0	1772196129000
27	2025-09-25	1	0	0	0	18	KARIM		\N	\N	\N	0	1772196129000
28	2025-09-30	0	2	0	0	36	BASSEM		\N	\N	\N	0	1772196129000
29	2025-10-02	1	0	0	0	18	KARIM		\N	\N	\N	0	1772196129000
30	2025-10-06	0	1	0	0	18	KARIM		\N	\N	\N	0	1772196129000
31	2025-10-07	0	1	0	0	18	KARIM		\N	\N	\N	0	1772196129000
32	2025-10-16	1	0	0	0	18	KARIM	Beb Hssine	\N	\N	\N	0	1772196129000
33	2025-10-31	1	0	0	0	18	BASSEM	13	\N	\N	\N	0	1772196129000
34	2025-11-01	1	0	0	0	18	KARIM	SADOK	\N	\N	\N	0	1772196129000
35	2025-11-06	0	1	0	0	18	KARIM	SKANDER	\N	\N	\N	0	1772196129000
36	2025-11-11	0	1	0	0	18	BASSEM		\N	\N	\N	0	1772196129000
37	2025-11-19	0	2	0	0	36	BASSEM		\N	\N	\N	0	1772196129000
38	2025-11-21	1	0	0	0	18	KARIM		\N	\N	\N	0	1772196129000
39	2025-11-25	1	0	0	0	18	KARIM		\N	\N	\N	0	1772196129000
40	2025-11-29	1	0	0	0	18	KARIM		\N	\N	\N	0	1772196129000
41	2025-12-08	0	1	0	0	18	KARIM		\N	\N	\N	0	1772196129000
42	2025-12-09	0	1	0	0	18	KARIM	ZIED	\N	\N	\N	0	1772196129000
43	2025-12-11	0	1	0	0	18	KARIM		\N	\N	\N	0	1772196129000
44	2025-12-12	0	1	0	0	18	BASSEM		\N	\N	\N	0	1772196129000
45	2025-12-16	0	1	0	0	18	BASSEM		\N	\N	\N	0	1772196129000
46	2025-12-18	1	0	0	0	18	KARIM		\N	\N	\N	0	1772196129000
47	2025-12-19	1	0	0	0	18	KARIM		\N	\N	\N	0	1772196129000
48	2025-12-20	0	1	0	0	18	BASSEM		\N	\N	\N	0	1772196129000
49	2025-12-20	1	0	0	0	18	BASSEM		\N	\N	\N	0	1772196129000
50	2025-12-22	0	1	0	0	18	BASSEM		\N	\N	\N	0	1772196129000
51	2025-12-30	0	1	0	0	18	BASSEM		\N	\N	\N	0	1772196129000
52	2026-01-02	0	1	0	0	18	YASSIN		\N	\N	\N	0	1772196129000
53	2026-01-05	0	1	0	0	18	YASSIN		\N	\N	\N	0	1772196129000
54	2026-01-08	0	1	0	0	18	YASSIN		\N	\N	\N	0	1772196129000
55	2026-01-10	0	1	0	0	18	YASSIN		\N	\N	\N	0	1772196129000
56	2026-01-13	0	2	0	0	36	YASSIN		\N	\N	\N	0	1772196129000
57	2026-01-16	1	0	0	0	18	KARIM	Adam BEN HSIN	\N	\N	\N	0	1772196129000
58	2026-01-21	0	1	0	0	18	KARIM	LARIANI	\N	\N	\N	0	1772196129000
59	2026-01-26	0	1	0	0	18	YASSIN	Ramzi BALOUTI	\N	\N	\N	0	1772196129000
60	2026-01-26	0	1	0	0	18	YASSIN		\N	\N	\N	0	1772196129000
61	2026-02-02	1	0	0	0	18	YASSIN		\N	\N	\N	0	1772196129000
62	2026-02-02	0	1	0	0	18	YASSIN	Ali	\N	\N	\N	0	1772196129000
63	2026-02-04	0	1	0	0	18	YASSIN	wael	\N	\N	\N	0	1772196129000
64	2026-02-05	1	0	0	0	18	KARIM	Adam BEN HSIN	\N	\N	\N	0	1772196129000
65	2026-02-06	1	0	0	0	18	KARIM	SABER HR	\N	\N	\N	0	1772196129000
66	2026-02-09	0	1	0	0	18	YASSIN	Sami	\N	\N	\N	0	1772196129000
67	2026-02-09	0	1	0	0	18	YASSIN	Abdeslem	\N	\N	\N	0	1772196129000
68	2026-02-14	1	0	0	0	14	YASSIN	Adam	\N	\N	\N	0	1772196129000
69	2026-02-14	0	1	0	0	18	KARIM	Skander	\N	\N	\N	0	1772196129000
70	2026-02-16	1	0	0	0	18	YASSIN	Saber Hr	\N	\N	\N	0	1772196129000
71	2026-02-16	1	0	0	0	18	YASSIN	Amir kirat	\N	\N	\N	0	1772196129000
72	2026-02-16	0	1	0	0	18	KARIM	Zied Mlawah	\N	\N	\N	0	1772196129000
73	2026-02-17	0	1	0	0	18	YASSIN	abdlkader hedfi	\N	\N	\N	0	1772196129000
74	2026-02-17	0	1	0	0	18	YASSIN	choaaib	\N	\N	\N	0	1772196129000
75	2026-02-18	0	1	0	0	18	YASSIN	Ramzi ballouti	\N	\N	\N	0	1772196129000
76	2026-02-20	0	1	0	0	18	YASSIN	Hazem Aalayet	\N	\N	\N	0	1772196129000
77	2026-02-23	0	1	0	0	18	YASSIN	Yacin Allagui	YASSIN	KARIM	1773137408243	0	1772196129000
78	2026-02-23	2	0	0	0	36	KARIM	Adem Ben Hssin	\N	\N	\N	0	1772267653000
79	2026-02-27	0	1	0	0	18	KARIM		\N	\N	\N	0	1772267763000
80	2026-02-28	0	1	0	0	18	KARIM	Med (bras visiére spring)	\N	\N	\N	0	1772280017000
81	2026-03-02	0	1	0	0	18	YASSIN	Iptissem MANSOURI	\N	\N	\N	0	1772537914000
82	2026-03-11	0	1	0	0	18	KARIM	Kais HADDAGI	\N	\N	\N	0	1773321866000
83	2026-03-13	2	0	0	0	36	KARIM	Abdelkader HEDFI	\N	\N	\N	0	1773837204000
84	2026-03-14	1	0	0	0	17	KARIM	Adem BEN HSSIN	\N	\N	\N	0	1773837249000
85	2026-03-18	1	0	0	0	18	KARIM	Lassaad GOUIDER	\N	\N	\N	0	1773837270000
86	2026-02-23	0	1	0	0	18	KARIM	Kilani FERCHICHI	\N	\N	\N	0	1773837668000
87	2026-03-24	1	0	0	0	18	KARIM	Adem BEN HSSIN	\N	\N	\N	0	1774338049000
88	2026-03-28	0	1	0	0	18	YASSIN	Abdelkader HEDFI	YASSIN	\N	1774969243966	0	1774700883000
89	2026-03-31	0	0	0	0	1	ANAS		YASSIN	KARIM	1774969854477	211	1774969849000
90	2026-04-01	1	0	0	0	18	KARIM	Adem BEN HSSIN	\N	\N	\N	0	1775028398000
91	2026-04-03	0	1	0	0	18	YASSIN	Ramzi BALOUTI	\N	\N	\N	0	1775202281000
92	2026-04-08	0	1	0	0	18	YASSIN	Ahmed AAGRBI	\N	\N	\N	0	1775647274000
93	2026-04-06	24	0	0	0	471	KARIM	STE SOPREM	\N	\N	\N	0	1775810158000
94	2026-04-10	0	1	0	0	18	YASSIN	passager	\N	\N	\N	0	1775892417000
95	2026-04-11	1	0	0	0	18	KARIM	Adem BEN HSSIN	\N	\N	\N	0	1775892450000
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (id, nom_prenom, designation, avance, date, numero_telephone, remarque, created_at) FROM stdin;
1	Abdelkader hedfi	Cache selle Noir XXL	0	2026-01-18			1774255910000
2	skander ben mrida	Casque TNL Black S	0	2026-02-13			1774255910000
3	Mohamed ben salem	Casque TNL Black L	0	2026-02-03	54278133		1774255910000
4	yassin riahi	compteur powere	0	2026-02-25	54498598		1774255910000
5	Othman	visiére power noir	0	2026-02-26	22147673		1774255910000
6	Dhia bouaadila	visiére+support+lampe	0	2026-03-01	28152417		1774255910000
7	Aziz ben Ahmed	Carénage avant	0	2026-03-03			1774255910000
8	Bilel Ghrairi	Visiére HR+	0	2026-03-11	55047200		1774255910000
9	Hamza Badr	support pied droit HR+	0	2026-03-05			1774255910000
10	Ayoub essid	support pied droit HR++cache filtre	0	2026-03-13	93280837		1774255910000
11	Anouar Abdalah	Chiane kemla+bougie	0	2026-03-14			1774255910000
12	HASSEN ARFAOUI	visiére power noir	0	2026-03-25	29957529		1774424203000
13	Hassen KASDAOUI	pedale freins power	0	2026-03-25	97161217		1774424258000
\.


--
-- Data for Name: product_families; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_families (id, name, created_at) FROM stdin;
1	Motos	1776955635000
\.


--
-- Data for Name: product_prices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_prices (id, number, designation, prix_vente_ttc) FROM stdin;
53	1	BAVETTE BOOSTER 2004 TAIWAN	9.261
54	2	AFFICHEUR DE TEMPERATURE+HORLOGE SC	9.959
55	3	AFFICHEUR DE VITESSE POWER 110	3.792
56	4	AILES COLORE GHOST V7	169
57	5	AILES JLM 110 BLEU	40.665
58	6	AILES JLM 110 GRIS	40.665
59	7	AILES JLM 110 ORIGINE	40.665
60	8	ALARME POUR MOTO	27.783
61	9	AMORTISSEUR GHOST V7	183
62	10	AMORTISSEUR NITRO  320mm	32.101
63	11	AMPOULE LED H4 AVEC VENTILATEUR TNN	28.938
64	12	AMPOULE LED H4 AVEC VENTILATUEUR 3F	28.938
65	13	AMPOULE LED H7 AVEC VENTILATEUR TNN	29.52
66	14	ANTI PARASIT PGT ACIER	1.365
67	15	APPAREIL COMPTEUR BOOSTER	14.965
68	16	APPAREIL COMPTEUR OVETT SEMI DIG NM	22.574
69	17	APPAREIL COMPTEUR OVETTO NM	14.965
70	18	APPAREIL COMPTEUR SH150/125	12.653
71	19	APPAREIL COMPTEUR SPRING ST 125	14.632
72	20	APPAREIL COUPE COURANT SPRING ST125	16.8
73	21	APPAREIL STOP DROITE  PISTA VCX	9.8
74	22	APPAREIL STOP GAUCHE  PISTA VCX	9.8
75	23	APPAREIL STOP POWER / SUPER50 /GY50	5.102
76	24	APPARIEL CLIGNOTANT GHOST V 7	12.8
77	25	ARBRE A CAME GHOST V7	25.6
78	26	ARBRE A CAME GY150	25.21
79	27	ARBRE A CAME POWER 110	12.445
80	28	ARBRE A CAME POWER 70cc	11.474
81	29	ARBRE A CAME SPRING ST 125 AM	17.445
82	30	ARBRE A CAME SPRING ST 125 NV	17.445
83	31	ATTACHE CABLE COMPTEUR POWER 110	2.1
84	32	AVERTISSEUR GHOST V7	8.6
85	33	AXE BEQUILLE CENTRALE JLM 110	2.551
86	34	AXE BLOCAGE VTT ARR 18 cm	4.249
87	35	AXE BOITE PISTA VCX	12.604
88	36	AXE BROCHE AD 50	14.118
89	37	AXE BROCHE BOOSTER 100	12.458
90	38	AXE BROCHE HONDA BALI 100	10.546
91	39	AXE BROCHE MOTOSIERRE 50	5.961
92	40	AXE BROCHE PISTA VCX 7.5CM	12.958
93	41	AXE BROCHE POWER MECANIQUE	14.691
94	42	AXE BROCHE SPRING ST 125	17.8
95	43	AXE CENTRALE GHOST V7	3.502
96	44	AXE DE ROUE ARRIERE GHOST V7	4.2
97	45	AXE DE ROUE ARRIERE PISTA HR	6.141
98	46	AXE DE ROUE AVANT  POWER110	4.161
99	47	AXE DE ROUE AVANT GHOST V7	4.356
100	48	AXE DE ROUE AVANT PISTA HR	6.141
101	49	AXE FOURCHE POWER 110	4.119
102	50	AXE FOURCHE POWER 110	4.119
103	51	AXE PEDALIER PGT	10.53
104	52	AXE TOCK PM 55MM	2.15
105	53	AXE TOCK POWER110/JLM110 GM	1.947
106	54	BAGUE BIELLE BOOSTER 50	2.595
107	55	BAGUE BIELLE BUXY 50	1.699
108	56	BATTERIE GEL -YTX7A GM TNN	66.448
109	57	BATTERIE GEL-12N9  GM TNN	59.574
110	58	BAVETTE ARR PISTA HR	17.9
111	59	BAVETTE ARR PISTA VCX	17.9
112	60	BAVETTE ARRIERE GHOST V7	27.9
113	61	BAVETTE ARRIERE+ PASSAGE DE ROUE  SPRING ST 125	36.585
114	62	BAVETTE BOOSTER 2003-SPIRIT	8.682
115	63	BAVETTE NITRO + REFLECTEUR NM	11.576
116	64	BAVETTE NITRO AM	11.576
117	65	BAVETTE STUNT SLIDER NM	10.71
118	66	BAVETTE TYPHOON 50	15.816
119	67	BENDIX COMPLET GHOST V7	47.998
120	68	BEQUILLE CENTRAL SPRING ST 125	33.9
121	69	BEQUILLE CENTRALE GHOST V7	40.733
122	70	BEQUILLE CENTRALE NITRO 50	22.954
123	71	BEQUILLE CENTRALE SH 125/150	41.636
124	72	BEQUILLE CENTRALE VTT ALUM NOIR REG	13.346
125	73	BEQUILLE LATERAL GHOST V 7	28.616
126	74	BEQUILLE LATERALE PISTA VCX	13.23
127	75	BEQUILLE LATERALE STUNT	18.616
128	76	BIELLE BUXY TNN	15.281
129	77	BIELLE DT 50 ORDINAIRE	6.66
130	78	BIELLE DT50 YOKO	12.619
131	79	BIELLE GY125 TNN	25.849
132	80	BIELLE JLM 110 ORIGINE	16.98
133	81	BIELLE JLM 70	10.645
134	82	BIELLE MBK AV7 TNN	13.075
135	83	BIELLE MOTOSIERRA 50 TNN	23.535
136	84	BIELLE PGT TNN	13.666
137	85	BIELLE VISION YOKO	12.619
138	86	BLOC  CDI GHOST V7	37.781
139	87	BLOC CDI BOOSTER AM	7.47
140	88	BLOC CDI GY 150 RACING	24.351
141	89	BLOC CDI KYMCO   6 FICHES	34.602
142	90	BLOC CDI KYMCO 50   -6FILES	60.897
143	91	BLOC CDI KYMCO50 AGILITY 8F	66.116
144	92	BLOC CDI PGT 3 FICHES	6.133
145	93	BLOC CDI PGT 5 FICHES 6V	8.311
146	94	BLOC CDI POWER 10 4F ORIGINE	15.659
147	95	BLOC CDI POWER 6 FICHES	15.604
148	96	BLOC CDI SPRING ST 125	18.659
149	97	BLOC MOTEUR COMPLET POWER 110	751.365
150	98	BLOC MOTEUR JOC-J 110	1110
151	99	BLOC MOTEUR SPRING ST 125	1071
152	100	BOBINE CADRE  GHOST V 7	19.695
153	101	BOBINE CADRE APRILIA	36.227
154	102	BOBINE CADRE DERBY	33.573
155	103	BOBINE CADRE PGT NM	11.781
156	104	BOBINE CADRE PISTA VCX	9.695
157	105	BOBINE CADRE POWER 110	7.977
158	106	BOBINE CADRE SPRING ST 125	12.977
159	107	BOBINE CADRE STALKER 97/PIAGGIO	31.252
160	108	BOBINE CADRE TYPHOON 3 FICHES	31.921
161	109	BOBINE D'ECLAIRAGE PGT	5.704
162	110	BOBINE MASSE CIAO	11.106
163	111	BOBINE MASSE MAJESTY 125	20.249
164	112	BOBINE MASSE PGT 10W	3.624
165	113	BOBINE MASSE PGT 15W	4.624
166	114	BOITE DE TRANSMISSION PISTA VCX	45.28
167	115	BOITE SELECTEUR DE VITESSE CG 125	28.552
168	116	BOITE SELECTEUR DE VITESSE DY150	30.227
169	117	BOITE VITESSE AUTOMATIQUE POWER 110	29.167
170	118	BOITE VITESSE CG 125	50.402
171	119	BOITE VITESSE COMPLET POWER MAX	54.039
172	120	BOITE VITESSE DY150	65.222
173	121	BOITE VITESSE MEC POWER 110 NICE CO	54.426
174	122	BOITE VITESSE SPRING ST 125 AM	64.039
175	123	BOITE VITESSE SPRING ST 125 NM	64.039
176	124	BOITIER POMPE A HUILE LUDIX	53.201
177	125	BOITIER VESPA PK50	14.237
178	126	BOUCHON CARTERE PISTA VCX	7.174
179	127	BOUCHON RESERVOIR GHOST V7	9.5
180	128	BOUCHON RESERVOIR JLM 110	4.764
181	129	BOUCHON RESERVOIR SPRING ST 125	9.764
182	130	BOUCHON+CACHE BOUCHON RESRVOIR PISTA HR	6.5
183	131	BOULON BEQUILLE GHOST V7	7.89
184	132	BOULON SUPPORT MOTEUR POWER 110 105mm	1.135
185	133	BOUTON CLIGNOTANT OVETTO JLM 110	1.148
186	134	BRAS DE KICK BOOSTER AM FONTE	8
187	135	BRAS DE KICK BOOSTER NM FONTE NOIR	8.5
188	136	BRAS DE KICK BOXTER 50	12.555
189	137	BRAS DE KICK GHOST V7	19.2
190	138	BRAS DE KICK SPRING ST 125 NV	12.299
191	139	BRAS D'EMBRAYAGE DY150	7.797
192	140	BRAS MANIVELLE VTT ALUM HG	9.903
193	141	CABLE  ACCELERATEUR  GHOST V7	9.68
194	142	CABLE  SELLE GHOST V7	7.9
195	143	CABLE ACCELERATEUR SPRING ST 125	11.359
196	144	CABLE APPAREIL COUPE COURANT PISTA HR	15.8
197	145	CABLE APPAREIL STOP POWER 110	2.551
198	146	CABLE COFFRE PISTA HR	7.8
199	147	CABLE COFFRE SPRING ST 125	12.8
200	148	CABLE COMPTEUR  MATRIX  YAMAX 50 TN	5.781
201	149	CABLE COMPTEUR BOOSTER	5.102
202	150	CABLE COMPTEUR CIAO	5.198
203	151	CABLE COMPTEUR JLM KTM 110	6.07
204	152	CABLE COMPTEUR MALAGUTTI	4.166
205	153	CABLE COMPTEUR MOTOSIERRA 125	5.781
206	154	CABLE COMPTEUR MOTOSIERRA 50	5.781
207	155	CABLE COMPTEUR NITRO AM TNN	4.764
208	156	CABLE COMPTEUR PISTA VCX/NITRO NM ORG	6.804
209	157	CABLE COMPTEUR SPRING ST 125	11.5
210	158	CABLE COUPE COURANT  BEQUILLE LATERALE  GHOST V7	19.8
211	159	CABLE FREIN BOOSTER NM  TNN ORIGINE	5.789
212	160	CABLE FREIN BOOSTER TNN	3.596
213	161	CABLE FREIN CG 125	5.781
214	162	CABLE FREIN MAJESTY 125	5.781
215	163	CABLE FRIEN ARRIERE PISTA HR	7.3
216	164	CABLE STARTER SPRING S T 125	4.084
217	165	CACHE BATTERIE PISTA VCX	11.176
218	166	CACHE BATTERIE SPRING ST 125	45.8
219	167	CACHE BOITE PISTA VCX	26.984
220	168	CACHE CULASSE PISTA VCX ALUM	7.047
221	169	CACHE CYLINDRE GHOST V7	22.6
222	170	CACHE CYLINDRE PISTA VCX	12.118
223	171	CACHE ECHAPPEMENT  GHOST V7	21
224	172	CACHE ECHAPPEMENT BOOSTER PLASTIQUE	3.035
225	173	CACHE ECHAPPEMENT PISTA	4
226	174	CACHE FEU STOP BRAVO	7.249
227	175	CACHE FEU STOP LIBERTY 50	4.748
228	176	CACHE FEU STOP NITRO	5.631
229	177	CACHE FEU STOP OVETTO ROUGE TNN	5.209
230	178	CACHE FEU STOP SPIRIT TRANSPARANT	7.815
231	179	CACHE FEU STOP STUNT	6.631
232	180	CACHE FEU STOP SUPER 50 COMPLET	4.631
233	181	CACHE FEU STOP TYPHOON	5.789
234	182	CACHE FRENIFLARD PISTA VCX	9.45
235	183	CACHE MISE EN MARCHE GHOST V7	89.254
236	184	CACHE PIGNON AVANT POWER	7.84
237	185	CACHE RESERVOIRE PISTA HR	39.715
238	186	CACHE VENTILATEUR  GHOST V7	22.2
239	187	CACHE VENTILATEUR +CACHE CYLINDRE PISTA VCX	18.9
240	188	CADENA VELO 650MM	6.925
241	189	CADENAS VTT SPIRALLE CODEE  12*1200MM	13.335
242	190	CAGE CARTER CG 125	42.009
243	191	CAGE CARTER MISE EN MARCHE PLASTIQUE PISTAVCX HR/JOC J	13
244	192	CAGE CHAINE POWER 110	7.113
245	193	CAGE CYLINDRE BOOSTER	6.946
246	194	CAGE CYLINDRE LIBERTY 50	14.42
247	195	CAGE D'ACCES CARBURATEUR PISTA HR	8.5
248	196	CAGE MISE EN MARCHE PISTA JOC-J/HR	70.269
249	197	CAGE MISE EN MARCHE PLASTIQ PISTA VCX	13
250	198	CAGE SERIE BOOSTER 2004	6.124
251	199	CAGE VENTILATEUR BOOSTER	4.818
252	200	CAGE VENTILATEUR BUXY	8.094
253	201	CAGE VENTILATEUR LUDIX	10.418
254	202	CAGE VENTILATEUR STUNT	9.312
255	203	CAGE VENTILATEUR TYPHOON 50 AM	10.501
256	204	CAGE VENTILATEUR TYPHOON 50 NM	16.733
257	205	CAGE VOLANT GAUCHE POWER MAX ORIGIN	35.403
258	206	CAGE VOLANT SPRING ST 125 AM	39.65
259	207	CAGE VOLANT SPRING ST 125 NM	39.65
260	208	CARBURATEUR BOOSTER 50 12 TNN	45.92
261	209	CARBURATEUR BOOSTER 50 17.5 TNN	48.97
262	210	CARBURATEUR CG125	50.649
263	211	CARBURATEUR PGT NM COMPLET	34.546
264	212	CARBURATEUR POWER 110 ORIGINE	56.062
265	213	CARBURATEUR SPRING ST 125	66.062
266	214	CARBURATEUR TYPHOON 50 TNN	48.206
267	215	CARENAGE  FEU  AVANT  GHOST V7	82.705
268	216	CARENAGE CLIGNOTANT TYPHOON 2008	34.58
269	217	CARENAGE COMPLET BWS 2004 TAIWAN BLANC	298
270	218	CARENAGE COMPLET BWS 2004 TAIWAN BLEU	298
271	219	CARENAGE COMPLET BWS 2004 TAIWAN NOIR	298
272	220	CARENAGE COMPLET GHOST V7	823
273	221	CARENAGE COMPLET GHOST V7 (BLACK)	823
274	222	CARENAGE COMPLET MAXIMUM 110  M-6 16 PIECES	325
275	223	CARENAGE COMPLET SPRING ST 125	462
276	224	CARENAGE COMPTEUR BOOSTER 2004	28.266
277	225	CARENAGE COMPTEUR COLORE GHOST V7	38.687
278	226	CARENAGE COMPTEUR JLM 110 D'ORI	19.531
279	227	CARENAGE COMPTEUR PISTA HR	57.1
280	228	CARENAGE COMPTEUR PISTA VCX	28.035
281	229	CARENAGE COMPTEUR TYPHOON 2008	28.791
282	230	CARENAGE LATERAL CENTRAL  GHOST V7	169
283	231	CARENAGE LATERAL PISTA VCX	66.91
284	232	CARENAGE OPTIQUE POWER 110 NOIR	11.799
285	233	CARENAGE OPTIQUE SPRING ST 125	36.9
286	234	CARENAGE OPTlQUE AVANT COLORE GHOST V7	83.103
287	235	CARENAGE SOUS OPTIQUE JLM BLEU	19.49
288	236	CARENAGE SOUS OPTIQUE JLM GRIS	19.49
289	237	CARTER  COMPLET SPRING ST 125 ANCIE	121
290	238	CARTER BLOC MOTEUR PISTA VCX	74.34
291	239	CARTER CIAO ORIGINE	65.103
292	240	CARTER COMPLET MBK AV7	50.329
293	241	CARTER COMPLET PGT 103	52.461
294	242	CARTER COMPLET POWER 110	101.453
295	243	CARTER COMPLET SPRING ST 125 NM	121.9
296	244	CARTER CPL SPRING ST 125 AM	121.9
297	245	CARTER PISTA VCX	48.808
298	246	CASQUE VELO AVEC LUNETTE	51.266
299	247	CHAINE  DE DISTRIBUTION GHOST V7	13.54
300	248	CHAINE DISTRIBUTION GY 125-90L	10.017
301	249	CHAINE DISTRIBUTION JLM 110 90L	4.764
302	250	CHAINE DISTRIBUTION LIBERTY 125-88L	13.843
303	251	CHAINE DISTRIBUTION PISTA VCX	9.441
304	252	CHAINE DISTRIBUTION POWER 110 84L	5.775
305	253	CHAINE DISTRIBUTION POWER 70-25H-62	3.743
306	254	CHAINE DISTRIBUTION SPRING ST 125 AN	11.772
307	255	CHAINE DISTRIBUTION SPRING ST NM	11.772
308	256	CHAMBRE A AIR   KT 2.75-14  F/V	5.251
309	257	CHAMBRE A AIR   KT 4.00-17  TR4	13.32
310	258	CHAMBRE A AIR   KT 4.00-18  TR4	13.32
311	259	CHAMBRE A AIR   KT 4.10-18  TR4	13.324
312	260	CHAMBRE A AIR  TNN 20*1.95 F/V 43MM	6.22
313	261	CHAMBRE A AIR TNN  12*1.95 F/V	4.816
314	262	CHAMBRE A AIR TNN  120/70/10 JS87	12.12
315	263	CHAMBRE A AIR TNN  130/60/13 JS87	11.085
316	264	CHAMBRE A AIR TNN  130/70/12 JS87	12.599
317	265	CHAMBRE A AIR TNN  130/90/10 JS87	12.98
318	266	CHAMBRE A AIR TNN  16*1.95 F/V	5.844
319	267	CHAMBRE A AIR TNN  2.75-14  TR4	8.554
320	268	CHAMBRE A AIR TNN  2.75-16  TR4	8.981
321	269	CHAMBRE A AIR TNN  2.75-17  TR4	9.877
322	270	CHAMBRE A AIR TNN  20*1.95 F/V	5.9
323	271	CHAMBRE A AIR TNN  24*1.95 F/V 33/4	5.882
324	272	CHAMBRE A AIR TNN  26*1.95 F/V	5.992
325	273	CHAMBRE A AIR TNN  3.50-10  JS87	8.622
326	274	CHAMBRE A AIR TNN  4.00-17  TR4	13.915
327	275	CHAMBRE A AIR TNN  4.00-18  TR4	13.328
328	276	CHAMBRE A AIR TNN  4.00-8  JS87	9.398
329	277	CHAMBRE A AIR TNN  4.10-18  TR4	13.997
330	278	CHAMBRE A AIR TNN  4.50-12  TR13	11.317
331	279	CHAMBRE A AIR TNN  90-90-21  TR4	11.196
332	280	CHAMBRE A AIR TNN 110-90-16 TR4	9.209
333	281	CHAMBRE A AIR TNN 120/70/12 JS87	12.499
334	282	CHAMBRE A AIR TNN 2.25-16 F/V	8.781
335	283	CHAMBRE A AIR TNN 20.195 F/V 48MM	6.32
336	284	CHAMBRE A AIR TNN 24*1.3/8 F/V	5.453
337	285	CHAMBRE A AIR TNN 24*1.3/8 TR4	5.557
338	286	CHAMBRE A AIR TNN 26*1.3/8 TR4	5.924
339	287	CHAMBRE A AIR TNN 26*2.00 F/V	4.997
340	288	CHAMBRE A AIR TNN 300/17 TR4	9.527
341	289	CHAMBRE A AIR TNN 300/18 TR4	10.228
342	290	CHAMBRE A AIR TNN 700C-28 F/V 33 MM	6.893
343	291	CHAMBRE A AIR TNN 700C-28 F/V 47 MM	6.893
344	292	CHAMBRE A AIR TNN 700C-35 F/V 33 MM	6.992
345	293	CHAMBRE A AIR TNN 700C-35 F/V 47 MM	6.992
346	294	CHAMBRE A AIR6-1/2*2L	6.6
347	295	CHARGEUR USB+SUPPORT ALUME CIGARE AVEC BOUTON OFF/ON	16.807
348	296	CLAPET D'ESSENCE BOOSTER	6.259
349	297	CLAPET D'ESSENCE BUXY	7.823
350	298	CLE BOUGIE POWER 110	2.503
351	299	COLIER RETRVISSEUR SPRING ST 125 G	5.662
352	300	COLLIER RETROVISEUR GAUCHE POWER110	3
353	301	COLLIER TIGE DE SELLE 27MM	7.304
354	302	COLLIER TIGE DE SELLE 30MM	7.304
355	303	COMMUTATEUR COMMODO NITRO D CARBON	10.385
356	304	COMMUTATEUR COMMODO NITRO DROITE	9.316
357	305	COMMUTATEUR COMMODO NITRO GAUCHE	9.316
358	306	COMMUTATEUR DE CLE PIAGGIO	17
359	307	COMPTEUR BOOSTER ROCKET	36.66
360	308	COMPTEUR DIGITAL PISTA VCX	77.28
361	309	COMPTEUR GHOST V7	138.4
362	310	COMPTEUR KTM 110 DEMI DIGITAL DIAM	47.959
363	311	COMPTEUR SPRING ST 125	105.8
364	312	CONTACT COFFRE BOOSTER ROCKET TNN	24.641
365	313	CONTACT COFFRE BWS ROCKET COMPLET	23.934
366	314	CONTACT MOTOSIERRA 50	18.922
367	315	CONTACT POWER 110	11.445
368	316	CONTACT SH 150	42.39
369	317	COQUE PISTA HR COMPLET	140
370	318	COQUE PISTA VCX COMPLET	119
371	319	CORPS CARBURATEUR PGT AM	29.853
372	320	COURONNE   PGT-103-56T	12.575
373	321	COURROIE  GHOST V7	53.8
374	322	COURROIE A48 DENTE	3.6
375	323	COURROIE GY125/SUPER 50  842*20*30	7.595
376	324	COURROIE HONDA BALI 50 700 15*30	9.018
377	325	COURROIE HONDA HELIX 250 HEX 845*22	14.33
378	326	COURROIE KYMCO 50 676*18*30 KTMP	9.03
379	327	COURROIE LIBERTY 125 830*18*30	8.963
380	328	COURROIE LIBERTY 50 2T 830*18.5*30	12.854
381	329	COURROIE LIBERTY 50 4T 601*20*30	11.952
382	330	COURROIE NH50  745-16*30	7.595
383	331	COURROIE PIAG ZIP 4T/ET2/ITALJET 73	12.51
384	332	COURROIE PIAGGIO LX 2T-4T 725*17.5	9.261
385	333	COURROIE PIAGGIO ZIP 50 734*17*30	11.594
386	334	COURROIE POMPE A AHUILE PIAGGIO125 OEM 286162/0 6MM*80T	7.665
387	335	COURROIE POMPE A HUILE PIAGGIO50 OEM 286162/0 6MM*80T TNN	6.3
388	336	COURROIE SH125   916*22*30	13.918
389	337	COURROIE SH125 BANDO	38.777
390	338	COURROIE SUZUKI KATANA 50 770*16.3	12.312
391	339	COURROIE TYPHOON 804*17.5	11.739
392	340	COUSSIN ARRIERE SPRING ST 125	23
393	341	COUVERCLE BOITE DE RANGEMENT GHOST V7	14.28
394	342	COUVERCLE CONTACT OVETTO TNN	1.98
395	343	COUVRE SELLE GEL GEVATI	11.979
396	344	COUVRE SELLE SCOOTEUR	9.365
397	345	CROCHET PORTE CASQUE BOOSTER 2004	4.631
398	346	CULASSE GHOST V7	135.599
399	347	CULASSE MOTOSIERRA 150	72.5
400	348	CULASSE PISTA JOC-J 51mm CPL	113.359
401	349	CULASSE PISTA VCX  49 mm CPL	113.359
402	350	CULASSE SPRING ST 125 NM	105.738
403	351	CULASSE TYPHOON 50	27.533
404	352	CULBITEUR COMPLET MOTOSIERRA 125	15.97
405	353	CULBITEUR SPRING ST 125 AM	19.28
406	354	CULBITEUR SPRING ST 125 NM	19.28
407	355	CULBUTEUR GHOST V7	23.584
408	356	CYLINDRE AD 50 *41mm TAIWAN	43.589
409	357	CYLINDRE BOOSTER 50     *FONTE*LUXE	48.546
410	358	CYLINDRE CG150	76.8
411	359	CYLINDRE CHALLENGER 125	75.26
412	360	CYLINDRE GHOST V7	92.292
413	361	CYLINDRE GY6-50	50.24
414	362	CYLINDRE HURRICANE 50	54.402
415	363	CYLINDRE HURRICANE 80  12mm	69.64
416	364	CYLINDRE KATANA 50	75.246
417	365	CYLINDRE KYMCO 50 AVEC CLAPET	64.826
418	366	CYLINDRE LUDIX 50 ALUM	64.124
419	367	CYLINDRE LUDIX 50 FONTE	60.228
420	368	CYLINDRE MAJESTY 125	109.827
421	369	CYLINDRE MBK AV10 LIQUIDE	26.369
422	370	CYLINDRE NITRO 50       *FONTE*LUXE	49.919
423	371	CYLINDRE NITRO 80       *FONTE*LUXE	70.617
424	372	CYLINDRE PGT 103	65.611
425	373	CYLINDRE PGT FOX	66.611
426	374	CYLINDRE POWER 110CC ORIGINE	62.983
427	375	CYLINDRE SH125	72.863
428	376	CYLINDRE SH150	104.398
429	377	CYLINDRE SPRING ST 125 AM	85.26
430	378	CYLINDRE SPRING ST 125 NM	85.26
431	379	DEMARREUR CG 125	57.147
432	380	DEMARREUR CG150	58.848
433	381	DEMARREUR GHOST V7	56.8
434	382	DEMARREUR HURRICANE	34.8
435	383	DEMARREUR INJECTION APRILIA	42.402
436	384	DEMARREUR KATANA	42.402
437	385	DEMARREUR PISTA HR	49.825
438	386	DEMARREUR PISTA VCX /JOC-J/HR	48.825
439	387	DEMARREUR POWER 110	36.046
440	388	DEMARREUR SH125/150	62.5
441	389	DEMARREUR SPRING ST 125 AM	46.046
442	390	DEMARREUR SPRING ST 125 NM	46.046
443	391	DEMARREUR ZIP,LIBERTY 50,FLY	34.479
444	392	DERAILLEUR ARR VTT HG +CROCHET	15.481
445	393	DERIVE CHAINE VELO	12.117
446	394	DISQUE DE FREIN ARRIERE  GHOST V7	47.9
447	395	DISQUE DE FREIN AVANT  GHOST V7	52.8
448	396	DISQUE D'EMBRAYAGE DY150	12.312
449	397	DISQUE D'EMBRAYAGE POWER COMPLET	9.92
450	398	DISQUE FREIN ARRIERE SPRING ST 125	26.472
451	399	DISQUE FREIN AV PISTA VCX	20.771
452	400	DISQUE FREIN AVANT SPRING ST 125	21.472
453	401	DISQUE FREIN BOOSTER 2004	26.423
454	402	DISQUE FREIN NITRO, OVETTO,MAJESTY	27.282
455	403	DISQUE POMPE A EAU NITRO	3.956
456	404	DOLPHIN SPRAY GRAISSE CHAINE 400ml	16.3
457	405	DOUILLE PROJECTEUR BOOSTER	3.5
458	406	DOUILLE PROJECTEUR NITRO TNN	3.5
459	407	DOUILLE PROJECTEUR POWER 110 ORIGIN	3.807
460	408	DOUILLE PROJECTEUR STUNT	3.5
461	409	DOUILLE VEILLEUSE LUDIX	5.66
462	410	DURITE RESERVOIRE D ESSENCE GHOST V7	2.254
463	411	ECHAPPEMENT  GHOST V7	92.98
464	412	ECHAPPEMENT BOOSTER 50 TNN	63.002
465	413	ECHAPPEMENT BRAVO	29.657
466	414	ECHAPPEMENT BUXY	85.285
467	415	ECHAPPEMENT CIAO	27.552
468	416	ECHAPPEMENT SI	25.862
469	417	ECHAPPEMENT SPEEDFIDHT	102.222
470	418	ECHAPPEMENT SPRING ST 125	89.585
471	419	ECLAIRAGE AVANT VTT DYNAMO	13.451
472	420	EMBRAYAGE ARR PISTA HR	66.7
473	421	EMBRAYAGE ARR PISTA VCX /JOC-J	67.272
474	422	EMBRAYAGE ARR SH 125 /150 COMPLET	66.5
475	423	EMBRAYAGE ARRIERE GHOST V7	86.523
476	424	EMBRAYAGE ARRIERE GY 50 COMPLET	60.059
477	425	EMBRAYAGE CG125 VIDE	29.255
478	426	EMBRAYAGE DY150	38.94
479	427	ETOILE JOUE FIXE PISTA VCX	3.447
480	428	ETRIE DE FRIEN  ARRIERE  GHOST V7	58.2
481	429	ETRIE DE FRIEN  AVANT GHOST V7	63.251
482	430	ETRIE FREIN CG 125	25.512
483	431	ETRIER FREIN PISTA HR	48.64
484	432	FEU ARRIERE GHOST V7	67.8
485	433	FEU DE PLAQUE MATRICULE GHOST V7	12.98
486	434	FEU STOP ARRIERE SPRING ST 125	32.939
487	435	FEU STOP DRAGON-VAVA	47.074
488	436	FEU STOP JLM 110 COMPLET	20.939
489	437	FEU STOP NITRO LED TNN	34.508
490	438	FEU STOP NITRO NM 2018 TNN	28.39
491	439	FEU STOP SI	11.59
492	440	FEU STOP SPIRIT	28.234
493	441	FEU STOP SPIRIT DIOD	31.224
494	442	FEU STOP STUNT	27.326
495	443	FEU STOP STUNT AVEC DIOD	30.025
496	444	FEU STOP TYPHOON	13.313
497	445	FILTRE A  AIR COMPLET GHOST V 7	39.6
498	446	FILTRE A AIR BOOSTER 100	18.709
499	447	FILTRE A AIR COMPETI STD 125	8.4
500	448	FILTRE A AIR DRAGON DEUX BOSSES	11.155
501	449	FILTRE A AIR GY150	4.64
502	450	FILTRE A AIR MAJESTY 125	7.133
503	451	FILTRE A AIR OVETTO	11.211
504	452	FILTRE A AIR PARTIE  INTERIEUR GHOST V 7	25.99
505	453	FILTRE A AIR PIAGGIO,TYPHOON 50,ZIP	27.878
506	454	FILTRE A AIR PISTA VCX CPL	27.25
507	455	FILTRE A AIR PISTA VCX PARTIE INTER	15.77
508	456	FILTRE A AIR SCARABEO	21.512
509	457	FILTRE A AIR SH150	14.965
510	458	FILTRE A AIR SPRING ST 125	14.996
511	459	FILTRE A HUILE APRILIA 600	17.364
512	460	FILTRE CARBURATEUR PGT NM	5.092
513	461	FILTRE COMPETITION 50/125	13.698
514	462	FILTRE PARTIE INTERIEUR PISTA HR+	16.558
515	463	FLASQUE FREIN ARR JLM 110 COMPL	20.412
516	464	FLASQUE FREIN ARRIERE PGT COMPLET	16.746
517	465	FLASQUE FREIN ARRIERE PGT SP COMPLE	11.338
518	466	FLASQUE FREIN ARRIERE PGT SP VIDE	7.214
519	467	FLASQUE MOYEAU ARRIERE SPRING ST125	32.852
520	468	FLASQUE STATOR COURANT PISTA HR	18.87
521	469	FLEXIBLE  DE FREIN ARRIERE CHOST V7	8.092
522	470	FLEXIBLE DE FREIN ARRIERE PARTIE 2 GHOST V7	11.449
523	471	FLEXIBLE DE FREIN AVANT GY125 / SPRING ST 125	9
524	472	FLEXIBLE DE FREIN AVANT PARTIE 1 GHOST V7	11.488
525	473	FLEXIBLE DE FREIN AVANT PARTIE 2 GHOST V7	11.488
526	474	FOURCHE ARRIERE POWER 110 AXE10 ORG	41.824
527	475	FOURCHETTE DE VITESSE DY150	14.361
528	476	FOURCHETTE DE VITESSE POWER MAX	13.157
529	477	FRIDEAU DE DEMARRAGE BRAVO	6.839
530	478	FRIDEAU DE FREIN ARRIERE PISTA VCX	10.98
531	479	FRIDEAU DE FREIN BUXY	8.979
532	480	FRIDEAU DE FREIN MBK	5.801
533	481	FRIDEAU D'EMBRAYAGE PGT WMPC	5.121
534	482	FRIDEAU D'EMBRAYAGE POWER 110 ORG	32.314
535	483	GARDE BOUT AV PISTA VCX	54.886
536	484	GARDE BOUT AVANT LUDIX 2008	25.199
537	485	GARDE BOUT AVANT SPRING ST	46.9
538	486	GARDE BOUT AVANT SPRING ST 125 CPL	56.6
539	487	GARDE BOUT PGT	27.996
540	488	GARDE CHAINE SI	21.834
541	489	GARDE CHAINE SPRING ST 125	33.9
542	490	GARDE-BOUT AVANT GHOST V7	66.9
543	491	GARDE-BOUT PARTIE  AVANT COLORE GHOST V7	42.84
544	492	GLACE COMPTEUR BOOSTER 2004	5.789
545	493	GLACE COMPTEUR JLM 110 ORGINE	4.797
546	494	GLACE COMPTEUR NITRO	5.789
547	495	GLACE COMPTEUR OVETTO 50 AM	6.503
548	496	GLACE COMPTEUR SPIRIT	6.124
549	497	GLACE OPTIQUE LX	13.335
550	498	GORGE FILTRE A AIR BOOSTER	2.9
551	499	GOUBLET D'HUILE GHOST V7	23.8
552	500	GOUJANT D'ECHAPPEMENT 6mm*L35+6mm*9.8	1.391
553	501	GUIDE CHAINE POWER 110	5.725
554	502	GUIDON PISTA VCX	58.2
555	503	GUIDON SPRING ST125	58.2
556	504	HUILE DE FOURCHE FASTER OIL 10W	9.022
557	505	HUILE DE FRIEN FASTER OIL DOT4 250ML	4.284
558	506	HUILE DE TRANSMISSION FASTER OIL 75W90 125 ml	5.6
559	507	HUILE POUR MOTO 10W40 FASTER OIL 4T API SN JASO MA2 1L	13.99
560	508	HUILE POUR MOTO 20W50  FASTER OIL 4T AP SL JASO MA2 1L	13.699
561	509	HUILE POUR MOTO 2T FASTER OIL TC-SAE 30	12.12
562	510	INSTALATION PISTA VCX	47.95
563	511	INSTALLATION   PISTA HR	47.95
564	512	INSTALLATION  GHOST V7	55.44
565	513	INSTALLATION COMPLET POWER 110 5F	29.106
566	514	INSTALLATION STATOR PGT AM	6.955
567	515	INTERRUPTEUR DE LA BOITE A OUTILS GHOST V7	2.904
568	516	INTERRUPTEUR ET FILS DU FREIN ARRIERE GHOST V7	9.8
569	517	JANTE ARRIERE 300-16 COMPLET	57.82
570	518	JAUGE  D'ESSENCE  GHOST V7	18.9
571	519	JAUGE D'ESSENCE POWER 110	6.224
572	520	JAUGE D'ESSENCE SPRING ST 125	12.143
573	521	JAUGE D'HUILE DY150	3.322
574	522	JAUGE D'HUILE GHOST V7	3.385
575	523	JAUGE D'HUILE JLM 110	1.95
576	524	JAUGE D'HUILE MATRIX	2.864
577	525	JAUGE D'HUILE PISTA VCX	4.163
578	526	JAUGE D'HUILE POWER 110 ORG	2.038
579	527	JAUGE D'HUILE SPRING ST 125 AM	3.028
580	528	JAUGE D'HUILE SPRING ST 125 NM	3.028
581	529	JEU DE 4 TOCK CG125	5.102
582	530	JEU DE 4 TOCK ELEGANCE	3.403
583	531	JEU DE 4 TOCK POWER 110	4.095
584	532	JEU DE BOITE VITESSE  GHOST V7	65.254
585	533	JEU DE DIRECTION BWS AM	10.755
586	534	JEU DE DIRECTION CIAO TNN	19.027
587	535	JEU DE DIRECTION GHOST V7	19.027
588	536	JEU DE DIRECTION MALAGUITI F10/	13.292
589	537	JEU DE DIRECTION PGT	7.263
590	538	JEU DE DIRECTION POWER 110	6.945
591	539	JEU DE DIRECTION SPRING ST 125	14.8
592	540	JEU DE DIRECTION VTT ORDINAIRE	3.813
593	541	JEU DE DIRECTION VTT SPECIAL	4.935
594	542	JEU DE GALET GHOST V7 13GR	13.328
595	543	JEU DE GALETS 15*12 TNT 4.5 GR	7.578
596	544	JEU DE GALETS 15*12 TNT 6.5 GR	7.578
597	545	JEU DE GALETS 15*12 TOP 5.0 gr	9.183
598	546	JEU DE GALETS 16*13 TNT 6.0 gr	6.658
599	547	JEU DE GALETS 16*13 TNT 6.5 gr	6.658
600	548	JEU DE GALETS 19*15.5 TNT 5gr PIAGG	9.277
601	549	JEU DE PARA-HUILE DY150	4.514
602	550	JEU DE PARAHUILE FOURCHE  PISTA VCX	8.8
603	551	JEU DE PARA-HUILE FOURCHE POWER 110	3.364
604	552	JEU DE PARA-HUILE LIBERTY 50	1.95
605	553	JEU DE PARA-HUILE MOTOSIERRA 125	4.015
606	554	JEU DE PATIN ARRIERE GHOST V7	23.8
607	555	JEU DE PATIN AVANT CHOST V7	20.3
608	556	JEU DE PATIN DE FREIN APRILIA SPORT CITY 125	7.259
609	557	JEU DE PATIN DE FREIN ARRIERE PISTA HR +	20
610	558	JEU DE PATIN DE FREIN BUXY	4.495
611	559	JEU DE PATIN DE FREIN MAJESTY 250	3.289
612	560	JEU DE PATIN DE FREIN MAJESTY125 AR	3.627
613	561	JEU DE PATIN DE FREIN NITRO	5.259
614	562	JEU DE PATIN DE FREIN PISTA HR	12.339
615	563	JEU DE PATIN DE FREIN PISTA HR+ AVANT	23
616	564	JEU DE PATIN DE FREIN SH125	9.806
617	565	JEU DE PATIN DE FREIN SH150	9.806
618	566	JEU DE PATIN DE FREIN SPEEDFIGHT	4.972
619	567	JEU DE PATIN DE FREIN SYM ARR OR	6.839
620	568	JEU DE PATIN DE FREIN SYM AVANT	3.627
621	569	JEU DE PATIN DE FRIEN DISQUE M2	6.136
622	570	JEU DE PATIN DE FRIEN DISQUE M3	6.136
623	571	JEU DE PATIN DE FRIEN DISQUE M4	6.136
624	572	JEU DE PATIN DE FRIEN HYPER	7.98
625	573	JEU DE SILENT BLOC BOOSTE/NITRO  50	5.808
626	574	JEU DE SILENT BLOC POWER 110   10"""	3.403
627	575	JEU DE SILENT BLOC POWER 110  12"""	3.781
628	576	JEU DE SILENT BLOC SPRING ST 125	6.54
629	577	JEU DE SOUPAPE DY150 COMPLET	10.641
630	578	JEU DE SOUPAPE LIBERTY 125	9.015
631	579	JEU DE SOUPAPE LIBERTY 50	8.199
632	580	JEU DE SOUPAPE MOTOSIERRA 50	6.741
633	581	JEU DE SOUPAPE MOTOSIERRE 150	9.176
634	582	JEU DE SOUPAPE SPRING ST 125 CPL AM	17.616
635	583	JEU DE SOUPAPE SPRING ST 125 CPL NM	17.615
636	584	JEU DE SOUPAPE SPRING ST 125 NU AM	11.615
637	585	JEU DE SOUPAPE SPRING ST 125 NU NM	11.615
638	586	JEU DURITE D' ESSENCE GHOST V7	6.664
639	587	JEU MANIVELLE ALUM VTT 1T 48T BRAS ALUM GANOPPER COULEUR	57.75
640	588	JEU MANIVELLE VTT 1T ALUM 52T HG	25.371
641	589	JEU MANIVELLE VTT 3 T ALUM	38.125
642	590	JEU MANIVELLE VTT 3T 24/34/42 SH AL	38.98
643	591	JEU MANIVELLE VTT 3T 28/38/48 NOIR	35.281
644	592	JOINT COUVERCLE D'ENGRENAGE GHOST V7	1.5
645	593	JOINT COUVERCLE DU CARTER PARTIE 2 GHOST  V7	1.5
646	594	JOINT DE COUVERCLE DE CARTER GHOST V7	1.5
647	595	JOINT DE COUVERCLE DU CARTER DROIT	1.5
648	596	JOINT ECHAPPEMENT BOOSTER 50	0.493
649	597	JOUE FIXE BOOSTER 100	19.531
650	598	JOUE FIXE BUXY	13.828
651	599	JOUE FIXE GILERA RUNNER 125/180 2T	39.938
652	600	JOUE FIXE LUDIX	10.617
653	601	JOUE FIXE MOTOSIERRE 50	8.563
654	602	JOUE FIXE PGT	9.866
655	603	JOUE MOBILE GHOST V7	64.8
656	604	JOUE MOBILE PISTA HR	56.8
657	605	KIT  PIGNON DAX	1.702
658	606	KIT 3 RESSORTS FRIDEAU EMBR JLM 110	1.471
659	607	KIT 3 RESSORTS PEDAL FREIN POWER 11	2.237
660	608	KIT 4 RESSORTS D'EMBRAYAGE POWER 11	1.864
661	609	KIT 5 PIGNON CHAPPY 13 T	1.702
662	610	KIT AXE DE KICK GHOST V7	21.354
663	611	KIT AXE SPRING ST 125 AXE BLOC+ROUE	3.028
664	612	KIT BLUETOOTH +MICRO POUR CASQUE MOTO	90
665	613	KIT BOUCHON  D 'HUILE  GHOST V7	7.8
666	614	KIT BOUCHONS CULASSE JLM 70	8.675
667	615	KIT BOUCHONS CULASSE POWER 110	10.274
668	616	KIT BOULONS DE TOCK POWER+AGRAFES	2.8
669	617	KIT BOULONS DEMARREUR JLM 110	1.445
670	618	KIT BOULONS+JOINT PIPE CARB KTM	2.8
671	619	KIT CACHE CLIGN+CACHE FEU AR NITRO	10.998
672	620	KIT CACHE CLIGNOTANT NITRO ORANGER	6.367
673	621	KIT CACHE CLIGNOTANT TYPHOON 50	7.178
674	622	KIT CARENAGE CENTRALE JLM 110 bleu	54.329
675	623	KIT CARENAGE CENTRALE JLM 110 GRIS	54.326
676	624	KIT CHAINE 420-35T-15  116L JLM 110	33.67
677	625	KIT CHAINE 428-36T-14T*116L ORG	33.504
678	626	KIT CONTACT GHOST V7	257
679	627	KIT CONTACT MATRIX 9-4T	22.652
680	628	KIT CONTACT NITRO TNN	52.009
681	629	KIT DISTRIBUTION POWER 110	12.622
682	630	KIT ECLAIRAGE VTT +DYNAMO	23.594
683	631	KIT FREIN VTT HYDRAULIQUE CPLT HG	74.55
684	632	KIT FREIN VTT NM ALUM	9.5
685	633	KIT MARCHE PIED GHOST V7 CAOUTCHOU	11.424
686	634	KIT NETOYEUR CHAINE	30.6
687	635	KIT PEDALIER BMX 20 inch	22.708
688	636	KIT POTENCE EMBRAYAGE BOOSTER 50	2.987
689	637	KIT POTENCE EMBRAYAGE PISTA VCX	2.987
690	638	KIT POTENCE EMBRAYAGE SH125	2.782
691	639	KIT ROULEMENT VILEBREQUIN LIBERTY 5	63.471
692	640	KIT SERRURE SELLE  GHOST V7	22.8
693	641	KIT VIS CAGE CARTER OVETTO EN FER	5.628
694	642	LECTEUR USB GHOST V7	12.138
695	643	LEVIER  DE FRIEN COMPLET AVANT GHOST V7	36.9
696	644	LEVIER CHANGEMENT DE VITESSE POWER	7.542
697	645	LEVIER DE FREIN GAUCHE COMPLT ZIP50	16.754
698	646	LEVIER DE FRIEN  ARRIERE  GHOST V7	36.248
699	647	LEVIER FREIN DROITE BOOSTER NM	4.084
700	648	LEVIER FREIN JLM 110 ORIGINE	3.5
701	649	LEVIER STARTER SPRING ST 125	2.533
702	650	LOGO CIAO	1.655
703	651	MACHOIR FREIN CIAO	5.5
704	652	MAITRE CYLINDRE +ETRIER PISTA HR	67.5
705	653	MAITRE CYLINDRE ARR  POWER 110 CPL	54.426
706	654	MAITRE CYLINDRE ARR POWER	18.804
707	655	MAITRE CYLINDRE AVANT POWER+ETRIER	54.426
708	656	MAITRE CYLINDRE D SPRING 125 CPL	64.98
709	657	MAITRE CYLINDRE DROITE POWER 110	15.05
710	658	MAITRE CYLINDRE+LEVIER D ET G NITRO	50.172
711	659	MAITRE CYLINDRE+LEVIER GAUCHE GY125	22.05
712	660	MAITRE CYLINDRE''G'' SPRING 125 CPL	68.585
713	661	MANETTE ACCELERATEUR BRAVO	19.891
714	662	MANETTE PGT AM DROITE	11.34
715	663	MANETTE PGT AM GAUCHE	9.476
716	664	MARCHE PIED BOOSTER 2004 TNN	67.5
717	665	MOYEU ARRIERE PGT   28T	41.109
718	666	MOYEU AVANT PGT      28T	35.887
719	667	MOYEU AVANT PGT      36T	39.951
720	668	MOYEU AVANT VTT 36T ALUM AVEC BLOC	9.115
721	669	NECESSAIRE BEQUILLE BRAVO	4.052
722	670	NECESSAIRE BEQUILLE CENTRALE PISTA VCX	4.747
723	671	NECESSAIRE BEQUILLE LIBERTY 50	9.015
724	672	NECESSAIRE BEQUILLE OVETTO	4.747
725	673	NECESSAIRE BEQUILLE TYPHOON 50	6.883
726	674	NECESSAIRE CARBURATEUR 50 AVEC FLOT	6.09
727	675	NECESSAIRE CARBURATEUR BUXY	6.09
728	676	NECESSAIRE CARBURATEUR GY125 AVEC F	6.51
729	677	NECESSAIRE CARBURATEUR JH70	4.38
730	678	NECESSAIRE CARBURATEUR PISTA VCX	7.781
731	679	NECESSAIRE CARBURATEUR POWER 110	4.958
732	680	NECESSAIRE FLASQUE FREIN PISTA VCX	4.291
733	681	NECESSAIRE POMPE A EAU NITRO	17.175
734	682	NECESSAIRE POMPE A EAU PIAGGIO 125	20.749
735	683	NECESSAIRE POMPE A EAU PIAGGIO 50	20.241
736	684	NECESSAIRE POMPE A EAU SH125/150	24.99
737	685	OPTIQUE BRAVO	12.871
738	686	PAIRE  COMMODO GHOST V7	44.8
739	687	PAIRE  LATERALE GHOST V7	144
740	688	PAIRE AILES SPRING ST 125 AV	158.99
741	689	PAIRE AMORTISSEUR HYD PGT 330	38.552
742	690	PAIRE AMORTISSEUR HYD PGT 360	37.887
743	691	PAIRE AMORTISSEUR SPRING ST 125	86.655
744	692	PAIRE BARRE GUIDON POWER 110	34.988
745	693	PAIRE CALLE AMORTISSEUR STD COLORS	4.644
746	694	PAIRE CARENAGE LATERAL SPRING ST AR	166.8
747	695	PAIRE CLIG ARR PISTA HR	28
748	696	PAIRE CLIG AV PISTA HR	36
749	697	PAIRE CLIG SCOOTEUR D-169	17.364
750	698	PAIRE CLIG STD TNN ACC071 DF 2COUL	17.364
751	699	PAIRE CLIGN STD N 67/69/12 SF FUMER	9.261
752	700	PAIRE CLIGN STD TNN 62/006 SF	8.682
753	701	PAIRE CLIGN STD TNN 63/007 DF ECLAI	15.048
754	702	PAIRE CLIGN STD TNN 68SF	8.102
755	703	PAIRE CLIGN STD TNN 70/002 3 FONCTI	17.364
756	704	PAIRE CLIGN STD TNN 72 DF LED B	13.892
757	705	PAIRE CLIGN STD TNN VTT091 SF FUMER	9.261
758	706	PAIRE CLIGN STD TNN VTT092 SF FUMER	9.261
759	707	PAIRE CLIGN STD TNN ZXD010 SF	8.102
760	708	PAIRE CLIGNOTANT ARR BOOSTER 2004	15.294
761	709	PAIRE CLIGNOTANT ARR OVETTO	14.606
762	710	PAIRE CLIGNOTANT AVANT BOOSTER 2004	13.7
763	711	PAIRE CLIGNOTANT AVANT JLM 110	18.602
764	712	PAIRE CLIGNOTANT AVANT NITRO	16.357
765	713	PAIRE CLIGNOTANT AVANT OVETTO	13.993
766	714	PAIRE CLIGNOTANT GHOST V7 ARR	25.241
767	715	PAIRE CLIGNOTANT GHOST V7 AV	39.8
768	716	PAIRE CLIGNOTANT SPIRIT CARBON	10.675
769	717	PAIRE CLIGNOTANT SPIRIT NOIR	9.966
770	718	PAIRE CLIGNOTANT TREEKER	13.89
771	719	PAIRE CLIGNOTTANT SPRING 125	47.01
772	720	PAIRE COMMODO PISTA HR	37.416
773	721	PAIRE COMMODO+LEVIER MATRIX	30.1
774	722	PAIRE GARDE MAIN AVEC CLIGNOTTANT AV RED/BLEU/BLACK	36.7
775	723	PAIRE JANTE CIAO GRIS  + FLSQ FRN	182.995
776	724	PAIRE JANTE CIAO JAUNE  + FLSQ FRN AV	182.995
777	725	PAIRE JANTE CIAO ROUGE  + FLSQ FRN AV	182.995
778	726	PAIRE JANTE POWER MAX	229.9
779	727	PAIRE LEVIER CHNG 7 VITESSE VTT GEVATTI	17.417
780	728	PAIRE LEVIER DE FREIN BMX	3.766
781	729	PAIRE LEVIER DE FREIN BUXY	7.533
782	730	PAIRE LEVIER DE FREIN LIBERTY 50	15.988
783	731	PAIRE LEVIER DE FREIN VTT ENFANT PLASTIQUE	5.04
784	732	PAIRE LEVIER FREIN BMX ACIER	3.399
785	733	PAIRE LEVIER FREIN BOOSTER NM TNN	7.645
786	734	PAIRE LEVIER FREIN BOOSTER ROCKET/SPIRIT	7.595
787	735	PAIRE MANETTE + EMBOUT SC BARRACODA	16.764
788	736	PAIRE MANETTE CHANGEMENT 7 VITESSE  VTT SAIGUN	14.591
789	737	PAIRE PEDALE VTT ALUM	11.135
790	738	PAIRE PEDALE VTT BMX	5.733
791	739	PAIRE PLONGEUR AVANT GHOST 7	97.9
792	740	PAIRE PLONGEUR BOOSTER 2004	128.5
793	741	PAIRE PLONGEUR PISTA HR	85.001
794	742	PAIRE PLONGEUR PISTA VCX	87.649
795	743	PAIRE PLONGEUR SPRING ST 125	135.6
796	744	PAIRE POIGNE GHOST V7	15.989
797	745	PAIRE POIGNEE BOOSTER 2004 ORIGINE	13.989
798	746	PAIRE POIGNEE PISTA VCX	13.23
799	747	PAIRE POIGNEE VTT ENFANT	3.378
800	748	PAIRE POIGNIER SPRING ST 125	12.905
801	749	PAIRE PROTEGE SCOOTEUR 551-07	18.407
802	750	PAIRE PROTEGE SCOOTEUR 551-15	18.407
803	751	PAIRE PROTEGE SCOOTEUR 551-22	18.407
804	752	PAIRE REFLECTEUR AVANT  GHOST V7	5.355
805	753	PAIRE REFLECTEUR POWER 110	3.059
806	754	PAIRE REPOSE PIEDS BOOSTER 2004 ALU	15.042
807	755	PAIRE RETROVISEUR OVETTO	9.75
808	756	PAIRE RETROVISEUR SYM	26.153
809	757	PAIRE RETROVISEUR VESPA LX 50/125	47.187
810	758	PAIRE SUITE AILES SPRING ST 125	25.652
811	759	PAIRE SUITE GARDE BOUT JLM 110	12.107
812	760	PANNEAU AVANT  GHOST V7	65.45
813	761	PANNEAU DE GARNITURE INTERIEURE AVANT GHOST V7	39.508
814	762	PARAHUILE GUIDE DE SOUPAPE POWER 70	0.324
815	763	PARE BRISE GHOST V7	36.8
816	764	PARE-A-CHOC AVANT JH 70	29.932
817	765	PARE-A-CHOC JLM 110	44
818	766	PARE-BRISE BATMAN  TRANS+BR	51.2
819	767	PARE-BRISE BATMAN ROUGE	56.2
820	768	PARE-BRISE BATMAN TRANSP+BB	51.2
821	769	PARE-BRISE PRIMAVERA 150 ORG	136.499
822	770	PARE-BRISE VESPA LX ORG	195.001
823	771	PARE-BRISE VESPA125 ORG	195.001
824	772	PASSAGE DE ROUE  GHOST V7	53.8
825	773	PASSAGE DE ROUE PISTA HR	32.5
826	774	PASSAGE DE ROUE PISTA VCX	30.5
827	775	PATTE DERAILLEUR VTT -4	3.898
828	776	PIGNON 428*15T+AGRAFES POWER 110	4.925
829	777	PIGNON 428*16T+AGRAFES  POWER 110	4.725
830	778	PIGNON DEMAREUR PISTA VCX/ JOC-J	13.263
831	779	PIGNON DEMARREUR DY150	7.522
832	780	PIGNON M.E.M BOOSTER 100+RESSORT	9.2
833	781	PIGNON M.E.M MOTOSIERRA50+RESSORT	6.133
834	782	PIGNON MEM +BAGUE AXE BROCHE +RESSORT PISTA JOC-J	11.191
835	783	PIPE CARBURATEUR  GHOST V7	13.9
836	784	PIPE CARBURATEUR BOOSTER	7.322
837	785	PIPE CARBURATEUR LIBERTY 125	14.186
838	786	PIPE CARBURATEUR LUDIX	8.992
839	787	PIPE CARBURATEUR MOTOSIERRA  50	5.299
840	788	PIPE CARBURATEUR MOTOSIERRE 150/125	5.246
841	789	PIPE CARBURATEUR OVETTO	7.654
842	790	PIPE CARBURATEUR POWER 110	6.818
843	791	PISTON  GHOST V7 52.4MM	22.524
844	792	PISTON BOOSTER  50 40.00	12.632
845	793	PISTON BOOSTER  50 40.50	12.632
846	794	PISTON BOOSTER  50 42.00	12.632
847	795	PISTON BOOSTER  50 43.50	12.632
848	796	PISTON BOOSTER  50 44.00	12.632
849	797	PISTON BOOSTER 100 52.0mm	23.174
850	798	PISTON BOOSTER 100 52.5mm	23.174
851	799	PISTON BOOSTER 100 53.00mm	23.174
852	800	PISTON BOOSTER 100 53.50mm	23.174
853	801	PISTON BOOSTER 50  STD+	12.632
854	802	PISTON BOOSTER 50  STD++	12.632
855	803	PISTON BOOSTER 50  STD+++	12.632
856	804	PISTON BOOSTER 50 *STAGE6  40.00	22.195
857	805	PISTON BOOSTER 50 *STAGE6  41.50	22.195
858	806	PISTON BOOSTER 50 *STAGE6  42.00	22.195
859	807	PISTON BOOSTER 50 *STAGE6  42.50	22.195
860	808	PISTON BOOSTER 50 *STAGE6  43.00	22.195
861	809	PISTON BOOSTER 50 *STAGE6 42.00++	22.195
862	810	PISTON BOOSTER 50 40.50+	12.632
863	811	PISTON BOOSTER 50 40.50++	12.632
864	812	PISTON BOOSTER 50 40.50+++	12.632
865	813	PISTON BOOSTER 50 41.00++	12.632
866	814	PISTON BOOSTER 50 41.00+++	12.632
867	815	PISTON BOOSTER 50 41.50++	12.632
868	816	PISTON BOOSTER 50 41.50+++	12.632
869	817	PISTON BOOSTER 80 *STAGE6  47.00	25.512
870	818	PISTON BOOSTER 80 *STAGE6  47.50	25.512
871	819	PISTON BOOSTER 80 *STAGE6  48.00	25.512
872	820	PISTON BOOSTER 80 47.00	15.33
873	821	PISTON BOOSTER 80 47.00+	15.33
874	822	PISTON BOOSTER 80 47.00+++	15.33
875	823	PISTON BOOSTER 80 47.50	14.329
876	824	PISTON BOOSTER 80 47.50+	15.33
877	825	PISTON BOOSTER 80 47.50++	14.329
878	826	PISTON BOOSTER 80 47.50+++	14.329
879	827	PISTON BOOSTER 80 47.60mm	19.05
880	828	PISTON BOOSTER 80 48.00	14.329
881	829	PISTON BOOSTER 80 48.00+	14.329
882	830	PISTON BOOSTER 80 48.00++	14.329
883	831	PISTON BOOSTER 80 48.00+++	14.329
884	832	PISTON BOOSTER 80 48.50	15.33
885	833	PISTON BOOSTER 80 48.50+	14.329
886	834	PISTON BOOSTER 80 48.50++	14.329
887	835	PISTON BRAVO 38.2+	11.187
888	836	PISTON BRAVO 38.4	11.187
889	837	PISTON BRAVO 38.6	11.187
890	838	PISTON BRAVO 38.8	11.187
891	839	PISTON BRAVO 39.0	11.187
892	840	PISTON BRAVO 39.2	11.187
893	841	PISTON BRAVO 39.4	11.187
894	842	PISTON BRAVO 39.6	11.187
895	843	PISTON BRAVO 39.8	11.187
896	844	PISTON BRAVO 40.0	11.187
897	845	PISTON BRAVO 40.2	11.187
898	846	PISTON BRAVO 40.4	11.187
899	847	PISTON BRAVO 40.6	11.187
900	848	PISTON BUXY 50     40.00+	12.632
901	849	PISTON BUXY 50     40.00++	12.632
902	850	PISTON BUXY 50     40.00+++	12.632
903	851	PISTON BUXY 50     40.50	15.133
904	852	PISTON BUXY 50     40.50+	12.632
905	853	PISTON BUXY 50     40.50++	12.632
906	854	PISTON BUXY 50     40.50+++	15.133
907	855	PISTON BUXY 50     41.00	12.632
908	856	PISTON BUXY 50     41.00+	12.632
909	857	PISTON BUXY 50     41.00++	12.632
910	858	PISTON BUXY 50     41.00+++	12.632
911	859	PISTON BUXY 50     41.50	12.632
912	860	PISTON BUXY 50     42.00	12.632
913	861	PISTON BUXY 50     42.50	15.133
914	862	PISTON BUXY 50     43.00	12.632
915	863	PISTON BUXY 50 *STAGE6  40.00+	22.113
916	864	PISTON BUXY 50 *STAGE6  40.50	22.113
917	865	PISTON BUXY 50 *STAGE6  41.00	22.113
918	866	PISTON BUXY 50 *STAGE6  41.50	22.113
919	867	PISTON BUXY 50 ALUM    39.98	12.632
920	868	PISTON BUXY 80     47.00	15.045
921	869	PISTON BUXY 80     47.00+	15.045
922	870	PISTON BUXY 80     47.50	15.045
923	871	PISTON BUXY 80     48.00	15.045
924	872	PISTON BUXY 80     48.50	15.045
925	873	PISTON CHALLENGER 125	23.3
926	874	PISTON CIAO AM 38.2+	11.489
927	875	PISTON CIAO AM 38.4	11.489
928	876	PISTON CIAO AM 38.6	11.489
929	877	PISTON CIAO AM 39.4	12.489
930	878	PISTON CIAO AM 39.6	12.489
931	879	PISTON CIAO AM 39.8	12.489
932	880	PISTON CIAO AM 40	12.489
933	881	PISTON CIAO AM 40.2	12.489
934	882	PISTON CIAO AM 40.4	12.489
935	883	PISTON CIAO AM 40.6	12.489
936	884	PISTON CIAO NM 38.2	12.489
937	885	PISTON CIAO NM 38.6	12.489
938	886	PISTON CIAO NM 38.8	12.489
939	887	PISTON CIAO NM 39	12.489
940	888	PISTON CIAO NM 39.6	12.489
941	889	PISTON CIAO NM 40	12.489
942	890	PISTON CIAO NM 40.2	12.489
943	891	PISTON CIAO NM 40.4	12.489
944	892	PISTON CIAO NM 40.6	12.489
945	893	PISTON DERBY     41	11.568
946	894	PISTON DERBY     42	11.568
947	895	PISTON DERBY     43	11.568
948	896	PISTON DERBY     44	11.568
949	897	PISTON DERBY  STAGE6*41	22.113
950	898	PISTON DERBY  STAGE6*41.50	22.113
951	899	PISTON DERBY  STAGE6*42	22.113
952	900	PISTON DERBY  STAGE6*42.50	22.113
953	901	PISTON DERBY  STAGE6*43.00	22.113
954	902	PISTON DERBY  STAGE6*43.50	22.113
955	903	PISTON DERBY  STAGE6*44.00	22.113
956	904	PISTON DERBY  STAGE6*44.50	22.113
957	905	PISTON DERBY  STAGE6*45.00	22.113
958	906	PISTON DIO 50 *STAGE6   39.00	22.113
959	907	PISTON DIO 50 *STAGE6   39.50	22.113
960	908	PISTON DIO 50 *STAGE6   40.00	22.113
961	909	PISTON DIO 50 *STAGE6   40.50	22.113
962	910	PISTON DIO 50 *STAGE6   41.00	22.113
963	911	PISTON DIO 50 *STAGE6   41.50	22.113
964	912	PISTON DIO 50 *STAGE6   42.00	22.113
965	913	PISTON DIO 50 39.00	11.968
966	914	PISTON DIO 50 39.50	11.568
967	915	PISTON DIO 50 40.00	11.568
968	916	PISTON DIO 50 40.50	11.568
969	917	PISTON DIO 50 41.50	11.968
970	918	PISTON DIO 50 42.00	11.968
971	919	PISTON DIO 50 42.50	11.968
972	920	PISTON DIO 50 43.00	11.968
973	921	PISTON DY150 STD++	30.167
974	922	PISTON ELEGANCE 110     54.75	14.015
975	923	PISTON GY 150  57.65	18.046
976	924	PISTON GY 150  57.90	18.046
977	925	PISTON GY 150  58.15	18.046
978	926	PISTON GY 150  STD	18.046
979	927	PISTON GY 150  STD+	18.046
980	928	PISTON GY 150  STD++	18.046
981	929	PISTON GY125     -52.65	13.396
982	930	PISTON GY125     -52.90	13.396
983	931	PISTON GY125     -53.15	13.396
984	932	PISTON GY125     -53.40	13.396
985	933	PISTON GY125     -STD	13.396
986	934	PISTON GY125     -STD+	13.396
987	935	PISTON GY50     -39.25	9.665
988	936	PISTON GY50     -39.50	9.665
989	937	PISTON GY50     -39.75	9.665
990	938	PISTON GY50     -40.00	9.665
991	939	PISTON GY50     -STD	9.665
992	940	PISTON GY50     -STD+	11.046
993	941	PISTON GY50     -STD++	11.046
994	942	PISTON GY60     -44.25	10.849
995	943	PISTON GY60     -44.50	10.849
996	944	PISTON GY60     -44.75	10.849
997	945	PISTON GY60     -45.00	10.849
998	946	PISTON GY60     -STD++	10.849
999	947	PISTON GY80    -47.00+	13.258
1000	948	PISTON GY80    -47.25	11.736
1001	949	PISTON GY80    -47.75	11.736
1002	950	PISTON GY80    -48.00	11.736
1003	951	PISTON HURRICANE 50 40.00	14.345
1004	952	PISTON HURRICANE 50 40.50	14.345
1005	953	PISTON HURRICANE 50 41.00	14.345
1006	954	PISTON HURRICANE 50 41.50	14.345
1007	955	PISTON HURRICANE 50 42.00	14.345
1008	956	PISTON HURRICANE 50 42.50	14.345
1009	957	PISTON HURRICANE 50 43.00	14.345
1010	958	PISTON HURRICANE 80 47.00	14.473
1011	959	PISTON HURRICANE 80 47.50	14.473
1012	960	PISTON HURRICANE 80 48.00	14.473
1013	961	PISTON JH70     47.50	13.846
1014	962	PISTON JH70     47.75	13.846
1015	963	PISTON JH70     48	13.846
1016	964	PISTON JH70     STD	13.846
1017	965	PISTON JH70     STD+	13.846
1018	966	PISTON JLM 110  50.25	14.459
1019	967	PISTON JLM 110 50.50	14.459
1020	968	PISTON JLM 110 50.75	14.459
1021	969	PISTON JLM 110 51.00	14.459
1022	970	PISTON JLM 110 STD	14.459
1023	971	PISTON JLM 110 STD+ ORIGINE	14.459
1024	972	PISTON JLM 110 STD++ ORIGINE	14.459
1025	973	PISTON KEEWAY ARN 125 STD	33.676
1026	974	PISTON LIBERTY 125     58.00mm	24.49
1027	975	PISTON LIBERTY 125     58.50mm	24.49
1028	976	PISTON LIBERTY 125     59.00mm	24.49
1029	977	PISTON LIBERTY 50 40.00	25.528
1030	978	PISTON LIBERTY 50 40.50	25.528
1031	979	PISTON LIBERTY 50 41.50	25.528
1032	980	PISTON LIBERTY 50 STD	25.528
1033	981	PISTON LIBERTY 50 STD+	25.027
1034	982	PISTON MAJESTY 125 -53.70mm	22.962
1035	983	PISTON MAJESTY 125 -54.00mm	22.962
1036	984	PISTON MAJESTY 125 -54.50mm	22.962
1037	985	PISTON MAJESTY 125 -55.00mm	22.962
1038	986	PISTON MAJESTY 125 -55.50mm	22.962
1039	987	PISTON MAJESTY 125 -56.00mm	22.962
1040	988	PISTON MAJESTY 125 -56.50mm	22.962
1041	989	PISTON MAJESTY 125 -57.00mm	22.962
1042	990	PISTON MBK 38.95	9.482
1043	991	PISTON MBK 38.96	9.482
1044	992	PISTON MBK 38.97	9.482
1045	993	PISTON MBK 39.00	9.882
1046	994	PISTON MBK 39.04	9.882
1047	995	PISTON MBK 39.05	9.882
1048	996	PISTON MBK 39.06	9.882
1049	997	PISTON MBK 39.07	9.882
1050	998	PISTON PGT TAIWAN 39.96	9.882
1051	999	PISTON PGT TAIWAN 39.99	9.882
1052	1000	PISTON PGT TAIWAN 40.00	9.882
1053	1001	PISTON PGT TAIWAN 40.01	9.882
1054	1002	PISTON PGT TAIWAN 40.04	9.882
1055	1003	PISTON PISTA HR STD	23.071
1056	1004	PISTON PISTA HR STD+	23.071
1057	1005	PISTON PISTA STD  49mm	23.071
1058	1006	PISTON PISTA STD+  49mm	23.071
1059	1007	PISTON PISTA STD++ 49mm	23.071
1060	1008	PISTON PK50 47.50	17.263
1061	1009	PISTON PK50 48.00	17.263
1062	1010	PISTON POWER  110     52.65	14.918
1063	1011	PISTON POWER  110     52.90	14.918
1064	1012	PISTON POWER  110     53.15	14.918
1065	1013	PISTON POWER  110     53.40	14.918
1066	1014	PISTON POWER  110    STD	14.918
1067	1015	PISTON POWER 110 STD+ ORIGINE	14.818
1068	1016	PISTON POWER 110 STD++ ORIGINE	14.98
1069	1017	PISTON POWER 110 STD+++	15.232
1070	1018	PISTON SH 125  ? 52.40+	28.038
1071	1019	PISTON SH 125  ? 52.90	28.038
1072	1020	PISTON SH 125  ? 53.15	28.038
1073	1021	PISTON SH150     ? 58.0mm	32.568
1074	1022	PISTON SH150     ? 58.5mm	32.568
1075	1023	PISTON SH150     ? 59.0mm	32.568
1076	1024	PISTON SPRING ST 125 STD  NM	15.9
1077	1025	PISTON SPRING ST 125 STD AM	15.9
1078	1026	PISTON SPRING ST 125 STD+ AM	15.9
1079	1027	PISTON SPRING ST 125 STD+ NM	15.9
1080	1028	PISTON SYM 50 -37.00+mm	21.9
1081	1029	PISTON SYM 50 -37.00mm	21.9
1082	1030	PISTON SYM 50 -37.50mm	21.601
1083	1031	PISTON SYM 50 -38.00mm	21.601
1084	1032	PISTON SYM 50 -38.50mm	21.601
1085	1033	PISTON SYM 50 -39.00mm	21.601
1086	1034	PISTON SYM 50 -39.50mm	21.601
1087	1035	PISTON SYM 50 -40.00mm	21.601
1088	1036	PISTON SYM 50 STAGE-37.50	28.91
1089	1037	PISTON SYM 50 STAGE-38.00	28.91
1090	1038	PISTON SYM 50 STAGE-38.50	28.91
1091	1039	PISTON SYM 50 STAGE-39.00	28.91
1092	1040	PISTON SYM 50 STAGE-39.50	28.91
1093	1041	PISTON SYM 50 STAGE-40.00	28.91
1094	1042	PISTON TYPHOON *STAGE6  40.00	22.195
1095	1043	PISTON TYPHOON *STAGE6  40.00+	22.195
1096	1044	PISTON TYPHOON *STAGE6  40.50	22.195
1097	1045	PISTON TYPHOON *STAGE6  41.00	22.195
1098	1046	PISTON TYPHOON *STAGE6  41.50	22.195
1099	1047	PISTON TYPHOON *STAGE6  42.50	22.195
1100	1048	PISTON TYPHOON *STAGE6  43.00	22.195
1101	1049	PISTON TYPHOON 125 STAGE6  55.00	28.8
1102	1050	PISTON TYPHOON 50  43.00	12.632
1103	1051	PISTON TYPHOON 50 40.00	12.632
1104	1052	PISTON TYPHOON 50 40.50+	12.632
1105	1053	PISTON TYPHOON 50 40.50++	12.632
1106	1054	PISTON TYPHOON 50 40.50+++	12.632
1107	1055	PISTON TYPHOON 50 41.00+	12.632
1108	1056	PISTON TYPHOON 50 41.00++	12.632
1109	1057	PISTON TYPHOON 50 41.00+++	12.632
1110	1058	PISTON TYPHOON 50 41.50	15.132
1111	1059	PISTON TYPHOON 50 41.50+	12.632
1112	1060	PISTON TYPHOON 50 41.50++	12.632
1113	1061	PISTON TYPHOON 50 42.00	12.632
1114	1062	PISTON TYPHOON 50 42.00+	12.632
1115	1063	PISTON TYPHOON 50 42.50	12.632
1116	1064	PISTON TYPHOON 50 43.50	12.632
1117	1065	PISTON TYPHOON 50 44	12.632
1118	1066	PISTON TYPHOON 80 *STAGE6  47.00	25.512
1119	1067	PISTON TYPHOON 80 *STAGE6  47.50	25.512
1120	1068	PISTON TYPHOON 80 *STAGE6  48.00	25.512
1121	1069	PISTON TYPHOON 80 47.00	15.045
1122	1070	PISTON TYPHOON 80 47.00+	15.33
1123	1071	PISTON TYPHOON 80 47.00+++	15.33
1124	1072	PISTON TYPHOON 80 47.50	15.045
1125	1073	PISTON TYPHOON 80 47.50+	15.045
1126	1074	PISTON TYPHOON 80 47.50++	15.045
1127	1075	PISTON TYPHOON 80 47.50+++	15.045
1128	1076	PISTON TYPHOON 80 48.00	15.045
1129	1077	PISTON TYPHOON 80 48.00+	15.045
1130	1078	PISTON TYPHOON 80 48.00++	15.045
1131	1079	PISTON TYPHOON 80 48.00+++	15.045
1132	1080	PISTON TYPHOON 80 48.50	15.045
1133	1081	PISTON TYPHOON 80 48.50+	15.045
1134	1082	PISTON TYPHOON 80 48.50++	15.045
1135	1083	PISTON TYPHOON 80 48.50+++	15.045
1136	1084	PISTON VISION *STAGE6 41.50	22.113
1137	1085	PISTON VISION *STAGE6 42	22.113
1138	1086	PISTON VISION *STAGE6 42.50	22.113
1139	1087	PISTON VISION 41	11.568
1140	1088	PISTON VISION 42	11.568
1141	1089	PISTON VISION 43	11.568
1142	1090	PIVOT DE FOURCHE BOOSTER 2004	72.878
1143	1091	PLAGE AVANT BOOSTER 2004 TAIWAN	62.262
1144	1092	PLAGE AVANT PISTA HR	115.8
1145	1093	PLAGE AVANT PISTA VCX CPL (aeration+plage avant+porte logo +2logo)	97.588
1146	1094	PLAGE AVANT TYPHOON 2008	57.653
1147	1095	PLAQUE D' ATTACHE LOGO GHOST V7	29.903
1148	1096	PLAQUE D'ATTACHE ARR JLM 110	10.514
1149	1097	PLAQUE D'ATTACHE CARENAGE PISTA VCX	19.903
1150	1098	PLAQUE D'ATTACHE SPRING ST 125	19.903
1151	1099	PLAQUE DE SEPARATION POWER 110 CPT	7.72
1152	1100	PLATEAU PGT ALUMINIUM	33.276
1153	1101	PLATEAU PGT PLASTIQUE	21.785
1154	1102	PNEU  VTT 29*2.0	16.48
1155	1103	PNEU 8*1/2 2 TT MODEL XIOMI	21
1156	1104	PNEU TNN  TUBLESS   3.00-18	92.98
1157	1105	PNEU TNN  TUBLESS 110/80/16	100.422
1158	1106	PNEU TNN  TUBLESS 2.17 TT	34.023
1159	1107	PNEU TNN  TUBLESS 2.25*16 TT	43.5
1160	1108	PNEU TNN  TUBLESS 2.25*17 TT	42.521
1161	1109	PNEU TNN TUBLESS   110-90-16	98.463
1162	1110	PNEU TNN TUBLESS   120-80-16	103.061
1163	1111	PNEU TNN TUBLESS   2.50-16	58.718
1164	1112	PNEU TNN TUBLESS   2.50-17	69.3
1165	1113	PNEU TNN TUBLESS   2.75-14	63.664
1166	1114	PNEU TNN TUBLESS   3.00-10	55.972
1167	1115	PNEU TNN TUBLESS   90-90-10	57.215
1168	1116	PNEU TNN TUBLESS 3.00-17	91.98
1169	1117	PNEU TUBELESS KENDA 2.50/17	89.3
1170	1118	PNEU TUBLESS 3.25-17 TNN	98.98
1171	1119	PNEU VTT   26*2.125 TNN	12.487
1172	1120	PNEU VTT 700 *23 TNN	14.616
1173	1121	POCHETTE JOINT COMPLET BOOSTER 50	5.724
1174	1122	POCHETTE JOINT COMPLET CG150	8.336
1175	1123	POCHETTE JOINT COMPLET GY50	5.024
1176	1124	POCHETTE JOINT COMPLET JLM 70	3.726
1177	1125	POCHETTE JOINT COMPLET POWER 110	6.852
1178	1126	POCHETTE JOINT COMPLET SPRING ST 12	6.9
1179	1127	POCHETTE JOINT COMPLET SPRING ST125 NM	3.1
1180	1128	POCHETTE JOINT COMPLET SYM50	7.662
1181	1129	POCHETTE JOINT DEMI POWER 110	2.81
1182	1130	POCHETTE JOINT MBK AV 7	1.261
1183	1131	POCHETTE JOINT RDG AD 50	1.501
1184	1132	POCHETTE JOINT RDG BOOSTER 50	2.1
1185	1133	POCHETTE JOINT RDG BOOSTER 80	2.5
1186	1134	POCHETTE JOINT RDG BUXY	1.501
1187	1135	POCHETTE JOINT RDG CG150	2.1
1188	1136	POCHETTE JOINT RDG GY6-150	2.1
1189	1137	POCHETTE JOINT RDG GY6-50	2.1
1190	1138	POCHETTE JOINT RDG LIBERTY 50	2.9
1191	1139	POCHETTE JOINT RDG OVETTO 2008 *4T	4.228
1192	1140	POCHETTE JOINT RDG OVETTO 80	2.679
1193	1141	POCHETTE JOINT RDG SH125	4.583
1194	1142	POCHETTE JOINT RDG SH150	5.739
1195	1143	POCHETTE JOINT RDG SPEEDFIGHT	3.152
1196	1144	POCHETTE JOINT RDG TYPHOON 80	2.5
1197	1145	POMPE A EAU HONDA SH125/150	125.24
1198	1146	POMPE A EAU LUDIX 50	66.799
1199	1147	POMPE A EAU MAJESTY 125/150	83.471
1200	1148	POMPE A EAU X-MAX 125 TNN	125.24
1201	1149	POMPE A ESSENCE SH125/150	91.504
1202	1150	POMPE A HUILE  GHOST V7	28.954
1203	1151	POMPE A HUILE DY150	12.224
1204	1152	POMPE A HUILE JLM ORG	10.715
1205	1153	POMPE A HUILE KEEWAY-HURRICANE 50	35.715
1206	1154	POMPE A HUILE PIAGGIO 50,TYPHOON,ST	46.013
1207	1155	POMPE A HUILE PISTA VCX /HR/JOC-J	30.136
1208	1156	POMPE A HUILE POWER 110+AXE	7.462
1209	1157	POMPE A HUILE SPRING ST 125 AM	23.875
1210	1158	POMPE A HUILE SPRING ST 125 NM	23.875
1211	1159	POMPE ATELIER AVEC MANOMETRE	21.019
1212	1160	POMPE ATELIER PROFESSIONNELLE	8.248
1213	1161	PORTE BAGAGE ARRIERE SPRING ST 125	54.999
1214	1162	PORTE BAGAGUE AVANT SPRING ST 125	20.154
1215	1163	PORTE CACHE DISQUE FREIN SPRING ST	12.78
1216	1164	PORTE CASQUE OVETTO/BWS	4.098
1217	1165	PORTE CASQUE PISTA VCX	6.098
1218	1166	PORTE CASQUE STUNT	5.807
1219	1167	PORTE MAIN ARR PISTA VCX	36.444
1220	1168	PORTE MAIN BOOSTER 2004	39.107
1221	1169	PORTE MAIN NITRO 50	17.2
1222	1170	POTENCE VTT 26 inch ALUM	9.115
1223	1171	POULIE ARRIERE CIAO PM	5.514
1224	1172	PROJECTEUR  AVANT GHOST V7	285
1225	1173	PROJECTEUR BRAVO SANS CORPS	34.804
1226	1174	PROJECTEUR JLM 110  2 AMPOULES	30.683
1227	1175	PROJECTEUR JLM 110 1 AMPOULE	32.683
1228	1176	PROJECTEUR LED PISTA VCX	79.8
1229	1177	PROJECTEUR LIBERTY 125 NM	112.622
1230	1178	PROJECTEUR NITRO CARBON	29.639
1231	1179	PROJECTEUR PISTA HR	89.5
1232	1180	PROJECTEUR PISTA VCX	45.15
1233	1181	PROJECTEUR SPRING ST 125	69.57
1234	1182	PROJECTEUR TNN 10 LED (GYROPHARE) 00	15.8
1235	1183	PROJECTEUR TNN LED (HIBOU) 05	17.2
1236	1184	PROJECTEUR TNN STD 18 LED  9000	9.9
1237	1185	REFLECTEUR ARRIERE GHOST V7	7.854
1238	1186	REFLECTEUR MODEL ROND	2.1
1239	1187	REFLECTEUR VTT MODEL POISSON	2.1
1240	1188	REFLECTEUR VTT MODEL RECTANGULAIRE	2.1
1241	1189	REGULATEUR  GHOST V7	52.5
1242	1190	REGULATEUR CG 125	25.941
1243	1191	REGULATEUR JLM 110  4FICHES	16.642
1244	1192	REGULATEUR JLM 110  5FICHES ORI	23.184
1245	1193	REGULATEUR PGT	8.25
1246	1194	REGULATEUR PIAGGIO 50* 3 FICHES	32.585
1247	1195	REGULATEUR POWER 110 4 FICHES ORIGI	13.576
1248	1196	REGULATEUR POWER110 MAX 2 D'ORIGINE	15.303
1249	1197	REGULATEUR SH125/SH150   -5 FICHES	36.698
1250	1198	REGULATEUR SH125/SH150   INJECTION	46.535
1251	1199	REGULATEUR SPRING ST 125	17.303
1252	1200	REGULATEUR VESPA PX 125/LIBERTY 125	32.585
1253	1201	RELAIS DEMARREUR BOOSTER NM	9.227
1254	1202	RELAIS DEMARREUR GHOST V7	13.85
1255	1203	RELAIS DEMARREUR JLM 110 ORIGIN	11.055
1256	1204	RELAIS DEMARREUR PISTA VCX	11.055
1257	1205	RELAIS DEMARREUR SPRING ST 125	12.055
1258	1206	RELAIS DEMARREUR TYPHOON 50	11.579
1259	1207	REPOSE PIED + BEQUILLE LATERAL SPRI	32.9
1260	1208	REPOSE PIED GHOST V7	39.129
1261	1209	RESERVOIR PISTA VCX	38.112
1262	1210	RESERVOIR SPRING ST 125	45.8
1263	1211	RESERVOIRE GHOST V7	58.545
1264	1212	RESSORT AXE BROCHE BUXY	3.589
1265	1213	RESSORT AXE BROCHE MOTOSIERRE 50	3.589
1266	1214	RESSORT BEQUILLE CENTRALE JLM 110	1.238
1267	1215	RESSORT FRIDEAU D'EMBRAYAGE CIAO	0.815
1268	1216	ROBINET D' ESSENCE GHOST V 7	23.98
1269	1217	ROBINET D'ESSENCE ROCKET/VCX	9.831
1270	1218	ROBINET D'ESSENCE SH125/150	13.947
1271	1219	ROBINET D'ESSENCE YAMAHA 600	13.677
1272	1220	RONDELLE JOUE FIXE GY50	3
1273	1221	ROULEMENT 6004 NTN	6.418
1274	1222	ROULEMENT 6005 NTN	6.912
1275	1223	ROULEMENT 6200 NTN	4.307
1276	1224	ROULEMENT 6201 NTN	4.307
1277	1225	ROULEMENT 6202 NTN	6.442
1278	1226	ROULEMENT NK CARTER 15*25*12 PISTA	7.442
1279	1227	ROULEMENT SC05 A51 NTN ORIGINAL  SU	17.669
1280	1228	ROULEMENT SC05 A97 NTN ORIGINAL HON	17.161
1281	1229	ROULIBRE CASSET 9 VITESSES	33.341
1282	1230	ROULIBRE VTT 8V GEVATTI	14.389
1283	1231	SABOT AVANT GHOST V7	34.8
1284	1232	SELLE GHOST V7	77.9
1285	1233	SELLE PISTA VCX	74.97
1286	1234	SELLE SPRING ST 125	69.604
1287	1235	SELLE VTT  M16 NOIR+MARRON	12.701
1288	1236	SELLE VTT +REFLECTEUR INTEGRER M1 NOIR	12.701
1289	1237	SELLE VTT +REFLECTEUR INTEGRER M15 NOIR	12.701
1290	1238	SELLE VTT +REFLECTEUR INTEGRER M5 NOIR +JAUNE	12.701
1291	1239	SELLE VTT +REFLECTEUR M4 NOIR+ROUGE	12.701
1292	1240	SELLE VTT M13 GRIS	10.31
1293	1241	SELLE VTT M3 VERT	10.31
1294	1242	SELLE VTT M9 VIOLET	10.31
1295	1243	SELLE VTT+REFLECTEUR INTEGRE M14 GRIS	11.532
1296	1244	SERRE COFFRE BOOSTER 2004	11.944
1297	1245	SERRE COFFRE POWER 110	5.985
1298	1246	SERRURE COFFRE SPRING ST 125	7.985
1299	1247	SERRURE CONTACT PIAGGIO	13.199
1300	1248	SERRURE RESERVOIRE  GHOST V7	16.898
1301	1249	SIEGE ENFANT VTT	14
1302	1250	SOUS TAPIS OVETTO AM	26.082
1303	1251	STATOR COURANT JLM 110 ORIGINE	34.865
1304	1252	STATOR COURANT KEEWAY ARN 125	71.091
1305	1253	STATOR COURANT LIBERTY 125	53.575
1306	1254	STATOR COURANT LIBERTY 50	43.409
1307	1255	STATOR COURANT LUDIX	36.841
1308	1256	STATOR COURANT PGT +VOLANT MAGNETIQ	67.598
1309	1257	STATOR COURANT PIAGGIO 125 4T	46.277
1310	1258	STATOR COURANT PISTA VCX	37.416
1311	1259	STATOR COURANT POWER 110 5 FILES	33.752
1312	1260	STATOR COURANT POWER MAX 2 ORIGINE	32.307
1313	1261	STATOR COURANT SPRING ST 125 NM	43.7
1314	1262	STATOR COURANT SPRING ST125 AM	43.7
1315	1263	STATOR COURANT TYPHOON NM	49.9
1316	1264	STATOR COURANT+VOLANT MAGNETIQUE PISTA VCX	77.283
1317	1265	SUPPORT MOTEUR  PISTA VCX	23.704
1318	1266	SUPPORT MOTEUR MAJESTY SUPER 50	8.025
1319	1267	SUPPORT MOTEUR PGT AM	15.904
1320	1268	SUPPORT MOTEUR PGT NM	16.907
1321	1269	SUPPORT MOTEUR PGT NM2012 GM	19.019
1322	1270	SUPPORT PORTABLE GUIDON	16.5
1323	1271	SUPPORT TENDEUR DE CHAINE BOXTER 12	8.211
1324	1272	SUPPORT TENDEUR DE CHAINE GHOST V7	8.768
1325	1273	TABLIER CONTACT AVANT GHOST V7	110.194
1326	1274	TABLIER CONTACT BOOSTER 2004 TNN	42.337
1327	1275	TABLIER CONTACT PISTA HR	125.8
1328	1276	TABLIER CONTACT PISTA VCX	40.402
1329	1277	TABLIER CONTACT PISTA VCX (tablier contact.porte boblette+mini coffre+cache serie+suite+porte casque)	99.6
1330	1278	TABLIER CONTACT SPRING ST 125	36.251
1331	1279	TAPIS +SOUS TAPIS +TRAPPE BATERIE +BOUCHON	165.5
1332	1280	TAPIS CIAO	8.441
1333	1281	TAPIS GHOST V7	66.254
1334	1282	TAPIS JLM 110 PM ORG	11.055
1335	1283	TAPIS PISTA VCX	72.623
1336	1284	TAPIS PM SPRING ST 125	13.05
1337	1285	TAPIS SPRING ST 125 GM	21.055
1338	1286	TAPIS STUNT SLIDER	65.513
1339	1287	TAPIS+SOUS TAPIS VCX+TRAPPE BATTERIE	145.5
1340	1288	TE DE FOURCHE GHOST V7	80.184
1341	1289	TE DE FOURCHE SPRING ST 125	68.179
1342	1290	TENDEUR BOITE VITESSE POWER 110	4.41
1343	1291	TENDEUR DE CHAINE CIAO	4.054
1344	1292	TENDEUR DE CHAINE GHOST V7	13.9
1345	1293	TENDEUR DE CHAINE LIBERTY 125	11.041
1346	1294	TENDEUR DE CHAINE MOTOSIERRA 50	4.2
1347	1295	TENDEUR DE CHAINE POWER/JLM 110	4.284
1348	1296	THERMOSTAT AEROX NITRO 50  2012	10.121
1349	1297	THERMOSTAT DE TEMPERATURE ET2/ET4	10.942
1350	1298	THERMOSTAT DE TEMPERATURE LIBERTY 1	17.368
1351	1299	TIGE DE FREIN POWER 110	4.161
1352	1300	TIGE DE SELLE VTT 28.6 MM ALUM PRO	18.082
1353	1301	TIGE DE SELLE VTT 29.2 MM ALUM PRO	18.082
1354	1302	TIGE DE SELLE VTT 30 MM ALUM PRO	18.082
1355	1303	TIGE DE SELLE VTT 31 MM ALUM PRO	18.082
1356	1304	TIGE DE SELLE VTT ALUM LUXE 27MM	18.082
1357	1305	TRAPE  BATTERIE GHOST V7	18.987
1358	1306	TRAPE DE REPARATION  MOTEUR GHOST V7	29.334
1359	1307	TRAPPE BATTERIE PISTA HR	11.176
1360	1308	TRAPPE BOUGIE BOOSTER 2004	15.986
1361	1309	TUBE MANETTE POWER 110	1.299
1362	1310	VANNE DE CONTR?LE CBS GHOST V7	19.278
1363	1311	VARIATEUR BRAVO	44.752
1364	1312	VENTILATEUR GHOST V 7	16.9
1365	1313	VENTILATEUR LUDIX 50	11.481
1366	1314	VENTILATEUR MOTOSIERRA 125	7.096
1367	1315	VENTILATEUR MOTOSIERRA 50	6.308
1368	1316	VENTILATEUR PISTA VCX	11.481
1369	1317	VENTILATEUR TYPHOON 50	8.419
1370	1318	VILBREQUIN  GHOST V7	115
1371	1319	VILEBREQUIN KEEWAY ARN 125	65.111
1372	1320	VILEBREQUIN MAXIMUM 110	89.9
1373	1321	VILEBREQUIN PISTA  VCX/JOC-J/	90.517
1374	1322	VILEBREQUIN POWER 110 CC PM ORG	65.691
1375	1323	VILEBREQUIN SPRING ST 125 AM	88.312
1376	1324	VILEBREQUIN SPRING ST 125 NM	88.312
1377	1325	VISIERE POUR CASQUE	3
1378	1326	VOLANT + STATOR GHOST V7	97.2
1379	1327	VOLANT MAGNETIQUE KEEWAY ARN 125	64.289
1380	1328	VOLANT MAGNETIQUE SPRING ST 125 AM	47.847
1381	1329	VOLANT MAGNETIQUE SPRING ST125 NM	42.9
1382	1	MAITRE CYLINDRE GAUCHE COMPLET HR+	36.987
1383	2	AMORTISSEUR AR HR+	41.75
1384	3	ARBRE A CAME  HR+	25.6
1385	4	AXE DE BROCHE + BAGUE  HR+	15.3
1386	5	AXE DE ROUE AR HR+	6.141
1387	6	AXE DE ROUE AVANT HR+	6.141
1388	7	BENDIX COMPLET HR+	47.998
1389	8	BEQUILLE CENTRALE  HR+	41.8
1390	9	BLOC CDI HR+	37.781
1391	10	BRAS DE KICK HR+	19.2
1392	11	CABLE ACCELERATEUR HR+	8.804
1393	12	CABLE COMPTEUR HR+	8.804
1394	13	CACHE CYLINDRE PISTA HR+	17.1
1395	14	CACHE VENTILATEUR PISTA  HR +	15.42
1396	15	CAGE MISE EN MARCHE CPL	106
1397	16	CARENAGE COMPLET PISTA HR +	756.254
1398	17	CARTER DROITE  HR+	88.1
1399	18	CARTER GAUCHE HR+	113.5
1400	19	CLOCH EMBRAYAGE PISTA HR +	23.48
1401	20	COMPTEUR HR+	81.9
1402	21	COURROIE HR+ POWERLINK	29.1
1403	22	COUVERCLE CULASSE HR+	23.9
1404	23	CYLINDER COMPLET HR+	98.292
1405	24	DEMAREUR HR+	56.8
1406	25	DISQUE DE FREIN AR HR+	30.871
1407	26	DISQUE DE FREIN AV HR+	25.771
1408	27	ECHAPEMENT HR+  ORIGINE	97.559
1409	28	EMBRAYAGE AR HR+	96.523
1410	29	EMBRAYAGE AVANT COMPLET HR+	63.81
1411	30	ETRIER DE FREIN AR HR+	58.2
1412	31	ETRIER DE FREIN AV HR+	60.251
1413	32	FEU STOP PISTA HR +	47.8
1414	33	FILTER AIR  COMPLET  HR+	29.253
1415	34	FILTRE AIR INTERIEUR  HR+	16.558
1416	35	FLEXIBLE DE FREIN AR HR+	11.78
1417	36	FLEXIBLE DE FREIN AV HR+ SYSTEME CBS	20.66
1418	37	JANTE ARRIERE PISTA HR+	145
1419	38	JANTE AVANT HR+	130
1420	39	JAUGE D'HUILE HR+	3.385
1421	40	JEU DE DIRECTION HR+	13.732
1422	41	JEU DE GALET HR+	13.328
1423	42	JEU DE PAR-HUILE FOURCHE AV HR+	8.8
1424	43	JEU DE PATIN AR HR+	20
1425	44	JEU DE PATIN AV  HR+	23
1426	45	JEU DE SOUPAPE PISTA HR +	16.89
1427	46	JOINT COUVERCLE D'ENGRENAGE HR+	0.445
1428	47	JOINT COUVERCLE MISE EN MARCHE PISTA HR+	0.8
1429	48	JOINT CULASSE HR+	0.55
1430	49	JOINT PIPE PISTA  HR+	0.3
1431	50	KIT BOITE DE TRANSMISSION PISTA HR+	65.254
1432	51	KIT CONTACT HR+	223.8
1433	52	KIT ROULEMENT + JEU DE PARAHUILE PISTA HR +	38.9
1434	53	LEVIER DE FREIN DROITE HR+	9.5
1435	54	LEVIER DE FREIN GAUCHE HR+	9.5
1436	55	MAITRE CYLINDRE DROITE COMPLET HR+	36.987
1437	56	MOTEUR HR 110 CC JINLANG ORIGINE	1210
1438	57	MOTEUR PISTA HR+ 124CC	1320
1439	58	PAIRE COMMODO PISTA HR +	44.616
1440	59	PAIRE PLONGEUR PISTA HR+	91.6
1441	60	PAIRE POIGNIEE PISTA HR +	16.23
1442	61	PAIRE RETROVISEUR  HR+	31.151
1443	62	PIGNON BOITE PM PISTA  HR+	19.6
1444	63	PIGNON DE DEMARRAGE HR+	14.89
1445	64	POCHETTE JOINT CACHE  CARTER DROITE  HR+	0.5
1446	65	POCHETTE JOINT CYLINDER HR +	0.445
1447	66	PROJECTEUR AVANT HR+	109.8
1448	67	REGULATEUR HR+	28.965
1449	68	SELLE HR+	90.585
1450	69	STATOR HR+	47.416
1451	70	SUPPORT MOTEUR PISTA HR+	56
1452	71	TE DE FOURCHE HR+	76.179
1453	72	VENTILATEUR PISTA HR+	16.9
1454	73	VILEBREQUIN HR+	115
\.


--
-- Data for Name: product_serials; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_serials (id, product_id, serial_number, purchase_price, status, reception_id, livraison_id, created_at) FROM stdin;
1	1	LCS4BGN60S1E00784	3445	delivered	\N	1	1776955635000
2	2	LEHTCJ015RRM00155	4874	delivered	\N	2	1776955635000
3	3	LYFXCJL07R7001152	3446	delivered	\N	3	1776955635000
4	1	LCS4BGN69S1E00783	3490	delivered	\N	4	1776955635000
5	3	LYFXCJL00R7001137	3405	delivered	\N	5	1776955635000
6	4	LC4XCHL02R0D03351	2353	delivered	\N	6	1776955635000
7	5	LCS4BGN69S1E00749	3445	delivered	\N	7	1776955635000
8	6	LEHTCJ014RRM00003	4840	delivered	\N	8	1776955635000
9	7	LYFXCJL08R7001015	3403	delivered	\N	9	1776955635000
10	8	LC4XCHL05R0D03604	2353	delivered	\N	10	1776955635000
11	2	LEHTCJ015RRM00141	4775	delivered	\N	11	1776955635000
12	9	LCS4BGN65S1E00697	3445	delivered	\N	12	1776955635000
13	9	LCS4BGN65S1E00702	3445	delivered	\N	13	1776955635000
14	10	LYFCXJL02R7001429	3361	delivered	\N	14	1776955635000
15	5	LCS4BGN69S1E00752	3445	delivered	\N	15	1776955635000
16	4	LC4XCHL01R0D03339	2353	delivered	\N	16	1776955635000
17	8	LC4XCHL03R0D03665	2395	delivered	\N	17	1776955635000
18	11	LCS4BGN68S1E00533	3445	delivered	\N	18	1776955635000
19	12	LEHTCJ011RRM00413	4958	delivered	\N	19	1776955635000
20	7	LYFXCJL04R7001030	3446	delivered	\N	20	1776955635000
21	13	LCS4BGN62S1E00768	3530	delivered	\N	21	1776955635000
22	4	LC4XCHL02R0D03348	2353	delivered	\N	22	1776955635000
23	8	LC4XCHL0XR0D03646	2395	delivered	\N	23	1776955635000
24	14	LC4XCHL08R0D03564	2395	delivered	\N	24	1776955635000
25	7	LYFXCJL04R7001013	3446	delivered	\N	25	1776955635000
26	2	LEHTCJ016RRM00472	4932	delivered	\N	26	1776955635000
27	14	LC4XCHL02R0D03592	2353	delivered	\N	27	1776955635000
28	8	LC4XCHL00R0D03414	2353	delivered	\N	28	1776955635000
29	15	LSC4BGN67S1E00586	3488	delivered	\N	29	1776955635000
30	8	LC4XCHL03S0D01355	2395	delivered	\N	30	1776955635000
31	7	LYFXCJL08R7001046	3403	delivered	\N	31	1776955635000
32	8	LC4XCHL0XS0D00171	2353	delivered	\N	32	1776955635000
33	16	LC4XCJL03S0D00732	2521	delivered	\N	33	1776955635000
34	4	LC4XCHL03S0D00058	2345	delivered	\N	34	1776955636000
35	2	LEHTCJ014RRM00471	4958	delivered	\N	35	1776955636000
36	17	LEHTCJ014RRM00311	4958	delivered	\N	36	1776955636000
37	3	LYFXCJL00R7001140	3360	delivered	\N	37	1776955636000
38	13	LCS4BGN61S1E00762	3487	delivered	\N	38	1776955636000
39	6	LEHTCJ012RRM00064	4958	delivered	\N	39	1776955636000
40	18	LC4XCJL06S0D00627	2521	delivered	\N	40	1776955636000
41	15	LSC4BGN66S1E00708	3487	delivered	\N	41	1776955636000
42	16	LC4XCJL08S0D00712	2563	delivered	\N	42	1776955636000
43	7	LYFXCJL05R7001229	3530	delivered	\N	43	1776955636000
44	4	LC4XCHL08S0D00041	2437	delivered	\N	44	1776955636000
45	19	LCS4BGN68S1E00452	3487	delivered	\N	45	1776955636000
46	11	LCS4BGN6XS1E00520	3487	delivered	\N	46	1776955636000
47	20	LCS4BGN65S1E00134	3487	delivered	\N	47	1776955636000
48	8	LC4XCHL04S0D00117	2395	delivered	\N	48	1776955636000
49	19	LCS4BGN63S1E00326	3488	delivered	\N	49	1776955636000
50	3	LYFXCJL08R7001337	3613	delivered	\N	50	1776955636000
51	7	LYFXCJL04R7001223	3613	delivered	\N	51	1776955636000
52	16	LC4XCJL07S0D00779	2563	delivered	\N	52	1776955636000
53	21	LCS4BGN69S1E00539	3530	delivered	\N	53	1776955636000
54	3	LYFXCJL09R7001170	3529	delivered	\N	54	1776955636000
55	22	LC4XCJL02S0D00673	2650	delivered	\N	55	1776955636000
56	3	LYFXCJL08R7001306	3529	delivered	\N	56	1776955636000
57	23	LCS4BJN87S1700138	4033	delivered	\N	57	1776955636000
58	24	LCS4BJN88S1700259	3990	delivered	\N	58	1776955636000
59	8	LC4XCHL06S0D00197	2395	delivered	\N	59	1776955636000
60	10	LYFXCJL01R7001082	3739	delivered	\N	60	1776955636000
61	25	LCS4BJN81S1700037	4033	delivered	\N	61	1776955636000
62	7	LYFXCJL03R7001360	3613	delivered	\N	62	1776955636000
63	26	LCS4BJN84S1700209	3949	delivered	\N	63	1776955636000
64	27	LCS4BJN88S1700083	4033	delivered	\N	64	1776955636000
65	7	LYFXCJL04R7001397	3571	delivered	\N	65	1776955636000
66	22	LC4XCJL00S0D00641	2563	delivered	\N	66	1776955636000
67	18	LC4XCJL07S0D00622	2647	delivered	\N	67	1776955636000
68	8	LC4XCHL09S0D00176	2370	delivered	\N	68	1776955636000
69	10	LYFXCJL01R7001079	3530	delivered	\N	69	1776955636000
70	28	LC4XCHL00S0D00003	2395	delivered	\N	70	1776955636000
71	29	LCS4BGN6XS1700491	3780	delivered	\N	71	1776955636000
72	14	LC4XCHL06S0D00085	2479	delivered	\N	72	1776955636000
73	30	LYFXCJL0XR7000657	3530	delivered	\N	73	1776955636000
74	31	LYFXCJL03R7000595	3530	delivered	\N	74	1776955636000
75	30	LYFXCJL09R7000956	3530	delivered	\N	75	1776955636000
76	32	LYFXCJL02R7000507	3530	delivered	\N	76	1776955636000
77	10	LYFXCJL08R7001435	3613	delivered	\N	77	1776955636000
78	33	LCS4BGN67S1700366	3740	delivered	\N	78	1776955636000
79	14	LC4XCHL02S0D00083	2395	delivered	\N	79	1776955636000
80	34	LC4XCJL00S0D00686	2647	delivered	\N	80	1776955636000
81	27	LCS4BJN88S1700665	3950	delivered	\N	81	1776955636000
82	25	LCS4BJN87S1700611	3950	delivered	\N	84	1776955636000
83	24	LCS4BJN84S1700792	3950	delivered	\N	85	1776955636000
84	26	LCS4BJN8XS1700781	3950	delivered	\N	86	1776955636000
85	38	LCS4BGN69S1700479	3697	delivered	\N	88	1776955636000
86	28	LC4XCHL01S0D01239	2479	delivered	\N	90	1776955636000
87	18	LC4XCJL01S0D01426	2647	delivered	\N	91	1776955636000
88	25	LCS4BJN84S1700596	4033	delivered	\N	92	1776955636000
89	8	LC4XCHL06S0D01365	2479	delivered	\N	93	1776955636000
90	4	LC4XCHL00S0D01264	2478	delivered	\N	95	1776955636000
91	32	LYFXCJL0XR7000724	3613	delivered	\N	96	1776955637000
92	8	LC4XCHL07S0D01357	2395	delivered	\N	97	1776955637000
93	23	LCS4BJN82S1700709	4033	delivered	\N	98	1776955637000
94	3	LYFXCJL04R7001125	3613	delivered	\N	99	1776955637000
95	4	LC4XCHL02S0D01248	2479	delivered	\N	101	1776955637000
96	16	LC4XCJL0XS0D01733	2647	delivered	\N	102	1776955637000
97	41	LYFXCJL01R7000689	3613	delivered	\N	103	1776955637000
98	8	LC4XCHL04S0D01364	2479	delivered	\N	104	1776955637000
99	41	LYFXCJL02R7000703	3614	delivered	\N	105	1776955637000
100	42	LYFXCJL04R7000783	3613	delivered	\N	106	1776955637000
101	8	LC4XCHL00S0D01345	2478	delivered	\N	107	1776955637000
102	23	LCS4BJN80S1700708	3992	delivered	\N	108	1776955637000
103	8	LC4XCHL07S0D01374	2479	delivered	\N	109	1776955637000
104	27	LCS4BJN84S1700663	3992	delivered	\N	110	1776955637000
105	43	LCS4BGN69S1000624	3782	delivered	\N	111	1776955637000
106	14	LC4XCHL09S0D01294	2479	delivered	\N	112	1776955637000
107	14	LC4XCHL02S0D01301	2479	delivered	\N	113	1776955637000
108	44	LCS4BGN63S1000585	3782	delivered	\N	114	1776955637000
109	42	LYFXCJL08R7000771	3488	delivered	\N	115	1776955637000
110	16	LC4XCJL07S0D01821	2648	delivered	\N	116	1776955637000
111	16	LC4XCJL08S0D01729	2564	delivered	\N	117	1776955637000
112	43	LCS4BGN60S1700418	3782	delivered	\N	118	1776955637000
113	45	LYFXCJL05R7000677	3612	delivered	\N	119	1776955637000
114	16	LC4XCJL07S0D01768	2606	delivered	\N	120	1776955637000
115	47	LCS4BJN81T1104041	4033	delivered	\N	122	1776955637000
116	48	LCS4BJN8XT1103891	4033	delivered	\N	123	1776955637000
117	41	LYFXCJL08R7000690	3530	delivered	\N	124	1776955637000
118	24	LCS4BJN83T1104123	4033	delivered	\N	125	1776955637000
119	49	LCS4BJN8XT1104006	4033	delivered	\N	126	1776955637000
120	50	LCS4BJN8XT1103941	4033	delivered	\N	127	1776955637000
121	34	LC4XCJL01S0D00681	2661	delivered	\N	128	1776955637000
122	51	LCS4BGN64S1700549	3700	delivered	\N	129	1776955637000
123	42	LYFXCJL02R7000751	3445	delivered	\N	130	1776955637000
124	52	LCS4BJN8XT1103860	3980	delivered	\N	131	1776955637000
125	53	LCS4BJN80T1103933	3980	delivered	\N	131	1776955637000
126	54	LCS4BJN86T1103886	3980	delivered	\N	131	1776955637000
127	55	LCS4BJN85T1103958	3980	delivered	\N	131	1776955637000
128	42	LYFXCJL05R7000775	3488	delivered	\N	132	1776955637000
129	56	LEHTDJ041TRA00126	5799	delivered	\N	133	1776955637000
130	34	LC4XCJL08S0D01486	2520	delivered	\N	134	1776955637000
131	57	LEHTDJ04XTRA00089	5800	delivered	\N	135	1776955637000
132	58	LEHTDJ042TRA00037	5799	delivered	\N	136	1776955637000
133	59	LCS4BJN82T1103917	3990	delivered	\N	137	1776955637000
134	52	LCS4BJN85T1103863	3990	delivered	\N	137	1776955637000
135	53	LCS4BJN82T1103951	3990	delivered	\N	137	1776955637000
136	42	LYFXCJL08R7000768	3530	delivered	\N	138	1776955637000
137	22	LC4XCJL06S0D01485	2563	delivered	\N	139	1776955637000
138	42	LYFXCJL0XR7000769	3613	delivered	\N	140	1776955637000
139	22	LC4XCJL00S0D01479	2521	delivered	\N	142	1776955637000
140	51	LCS4BGN66S1000824	3697.5	delivered	\N	144	1776955637000
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, reference, designation, family_id, default_price, tva_pct, created_at) FROM stdin;
1	007	PISTA VCX NOIRE NOIRE	1	3467.5	19	1776955635000
2	151	GHOST V7 124CC BLEUE JAUNE	1	4884.75	19	1776955635000
3	050	SPRING ST 124CC VERT PISTACHE	1	3499.285714285714	19	1776955635000
4	101	FORZA POWER 107CC GRIS	1	2399.714285714286	19	1776955635000
5	003	PISTA VCX VERT PISTACHE	1	3445	19	1776955635000
6	150	GHOST V7 124CC VERT NOIRE	1	4899	19	1776955635000
7	052	SPRING ST 124CC BLEUE CIEL	1	3503.125	19	1776955635000
8	102	FORZA POWER 107CC NOIRE	1	2408.1428571428573	19	1776955635000
9	008	PISTA VCX BLANC NOIRE	1	3445	19	1776955635000
10	051	SPRING ST 124CC JAUNE NOIRE	1	3560.75	19	1776955635000
11	005	PISTA VCX BLEUE JAUNE	1	3466	19	1776955635000
12	152	GHOST V7 124CC NOIRE	1	4958	19	1776955635000
13	002	PISTA VCX VERT NOIRE	1	3508.5	19	1776955635000
14	100	FORZA POWER 107CC BLEUE	1	2430	19	1776955635000
15	006	PISTA VCX BLEUE NOIRE	1	3487.5	19	1776955635000
16	106	FORZA POWER 124CC NOIRE	1	2587.4285714285716	19	1776955635000
17	153	GHOST V7 124CC GRIS BLEU	1	4958	19	1776955635000
18	107	FORZA POWER 124CC ROUGE	1	2605	19	1776955635000
19	001	PISTA VCX ROUGE NOIRE	1	3487.5	19	1776955635000
20	004	PISTA VCX DORE NOIRE	1	3487	19	1776955635000
21	004	PISTA VCX NOIRE NOIRE	1	3530	19	1776955635000
22	105	FORZA POWER 124CC GRIS	1	2574.25	19	1776955635000
23	12	PISTA HR+ NOIRE BLEU	1	4019.3333333333335	19	1776955635000
24	13	PISTA HR+ CARBONE	1	3991	19	1776955635000
25	11	PISTA HR+ GRIS VERT	1	4005.3333333333335	19	1776955635000
26	10	PISTA HR+ NOIRE MARRON	1	3949.5	19	1776955635000
27	9	PISTA HR+ VERT JAUNE	1	3991.6666666666665	19	1776955635000
28	103	FORZA POWER 107CC ROUGE	1	2437	19	1776955635000
29	017	PISTA HR NOIR / MARRON	1	3780	19	1776955635000
30	053	SPRING ST 124CC NOIR	1	3530	19	1776955635000
31	054	SPRING ST 124CC BLEU FONCE	1	3530	19	1776955635000
32	055	SPRING ST 124CC VERT	1	3571.5	19	1776955635000
33	014	PISTA HR CARBON	1	3740	19	1776955635000
34	104	FORZA POWER 124CC BLEU	1	2609.3333333333335	19	1776955635000
35	905	CASQUE LS2 AIRFLOW MATT-Taille XXL	1	324	19	1776955635000
36	911	CASQUE LS2 AIRFLOW GLOSS -Taille L	1	323.75	19	1776955635000
37	903	CASQUE LS2 AIRFLOW MATT-Taille XXL	1	294	19	1776955635000
38	016	PISTA HR NOIR / GRIS	1	3697	19	1776955635000
39	902	CASQUE LS2 AIRFLOW MATT-Taille M	1	315	19	1776955635000
40	920	CASQUE MT HELMETS MATT-Taille L	1	231	19	1776955635000
41	55	SPRING ST 124CC VERT	1	3585.6666666666665	19	1776955635000
42	54	SPRING ST 124CC BLEU FONCE	1	3529.5	19	1776955635000
43	14	PISTA HR CARBON	1	3782	19	1776955635000
44	16	PISTA HR NOIR / GRIS	1	3782	19	1776955635000
45	55	SPRING ST 124CC VERT + Casque TNL	1	3612	19	1776955635000
46	666A	Casque TNL	1	124	19	1776955635000
47	14	PISTA HR+ VERT MARRON	1	4033	19	1776955635000
48	21	PISTA HR+ ROUGE NOIRE	1	4033	19	1776955635000
49	15	PISTA HR+ NOIR ROUGE	1	4033	19	1776955635000
50	20	PISTA HR+ BLEU BEIGE	1	4033	19	1776955635000
51	18	PISTA HR VERT JAUNE 107 CC	1	3698.75	19	1776955635000
52	15	PISTA HR+ NOIR ROUGE 124 cc	1	3985	19	1776955635000
53	20	PISTA HR+ BLEU BEIGE 124 cc	1	3985	19	1776955635000
54	21	PISTA HR+ ROUGE NOIRE 124 cc	1	3980	19	1776955635000
55	22	PISTA HR+ CARBONE ROUGE 124 cc	1	3980	19	1776955635000
56	72	BLASTER GRIS 125cc	1	5799	19	1776955635000
57	71	BLASTER VERT 125cc	1	5800	19	1776955635000
58	73	BLASTER NOIR 125cc	1	5799	19	1776955635000
59	14	PISTA HR+ VERT MARRON 124 cc	1	3990	19	1776955635000
60	927	CASQUE MT HELMETS GLOSS -Taille L	1	230	19	1776955635000
61	500	HUILE MOTOS 10W40	1	16.5	19	1776955635000
\.


--
-- Data for Name: reception_lines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reception_lines (id, reception_id, product_id, quantity, prix, tva_pct, remise, created_at) FROM stdin;
\.


--
-- Data for Name: receptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.receptions (id, bon_number, date, fournisseur, created_at) FROM stdin;
\.


--
-- Data for Name: reservations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reservations (id, nom_prenom, designation, avance, date, numero, remarque, created_at) FROM stdin;
1	Naoufel Barguaoui	GHOST V7	0	2026-02-25		bn de commande big shop	1774255902000
2	bn de commande big shop Nadhem	GHOST V7	0	2026-02-27			1774255902000
3	Oussema Naffeti	GHOST V7	500	2026-01-29		avance	1774255902000
4	ALI	Blaster	0	2026-03-01			1774255902000
5	Inconnu	Blaster Rouge	0	2026-03-01	53304799		1774255902000
6	Boudria lucky	Blaster Noir	0	2026-03-01			1774255902000
7	tiktok Rafik	Blaster Rouge-Gris	0	2026-03-01	58380872		1774255902000
8	Monastir Omar	Blaster Rouge	0	2026-03-01	95460185		1774255902000
9	Coiffeur Kairwan	Blaster Rouge-Turcoise	0	2026-03-01	24636060		1774255902000
10	Rabeb	HR+ Rouge	0	2026-03-10	22400643		1774255902000
11	Mohamed Slim ABID	Blaster Noir-Rouge	0	2026-03-16	22873434	pour passer l'été	1774255902000
12	Mohamed Khalil boussif	HR+ carbone / noire	0	2026-03-24	29032851		1774361245000
13	Charfeddin Sghaier	Ghost V7 / HR+	0	2026-03-25	26442113		1774424306000
14	Ahmed BT	Ghost V7	0	2026-03-27	90213094		1774624368000
15	Zied	Ghost V7	0	2026-03-27	22745307		1774627114000
16	Nadhem	   GHOST V7 	0	2026-02-27	23411873		1774627330000
17	Kefi Mnaoubi	Power 110 Blanc/Turcoise/rouge	500	2026-03-30	96043254	exigence blanc	1774870299000
18	Akrem Saalaoui	Power 125 Bleu et Noir	0	2026-03-30	54049945		1774872156000
19	Amir KIRAT	HR+ noir/rouge	0	2026-04-06	55361123		1775472260000
20	Ramzi Wesleti	HR+	0	2026-04-07	26264999		1775563192000
21	Mohamed Fahd	HR+ CARBON	0	2026-04-12	27623860	SAHEB ADEM BEN HSSIN	1776067403000
22	Hammouda Bousetta	hr+ carbone 	0	2026-04-18	22207867	facilité	1776504350000
23	Hatem Mraidi	Power 110 	0	2026-04-20	26508895		1776694820000
\.


--
-- Data for Name: saddle_purchases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.saddle_purchases (id, date, taille_xl, taille_xxl, fournisseur, prix, created_at) FROM stdin;
2	2026-02-28	15	15		360	1772279447000
\.


--
-- Data for Name: saddle_sales; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.saddle_sales (id, date, taille_xl, taille_xxl, prix, encaissement, client, confirmed_by_staff, confirmed_by_manager, calculation_timestamp, amount_handed, created_at) FROM stdin;
1	2025-09-01	1	0	15	ANAS	Khmais	\N	\N	\N	0	1772278328000
2	2025-09-02	0	1	15	ANAS	Hmaida	\N	\N	\N	0	1772278328000
3	2025-09-10	1	0	0	KARIM	KASDAOUI	\N	\N	\N	0	1772278328000
4	2025-09-20	1	0	15	KARIM		\N	\N	\N	0	1772278328000
5	2025-09-23	2	0	0	KARIM		\N	\N	\N	0	1772278328000
6	2025-10-06	0	1	0	KARIM		\N	\N	\N	0	1772278328000
7	2025-11-27	0	1	15	KARIM		\N	\N	\N	0	1772278328000
8	2025-12-05	0	1	15	BASSEM		\N	\N	\N	0	1772278328000
9	2025-12-09	0	1	15	KARIM		\N	\N	\N	0	1772278328000
10	2025-12-09	0	1	15	KARIM	ZIED	\N	\N	\N	0	1772278328000
11	2026-01-14	1	0	15	YASSIN		\N	\N	\N	0	1772278328000
12	2026-01-22	0	1	15	YASSIN	SHILI	\N	\N	\N	0	1772278328000
13	2026-02-02	1	0	15	YASSIN	ALI	YASSIN	KARIM	1773137846578	0	1772278328000
14	2026-03-20	0	1	15	YASSIN	passager (yheb aala carénage FORZZA FTM) 	\N	\N	\N	0	1774256587000
15	2026-03-28	1	0	15	YASSIN	passager	YASSIN	KARIM	1774970786173	30	1774856402000
\.


--
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales (id, invoice_number, date, designation, client_type, client_name, convention_name, chassis_number, registration_number, gray_card_status, total_to_pay, advance, payments, payment_day, created_at) FROM stdin;
109	25/000003	2025-06-17	SPRING ST 124CC VERT  PISTACHE	B2B	STE AKRAM DE COMMERCE ET SERICES	\N	LYFXCJL07R7001152	59592 DN	Récupérée	4101	4101	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
122	25/000016	2025-07-10	FORZA POWER 107CC NOIRE	B2C	Mr Sami ESSID	\N	LC4XCHL01R0D03339	62495 DN	Récupérée	2800	2800	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
124	25/000018	2025-07-12	PISTA VCX BLUE JAUNE	B2C	Mr Jamel AAROURI	\N	LCS4BGN68S1E00533	65586 DN	Récupérée	4100	4100	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
126	25/000020	2025-07-14	SPRING ST 124CC BLEUE CIEL	B2C	Mr Abdelhmid CHAOUATI	CONVENTION STEG	LYFXCJL04R7001030	63873 DN	Récupérée	4100	0	{"mai_2026": {"amount": 227.777, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 227.777, "isPaid": true}, "aout_2026": {"amount": 227.777, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 227.777, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 227.777, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 227.777, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 227.777, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 227.777, "isPaid": false}, "janvier_2027": {"amount": 227.777, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 227.777, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 227.777, "isPaid": true}, "octobre_2026": {"amount": 227.777, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 227.777, "isPaid": false}, "decembre_2026": {"amount": 227.777, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 227.777, "isPaid": true}, "novembre_2026": {"amount": 227.777, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 227.777, "isPaid": true}, "septembre_2026": {"amount": 227.777, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
129	25/000023	2025-07-16	FORZA POWER 107CC NOIRE	B2C	Mr Hssan HARWAK	CONVENTION STEG	LC4XCHL0XR0D03646	65075 DN	Récupérée	2850	0	{"mai_2026": {"amount": 158.336, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 158.336, "isPaid": true}, "aout_2026": {"amount": 158.336, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 158.336, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 158.336, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 158.336, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 158.336, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 158.336, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 158.336, "isPaid": true}, "juillet_2026": {"amount": 158.336, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 158.336, "isPaid": true}, "octobre_2026": {"amount": 158.336, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 158.336, "isPaid": false}, "decembre_2026": {"amount": 158.336, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 158.336, "isPaid": false}, "novembre_2026": {"amount": 158.336, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 158.336, "isPaid": true}, "septembre_2026": {"amount": 158.336, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
140	25/000034	2025-08-02	FORZA POWER 107CC GRIS	B2C	Mr Mustapha ZOUAGHI	\N	LC4XCHL03S0D00058	63121 DN	Récupérée	2791	2791	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
142	25/000036	2025-08-06	GHOST V7 124CC GRIS BLEU	B2C	Mr Adel IBN EL ASOUED	CONVENTION STEG	LEHTCJ014RRM00311	63880 DN	Récupérée	5900	0	{"mai_2026": {"amount": 327.777, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 327.777, "isPaid": true}, "aout_2026": {"amount": 327.777, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 327.777, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 327.777, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 327.777, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 327.777, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 327.777, "isPaid": false}, "janvier_2027": {"amount": 327.777, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 327.777, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 327.777, "isPaid": true}, "octobre_2026": {"amount": 327.777, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 327.777, "isPaid": false}, "decembre_2026": {"amount": 327.777, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 327.777, "isPaid": true}, "novembre_2026": {"amount": 327.777, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 327.777, "isPaid": true}, "septembre_2026": {"amount": 327.777, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
147	25/000041	2025-08-21	PISTA VCX BLEUE NOIRE	B2B	STE TUNISIENNE DE DISTRIBUTION DES PRODUITS	\N	LSC4BGN66S1E00708	70751 DN	Récupérée	4150	4150	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
166	25/000060	2025-09-25	SPRING ST 124CC BLEUE CIEL	B2C	Mr Achref GHARBI	\N	LYFXCJL03R7001360	75632 DN	Récupérée	4300	2000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 200, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 400, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 600, "isPaid": true}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 500, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 600, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
111	25/000005	2025-06-19	SPRING ST 124CC VERT  PISTACHE	B2B	DARDOUR ET COMPAGNIE SDC	\N	LYFXCJL00R7001137	59599 DN	Récupérée	4052	4052	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
193	25/000087	2025-11-25	CASQUE LS2	B2C	Mr Zaid BAILI	\N	\N		None	350	0	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 350, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
200	25/000094	2025-12-20	CASQUE LS2	B2C	Mr Moataz BOUAADILA	\N	\N		None	375	0	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 375, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
112	25/000006	2025-06-21	FORZA POWER 107CC GRIS	B2C	Mr ALI CHEBBI	\N	LC4XCHL02R0D03351	58695 DN	Récupérée	2800	2800	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
220	26/000011	27/01/2026	FORZA POWER 107CC NOIRE	B2C	Hamza HASSNAOUI	\N	LC4XCHL07S0D01374	91781 DN	Récupérée	2950	2000	{"mai_2026": {"amount": 237, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 238, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 237, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 238, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1769500858000
224	26/000015	2026-02-06	FORZA POWER 107CC BLEUE	B2C	Yassine RIAHI	\N	LC4XCHL02S0D01301	94423 DN	Récupérée	2950	950	{"mai_2026": {"amount": 500, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 500, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	3	1770457869000
250	26/000038	2026-03-13	BLASTER NOIR 125cc	B2C	Saber JBALI	\N	LEHTDJ042TRA00037		En cours	6900	6900	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1773839088795
258	26/000046	2026-04-18	\tPISTA HR VERT JAUNE 107 CC	B2C	Yassine RIAHI		LCS4BGN66S1000824		En cours	4400	2000	{"mai_2026": {"amount": 800, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 800, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 800, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1776520485000
254	26/000040	2026-03-19	SPRING ST 124CC BLEU FONCE	B2C	Mohamed Amine BEN SALAH	\N	LYFXCJL08R7000768	\N	En cours	4200	1200	{"mai_2026": {"amount": 750, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 750, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 750, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 750, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1774255935000
256	26/000042	2026-03-26	\tSPRING ST 124CC BLEU FONCE	B2C	Ayoub ALMAHMOUDI		LYFXCJL0XR7000769	99597 DN	Récupérée	4300	2300	{"mai_2026": {"amount": 500, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 500, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 500, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 500, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1774525627000
255	26/000041	2026-03-24	\tFORZA POWER 124CC GRIS	B2C	Ali RIAHI		LC4XCJL06S0D01485	99600 DN	Récupérée	3050	2500	{"mai_2026": {"amount": 250, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 300, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1774364134000
249	26/000037	2026-03-12	BLASTER VERT 125cc	B2C	Taieb KACHOUB	\N	LEHTDJ04XTRA00089	97300 DN	Récupérée	6902	6902	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1773839085030
252	26/000039	2026-03-16	PISTA HR+ NOIR ROUGE	B2B	STE SOTUCHOC		LCS4BJN85T1103863	99945 DN	Récupérée	4750	4750	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1773839096720
251	26/000039	2026-03-16	PISTA HR+ BLEU BEIGE	B2B	STE SOTUCHOC		LCS4BJN82T1103951	99944 DN	Récupérée	4750	4750	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1773839092978
245	26/000033	2026-02-27	PISTA HR+ CARBONE ROUGE 124 cc	B2B	STE SOPREM	\N	LCS4BGN85T1103958	95102 DN	Récupérée	4736	4736	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
246	26/000034	2026-03-11	SPRING ST 124CC BLEU FONCE	B2C	Bachir BALLOUMI	\N	LYFXCJL05R7000775	97017 DN	Récupérée	4150	4150	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1773839073297
247	26/000035	2026-03-11	BLASTER GRIS 125cc	B2C	Zaid BAILI	\N	LEHTDJ041TRA00126	97306 DN	Récupérée	6900	5000	{"mai_2026": {"amount": 400, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 1000, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1773839077478
241	26/000032	2026-02-25	Spring ST 124cc Bleu	B2C	Anouar ABDALLAH	\N	LYFXCJL02R7000751	94855 DN	Récupérée	4100	4100	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
243	26/000033	2026-02-27	PISTA HR+ BLEU BEIGE 124 cc	B2C	STE SOPREM	\N	LCS4BGN80T1103933	95100 DN	Récupérée	4736	4736	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
244	26/000033	2026-02-27	PISTA HR+ ROUGE NOIRE 124 cc	B2B	STE SOPREM	\N	LCS4BGN86T1103886	95101 DN	Récupérée	4736	4736	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
236	26/000027	2026-02-18	PISTA HR+ CARBONE	B2C	Bilel GHRAIRI	\N	LCS4BJN83T1104123		Impôt	4800	1500	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
237	26/000028	2026-02-19	PISTA HR+ Noir/Rouge	B2C	Issam NAWALI	\N	LCS4BJN8XT1104006		A Déposer	4800	4800	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
238	26/000029	2026-02-19	PISTA HR+ Bleu/Beige	B2C	Hajer MOHSEN	\N	LCS4BJN8XT1103941	94259 DN	Récupérée	4800	1300	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 3500, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
232	26/000023	2026-02-17	Casque TNL	B2C	Protest Engineering	\N	\N		None	148	148	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
233	26/000024	2026-02-17	PISTA HR+ VERT MARRON	B2C	Adem BEN HSSIN	\N	LCS4BJN81T1104041	94537 DN	Récupérée	4800	3200	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 400, "isPaid": true}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 400, "isPaid": true}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 400, "isPaid": true}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 400, "isPaid": true}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
234	26/000025	2026-02-18	PISTA HR+ ROUGE NOIRE	B2C	Aniss TIAHI	\N	LCS4BJN8XT1103891		Impôt	4800	1500	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
228	26/000019	2026-02-10	FORZA POWER 124CC NOIRE	B2C	Ali HATHROUBI	\N	LC4XCJL08S0D01729	92024 DN	Récupérée	3050	3050	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1770723298000
229	26/000020	2026-02-11	PISTA HR CARBON	B2C	CharfE Eddin ALAAMRI	\N	LCS4BGN60S1700418	92536 DN	Récupérée	4648	1100	{"mai_2026": {"amount": 500, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 500, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 500, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 500, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 548, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1770808882000
230	26/000021	2026-02-16	SPRING ST 124CC VERT + Gris TNL	B2C	Hazem BEN AALAYET	\N	LYFXCJL05R7000677	92991 DN	Récupérée	4300	4100	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 200, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
223	26/000014	2026-02-03	FORZA POWER 107CC BLEUE	B2C	NIZAR BOU DHAOWIA	\N	LC4XCHL09S0D01294	91997 DN	Récupérée	2950	1500	{"mai_2026": {"amount": 450, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1770367525000
226	26/000017	2026-02-07	SPRING ST 124CC BLEU FONCE	B2C	Mohamed Ali NASRALLAH	\N	LYFXCJL08R7000771	92363 DN	Récupérée	4150	4150	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1770723298000
225	26/000016	2026-02-07	PISTA HR NOIR / GRIS	B2C	Amir KIRAT	\N	LCS4BGN63S1000585	99618 DN	Prête	4500	1500	{"mai_2026": {"amount": 1000, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 400, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 1000, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 600, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	2	1770457869000
218	26/000009	22/01/2026	FORZA POWER 107CC NOIRE	B2C	Alae NAJEM	\N	LC4XCHL00S0D01345	92034 DN	Récupérée	2950	950	{"mai_2026": {"amount": 500, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 500, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1769072307000
219	26/000010	27/01/2026	PISTA HR+ NOIRE BLEU	B2C	Mohamed Aziz DALLAJI	\N	LCS4BJN80S1700708	95318 DN	Récupérée	4750	1000	{"mai_2026": {"amount": 625, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 625, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 625, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 625, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 625, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 625, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1769500662000
221	26/000012	27/01/2026	PISTA HR+ JAUNE VERT	B2C	Mohamed Slim ABID 	\N	LCS4BJN84S1700663	94846 DN	Récupérée	4750	1000	{"mai_2026": {"amount": 600, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 625, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 625, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 650, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 625, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 625, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1769527437000
208	26/000004	2026-01-09	FORZA POWER 124CC NOIRE	B2C	Mr Ramzi BALOUTI	\N	LC4XCJL0XS0D01733	90565 DN	Récupérée	3150	1150	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 700, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 700, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 600, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
210	26/000005	2026-01-09	SPRING ST 124CC VERT	B2C	Mr Walid BENCHIKH	\N	LYFXCJL01R7000689		Impôt	4300	1400	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 1400, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 1500, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768231103000
212	26/000006	13/01/2026	FORZA POWER 107CC NOIRE	B2C	Mr Ihsen LARIANI	\N	LC4XCHL04S0D01364	88874 DN	Récupérée	2950	0	{"mai_2026": {"amount": 180, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 985, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 985, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 800, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768304795000
204	25/000098	2025-12-29	PISTA HR+ NOIR BLEU	B2C	Mr Mohamed AZIZ BEN AHMED	\N	LCS4BJN82S1700709	86523 DN	Récupérée	4800	2800	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 700, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 600, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 700, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
205	26/000001	2026-01-02	SPRING ST 124CC VERT PISTACHE	B2C	Mr Skander SHILI	\N	LYFXCJL04R7001125	86700 DN	Récupérée	4200	700	{"mai_2026": {"amount": 2000, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 500, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
206	26/000002	2026-01-02	CASQUE MT	B2C	Mr Skander SHILI	\N	\N		None	275	0	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 275, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
199	25/000093	2025-12-19	FORZA POWER 107CC NOIRE	B2C	Mr Yassine RIAHI	\N	LC4XCHL06S0D01365	86705 DN	Récupérée	2950	1700	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 420, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 420, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 410, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
202	25/000096	2025-12-22	SPRING ST 124CC VERT	B2C	Mr Wissem ROMDHANI	\N	LYFXCJL0XR7000724	86704 DN	Récupérée	4300	2300	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 500, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 500, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
201	25/000095	2025-12-22	FORZA POWER 107CC GRIS	B2C	Mr Abdessalem BOUSEDRA	\N	LC4XCHL00S0D01264	98122 DN	Récupérée	2950	1450	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 500, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	2	1768230408000
195	25/000089	2025-12-09	CASQUE LS2	B2C	Mr Mohamed RAYEN MATHLOUTHI	\N	\N		None	385	0	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 192.5, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 192.5, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
196	25/000090	2025-12-15	FORZA POWER 107CC ROUGE	B2C	Mr Ihsen LARIANI	\N	LC4XCHL01S0D01239	85524 DN	Récupérée	2950	1650	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 325, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 325, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 325, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 325, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
197	25/000091	2025-12-16	FORZA POWER 124CC ROUGE	B2C	Mr Kais HADDAGI	\N	LC4XCJL01S0D01426	85522 DN	Récupérée	3150	2000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 1150, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
190	25/000084	2025-11-20	PISTA HR+ CARBONE	B2C	Mr Seifeddine BEN ZEKRI	\N	LCS4BJN84S1700792	83934 DN	Récupérée	4701	4701	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
191	25/000085	2025-11-21	PISTA VCX DORE NOIRE	B2C	Mr Skander BEN MRIDA	\N	LCS4BGN69S1E00539	90956 DN	Récupérée	4201	4201	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
192	25/000086	2025-11-25	PISTA HR+ NOIRE MARRON	B2C	Mr Zaid BAILI	\N	LCS4BJN8XS1700781	83686 DN	Récupérée	4700	2700	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 1000, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 1000, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
186	25/000080	2025-11-14	PISTA HR+ VERT JAUNE	B2C	Mr Mohamed AZIZ SAADAOUI	\N	LCS4BJN88S1700665	88862 DN	Récupérée	4701	4701	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
187	25/000081	2025-11-17	CASQUE LS2	B2B	STE AKRAM DE COMMERCE ET SERICES	\N	\N		None	385	0	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 385, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
188	25/000082	2025-11-17	CASQUE LS2	B2C	Mr Skander SHILI	\N	\N		None	100	0	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 100, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
181	25/000075	2025-11-08	SPRING ST 124CC VERT	B2C	Mr Mohamed Ali EL GHRAIRI	\N	LYFXCJL02R7000507	83932 DN	Récupérée	4201	4201	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
182	25/000076	2025-11-10	SPRING ST 124CC JAUNE NOIRE	B2C	Mr Abd Raouf EL MELHMI	\N	LYFXCJL08R7001435	79846 DN	Récupérée	4300	2300	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 200, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 400, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 700, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 700, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
183	25/000077	2025-11-10	PISTA HR CARBON	B2C	Mr Bilel MANNAII	\N	LCS4BGN67S1700366	79846 DN	Récupérée	4451	4451	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
177	25/000071	2025-10-27	FORZA POWER 107CC BLEUE	B2C	Mr MED ADNENE CHAMTOURI	\N	LC4XCHL06S0D00085	77614 DN	Récupérée	2950	1500	{"mai_2026": {"amount": 250, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 200, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 200, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 200, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 200, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 200, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 200, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
178	25/000072	2025-10-28	SPRING ST 124CC NOIR	B2C	Mr Fawzi TLILI	\N	LYFXCJL0XR7000657	77001 DN	Récupérée	4200	1500	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 200, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 500, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 500, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 500, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 500, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
179	25/000073	2025-11-06	SPRING ST 124CC BLEU FONCEE	B2C	Mr Skander SHILI	\N	LYFXCJL03R7000595	78860 DN	Récupérée	4200	2200	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 1000, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 1000, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
172	25/000066	2025-10-08	FORZA POWER 107CC NOIRE	B2C	Mr Fraj BOUKHRIS	\N	LC4XCHL09S0D00176	73877 DN	Récupérée	2820	2820	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
173	25/000067	2025-10-08	SPRING ST 124CC JAUNE NOIRE	B2C	Mr MED Amine EL FRADI	\N	LYFXCJL01R7001079	73873 DN	Récupérée	4201	4201	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
175	25/000069	2025-10-22	PISTA HR NOIR / MARRON	B2C	Mr Ahmed KANZARI	\N	LCS4BGN6XS1700491	79363 DN	Récupérée	4500	4000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 500, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
168	25/000062	2025-09-29	PISTA HR+ VERT JAUNE	B2C	Mr Abderrazek ARAARI	\N	LCS4BJN88S1700083	70655 DN	Récupérée	4799	4799	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
169	25/000063	2025-09-30	SPRING ST 124CC BLEUE CIEL	B2C	Mr Naoufel EL HAMZI	\N	LYFXCJL04R7001397	76146 DN	Récupérée	4250	2000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 1250, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 1000, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
170	25/000064	2025-10-06	FORZA POWER 124CC GRIS	B2C	Mr Med Ayoub GOUADER	\N	LC4XCJL00S0D00641	73875 DN	Récupérée	3050	3050	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
163	25/000057	2025-09-24	FORZA POWER 107CC NOIRE	B2C	Mr Mahdi SASSI	\N	LC4XCHL06S0D00197	78018 DN	Récupérée	2850	2850	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
164	25/000058	2025-09-24	SPRING ST 124CC JAUNE NOIRE	B2B	SOCIETE WAFRA AGRICOLE SWA	\N	LYFXCJL01R7001082	72034 DN	Récupérée	4449	4449	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
165	25/000059	2025-09-25	PISTA HR+ GRIS VERT	B2C	Mr MOHAMED EL AMDOUNI	\N	LCS4BJN81S1700037	78010 DN	Récupérée	4800	2000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 560, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 560, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 560, "isPaid": true}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 560, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 560, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
158	25/000052	2025-09-11	FORZA POWER 124CC NOIRE	B2C	Mr Yosri MAHWACHI	\N	LC4XCJL07S0D00779	78022 DN	Récupérée	50	0	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 50, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
160	25/000054	2025-09-22	SPRING ST 124CC VERT PISTACHE	B2C	Mme Nassima THEMRI	\N	LYFXCJL08R7001306	72867 DN	Récupérée	4200	3000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 600, "isPaid": true}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 600, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
161	25/000055	2025-09-23	PISTA HR+ NOIRE BLEU	B2B	STE LE CLUB	\N	LCS4BJN87S1700138	71057 DN	Récupérée	4752	0	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 2376, "isPaid": true}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 2376, "isPaid": true}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
154	25/000048	2025-09-01	FORZA POWER 107CC NOIRE	B2C	Mr Khmais DRIDI	\N	LC4XCHL04S0D00117	66239 DN	Récupérée	2850	2850	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
155	25/000049	2025-09-03	PISTA VCX ROUGE NOIRE	B2C	Mr Adem BEN HSSIN	\N	LCS4BGN63S1E00326	67156 DN	Récupérée	4150	2150	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 500, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 500, "isPaid": true}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 500, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 500, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
156	25/000050	2025-09-08	SPRING ST 124CC VERT PISTACHE	B2C	Mr Zied MLAOUH	\N	LYFXCJL08R7001337	72869 DN	Récupérée	4300	300	{"mai_2026": {"amount": 500, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 500, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 500, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 500, "isPaid": true}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 500, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 500, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
150	25/000044	2025-08-23	FORZA POWER 107CC GRIS	B2C	Mr Kais KASDAOUI	\N	LC4XCHL08S0D00041	67168 DN	Récupérée	2700	1700	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 100, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 300, "isPaid": true}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 300, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 300, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
151	25/000045	2025-08-25	PISTA VCX ROUGE NOIRE	B2C	Mr Mohamed AZIZ KESIBI	\N	LCS4BGN68S1E00452	70758 DN	Récupérée	4150	4150	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
152	25/000046	2025-08-25	PISTA VCX BLEUE JAUNE	B2C	Mr Kamel JELASSI	\N	LCS4BGN6XS1E00520	66169 DN	Récupérée	4150	4150	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
145	25/000039	2025-08-18	GHOST V7 124CC VERT NOIRE	B2C	Mr Moez JBELI	\N	LEHTCJ012RRM00064	72354 DN	Récupérée	5900	5900	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
146	25/000040	2025-08-18	FORZA POWER 124CC ROUGE	B2C	Mr Mohamed DAOUTHI	\N	LC4XCJL06S0D00627		Impôt	3000	3000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
148	25/000042	2025-08-21	FORZA POWER 124CC NOIRE	B2C	Mr Sami BEN DHAW	\N	LC4XCJL08S0D00712	66171 DN	Récupérée	3050	3050	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
139	25/000033	2025-08-01	FORZA POWER 124CC NOIRE	B2C	Mr Hassen KASDAOUI	\N	LC4XCJL03S0D00732	65919 DN	Récupérée	3000	3000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
141	25/000035	2025-08-02	GHOST V7 124CC BLEUE JAUNE	B2C	Mr Souhail BEN REJEB	CONVENTION STEG	LEHTCJ014RRM00471	66236 DN	Récupérée	5900	1400	{"mai_2026": {"amount": 250, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 250, "isPaid": true}, "aout_2026": {"amount": 250, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 250, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 250, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 250, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 250, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 250, "isPaid": false}, "janvier_2027": {"amount": 250, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 250, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 250, "isPaid": true}, "octobre_2026": {"amount": 250, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 250, "isPaid": false}, "decembre_2026": {"amount": 250, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 250, "isPaid": true}, "novembre_2026": {"amount": 250, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 250, "isPaid": true}, "septembre_2026": {"amount": 250, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
143	25/000037	2025-08-11	SPRING ST 124CC VERT  PISTACHE	B2C	Mr Bilel AHMED	\N	LYFXCJL00R7001140	64425 DN	Récupérée	3998	3998	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
135	25/000029	2025-07-23	PISTA VCX BLEU NOIRE	B2C	Mr Naoufel EL HAMZI	\N	LSC4BGN67S1E00586	62917 DN	Récupérée	4151	4151	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
136	25/000030	2025-07-23	FORZA POWER 107CC NOIRE	B2B	STE MGF	\N	LC4XCHL03S0D01355	83680 DN	Récupérée	2850	2850	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
137	25/000031	2025-07-26	SPRING ST 124CC BLEUE CIEL	B2C	Mr Abdelkrim BEN MAATOUG	\N	LYFXCJL08R7001046	64071 DN	Récupérée	4050	3050	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 500, "isPaid": true}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 500, "isPaid": true}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
130	25/000024	2025-07-17	FORZA POWER 107CC BLEUE	B2C	Mr Youssef BEN YOUNES	\N	LC4XCHL08R0D03564	73879 DN	Récupérée	2850	2850	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
131	25/000025	2025-07-16	SPRING ST 124CC BLEUE CIEL	B2C	Mr Wahid LABIDI	\N	LYFXCJL04R7001013	62922 DN	Récupérée	4100	2000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 500, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 500, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 600, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 500, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
132	25/000026	2025-07-19	GHOST V7 124CC BLEUE JAUNE	B2C	Mr Mokhtar NAHHALI	\N	LEHTCJ016RRM00472	66238 DN	Récupérée	5869	5869	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
121	25/000015	2025-07-10	PISTA VCX VERT PISTACHE	B2C	Mr Mourad GHRAIRI	\N	LCS4BGN69S1E00752	61344 DN	Récupérée	4100	4100	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
123	25/000017	2025-07-11	FORZA POWER 107CC NOIRE	B2C	Mr HASSEN ARFAOUI	CONVENTION STEG	LC4XCHL03R0D03665	63878 DN	Récupérée	2850	0	{"mai_2026": {"amount": 158.336, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 158.336, "isPaid": true}, "aout_2026": {"amount": 158.336, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 158.336, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 158.336, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 158.336, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 158.336, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 158.336, "isPaid": false}, "janvier_2027": {"amount": 158.336, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 158.336, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 158.336, "isPaid": true}, "octobre_2026": {"amount": 158.336, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 158.336, "isPaid": false}, "decembre_2026": {"amount": 158.336, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 158.336, "isPaid": true}, "novembre_2026": {"amount": 158.336, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 158.336, "isPaid": true}, "septembre_2026": {"amount": 158.336, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
127	25/000021	2025-07-15	PISTA VCX VERT JAUNE	B2C	Mr Nader CHAOUACHI	CONVENTION STEG	LCS4BGN62S1E00768	63882 DN	Récupérée	4200	0	{"mai_2026": {"amount": 233.333, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 233.333, "isPaid": true}, "aout_2026": {"amount": 233.333, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 233.333, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 233.333, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 233.333, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 233.333, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 233.333, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 233.333, "isPaid": true}, "juillet_2026": {"amount": 233.333, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 233.333, "isPaid": true}, "octobre_2026": {"amount": 233.333, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 233.333, "isPaid": false}, "decembre_2026": {"amount": 233.333, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 233.333, "isPaid": false}, "novembre_2026": {"amount": 233.333, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 233.333, "isPaid": true}, "septembre_2026": {"amount": 233.333, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
117	25/000011	2025-06-25	GHOST V7 124CC BLEUE JAUNE	B2C	Mme AZIZA ABIDI	\N	LEHTCJ015RRM00141	64075 DN	Récupérée	5682	5682	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
118	25/000012	2025-06-30	PISTA VCX BLANC NOIRE	B2C	MR DHAKER KHADRAOUI	\N	LCS4BGN65S1E00697		Impôt	4100	4100	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
119	25/000013	2025-07-01	PISTA VCX BLANC NOIRE	B2C	Mr MOHAMED SNOUN	\N	LCS4BGN65S1E00702	60289 DN	Récupérée	4100	4100	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
113	25/000007	2025-06-21	PISTA VCX VERT PISTACHE	B2C	MR OUSSEMA BEN AISSA	\N	LCS4BGN69S1E00749	58973 DN	Récupérée	4100	4100	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
114	25/000008	2025-06-21	GHOST V7 124CC VERT NOIRE	B2C	MR MALEK JBELI	\N	LEHTCJ014RRM00003	58967 DN	Récupérée	5760	5760	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
115	25/000009	2025-06-22	SPRING ST 124CC BLEUE CIEL	B2C	MR MOUJIB ALLAH EL JENDOUBI	\N	LYFXCJL08R7001015	59380 DN	Récupérée	4050	4050	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
107	25/000001	2025-06-16	PISTA VCX NOIRE NOIRE	B2C	Mr ZIED BOUAFIA	\N	LCS4BGN60S1E00784	72925 DN	Récupérée	4100	4100	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
108	25/000002	2025-06-17	GHOST V7 124CC BLEUE JAUNE	B2C	Mr MED MAROUEN EL HAJRI	\N	LEHTCJ015RRM00155	58968 DN	Récupérée	5800	5800	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
110	25/000004	2025-06-19	PISTA VCX NOIRE NOIRE	B2B	EMEB	\N	LCS4BGN69S1E00783	58752 DN	Récupérée	4153	4153	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
116	25/000010	2025-06-22	FORZA POWER 107CC NOIRE	B2C	MR MOHAMED HAMROUNI	\N	LC4XCHL05R0D03604	60190 DN	Récupérée	2800	2800	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
120	25/000014	2025-07-03	SPRING ST 124CC JAUNE NOIRE	B2C	Mr IBRAHIM ABID	\N	LYFCXJL02R7001429	81284 DN	Récupérée	4000	4000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
125	25/000019	2025-07-12	GHOST V7 124CC NOIRE	B2C	Mr Ahmed FARHAT	\N	LEHTCJ011RRM00413	66237 DN	Récupérée	5900	5900	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
128	25/000022	2025-07-24	FORZA POWER 107CC GRIS	B2C	Mr Nizar SALHI	\N	LC4XCHL02R0D03348	63115 DN	Récupérée	2800	2800	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
133	25/000027	2025-07-20	FORZA POWER 107CC BLEUE	B2C	Mme Fathia DHAHRI	\N	LC4XCHL02R0D03592	63122 DN	Récupérée	2800	2800	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
134	25/000028	2025-07-22	FORZA POWER 107CC NOIRE	B2C	Mr Abdelkader HEDFI	\N	LC4XCHL00R0D03414	64080 DN	Récupérée	2800	2800	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
138	25/000032	2025-07-31	FORZA POWER 107CC NOIRE	B2C	Mr Ahmed TRABELSI	\N	LC4XCHL0XS0D00171	65925 DN	Récupérée	2800	2800	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
144	25/000038	2025-08-16	PISTA VCX VERT NOIRE	B2C	Mr Ghassen BALTI	\N	LCS4BGN61S1E00762	67093 DN	Récupérée	4150	4150	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
149	25/000043	2025-08-21	SPRING ST 124CC BLEUE CIEL	B2C	Mr Foued EL AALLAGUI	\N	LYFXCJL05R7001229	67810 DN	Récupérée	4201	4201	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
153	25/000047	2025-08-30	PISTA VCX DORE NOIRE	B2C	Mr Sadok SALHI	\N	LCS4BGN65S1E00134	68751 DN	Récupérée	4150	4150	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
157	25/000051	2025-09-08	SPRING ST 124CC BLEUE CIEL	B2C	Hajer NAFFETI	\N	LYFXCJL04R7001223	96351 DN	Récupérée	4300	1200	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 500, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 600, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 1000, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 1000, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
159	25/000053	2025-09-19	SPRING ST 124CC VERT PISTACHE	B2C	Mr Abderrazek EL AJIMI	\N	LYFXCJL09R7001170	72868 DN	Récupérée	4200	4200	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
162	25/000056	2025-09-23	PISTA HR+ CARBONE	B2C	Mr HASANINE REBII	\N	LCS4BJN88S1700259	73614 DN	Récupérée	4748	4748	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
167	25/000061	2025-09-26	PISTA HR+ NOIRE MARRON	B2B	STE TULIPE TECHNOLOGY	\N	LCS4BJN84S1700209	71064 DN	Récupérée	4699	4699	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
171	25/000065	2025-10-06	FORZA POWER 124CC ROUGE	B2C	Mr Wassim ABBESSI	\N	LC4XCJL07S0D00622	73622 DN	Récupérée	3150	1150	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 100, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 400, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 500, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 500, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 500, "isPaid": true}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
174	25/000068	2025-10-13	FORZA POWER 107CC ROUGE	B2C	Mr Fraj BEN AMMAR	\N	LC4XCHL00S0D00003	84957 DN	Récupérée	2850	2850	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
176	25/000070	2025-10-22	FORZA POWER 124CC GRIS	B2C	Mme AALIA SAMIA	\N	LC4XCJL02S0D00673	78021 DN	Récupérée	3154	3154	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
180	25/000074	2025-11-07	SPRING ST 124CC NOIR	B2C	Mr Mohamed RAYEN MATHLOUTHI	\N	LYFXCJL09R7000956	78716 DN	Récupérée	4200	2450	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 200, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 200, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 400, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 400, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 400, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 150, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
184	25/000078	2025-11-10	FORZA POWER 107CC BLEUE	B2C	Mr Iyed EL HAMADI	\N	LC4XCHL02S0D00083	78867 DN	Récupérée	2850	2850	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
185	25/000079	2025-11-10	FORZA POWER 124CC BLEU	B2C	Mr Ahmed WERGHEMI	\N	LC4XCJL00S0D00686	78868 DN	Récupérée	3150	500	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 700, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 300, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 500, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 500, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 150, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
189	25/000083	2025-11-18	PISTA HR+ GRIS VERT	B2C	Mr Omar FERGENI	\N	LCS4BJN87S1700611	79432 DN	Récupérée	4700	2000	{"mai_2026": {"amount": 450, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 450, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 450, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 450, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 450, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 450, "isPaid": true}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
194	25/000088	2025-12-04	PISTA HR NOIR / GRIS	B2C	Mr Moataz BOUAADILA	\N	LCS4BGN69S1700479	85525 DN	Récupérée	4399	4399	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
198	25/000092	2025-12-19	PISTA HR+ GRIS VERT	B2C	Mr Idriss HAMADA	\N	LCS4BJN84S1700596	86696 DN	Récupérée	4800	3000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 600, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 600, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 600, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
203	25/000097	2025-12-24	FORZA POWER 107CC NOIRE	B2C	Mme  Saida FAZAII	\N	LC4XCHL07S0D01357	87350 DN	Récupérée	2850	2850	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
207	26/000003	2026-01-05	FORZA POWER 107CC GRIS	B2C	Mr Kais HADDAGI	\N	LC4XCHL02S0D01248	94553 DN	Récupérée	2950	0	{"mai_2026": {"amount": 950, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 750, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 750, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768230408000
216	26/000007	2026-01-14	SPRING ST 124CC VERT	B2C	Mr Lassaad GOUIDER	\N	LYFXCJL02R7000703	94979 DN	Récupérée	4300	2300	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 500, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 500, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 500, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 500, "isPaid": true}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768548791000
217	26/000008	2026-01-15	SPRING ST 124CC BLEU FONCEE	B2C	Mr Skander SHILI	\N	LYFXCJL08R7000783	91031 DN	Récupérée	4300	1100	{"mai_2026": {"amount": 400, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 400, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 400, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 400, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 450, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 400, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 400, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 350, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1768548791000
222	26/000013	28/01/2026	PISTA HR CARBON	B2C	Saber BADR	\N	LCS4BGN69S1000624	91029 DN	Récupérée	4500	1500	{"mai_2026": {"amount": 750, "isPaid": true}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 750, "isPaid": true}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 750, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 750, "isPaid": true}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1769608499000
227	26/000018	2026-02-10	FORZA POWER 124CC NOIRE	B2C	Iptissem MANSOURI	\N	LC4XCJL07S0D01821	91992 DN	Récupérée	3050	2650	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 400, "isPaid": true}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1770723298000
231	26/000022	2026-02-17	FORZA POWER 124CC NOIRE	B2C	Protest Engineering	\N	LC4XCJL07S0D01768	93684 DN	Récupérée	3100	3100	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
235	26/000026	2026-02-18	SPRING ST 124CC VERT	B2C	Kilani FERCHICHI	\N	LYFXCJL08R7000690	93646 DN	Récupérée	4200	2000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 2200, "isPaid": true}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
239	26/000030	2026-02-23	FORZA POWER 124CC BLEU	B2B	FSIC	\N	LC4XCJL01S0D00681	94255 DN	Récupérée	3167	3167	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
240	26/000031	2026-02-21	PISTA HR Vert/Jaune	B2B	STE GREPSYS	\N	LCS4BGN64S1700549	94258 DN	Récupérée	4404	4404	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
242	26/000033	2026-02-27	PISTA HR+ NOIR ROUGE 124 cc	B2B	STE SOPREM	\N	LCS4BGN8XT1103860	95099 DN	Récupérée	4737	4737	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1772449417000
257	26/000044	2026-04-06	FORZA POWER 124CC GRIS	B2C	Sami ESSID		LC4XCJL00S0D01479		En cours	3000	2200	{"mai_2026": {"amount": 200, "isPaid": true}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 600, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1775549533000
253	26/000039	2026-03-16	PISTA HR+ VERT MARRON	B2B	STE SOTUCHOC		LCS4BJN82T1103917	99947 DN	Récupérée	4750	4750	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1773839100758
248	26/000036	2026-03-12	FORZA POWER 124CC BLEU	B2C	Ahmed AAGRBI	\N	LC4XCJL08S0D01486	98029 DN	Récupérée	3000	3000	{"mai_2026": {"amount": 0, "isPaid": false}, "mai_2027": {"amount": 0, "isPaid": false}, "aout_2025": {"amount": 0, "isPaid": false}, "aout_2026": {"amount": 0, "isPaid": false}, "aout_2027": {"amount": 0, "isPaid": false}, "juin_2026": {"amount": 0, "isPaid": false}, "juin_2027": {"amount": 0, "isPaid": false}, "mars_2026": {"amount": 0, "isPaid": false}, "mars_2027": {"amount": 0, "isPaid": false}, "avril_2026": {"amount": 0, "isPaid": false}, "avril_2027": {"amount": 0, "isPaid": false}, "fevrier_2026": {"amount": 0, "isPaid": false}, "fevrier_2027": {"amount": 0, "isPaid": false}, "janvier_2026": {"amount": 0, "isPaid": false}, "janvier_2027": {"amount": 0, "isPaid": false}, "janvier_2028": {"amount": 0, "isPaid": false}, "juillet_2025": {"amount": 0, "isPaid": false}, "juillet_2026": {"amount": 0, "isPaid": false}, "juillet_2027": {"amount": 0, "isPaid": false}, "octobre_2025": {"amount": 0, "isPaid": false}, "octobre_2026": {"amount": 0, "isPaid": false}, "octobre_2027": {"amount": 0, "isPaid": false}, "decembre_2025": {"amount": 0, "isPaid": false}, "decembre_2026": {"amount": 0, "isPaid": false}, "decembre_2027": {"amount": 0, "isPaid": false}, "novembre_2025": {"amount": 0, "isPaid": false}, "novembre_2026": {"amount": 0, "isPaid": false}, "novembre_2027": {"amount": 0, "isPaid": false}, "septembre_2025": {"amount": 0, "isPaid": false}, "septembre_2026": {"amount": 0, "isPaid": false}, "septembre_2027": {"amount": 0, "isPaid": false}}	1	1773839081297
\.


--
-- Data for Name: user_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_notifications (id, user_id, notification_id, is_read, dismissed) FROM stdin;
90	1	47	t	t
91	1	46	t	t
92	1	45	t	t
93	1	44	t	t
94	1	43	t	t
95	1	42	t	t
96	1	41	t	t
97	1	40	t	t
98	1	39	t	t
99	1	38	t	t
100	1	37	t	t
101	1	36	t	t
102	1	34	t	t
103	1	35	t	t
104	1	33	t	t
105	1	32	t	t
106	1	31	t	t
107	1	30	t	t
108	1	28	t	t
109	1	29	t	t
146	2	63	t	t
147	2	62	t	t
148	2	61	t	t
149	2	60	t	t
150	2	59	t	t
151	2	58	t	t
152	2	57	t	t
153	2	56	t	t
154	2	55	t	t
155	2	54	t	t
156	2	53	t	t
157	2	52	t	t
158	2	51	t	t
159	2	50	t	t
160	2	49	t	t
161	2	48	t	t
162	2	47	t	t
163	2	46	t	t
164	2	45	t	t
165	2	44	t	t
166	2	64	t	t
167	2	65	t	t
168	2	66	t	t
169	2	67	t	t
170	2	68	t	t
171	2	69	t	t
172	2	70	t	t
173	2	71	t	t
174	2	72	t	t
175	2	73	t	t
176	2	74	t	t
177	2	75	t	t
178	2	76	t	t
179	2	43	t	t
180	2	42	t	t
181	2	41	t	t
182	2	40	t	t
183	2	39	t	t
184	2	38	t	t
185	2	37	t	t
186	2	36	t	t
187	2	35	t	t
188	2	34	t	t
189	2	33	t	t
190	2	31	t	t
191	2	32	t	t
192	2	30	t	t
193	2	29	t	t
194	2	28	t	t
195	2	27	t	t
196	2	26	t	t
197	2	25	t	t
198	2	24	t	t
199	2	23	t	t
200	2	22	t	t
201	2	21	t	t
202	2	20	t	t
203	2	18	t	t
204	2	19	t	t
205	2	17	t	t
206	2	16	t	t
207	2	15	t	t
208	2	14	t	t
209	2	13	t	t
210	2	12	t	t
211	2	11	t	t
212	2	10	t	t
213	2	9	t	t
214	2	8	t	t
215	2	7	t	t
216	2	6	t	t
217	2	5	t	t
218	2	4	t	t
219	2	3	t	t
220	2	2	t	t
221	2	1	t	t
222	2	77	t	t
223	2	78	t	t
224	2	79	t	t
225	1	79	t	t
226	1	78	t	t
227	1	77	t	t
228	1	76	t	t
229	1	75	t	t
230	1	74	t	t
231	1	73	t	t
232	1	72	t	t
233	1	71	t	t
234	1	70	t	t
235	1	69	t	t
236	1	68	t	t
237	1	67	t	t
238	1	65	t	t
239	1	66	t	t
240	1	64	t	t
241	1	63	t	t
242	1	62	t	t
243	1	61	t	t
244	1	60	t	t
245	2	80	t	t
246	1	80	t	t
247	1	59	t	t
248	1	58	t	t
249	1	57	t	t
250	1	56	t	t
251	1	55	t	t
252	1	53	t	t
253	1	54	t	t
254	1	52	t	t
255	1	50	t	t
256	1	51	t	t
257	1	49	t	t
258	1	48	t	t
259	1	27	t	t
260	1	26	t	t
261	1	25	t	t
262	1	24	t	t
263	1	23	t	t
264	1	22	t	t
265	1	21	t	t
266	1	20	t	t
267	1	18	t	t
268	1	19	t	t
269	1	17	t	t
270	1	16	t	t
271	1	15	t	t
272	1	14	t	t
273	1	13	t	t
274	1	12	t	t
275	1	11	t	t
276	1	10	t	t
277	1	9	t	t
278	1	8	t	t
279	1	7	t	t
280	1	6	t	t
281	1	5	t	t
282	1	4	t	t
283	1	3	t	t
284	1	2	t	t
285	1	1	t	t
286	1	81	t	f
287	1	82	t	f
288	1	83	t	f
289	2	84	t	t
290	2	85	t	t
291	2	86	t	t
292	2	83	t	t
293	2	82	t	t
294	2	81	t	t
295	2	87	t	t
296	2	88	t	t
297	2	89	t	t
298	2	90	t	t
299	2	91	t	t
300	2	92	t	t
301	2	93	t	t
302	2	94	t	t
303	2	95	t	t
304	2	96	t	t
305	2	97	t	t
306	2	98	t	t
307	2	99	t	t
308	2	100	t	t
309	2	101	t	t
310	2	102	t	t
311	2	103	t	t
312	2	104	t	t
313	2	105	t	t
314	2	106	t	t
315	2	107	t	t
316	2	108	t	t
317	2	109	t	t
318	2	110	t	t
319	2	111	t	t
320	2	112	t	t
321	2	113	t	t
322	2	114	t	t
323	2	115	t	t
324	1	116	t	f
325	1	117	t	f
326	1	118	t	f
327	2	119	t	t
328	2	120	t	t
329	1	121	t	f
330	2	122	t	t
331	2	123	t	t
332	2	124	t	t
333	2	121	t	t
334	2	118	t	t
335	2	117	t	t
336	2	116	t	t
337	2	125	t	f
338	2	126	t	f
339	1	126	t	f
340	1	125	t	f
341	1	124	t	f
342	1	123	t	f
343	1	122	t	f
344	1	120	t	f
345	1	119	t	f
346	1	115	t	f
347	1	114	t	f
348	1	113	t	f
349	1	112	t	f
350	1	111	t	f
351	1	110	t	f
352	1	109	t	f
353	1	108	t	f
354	1	107	t	f
355	2	127	t	f
356	1	127	t	f
357	2	128	t	f
358	2	129	t	f
359	2	130	t	f
360	2	131	t	f
361	1	132	t	f
362	1	133	t	f
363	2	134	t	f
364	2	135	t	f
365	2	133	t	f
366	2	132	t	f
367	2	136	t	f
368	2	137	t	f
369	1	138	t	f
370	1	139	t	f
371	2	140	t	f
372	2	141	t	f
373	2	142	t	f
374	2	143	t	f
375	2	144	t	f
376	2	145	t	f
377	2	146	t	f
378	2	147	t	f
379	2	148	t	f
380	2	149	t	f
381	2	150	t	f
382	2	151	t	f
383	2	152	t	f
384	2	153	t	f
385	2	154	t	f
386	2	155	t	f
387	2	156	t	f
388	2	157	t	f
389	2	158	t	f
390	2	159	t	f
391	2	160	t	f
392	2	161	t	f
393	2	162	t	f
394	2	163	t	f
395	2	164	t	f
396	2	165	t	f
397	2	166	t	f
398	2	167	t	f
399	2	168	t	f
400	2	169	t	f
401	2	170	t	f
402	2	171	t	f
403	2	172	t	f
404	2	173	t	f
405	2	174	t	f
406	2	175	t	f
407	2	176	t	f
408	2	177	t	f
409	2	178	t	f
410	2	179	t	f
411	2	180	t	f
412	2	181	t	f
413	2	182	t	f
414	2	183	t	f
415	2	184	t	f
416	2	185	t	f
417	2	186	t	f
418	2	187	t	f
419	2	188	t	f
420	2	189	t	f
421	1	190	t	f
422	2	191	t	f
423	2	192	t	f
424	2	193	t	f
425	2	194	t	f
426	2	195	t	f
427	2	196	t	f
428	2	197	t	f
429	2	198	t	f
430	2	199	t	f
431	2	200	t	f
432	2	201	t	f
433	2	202	t	f
434	1	203	t	f
435	1	204	t	f
436	1	205	t	f
437	1	206	t	f
438	1	207	t	f
439	1	208	t	f
440	1	209	t	f
441	1	210	t	f
442	1	211	t	f
443	1	212	t	f
444	1	213	t	f
445	1	214	t	f
446	1	215	t	f
447	1	216	t	f
448	1	217	t	f
449	1	218	t	f
450	1	219	t	f
451	1	220	t	f
452	2	221	t	f
453	2	222	t	f
454	2	223	t	f
455	2	224	t	f
456	1	225	t	f
457	2	226	t	f
458	2	225	t	f
459	2	220	t	f
460	2	219	t	f
461	2	218	t	f
462	2	217	t	f
463	2	216	t	f
464	2	215	t	f
465	2	214	t	f
466	2	213	t	f
467	2	212	t	f
468	2	211	t	f
469	2	210	t	f
470	2	209	t	f
471	2	207	t	f
472	2	208	t	f
473	2	227	t	f
474	2	228	t	f
475	2	229	t	f
476	2	230	t	f
477	2	231	t	f
478	2	232	t	f
479	2	233	t	f
480	2	234	t	f
481	2	235	t	f
482	2	236	t	f
483	2	237	t	f
484	2	238	t	f
485	2	239	t	f
486	2	240	t	f
487	2	241	t	f
488	2	242	t	f
489	2	243	t	f
490	2	244	t	f
491	2	245	t	f
492	2	246	t	f
493	2	247	t	f
494	2	248	t	f
495	2	249	t	f
496	2	250	t	f
497	2	251	t	f
498	2	252	t	f
499	2	253	t	f
500	2	254	t	f
501	2	255	t	f
502	2	256	t	f
503	2	257	t	f
504	2	258	t	f
505	2	259	t	f
506	2	260	t	f
507	2	261	t	f
508	2	262	t	f
509	2	263	t	f
510	2	264	t	f
511	2	265	t	f
512	2	266	t	f
513	2	267	t	f
514	2	268	t	f
515	2	269	t	f
516	2	270	t	f
517	2	271	t	f
518	2	272	t	f
519	2	273	t	f
520	2	274	t	f
521	2	275	t	f
522	2	276	t	f
523	2	277	t	f
524	2	278	t	f
525	2	279	t	f
526	2	280	t	f
527	2	281	t	f
528	2	282	t	f
529	2	283	t	f
530	2	284	t	f
531	2	285	t	f
532	2	286	t	f
533	2	287	t	f
534	2	288	t	f
535	2	289	t	f
536	2	290	t	f
537	2	291	t	f
538	2	292	t	f
539	2	293	t	f
540	2	294	t	f
541	2	295	t	f
542	2	296	t	f
543	2	297	t	f
544	2	298	t	f
545	2	299	t	f
546	2	300	t	f
547	2	301	t	f
548	2	302	t	f
549	2	303	t	f
550	2	304	t	f
551	2	305	t	f
552	2	306	t	f
553	2	307	t	f
554	2	308	t	f
555	2	309	t	f
556	2	310	t	f
557	2	311	t	f
558	2	312	t	f
559	2	313	t	f
560	2	314	t	f
561	2	315	t	f
562	2	316	t	f
563	2	317	t	f
564	2	318	t	f
565	2	319	t	f
566	2	320	t	f
567	2	321	t	f
568	2	322	t	f
569	2	323	t	f
570	2	324	t	f
571	2	325	t	f
572	2	326	t	f
573	2	327	t	f
574	2	328	t	f
575	2	329	t	f
576	2	330	t	f
577	2	331	t	f
578	2	332	t	f
579	2	333	t	f
580	2	334	t	f
581	2	335	t	f
582	2	336	t	f
583	2	337	t	f
584	2	338	t	f
585	2	339	t	f
586	2	340	t	f
587	2	341	t	f
588	2	342	t	f
589	2	343	t	f
590	2	344	t	f
591	2	345	t	f
592	2	346	t	f
593	2	347	t	f
594	2	348	t	f
595	2	349	t	f
596	2	350	t	f
597	2	351	t	f
598	2	352	t	f
599	2	353	t	f
600	2	354	t	f
601	2	355	t	f
602	2	356	t	f
603	2	357	t	f
604	2	358	t	f
605	2	359	t	f
606	2	360	t	f
607	2	361	t	f
608	2	362	t	f
609	2	363	t	f
610	2	364	t	f
611	2	365	t	f
612	2	366	t	f
613	2	367	t	f
614	2	368	t	f
615	2	369	t	f
616	2	370	t	f
617	2	371	t	f
618	2	372	t	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, username, role) FROM stdin;
1	Karim	manager
2	Yassin	staff
\.


--
-- Name: clients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.clients_id_seq', 317, true);


--
-- Name: deferred_sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deferred_sales_id_seq', 7, true);


--
-- Name: divers_purchases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.divers_purchases_id_seq', 9, true);


--
-- Name: facture_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.facture_lines_id_seq', 149, true);


--
-- Name: factures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.factures_id_seq', 144, true);


--
-- Name: helmet_purchases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.helmet_purchases_id_seq', 14, true);


--
-- Name: helmet_sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.helmet_sales_id_seq', 16, true);


--
-- Name: livraison_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.livraison_lines_id_seq', 149, true);


--
-- Name: livraisons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.livraisons_id_seq', 144, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_id_seq', 372, true);


--
-- Name: oil_purchases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.oil_purchases_id_seq', 11, true);


--
-- Name: oil_sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.oil_sales_id_seq', 95, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_seq', 13, true);


--
-- Name: product_families_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_families_id_seq', 1, true);


--
-- Name: product_prices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_prices_id_seq', 1454, true);


--
-- Name: product_serials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_serials_id_seq', 140, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 61, true);


--
-- Name: reception_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reception_lines_id_seq', 1, false);


--
-- Name: receptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.receptions_id_seq', 1, false);


--
-- Name: reservations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reservations_id_seq', 23, true);


--
-- Name: saddle_purchases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.saddle_purchases_id_seq', 2, true);


--
-- Name: saddle_sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.saddle_sales_id_seq', 15, true);


--
-- Name: sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sales_id_seq', 258, true);


--
-- Name: user_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_notifications_id_seq', 618, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: deferred_sales deferred_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deferred_sales
    ADD CONSTRAINT deferred_sales_pkey PRIMARY KEY (id);


--
-- Name: divers_purchases divers_purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.divers_purchases
    ADD CONSTRAINT divers_purchases_pkey PRIMARY KEY (id);


--
-- Name: facture_lines facture_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facture_lines
    ADD CONSTRAINT facture_lines_pkey PRIMARY KEY (id);


--
-- Name: factures factures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factures
    ADD CONSTRAINT factures_pkey PRIMARY KEY (id);


--
-- Name: helmet_purchases helmet_purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.helmet_purchases
    ADD CONSTRAINT helmet_purchases_pkey PRIMARY KEY (id);


--
-- Name: helmet_sales helmet_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.helmet_sales
    ADD CONSTRAINT helmet_sales_pkey PRIMARY KEY (id);


--
-- Name: livraison_lines livraison_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraison_lines
    ADD CONSTRAINT livraison_lines_pkey PRIMARY KEY (id);


--
-- Name: livraisons livraisons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraisons
    ADD CONSTRAINT livraisons_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oil_purchases oil_purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oil_purchases
    ADD CONSTRAINT oil_purchases_pkey PRIMARY KEY (id);


--
-- Name: oil_sales oil_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oil_sales
    ADD CONSTRAINT oil_sales_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: product_families product_families_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_families
    ADD CONSTRAINT product_families_pkey PRIMARY KEY (id);


--
-- Name: product_prices product_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_prices
    ADD CONSTRAINT product_prices_pkey PRIMARY KEY (id);


--
-- Name: product_serials product_serials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_serials
    ADD CONSTRAINT product_serials_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: reception_lines reception_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reception_lines
    ADD CONSTRAINT reception_lines_pkey PRIMARY KEY (id);


--
-- Name: receptions receptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receptions
    ADD CONSTRAINT receptions_pkey PRIMARY KEY (id);


--
-- Name: reservations reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- Name: saddle_purchases saddle_purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saddle_purchases
    ADD CONSTRAINT saddle_purchases_pkey PRIMARY KEY (id);


--
-- Name: saddle_sales saddle_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saddle_sales
    ADD CONSTRAINT saddle_sales_pkey PRIMARY KEY (id);


--
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);


--
-- Name: user_notifications user_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_unique UNIQUE (username);


--
-- Name: notifications notifications_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_notifications user_notifications_notification_id_notifications_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_notification_id_notifications_id_fk FOREIGN KEY (notification_id) REFERENCES public.notifications(id);


--
-- Name: user_notifications user_notifications_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict krbRTqvbrDP7flK1ohu5eC2KrB1UTSefIIjbguM9Mg0cbnNiFw8NKSsXesF4oDN

