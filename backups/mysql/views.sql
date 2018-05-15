DELIMITER $$

CREATE VIEW `view_catalog_config_visibility` AS 
SELECT `catalog_config`.`sku` AS `sku`,IF(((`catalog_config`.`status` = 'active') AND (`catalog_config`.`status_supplier_config` = 'active') AND (`catalog_config`.`pet_approved` = 1) AND EXISTS(SELECT `catalog_brand`.`id_catalog_brand` FROM `catalog_brand` WHERE ((`catalog_config`.`fk_catalog_brand` = `catalog_brand`.`id_catalog_brand`) AND (`catalog_brand`.`status` = 'active'))) AND EXISTS(SELECT `supplier`.`id_supplier` FROM ((`catalog_simple` `csi` JOIN `catalog_source` `cso` ON((`cso`.`fk_catalog_simple` = `csi`.`id_catalog_simple`))) JOIN `supplier` ON(((`cso`.`fk_supplier` = `supplier`.`id_supplier`) AND (`supplier`.`status` = 'active')))) WHERE (`catalog_config`.`id_catalog_config` = `csi`.`fk_catalog_config`)) AND EXISTS(SELECT `catalog_category`.`id_catalog_category` FROM (`catalog_category` JOIN `catalog_config_has_catalog_category` ON((`catalog_config_has_catalog_category`.`fk_catalog_category` = `catalog_category`.`id_catalog_category`))) WHERE ((`catalog_config_has_catalog_category`.`fk_catalog_config` = `catalog_config`.`id_catalog_config`) AND (`catalog_category`.`status` = 'active'))) AND ((`catalog_config`.`display_if_out_of_stock` = '1') OR ((((SELECT SUM(`catalog_stock`.`quantity`) FROM ((`catalog_stock` JOIN `catalog_source` ON((`catalog_stock`.`fk_catalog_source` = `catalog_source`.`id_catalog_source`))) JOIN `catalog_simple` `stock_simple` ON((`catalog_source`.`fk_catalog_simple` = `stock_simple`.`id_catalog_simple`))) WHERE ((`stock_simple`.`fk_catalog_config` = `catalog_config`.`id_catalog_config`) AND (`catalog_source`.`status_source` = 'active') AND (`catalog_source`.`status_supplier_source` = 'active'))) - (SELECT COUNT(0) FROM (((`sales_order_item` `reserved_item` JOIN `sales_order` `reserved_order` ON((`reserved_item`.`fk_sales_order` = `reserved_order`.`id_sales_order`))) JOIN `catalog_source` `reserved_source` ON((`reserved_item`.`sku_source` = `reserved_source`.`sku_source`))) JOIN `catalog_simple` `reserved_simple` ON((`reserved_source`.`fk_catalog_simple` = `reserved_simple`.`id_catalog_simple`))) WHERE ((`reserved_order`.`fk_sales_order_process` IN (4,5,3,2,1,6)) AND (`reserved_item`.`is_reserved` = 1) AND (`reserved_simple`.`fk_catalog_config` = `catalog_config`.`id_catalog_config`)))) - IFNULL((SELECT SUM(`shared_stock`.`reserved`) FROM (`catalog_stock_shared` `shared_stock` JOIN `catalog_simple` `shared_stock_simple` ON((`shared_stock`.`sku` = `shared_stock_simple`.`sku`))) WHERE (`shared_stock_simple`.`fk_catalog_config` = `catalog_config`.`id_catalog_config`) GROUP BY `shared_stock_simple`.`fk_catalog_config`),0)) > 0)) AND EXISTS(SELECT `catalog_simple`.`id_catalog_simple` FROM `catalog_simple` WHERE ((`catalog_simple`.`status` = 'active') AND (`catalog_simple`.`price` > 0) AND EXISTS(SELECT `catalog_source`.`id_catalog_source` FROM `catalog_source` WHERE ((`catalog_source`.`status_source` = 'active') AND (`catalog_source`.`status_supplier_source` = 'active') AND (`catalog_source`.`fk_catalog_simple` = `catalog_simple`.`id_catalog_simple`))) AND (`catalog_simple`.`fk_catalog_config` = `catalog_config`.`id_catalog_config`)))),1,0) AS `visible_in_shop` FROM `catalog_config`$$

CREATE VIEW `view_catalog_simple_visibility` AS 
SELECT `catalog_simple`.`sku` AS `sku`,IF(((`catalog_config`.`status` = 'active') AND (`catalog_config`.`status_supplier_config` = 'active') AND (`catalog_config`.`pet_approved` = 1) AND EXISTS(SELECT `catalog_brand`.`id_catalog_brand` FROM `catalog_brand` WHERE ((`catalog_config`.`fk_catalog_brand` = `catalog_brand`.`id_catalog_brand`) AND (`catalog_brand`.`status` = 'active'))) AND EXISTS(SELECT `supplier`.`id_supplier` FROM ((`catalog_simple` `csi` JOIN `catalog_source` `cso` ON((`cso`.`fk_catalog_simple` = `csi`.`id_catalog_simple`))) JOIN `supplier` ON(((`cso`.`fk_supplier` = `supplier`.`id_supplier`) AND (`supplier`.`status` = 'active')))) WHERE (`catalog_config`.`id_catalog_config` = `csi`.`fk_catalog_config`)) AND EXISTS(SELECT `catalog_category`.`id_catalog_category` FROM (`catalog_category` JOIN `catalog_config_has_catalog_category` ON((`catalog_config_has_catalog_category`.`fk_catalog_category` = `catalog_category`.`id_catalog_category`))) WHERE ((`catalog_config_has_catalog_category`.`fk_catalog_config` = `catalog_config`.`id_catalog_config`) AND (`catalog_category`.`status` = 'active'))) AND ((`catalog_config`.`display_if_out_of_stock` = '1') OR ((((SELECT SUM(`catalog_stock`.`quantity`) FROM ((`catalog_stock` JOIN `catalog_source` ON((`catalog_stock`.`fk_catalog_source` = `catalog_source`.`id_catalog_source`))) JOIN `catalog_simple` `stock_simple` ON((`catalog_source`.`fk_catalog_simple` = `stock_simple`.`id_catalog_simple`))) WHERE ((`stock_simple`.`fk_catalog_config` = `catalog_config`.`id_catalog_config`) AND (`catalog_source`.`status_source` = 'active') AND (`catalog_source`.`status_supplier_source` = 'active'))) - (SELECT COUNT(0) FROM (((`sales_order_item` `reserved_item` JOIN `sales_order` `reserved_order` ON((`reserved_item`.`fk_sales_order` = `reserved_order`.`id_sales_order`))) JOIN `catalog_source` `reserved_source` ON((`reserved_item`.`sku_source` = `reserved_source`.`sku_source`))) JOIN `catalog_simple` `reserved_simple` ON((`reserved_source`.`fk_catalog_simple` = `reserved_simple`.`id_catalog_simple`))) WHERE ((`reserved_order`.`fk_sales_order_process` IN (4,5,3,2,1,6)) AND (`reserved_item`.`is_reserved` = 1) AND (`reserved_simple`.`fk_catalog_config` = `catalog_config`.`id_catalog_config`)))) - IFNULL((SELECT SUM(`shared_stock`.`reserved`) FROM (`catalog_stock_shared` `shared_stock` JOIN `catalog_simple` `shared_stock_simple` ON((`shared_stock`.`sku` = `shared_stock_simple`.`sku`))) WHERE (`shared_stock_simple`.`fk_catalog_config` = `catalog_config`.`id_catalog_config`) GROUP BY `shared_stock_simple`.`fk_catalog_config`),0)) > 0)) AND EXISTS(SELECT `catalog_simple`.`id_catalog_simple` FROM `catalog_simple` WHERE ((`catalog_simple`.`status` = 'active') AND (`catalog_simple`.`price` > 0) AND EXISTS(SELECT `catalog_source`.`id_catalog_source` FROM `catalog_source` WHERE ((`catalog_source`.`status_source` = 'active') AND (`catalog_source`.`status_supplier_source` = 'active') AND (`catalog_source`.`fk_catalog_simple` = `catalog_simple`.`id_catalog_simple`))) AND (`catalog_simple`.`fk_catalog_config` = `catalog_config`.`id_catalog_config`)))),IF(((`catalog_simple`.`status` = 'active') AND (`catalog_simple`.`price` > 0) AND EXISTS(SELECT `catalog_source`.`id_catalog_source` FROM `catalog_source` WHERE ((`catalog_source`.`status_source` = 'active') AND (`catalog_source`.`status_supplier_source` = 'active') AND (`catalog_source`.`fk_catalog_simple` = `catalog_simple`.`id_catalog_simple`)))),1,0),0) AS `visible_in_shop` FROM (`catalog_simple` JOIN `catalog_config` ON((`catalog_config`.`id_catalog_config` = `catalog_simple`.`fk_catalog_config`)))$$

CREATE VIEW `view_creditmemo_list` AS 
SELECT
  `sr`.`id_sales_rule`        AS `id_sales_rule`,
  `sr`.`fk_sales_rule_set`    AS `fk_sales_rule_set`,
  `sr`.`code`                 AS `code`,
  IF(((`sr`.`times_used` > 0) AND (`sr`.`is_active` = 0)),1,0) AS `is_active`,
  `sr`.`times_used`           AS `times_used`,
  `sr`.`from_date`            AS `from_date`,
  `sr`.`to_date`              AS `to_date`,
  `sr`.`used_discount_amount` AS `used_discount_amount`,
  `sr`.`fk_customer`          AS `fk_customer`,
  `sr`.`discount_amount`      AS `discount_amount`,
  'couponreturn'              AS `is_public`,
  `srs`.`type`                AS `customer_tax_number`
FROM (`sales_rule` `sr`
   JOIN `sales_rule_set` `srs`
     ON ((`sr`.`fk_sales_rule_set` = `srs`.`id_sales_rule_set`)))
WHERE ((`srs`.`name` LIKE 'C2%')
       AND (`srs`.`code_prefix` LIKE 'CM%')
       AND (`sr`.`code` IS NOT NULL)
       AND (`srs`.`is_active` = 1)
       AND (`sr`.`is_active` = 1))
ORDER BY `sr`.`is_active` DESC,`srs`.`id_sales_rule_set`$$

CREATE VIEW `view_nps_report_by_week` AS 
SELECT
  `so`.`order_nr`   AS `order_nr`,
  `rs`.`rate`       AS `rate`,
  `rs`.`comment`    AS `comment`,
  `so`.`created_at` AS `order date`,
  `rs`.`updated_at` AS `comment date`,
  WEEK(`rs`.`updated_at`,1) AS `comment week`,
  YEAR(`rs`.`updated_at`) AS `comment year`
FROM (`rating_service` `rs`
   JOIN `sales_order` `so`
     ON ((`so`.`id_sales_order` = `rs`.`fk_sales_order`)))
WHERE ((`rs`.`answered` = 1)
       AND (WEEK(`rs`.`updated_at`,1) = WEEK(NOW(),0))
       AND (YEAR(`rs`.`updated_at`) = YEAR(NOW())))
GROUP BY `so`.`order_nr`
ORDER BY `rs`.`updated_at` DESC$$

DELIMITER ;
