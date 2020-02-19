/*
Création de la vue des 90 communes de la BdTopo de l'IGN 
*/
DROP VIEW v_90_communes_ign;

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW g_referentiel.v_90_communes_ign (
    nom,
    code_insee,
    code_postal,
    geom,
    source,
    CONSTRAINT "v_90_communes_ign_PK" PRIMARY KEY ("CODE_INSEE") DISABLE
)
AS
 WITH
 v_main_selection AS(
    SELECT
        a.fid_commune,
        b.code AS code_insee,
        d.nom,
        c.geom,
        CONCAT(CONCAT(f.nom_source, ' - '), h.acronyme) AS source
    FROM
        g_geo.ta_identifiant_commune a
        INNER JOIN g_geo.ta_code b ON a.fid_identifiant = b.objectid
        INNER JOIN g_geo.ta_commune c ON a.fid_commune = c.objectid
        INNER JOIN g_geo.ta_nom d ON c.fid_nom = d.objectid
        INNER JOIN g_geo.ta_metadonnee e ON c.fid_metadonnee = e.objectid
        INNER JOIN g_geo.ta_source f ON e.fid_source = f.objectid
        INNER JOIN g_geo.ta_za_communes g ON c.objectid = g.fid_commune
        INNER JOIN g_geo.ta_organisme h ON e.fid_organisme = h.objectid
    WHERE
        b.fid_libelle = 1
        AND g.fid_zone_administrative = 1
        AND g.debut_validite = '01/01/2017'
        AND g.fin_validite = '01/03/2020'
    ),
    
    v_code_postal AS(
    SELECT
        a.fid_commune,
        b.code AS code_postal
    FROM
        g_geo.ta_identifiant_commune a
        INNER JOIN g_geo.ta_code b ON a.fid_identifiant = b.objectid
    WHERE
        b.fid_libelle = 2
    )
    SELECT
        a.nom,
        a.code_insee,
        b.code_postal,
        a.geom,
        a.source
    FROM
        v_main_selection a,
        v_code_postal b 
    WHERE
        a.fid_commune = b.fid_commune;

-- 2. Création des commentaires de table et de colonnes
COMMENT ON TABLE v_90_communes_ign IS 'Vue proposant les communes actuelles de la MEL extraites de la BdTopo de l''IGN.';
COMMENT ON COLUMN v_90_communes_ign.NOM IS 'Nom de chaque commune de la MEL.';
COMMENT ON COLUMN v_90_communes_ign.CODE_INSEE IS 'Code INSEE de chaque commune.';
COMMENT ON COLUMN v_90_communes_ign.CODE_POSTAL IS 'Code Postal de chaque commune.';
COMMENT ON COLUMN v_90_communes_ign.GEOM IS 'Géométrie de chaque commune - de type polygone.';
COMMENT ON COLUMN v_90_communes_ign.SOURCE IS 'Source de la donnée avec l''organisme créateur de la source.';