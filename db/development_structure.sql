CREATE TABLE `accounts` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `address` text,
  `city` varchar(255) default NULL,
  `state` varchar(255) default NULL,
  `country` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `last_logged_in` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `bus_secure_actions` (
  `id` int(11) NOT NULL auto_increment,
  `permitted_actions` varchar(255) default NULL,
  `bus_security_level_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `bus_secure_actions_bus_user_types` (
  `id` int(11) NOT NULL auto_increment,
  `bus_secure_action_id` int(11) default NULL,
  `bus_user_type_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `bus_security_levels` (
  `id` int(11) NOT NULL auto_increment,
  `controller` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `bus_user_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `bus_users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `bus_user_type_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cities` (
  `id` int(11) NOT NULL auto_increment,
  `city_name` varchar(255) NOT NULL,
  `region_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `contacts` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `phone_number` varchar(255) default NULL,
  `fax_number` varchar(255) default NULL,
  `email_address` varchar(255) default NULL,
  `web_address` varchar(255) default NULL,
  `department` varchar(255) default NULL,
  `continent_id` int(11) default NULL,
  `country_id` int(11) default NULL,
  `region_id` int(11) default NULL,
  `urban_centre_id` int(11) default NULL,
  `address_line_1` varchar(255) default NULL,
  `address_line_2` varchar(255) default NULL,
  `postal_code` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `contacts_partners` (
  `id` int(11) NOT NULL auto_increment,
  `contact_id` int(11) NOT NULL,
  `partner_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `continents` (
  `id` int(11) NOT NULL auto_increment,
  `continent_name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `countries` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `continent_id` int(11) NOT NULL,
  `html_data` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `frequency_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `indicator_measurements` (
  `id` int(11) NOT NULL auto_increment,
  `project_id` int(11) NOT NULL,
  `indicator_id` int(11) NOT NULL,
  `frequency_id` int(11) NOT NULL,
  `units` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `indicators` (
  `id` int(11) NOT NULL auto_increment,
  `target_id` int(11) default NULL,
  `description` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `measure_categories` (
  `id` int(11) NOT NULL auto_increment,
  `category` varchar(255) default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `measurements` (
  `id` int(11) NOT NULL auto_increment,
  `indicator_measurement_id` int(11) NOT NULL,
  `value` varchar(255) NOT NULL,
  `comment` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `measures` (
  `id` int(11) NOT NULL auto_increment,
  `measure_category_id` int(11) default NULL,
  `quantity` int(11) default NULL,
  `measure_date` date default NULL,
  `user_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `milestone_categories` (
  `id` int(11) NOT NULL auto_increment,
  `category` varchar(255) default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `milestone_histories` (
  `id` int(11) NOT NULL auto_increment,
  `milestone_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `reason` text,
  `project_id` int(11) NOT NULL,
  `milestone_category_id` int(11) NOT NULL,
  `milestone_status_id` int(11) NOT NULL,
  `measure_id` int(11) NOT NULL,
  `description` text,
  `target_date` date default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `milestone_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `milestones` (
  `id` int(11) NOT NULL auto_increment,
  `project_id` int(11) NOT NULL,
  `name` varchar(255) default NULL,
  `description` text,
  `target_date` date default NULL,
  `milestone_status_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `millennium_goals` (
  `id` int(11) NOT NULL auto_increment,
  `description` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `partner_histories` (
  `id` int(11) NOT NULL auto_increment,
  `partner_id` int(11) default NULL,
  `name` varchar(50) default NULL,
  `description` varchar(1000) default NULL,
  `partner_type_id` int(11) default NULL,
  `partner_status_id` int(11) default NULL,
  `created_on` datetime default NULL,
  `bus_user_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `partner_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(25) NOT NULL,
  `description` varchar(250) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `partner_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `description` varchar(500) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `partner_versions` (
  `id` int(11) NOT NULL auto_increment,
  `partner_id` int(11) default NULL,
  `version` int(11) default NULL,
  `name` varchar(50) default '',
  `description` varchar(1000) default NULL,
  `partner_type_id` int(11) default NULL,
  `partner_status_id` int(11) default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `partners` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `description` varchar(1000) default NULL,
  `partner_type_id` int(11) default NULL,
  `partner_status_id` int(11) default NULL,
  `version` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `programs` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `contact_id` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `project_categories` (
  `id` int(11) NOT NULL auto_increment,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `project_histories` (
  `id` int(11) NOT NULL auto_increment,
  `project_id` int(11) NOT NULL,
  `date` date default NULL,
  `description` text,
  `total_cost` float default NULL,
  `dollars_raised` float default NULL,
  `dollars_spent` float default NULL,
  `expected_completion_date` date default NULL,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `user_id` int(11) default NULL,
  `project_status_id` int(11) default NULL,
  `bus_user_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `project_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `project_you_tube_videos` (
  `id` int(11) NOT NULL auto_increment,
  `project_id` int(11) default NULL,
  `you_tube_video_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `projects` (
  `id` int(11) NOT NULL auto_increment,
  `program_id` int(11) default NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `total_cost` decimal(12,2) default '0.00',
  `dollars_spent` decimal(12,2) default '0.00',
  `expected_completion_date` date default NULL,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `project_status_id` int(11) default NULL,
  `contact_id` int(11) default NULL,
  `urban_centre_id` int(11) default NULL,
  `partner_id` int(11) default NULL,
  `dollars_raised` decimal(12,2) default '0.00',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `projects_millennium_development_goals` (
  `project_id` int(11) default NULL,
  `millennium_development_goal_id` int(11) default NULL,
  KEY `index_projects_millennium_development_goals_on_project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `region_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `regions` (
  `id` int(11) NOT NULL auto_increment,
  `region_name` varchar(255) NOT NULL,
  `country_id` int(11) NOT NULL,
  `region_type_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `rss_feed_elements` (
  `id` int(11) NOT NULL auto_increment,
  `rss_feed_id` int(11) NOT NULL,
  `title` varchar(255) default NULL,
  `link` varchar(255) default NULL,
  `description` text,
  `author` varchar(255) default NULL,
  `comments` text,
  `pubDate` datetime default NULL,
  `source` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `rss_feeds` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) NOT NULL,
  `link` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `language` varchar(255) default NULL,
  `copyright` varchar(255) default NULL,
  `managing_editor` varchar(255) default NULL,
  `pub_date` datetime default NULL,
  `image_url` varchar(255) default NULL,
  `image_title` varchar(255) default NULL,
  `image_link` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sectors` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `targets` (
  `id` int(11) NOT NULL auto_increment,
  `millennium_development_goal_id` int(11) NOT NULL,
  `description` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `task_categories` (
  `id` int(11) NOT NULL auto_increment,
  `category` varchar(255) default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `task_histories` (
  `id` int(11) NOT NULL auto_increment,
  `task_id` int(11) NOT NULL,
  `milestone_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `etc_date` date default NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `task_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `status` varchar(255) default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL auto_increment,
  `milestone_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `etc_date` date default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `urban_centres` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `region_id` int(11) NOT NULL,
  `blog_name` varchar(255) default NULL,
  `blog_url` varchar(255) default NULL,
  `rss_url` varchar(255) default NULL,
  `population` int(11) default NULL,
  `village_plan` text,
  `facebook_group_id` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `village_groups` (
  `id` int(11) NOT NULL auto_increment,
  `village_group_name` varchar(255) NOT NULL,
  `region_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `villages` (
  `id` int(11) NOT NULL auto_increment,
  `village_name` varchar(255) NOT NULL,
  `village_group_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `you_tube_videos` (
  `id` int(11) NOT NULL auto_increment,
  `you_tube_video_ref` varchar(255) default NULL,
  `message` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_info (version) VALUES (46)