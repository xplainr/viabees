

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


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."insert_redemption"("_claim_token" "text", "_business_id" "uuid", "_campaign_id" "uuid", "_sharer_id" "uuid", "_status" "text", "_ip_address" "text", "_user_agent" "text", "_event" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
declare
  _business_id_text text;
begin
  _business_id_text := _business_id::text;
  set local app.current_business_id = _business_id_text;

  insert into redemption_journal (
    claim_token,
    business_id,
    campaign_id,
    sharer_id,
    status,
    ip_address,
    user_agent,
    event
  )
  values (
    _claim_token,
    _business_id,
    _campaign_id,
    _sharer_id,
    _status,
    _ip_address,
    _user_agent,
    _event
  );
end;
$$;


ALTER FUNCTION "public"."insert_redemption"("_claim_token" "text", "_business_id" "uuid", "_campaign_id" "uuid", "_sharer_id" "uuid", "_status" "text", "_ip_address" "text", "_user_agent" "text", "_event" "jsonb") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."auth_identity" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "auth_email" "text" NOT NULL,
    "auth_phone" "text" NOT NULL,
    "login_method" "text" NOT NULL,
    "magic_link_enabled" boolean DEFAULT false NOT NULL,
    "proof_of_business_submitted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "auth_identity_auth_email_check" CHECK (("auth_email" ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'::"text")),
    CONSTRAINT "auth_identity_login_method_check" CHECK (("login_method" = ANY (ARRAY['password'::"text", 'magic_link'::"text"])))
);


ALTER TABLE "public"."auth_identity" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."business" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "category" "text" NOT NULL,
    "contact_phone" "text" NOT NULL,
    "contact_email" "text" NOT NULL,
    "public_contact_uri" "text",
    "street" "text" NOT NULL,
    "city" "text" NOT NULL,
    "postal_code" "text" NOT NULL,
    "country" "text" NOT NULL,
    "region" "text",
    "registered_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "active" boolean DEFAULT true,
    CONSTRAINT "business_category_check" CHECK (("char_length"("category") >= 1)),
    CONSTRAINT "business_city_check" CHECK (("char_length"("city") >= 1)),
    CONSTRAINT "business_contact_email_check" CHECK (("contact_email" ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'::"text")),
    CONSTRAINT "business_country_check" CHECK (("char_length"("country") >= 1)),
    CONSTRAINT "business_name_check" CHECK (("char_length"("name") >= 1)),
    CONSTRAINT "business_postal_code_check" CHECK (("char_length"("postal_code") >= 1)),
    CONSTRAINT "business_street_check" CHECK (("char_length"("street") >= 1))
);


ALTER TABLE "public"."business" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."campaign" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "recipient_offer_text" "text" NOT NULL,
    "sharer_offer_text" "text",
    "terms_and_conditions" "text",
    "offer_type" "text",
    "valid_from" timestamp with time zone NOT NULL,
    "valid_until" timestamp with time zone NOT NULL,
    "redemption_limit" integer,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "active" boolean DEFAULT true,
    CONSTRAINT "campaign_check" CHECK (("valid_until" > "valid_from")),
    CONSTRAINT "campaign_offer_type_check" CHECK ((("offer_type" = ANY (ARRAY['Discount Percentage'::"text", 'Flat Discount'::"text", 'Free Item'::"text", 'Other'::"text"])) OR ("offer_type" IS NULL))),
    CONSTRAINT "campaign_recipient_offer_text_check" CHECK (("char_length"("recipient_offer_text") >= 5)),
    CONSTRAINT "campaign_sharer_offer_text_check" CHECK ((("sharer_offer_text" IS NULL) OR ("char_length"("sharer_offer_text") >= 5))),
    CONSTRAINT "campaign_terms_and_conditions_check" CHECK ((("terms_and_conditions" IS NULL) OR ("char_length"("terms_and_conditions") <= 500)))
);


ALTER TABLE "public"."campaign" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."redemption_journal" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "claim_token" "text" NOT NULL,
    "business_id" "uuid" NOT NULL,
    "campaign_id" "uuid" NOT NULL,
    "sharer_id" "uuid",
    "redeemed_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ip_address" "text",
    "user_agent" "text",
    "status" "text" NOT NULL,
    "event" "jsonb",
    CONSTRAINT "redemption_journal_status_check" CHECK (("status" = ANY (ARRAY['valid'::"text", 'redeemed'::"text", 'expired'::"text", 'invalid'::"text"])))
);


ALTER TABLE "public"."redemption_journal" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sharer" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "external_user_id" "text",
    "device_fingerprint" "text",
    "user_agent" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "email" "text",
    "phone" "text",
    "active" boolean DEFAULT true,
    CONSTRAINT "sharer_email_check" CHECK ((("email" IS NULL) OR ("email" ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'::"text")))
);


ALTER TABLE "public"."sharer" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sharer_business" (
    "sharer_id" "uuid" NOT NULL,
    "business_id" "uuid" NOT NULL,
    "first_seen_at" timestamp with time zone DEFAULT "now"(),
    "last_seen_at" timestamp with time zone,
    "consent_to_retargeting" boolean DEFAULT false
);


ALTER TABLE "public"."sharer_business" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sharer_campaign" (
    "sharer_id" "uuid" NOT NULL,
    "campaign_id" "uuid" NOT NULL,
    "first_shared_at" timestamp with time zone DEFAULT "now"(),
    "shares_count" integer DEFAULT 1
);


ALTER TABLE "public"."sharer_campaign" OWNER TO "postgres";


ALTER TABLE ONLY "public"."auth_identity"
    ADD CONSTRAINT "auth_identity_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."business"
    ADD CONSTRAINT "business_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."campaign"
    ADD CONSTRAINT "campaign_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."redemption_journal"
    ADD CONSTRAINT "redemption_journal_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sharer_business"
    ADD CONSTRAINT "sharer_business_pkey" PRIMARY KEY ("sharer_id", "business_id");



ALTER TABLE ONLY "public"."sharer_campaign"
    ADD CONSTRAINT "sharer_campaign_pkey" PRIMARY KEY ("sharer_id", "campaign_id");



ALTER TABLE ONLY "public"."sharer"
    ADD CONSTRAINT "sharer_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."auth_identity"
    ADD CONSTRAINT "auth_identity_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."campaign"
    ADD CONSTRAINT "campaign_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."redemption_journal"
    ADD CONSTRAINT "redemption_journal_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id");



ALTER TABLE ONLY "public"."redemption_journal"
    ADD CONSTRAINT "redemption_journal_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "public"."campaign"("id");



ALTER TABLE ONLY "public"."sharer_business"
    ADD CONSTRAINT "sharer_business_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sharer_business"
    ADD CONSTRAINT "sharer_business_sharer_id_fkey" FOREIGN KEY ("sharer_id") REFERENCES "public"."sharer"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sharer_campaign"
    ADD CONSTRAINT "sharer_campaign_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "public"."campaign"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sharer_campaign"
    ADD CONSTRAINT "sharer_campaign_sharer_id_fkey" FOREIGN KEY ("sharer_id") REFERENCES "public"."sharer"("id") ON DELETE CASCADE;



ALTER TABLE "public"."auth_identity" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."business" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."campaign" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."redemption_journal" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "select: auth identity for current business" ON "public"."auth_identity" FOR SELECT USING ((("business_id")::"text" = "current_setting"('app.current_business_id'::"text", true)));



CREATE POLICY "select: campaigns in current business" ON "public"."campaign" FOR SELECT USING ((("business_id")::"text" = "current_setting"('app.current_business_id'::"text", true)));



CREATE POLICY "select: own business" ON "public"."business" FOR SELECT USING ((("id")::"text" = "current_setting"('app.current_business_id'::"text", true)));



CREATE POLICY "select: redemptions for current business" ON "public"."redemption_journal" FOR SELECT USING ((("business_id")::"text" = "current_setting"('app.current_business_id'::"text", true)));



CREATE POLICY "select: sharer-business for current business" ON "public"."sharer_business" FOR SELECT USING ((("business_id")::"text" = "current_setting"('app.current_business_id'::"text", true)));



CREATE POLICY "select: sharer-campaign for current business" ON "public"."sharer_campaign" FOR SELECT USING (("campaign_id" IN ( SELECT "campaign"."id"
   FROM "public"."campaign"
  WHERE (("campaign"."business_id")::"text" = "current_setting"('app.current_business_id'::"text", true)))));



ALTER TABLE "public"."sharer" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sharer_business" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sharer_campaign" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_redemption"("_claim_token" "text", "_business_id" "uuid", "_campaign_id" "uuid", "_sharer_id" "uuid", "_status" "text", "_ip_address" "text", "_user_agent" "text", "_event" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."insert_redemption"("_claim_token" "text", "_business_id" "uuid", "_campaign_id" "uuid", "_sharer_id" "uuid", "_status" "text", "_ip_address" "text", "_user_agent" "text", "_event" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_redemption"("_claim_token" "text", "_business_id" "uuid", "_campaign_id" "uuid", "_sharer_id" "uuid", "_status" "text", "_ip_address" "text", "_user_agent" "text", "_event" "jsonb") TO "service_role";



GRANT ALL ON TABLE "public"."auth_identity" TO "anon";
GRANT ALL ON TABLE "public"."auth_identity" TO "authenticated";
GRANT ALL ON TABLE "public"."auth_identity" TO "service_role";



GRANT ALL ON TABLE "public"."business" TO "anon";
GRANT ALL ON TABLE "public"."business" TO "authenticated";
GRANT ALL ON TABLE "public"."business" TO "service_role";



GRANT ALL ON TABLE "public"."campaign" TO "anon";
GRANT ALL ON TABLE "public"."campaign" TO "authenticated";
GRANT ALL ON TABLE "public"."campaign" TO "service_role";



GRANT ALL ON TABLE "public"."redemption_journal" TO "anon";
GRANT ALL ON TABLE "public"."redemption_journal" TO "authenticated";
GRANT ALL ON TABLE "public"."redemption_journal" TO "service_role";



GRANT ALL ON TABLE "public"."sharer" TO "anon";
GRANT ALL ON TABLE "public"."sharer" TO "authenticated";
GRANT ALL ON TABLE "public"."sharer" TO "service_role";



GRANT ALL ON TABLE "public"."sharer_business" TO "anon";
GRANT ALL ON TABLE "public"."sharer_business" TO "authenticated";
GRANT ALL ON TABLE "public"."sharer_business" TO "service_role";



GRANT ALL ON TABLE "public"."sharer_campaign" TO "anon";
GRANT ALL ON TABLE "public"."sharer_campaign" TO "authenticated";
GRANT ALL ON TABLE "public"."sharer_campaign" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






RESET ALL;
