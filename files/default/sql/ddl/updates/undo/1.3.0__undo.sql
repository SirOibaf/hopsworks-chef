ALTER TABLE `hopsworks`.`shared_topics` DROP COLUMN `accepted`;


ALTER TABLE `hopsworks`.`external_training_dataset` DROP COLUMN `path`;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `hdfs_user_id` int(11) NOT NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `fk_hdfs_user_id` FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`feature_store_feature` MODIFY COLUMN `description` VARCHAR(10000) COLLATE latin1_general_cs NOT NULL;

DROP TABLE IF EXISTS `feature_store_tag`;

DROP TABLE IF EXISTS `feature_store_statistic`;

CREATE TABLE `featurestore_statistic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feature_group_id` int(11) DEFAULT NULL,
  `training_dataset_id` int(11) DEFAULT NULL,
  `name` varchar(500) COLLATE latin1_general_cs DEFAULT NULL,
  `statistic_type` int(11) NOT NULL DEFAULT '0',
  `value` varchar(13300) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`id`),
  KEY `feature_group_id` (`feature_group_id`),
  KEY `training_dataset_id` (`training_dataset_id`),
  CONSTRAINT `FK_693_956` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_812_957` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;