CREATE TABLE IF NOT EXISTS `comment` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(39) COLLATE utf8_unicode_ci NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `format` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `content` text COLLATE utf8_unicode_ci NOT NULL,
  `sent` tinyint(1) NOT NULL DEFAULT '0',
  `sw` smallint(5) unsigned NOT NULL DEFAULT '32',
  PRIMARY KEY (`id`),
  KEY `sent` (`sent`),
  KEY `time` (`time`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;