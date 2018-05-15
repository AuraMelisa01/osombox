-- MySQL dump 10.13  Distrib 5.6.31, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.33.10    Database: bob
-- ------------------------------------------------------
-- Server version	5.5.49-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping routines for database 'bob'
--
/*!50003 DROP PROCEDURE IF EXISTS `cleanConfigAndCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cleanConfigAndCategory`(
                        IN config_id INT(11),
                        IN parentCat INT(11),
                        IN childCat INT(11),
                        IN include_parent INT(1),
                        IN remove_badges INT(1))
BEGIN
    CASE
        WHEN include_parent = 1 THEN
            DELETE FROM catalog_config_has_catalog_category WHERE fk_catalog_config = config_id AND fk_catalog_category IN (parentCat, childCat);
        WHEN include_parent = 0 THEN
            DELETE FROM catalog_config_has_catalog_category WHERE fk_catalog_config = config_id AND fk_catalog_category = childCat;
    END CASE;
   
    IF remove_badges = 1 THEN
        UPDATE catalog_config SET special_badge_url = NULL, mobile_app_ios_badge_url= NULL, fk_catalog_attribute_option_global_special_badge_type = NULL WHERE id_catalog_config = config_id LIMIT 1;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getItemInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemInfo`(skuval VARCHAR(25))
SELECT
  `cc`.`id_catalog_config` AS `id_config`,
  `cc`.`name`,
  FORMAT(
        (CASE
                WHEN (ISNULL(cs.special_from_date) AND ISNULL(cs.special_to_date) AND NOT ISNULL(cs.special_price))
                        THEN cs.special_price
                WHEN (cs.special_to_date >= DATE(NOW()) OR cs.special_from_date <= DATE(NOW()))
                        THEN cs.special_price
                WHEN (NOT ISNULL(cs.special_from_date) AND NOT ISNULL(cs.special_price))
                        THEN cs.price
                WHEN (cs.special_to_date <= DATE(NOW()))
                        THEN cs.price
                ELSE cs.price
          END)
        ,0) AS `price`,
  `cb`.`name` AS `brand`,
  (SELECT
     `ct`.`name`
   FROM `catalog_category` AS `ct`
     LEFT JOIN `catalog_config_has_catalog_category` AS `chc`
       ON ct.id_catalog_category = chc.fk_catalog_category
   WHERE (chc.fk_catalog_config = cc.id_catalog_config
          AND ct.name <> 'Promociones'
          AND ct.id_catalog_category <> 318)
   ORDER BY `ct`.`id_catalog_category` DESC
   LIMIT 1) AS `category`
FROM `catalog_config` AS `cc`
  LEFT JOIN `catalog_simple` AS `cs`
    ON cc.id_catalog_config = cs.fk_catalog_config
  LEFT JOIN `catalog_brand` AS `cb`
    ON cc.fk_catalog_brand = cb.id_catalog_brand
WHERE (cc.sku = skuval)
GROUP BY `cs`.`fk_catalog_config` ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getSizeAvailability` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getSizeAvailability`(IN config_id INT(11))
BEGIN
    DECLARE endCursor INTEGER DEFAULT 0;
    DECLARE simpleSku VARCHAR(255);
    DECLARE simpleQty INT(11);
    DECLARE configQty INT(11);
    DECLARE availSmpl INT(11);
    DECLARE totlAvail INT(11);
    DECLARE simple_items CURSOR FOR SELECT si.sku, IF(ISNULL(ks.quantity),0,ks.quantity) AS q FROM catalog_stock AS ks RIGHT JOIN catalog_source AS s ON ks.fk_catalog_source = s.id_catalog_source RIGHT JOIN catalog_simple AS si ON si.id_catalog_simple = s.fk_catalog_simple WHERE si.fk_catalog_config = config_id AND si.price > 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET endCursor = 1;
    SET totlAvail = 0;
    OPEN simple_items;
    SELECT FOUND_ROWS() INTO configQty;
    get_simples: LOOP
        FETCH simple_items INTO simpleSku, simpleQty;
        IF endCursor = 1 THEN
            LEAVE get_simples;
        END IF;
        SELECT IF(simpleQty > COUNT(soi.id_sales_order_item), 1,0) INTO availSmpl
        FROM sales_order_item AS soi
            INNER JOIN catalog_simple AS csi ON soi.sku = csi.sku
        WHERE csi.sku = simpleSku AND soi.is_reserved = 1 AND csi.price > 0;
        SET totlAvail = totlAvail + availSmpl;
    END LOOP get_simples;
    CLOSE simple_items;
SELECT FORMAT(((totlAvail*100)/configQty)/100,4) AS avail_size;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `updateConfigAndCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateConfigAndCategory`(
                        IN config_id INT(11),
                        IN parentCat INT(11),
                        IN childCat INT(11),
                        IN badge_type VARCHAR(1),
                        IN web_badge VARCHAR(254),
                        IN mob_badge VARCHAR(254))
BEGIN
    DECLARE valBadgeType INT(1);
    SET valBadgeType = badge_type;
    INSERT IGNORE INTO catalog_config_has_catalog_category(fk_catalog_config,fk_catalog_category) VALUES(config_id,parentCat);
    INSERT IGNORE INTO catalog_config_has_catalog_category(fk_catalog_config,fk_catalog_category) VALUES(config_id,childCat);
    IF badge_type <> '' THEN
        UPDATE catalog_config SET special_badge_url = web_badge, mobile_app_ios_badge_url= mob_badge, fk_catalog_attribute_option_global_special_badge_type = valBadgeType WHERE id_catalog_config = config_id LIMIT 1;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-10-11 10:53:37
