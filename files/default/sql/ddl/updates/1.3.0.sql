ALTER TABLE `hopsworks`.`shared_topics` ADD COLUMN `accepted` tinyint(1) NOT NULL DEFAULT '0';
SET SQL_SAFE_UPDATES = 0;
UPDATE `hopsworks`.`shared_topics` SET accepted=1;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `hopsworks`.`external_training_dataset` ADD COLUMN `path` VARCHAR(10000);

-- Find the name of the FK
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "training_dataset" AND REFERENCED_TABLE_NAME="hdfs_users");
SET @s := concat('ALTER TABLE hopsworks.training_dataset DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `hdfs_user_id`; 

ALTER TABLE `hopsworks`.`feature_store_feature` MODIFY COLUMN `description` VARCHAR(10000) COLLATE latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_store_tag` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(255) NOT NULL,
      `type` varchar(45) NOT NULL DEFAULT 'STRING',
      PRIMARY KEY (`id`),
      UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

DROP TABLE IF EXISTS `hopsworks`.`featurestore_statistic`;

CREATE TABLE `feature_store_statistic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `commit_time` VARCHAR(20) COLLATE latin1_general_cs NOT NULL, 
  `inode_pid` BIGINT(20) NOT NULL,
  `inode_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL,
  `partition_id` BIGINT(20) NOT NULL,
  `feature_group_id` INT(11),
  `training_dataset_id`INT(11),
  PRIMARY KEY (`id`),
  KEY `feature_group_id` (`feature_group_id`),
  KEY `training_dataset_id` (`training_dataset_id`),
  CONSTRAINT `fg_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `td_fk` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `inode_fk` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;