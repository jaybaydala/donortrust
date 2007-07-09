CREATE TABLE `bus_secure_actions` (
  `id` int(11) NOT NULL auto_increment,
  `permitted_actions` varchar(255) default NULL,
  `bus_security_level_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bus_secure_actions_bus_user_types` (
  `id` int(11) NOT NULL auto_increment,
  `bus_secure_action_id` int(11) default NULL,
  `bus_user_type_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bus_security_levels` (
  `id` int(11) NOT NULL auto_increment,
  `controller` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bus_user_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `city_id` int(11) default NULL,
  `address_line_1` varchar(255) default NULL,
  `address_line_2` varchar(255) default NULL,
  `postal_code` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `contacts_partners` (
  `id` int(11) NOT NULL auto_increment,
  `contact_id` int(11) NOT NULL,
  `partner_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `continents` (
  `id` int(11) NOT NULL auto_increment,
  `continent_name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `countries` (
  `id` int(11) NOT NULL auto_increment,
  `country_name` varchar(255) NOT NULL,
  `continent_id` int(11) NOT NULL,
  `content` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `indicators` (
  `id` int(11) NOT NULL auto_increment,
  `target_id` int(11) default NULL,
  `description` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `measure_categories` (
  `id` int(11) NOT NULL auto_increment,
  `category` varchar(255) default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `measures` (
  `id` int(11) NOT NULL auto_increment,
  `measure_category_id` int(11) default NULL,
  `quantity` int(11) default NULL,
  `measure_date` date default NULL,
  `user_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `milestone_categories` (
  `id` int(11) NOT NULL auto_increment,
  `category` varchar(255) default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `milestone_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `status` varchar(255) NOT NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `milestones` (
  `id` int(11) NOT NULL auto_increment,
  `project_id` int(11) NOT NULL,
  `milestone_category_id` int(11) NOT NULL,
  `milestone_status_id` int(11) NOT NULL,
  `measure_id` int(11) default NULL,
  `target_date` date default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `millennium_development_goals` (
  `id` int(11) NOT NULL auto_increment,
  `description` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `partner_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `statusType` varchar(25) NOT NULL,
  `description` varchar(250) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `partner_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `partners` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `description` varchar(1000) default NULL,
  `partner_type_id` int(11) default NULL,
  `partner_status_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `programs` (
  `id` int(11) NOT NULL auto_increment,
  `program_name` varchar(255) NOT NULL,
  `contact_id` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `project_categories` (
  `id` int(11) NOT NULL auto_increment,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `project_histories` (
  `id` int(11) NOT NULL auto_increment,
  `project_id` int(11) NOT NULL,
  `date` datetime default NULL,
  `description` text,
  `total_cost` float default NULL,
  `dollars_spent` float default NULL,
  `expected_completion_date` datetime default NULL,
  `start_date` datetime default NULL,
  `end_date` datetime default NULL,
  `user_id` int(11) default NULL,
  `project_status_id` int(11) default NULL,
  `project_category_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `project_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `status_type` varchar(255) NOT NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `projects` (
  `id` int(11) NOT NULL auto_increment,
  `program_id` int(11) default NULL,
  `project_category_id` int(11) default NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `total_cost` float default NULL,
  `dollars_spent` float default NULL,
  `expected_completion_date` datetime default NULL,
  `start_date` datetime default NULL,
  `end_date` datetime default NULL,
  `project_status_id` int(11) default NULL,
  `contact_id` int(11) default NULL,
  `village_group_id` int(11) default NULL,
  `partner_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `region_types` (
  `id` int(11) NOT NULL auto_increment,
  `region_type_name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `regions` (
  `id` int(11) NOT NULL auto_increment,
  `region_name` varchar(255) NOT NULL,
  `country_id` int(11) NOT NULL,
  `region_type_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `sectors` (
  `id` int(11) NOT NULL auto_increment,
  `sector_name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `targets` (
  `id` int(11) NOT NULL auto_increment,
  `millennium_development_goal_id` int(11) NOT NULL,
  `description` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `task_categories` (
  `id` int(11) NOT NULL auto_increment,
  `category` varchar(255) default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `task_histories` (
  `id` int(11) NOT NULL auto_increment,
  `task_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `milestone_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `task_category_id` int(11) NOT NULL,
  `task_status_id` int(11) NOT NULL,
  `description` text,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `etc_date` date default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `task_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `status` varchar(255) default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL auto_increment,
  `milestone_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `task_category_id` int(11) NOT NULL,
  `task_status_id` int(11) NOT NULL,
  `description` text,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `etc_date` date default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `urban_centres` (
  `id` int(11) NOT NULL auto_increment,
  `urban_centre_name` varchar(255) NOT NULL,
  `region_id` int(11) NOT NULL,
  `facebook_group_id` int(11) default NULL,
  `blog_name` varchar(255) default NULL,
  `blog_url` varchar(255) default NULL,
  `rss_url` varchar(255) default NULL,
  `population` int(11) default NULL,
  `village_plan` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `villages` (
  `id` int(11) NOT NULL auto_increment,
  `village_name` varchar(255) NOT NULL,
  `village_group_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (39)