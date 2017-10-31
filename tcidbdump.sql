-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: 127.0.0.1    Database: theia_development
-- ------------------------------------------------------
-- Server version	5.1.73

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
-- Table structure for table `assignment_submissions`
--

DROP TABLE IF EXISTS `assignment_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignment_submissions` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `enrolment_id` int(11) unsigned NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `summary` text COLLATE utf8_unicode_ci,
  `description` mediumtext COLLATE utf8_unicode_ci,
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `scheduled_assignment_id` int(11) unsigned NOT NULL,
  `rearrangement` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `idx_enrolment_id` (`enrolment_id`),
  KEY `idx_scheduled_assignment_id` (`scheduled_assignment_id`,`enrolment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignment_submissions`
--

LOCK TABLES `assignment_submissions` WRITE;
/*!40000 ALTER TABLE `assignment_submissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `assignment_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignments`
--

DROP TABLE IF EXISTS `assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignments` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `lesson_id` int(11) unsigned NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `summary` text COLLATE utf8_unicode_ci,
  `description` mediumtext COLLATE utf8_unicode_ci,
  `duration` smallint(5) unsigned NOT NULL,
  `starts_after` smallint(5) unsigned NOT NULL DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_lesson_id` (`lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignments`
--

LOCK TABLES `assignments` WRITE;
/*!40000 ALTER TABLE `assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attachments`
--

DROP TABLE IF EXISTS `attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attachments` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `owner_user_id` int(11) unsigned NOT NULL,
  `attachable_id` int(11) unsigned NOT NULL,
  `attachable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci,
  `position` int(11) unsigned NOT NULL DEFAULT '0',
  `asset_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `asset_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `asset_file_size` int(11) unsigned DEFAULT NULL,
  `asset_updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(1) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'n',
  `asset_orientation` varchar(9) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_owner_user_id` (`owner_user_id`),
  KEY `idx_attachable_type_attachable_id` (`attachable_type`,`attachable_id`),
  KEY `idx_position` (`position`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attachments`
--

LOCK TABLES `attachments` WRITE;
/*!40000 ALTER TABLE `attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog_posts`
--

DROP TABLE IF EXISTS `blog_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blog_posts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_posts`
--

LOCK TABLES `blog_posts` WRITE;
/*!40000 ALTER TABLE `blog_posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `blog_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_types`
--

DROP TABLE IF EXISTS `course_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `course_types` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `homepage_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `course_page_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `course_page_description` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_types`
--

LOCK TABLES `course_types` WRITE;
/*!40000 ALTER TABLE `course_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `courses` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `summary` text COLLATE utf8_unicode_ci,
  `description` mediumtext COLLATE utf8_unicode_ci,
  `price_in_cents` int(11) unsigned NOT NULL DEFAULT '0',
  `starts_on` date NOT NULL,
  `frequency` smallint(5) unsigned NOT NULL,
  `photo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_file_size` int(11) unsigned DEFAULT NULL,
  `photo_updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `price_currency` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'USD',
  `available` tinyint(1) NOT NULL DEFAULT '1',
  `page_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `instant_access` tinyint(1) DEFAULT '0',
  `hidden` tinyint(1) DEFAULT '0',
  `meta_description` text COLLATE utf8_unicode_ci,
  `meta_keywords` text COLLATE utf8_unicode_ci,
  `hide_dates` tinyint(1) DEFAULT '0',
  `course_type_id` int(11) DEFAULT NULL,
  `portfolio_review` tinyint(1) DEFAULT '0',
  `youtube_video_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vimeo_video_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category_1` tinyint(1) DEFAULT '0',
  `category_2` tinyint(1) DEFAULT '0',
  `category_3` tinyint(1) DEFAULT '0',
  `category_4` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES (1,'Telling Your Story with Video','Producing an engaging video film has little to do with attending a prestigious and expensive film school. What it does have to do with, is developing a clear vision of your creative end-product and just how you\'ll realize it. This fun and challenging course will introduce you to the world of digital video production. From developing your storyline, to scripting, capturing, editing and debuting your work, you\'ll be guided - confidently - each step of the way.','<p>Your aim may be a documentary production or a purely fictional art-cinema comedy or drama - or just an entertaining presentation of your latest holiday travels before family and friends. But whatever the genre, there are set ways to achieve a stunning result - tried-and-true steps through which to ensure that your video film is an overall technical and aesthetic success. This online videography course, designed for complete beginners to those seeking a comprehensive refresher, will start the cameras rolling for you and once your first production is finished - we\'re certain there\'ll be a sequel.</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:37','2014-05-29 11:51:37','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(2,'The Way to Backpack Journalism','The face of news-gathering and reporting is changing. Organizations that report the news are slimming down their teams in the field and welcoming a more mobile, flexible and responsive brand of journalism. Enter the Backpack Journalist - videographer, writer, producer, editor and reporter who is fleet afoot with it all. Designed and taught by Chicago Tribune multimedia producer and video-journalist, Christopher Booker, this extensive introduction to Backpack Journalism will get you started and point you to the growing number of internet venues where your work can be shown.','<p>Not quite television news and not exactly cinema either, Backpack Journalism is a multimedia phenomenon unique to our times. Its practice draws on skill-sets delivered historically by a \'crew\' of news personnel - cameraman, sound person, producer and reporter. As the name implies, advantages of Backpack Journalism lie in going light - cost-wise and in the size and amount of equipment for the job. Backpack journalists are more mobile, flexible and responsive to the moment - everything it takes to compete in a media world, where even video-savvy mobile-phone users pose competition today. Comprehensively designed, this online multimedia course will supply you with the basic techniques, methods - and practice - to begin your journey into this exiting and rapidly growing field of visual journalism.</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:37','2014-05-29 11:51:37','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(3,'Introduction to Video Editing with Final Cut Pro / Final Cut Express','Final Cut Pro and its abbreviated version, Final Cut Express, are two of the most popular video-editing software applications available today.  Though powerful in performance, both can appear daunting to first-time users.  This comprehensive \'complete beginners\' course instills the fundamentals of digital video and the basics of editing through easy-to-understand lessons and practical application assignments - designed to have you up and running as a video editor in no time flat.','<p>Final Cut Pro and Final Cut Express, are among the most highly acclaimed of video-editing software. In its easily affordable consumer edition, Final Cut Express places creative production tools in the hands of video enthusiasts. The Pro suite of Apple\'s premier software is already hugely popular with independent filmmakers and video journalists and seeing growing acclaim among Hollywood film editors, too. The aim of this 4-week course is to give complete newcomers a solid practical grasp on Final Cut, in both its versions. Through easily understood lessons and enjoyable, but challenging assignments, you\'ll gain a solid stance with this creative editing tool - one that will easily prepare you for the next creative level.</p>',34900,'2009-03-23',49,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:38','2014-05-29 11:51:38','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(4,'Step Into Outdoor and Adventure Photography','Got a hankering to shoot dynamic photos of the great outdoors and those who play hard in it? This 4-week online course taught by professional adventure photographer, Dan Bailey, will guide you directly there.','<p>You love the outdoors and everything that has to do with being active in it. And part of this enjoyment has to do with capturing in pictures all the action and excitement of moments spent there. Photographing outdoor sports and the whole range of adventure possibilities calls for a special brand of camera craft - one that doesn\'t interfere with the process, but brings to life over-and-over again, all the fun and excitement of having been there. This action- and expertise-packed online photography course will gear you up to meet the challenge of all that lies to photograph in the great outdoors.</p>',34900,'2009-03-23',49,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:39','2014-05-29 11:51:39','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(5,'Sports Photography - A Defining Start','Whether your goal is to capture the sports heroes of your family, show support for your local club or team in pictures, or aim for a part- to full-time career as a sports photojournalist, this solid and exciting introductory course will equip you with all the essentials you need.','<p>Have you ever noticed how the sports images in your local newspaper, favorite sports publication, or team website always look so consistently sharp and well composed? Do you wish you could improve your own skills in the very challenging genre of photography? Whether your interests are simply to capture better sports-related images of your family, to improve upon your existing skills in the subject or to build a solid foundation for continuing studies in this fun and exciting subject, join professional sports photographer Shawn M. Knox as he leads you through this 4-week online photography course covering the fundamentals you need to know in order to begin, or improve, your sports photography.</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:40','2014-05-29 11:51:40','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(6,'Exploring Long-Lens Success','Two-, three-, four-hundred-millimeter and beyond - there are sound reasons why telephoto lenses are coveted by professional photographers. Used correctly, their optical formulas offer shooters a unique vision and \'voice\'.  This course is designed to prepare you for getting the most from \'long glass\' - practically and creatively.','<p>Many photographers see telephoto lenses as just a way to get closer. True - there are definitely times when \'flighty\' wildlife, inaccessible situations - risky and dangerous - circumvent simply \'getting there and close\' with a shorter focal-length alternative. Telephoto lenses, though, are a whole lot more than most photographers ever touch upon. Possessed of a shallow depth-of-field and soft-focus characteristics, longer lenses hold the potential to deliver impressive portraiture and dramatic interpretations of a range of - otherwise - \'everyday\' scenes and situations. This online photography course is designed specifically to have you learn and apply the full spectrum of optical benefits offered by telephoto lenses, making them a working part of your photographic repertoire.</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:41','2014-05-29 11:51:41','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(7,'Finding Your Photo Style','Advancing from snapshots to making photographs is a quantum step for photographers keen on self-expression. It requires competency with light, colour, composition and capturing that definitive sense of moment. But this is just the start!','<p>This online photography course lies beyond the boundary of rules. Oh sure - we\'ll touch on them, discuss what they mean and then find ways to both stretch and break them - all in the interest of having you come that much closer to discovering your photographic voice - your unique style of photographic expression. </p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:42','2014-05-29 11:51:42','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(8,'Capturing Flowers - Macro and Creatively','Whether your floral Eden is an English-style garden, a greenhouse in the backyard or simply a well-lit windowsill lined with favorite houseplants, the four lessons composing this unique online photography course, will guide you through the process of capturing it all with personal expression.','<p>Photographing flowers is an art in itself. It requires a fine knowledge of the nuances associated with each and every subject, the way light will best showcase those characteristics and what role a particular background will play in it all. A portion of the success that a photographer can have with floral subjects has to do with equipment - the right kind and how to use it best. The overriding element of creative flower photography , however, resides with the one behind the camera, carefully composing just what it is that draws emotion from what lies before the lens. This fascinating online photography course will take you to a form of photography - so enthralling - you\'ll wonder why you\'ve never gone there before.</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:43','2014-05-29 11:51:43','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(9,'Craft Your Photo Presentation - Elevate Your Work and Its Message','You\'re thoughtful in the way you make photographs. You invest time, energy and finances in capturing images that ideally speak your voice.  But why stop there? Creatively and effectively \'packaging\' your photo collections, works-in-progress, slide-shows and portfolio can spell the difference between mediocre and all that your photography can be.  This course is designed to show you that difference and guide you to make editorial choices that will raise your work above the rest.','<p>Selecting and pairing your photographs puts polish to your body of work, making it the best it can be. \'Craft Your Photo Presentation\' will guide you to consistently display your photographs with optimum visual impact. Whether your goal is to assemble and deliver a professional portfolio, sequence images for a slideshow; compile a layout for self-promotion or simply create a super good-looking album to share with family and friends, this comprehensive and valuable online photography course will equip you with the tools, skills and practice to produce powerful visual narratives with the photographs you make.</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:44','2014-05-29 11:51:44','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(10,'Developing a Photographer\'s Eye','Want to improve your photography, but finding it hard to effectively evaluate your own work? This inspiring and informative online photography course will lead you to view your images with a fresh eye. You\'ll learn how to use elements of style such as light, depth of field, composition and more to express your unique vision in powerful photographs. You\'ll come away with specific techniques to further develop your creative strengths and new skills in understanding how photographs are constructed.','<p>Everyone has a unique vision - a special way of viewing the world. Your photographic vision develops not just through practice, but through having a mentor at your side along the way. That\'s what this online photography course is all about - guidance and learning the right combination of skills so you can make informed choices about what is placed, and how, in the frame. The goal of this valuable 4-week course is to create images that speak clearly and powerfully in a style and tone that reflect your vision.</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:45','2014-05-29 11:51:45','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(11,'People Pictures with Impact and Emotion','Photographing people from across the street with a long lens is one thing; making those same images at conversational distance is a whole new level of photographic expression.','<p>Fact is - many people behind the camera fear close encounters of the photographic kind. Shyness and fear of rejection are a part of it. Not knowing just how to handle the situation once you\'re in it, is another. This challenging online photography course aims to counter those obstacles - bringing close-in photography of people - total strangers included - well within your reach. The result is nothing short of powerful!</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:46','2014-05-29 11:51:46','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(12,'On Assignment - Self-Assignment','Self-assignments are an excellent way to build your portfolio, gain hands-on experience and show prospective employers that - you can do it!  If you\'ve always wanted to try a self-commissioned project - or have attempted them in the past without success, this course will bring you stunningly through it and set you up for more.','<p>Many photographers know the value of self-assigned work. Yet commissioning oneself to do a project requires good planning, discipline and a clear vision of what is to be achieved. Once complete and in your portfolio, creatively-executed, self-assigned bodies of work speak volumes of your ability to develop ideas and deliver them in a stunning and professional way. Whether your aim is to land that first assignment or you simply want to expand your horizons as a visual storyteller, this course gives you the skill-set and mentorship to - make it happen.</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:47','2014-05-29 11:51:47','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(13,'Spot News - Capturing Events as They Happen','First-hand and up-to-the-moment - that\'s what spot news is about. Whether it\'s in your hometown neighborhood or clear across the globe that events are unfolding quickly before your camera, you\'ll learn just how to capture them with style and affect. Taught by Associated Press photographer Ashwini Bhatia, this fast-paced online photography course will guide you in words and practice to getting The Shot that tells the story best.','<p>It can spell high-energy and adrenaline for many a photographer - being in the moment of events taking place. With tips, techniques and plenty of practical application, this exciting course taught by veteran Associated Press news photographer, Ashwini Bhatia, will have you covering dynamic news situations, in no time flat. From company and organization newsletters to regional and larger newspapers and magazines of all kinds, this course is designed to guide you step-by-step to capturing telling images with dramatic affect. Whether you\'re already an aspiring news photographer or have been long wanting to try your hand at it, this comprehensively valuable online photography course is for you.</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:48','2014-05-29 11:51:48','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(14,'Street Photography with Purpose','Designed to bring new focus to the long-practiced art of street photography, this course guides participants to produce unified and thematic bodies of work that can serve either as powerful portfolio additions or dramatic stand-alone photo essays.','<p>Roaming streets and byways in search of dramatic photos has been around since the start of compact 35mm cameras. Raised to a photographic genre by Cartier-Bresson and generations of inspired photographers after him, Street Photography remains as much an accepted genre today, as it ever has been. But followed seriously, street shooting should land its practitioner more than just a collection of unrelated images. It should exhibit thematic focusvisual intent. This 4-week online photography course is designed to point you in just such a direction. Its aim is not just the daily exercise you\'ll receive, but a powerful and cohesive body of work fit for portfolio presentation or submission as a photo-essay.</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:49','2014-05-29 11:51:49','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(15,'Digital Beginnings - Getting Started in Photography','Finally making the jump from film to digital? Trying to decide which new camera model to buy, but getting confused by pixel controversies and all those dials? Maybe you\'re new to photography altogether and need some basic \'first-steps\' to get you started. Designed for absolute newcomers to photo-making in the digital age, this online photography course will take you behind the menus and buttons to reveal what photography has always been about, while leading you confidently to the fun and efficiency that digital offers today.','<p>Setting aside your film camera for a new digital model can be an exhilarating process. We\'ll help make it so by first covering - or refreshing - the basics of the photographic process - controlling light, creating pleasing compositions and anticipating that all-illusive, defining moment, where everything comes together in a powerful way. That accomplished, this course will guide you through capturing your work on digital media, down-loading your pictures to the computer, toning your photographs to perfection and transferring them to your hard-drive for safe storage and future retrieval. As enjoyable as it is practical and valuable, this digital \'jump-start\' will have you shooting stunning images the digital way in no time flat. In fact - you may never touch another roll of film again!</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:50','2014-05-29 11:51:50','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(16,'Wide Angle - First and Foremost','Wide-angles are becoming increasingly popular – and increasingly wider – especially among photographers seeking to explore new caveats of creativity, express unique visions and come ever closer to the subjects that fascinate them most.','<p>A lot of photographers believe wide-angle lenses are only for the \'Big Scene\' or for jockeying in cramped and crowded quarters. Truth is - there\'s much more to it than that. Wide-angles are not just means to a practical end, they are tools for exploration and that can\'t be accomplished when they\'re resting at the bottom of your camera bag. This online photography course will put you to reorganizing that kit and moving your wide-angle lens to where it should be - right on top of the picture!</p>',24900,'2009-03-23',35,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:51','2014-05-29 11:51:51','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(17,'The World, The World - Through Your Lens','Travel Photography is its own genre.  Making images of the colorful and fascinating places and cultures that confront you while traveling, calls for more than just a passing snapshot made in the worst photographic light of the day.  To build a collection of truly memorable photographs that speak of the places you\'ve been, requires more than just the press of a button.  This highly informative and practical online photography course will ensure stunning photos of your next journey - be it around the state or across the globe - and all the rest to follow.','<p>Travel and photography are truly inseparable passions. And with the affordability and convenience of today\'s digital cameras, nearly everyone is guaranteed satisfying snapshot results upon their return home. Travel \'Photographs\' however - stunning images that express and inspire are a different class of photography, altogether. In this expertly instructive online photography course, you will learn to see, compose and shoot them - no matter where your are in the world - every time!</p>',34900,'2009-03-23',49,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:52','2014-05-29 11:51:52','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0),(18,'Photojournalism: The Art and Craft of Visual Story-Telling','Viewing the world through photojournalistic eyes means more than taking the occasional snapshot. It involves a deeper look to uncover the facts and then present them in an informative and creative way.','<p>Whether you travel the world with your camera or simply explore your own home town, visual stories are everywhere. Viewing the world through photojournalistic eyes means more than taking the occasional snapshot. It involves a deeper look to uncover the facts and then present them in an informative and creative way. This online photography course will point you in the right direction.</p>',34900,'2009-03-23',49,NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:53','2014-05-29 11:51:53','USD',1,NULL,0,0,NULL,NULL,0,NULL,0,NULL,NULL,0,0,0,0);
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `critiques`
--

DROP TABLE IF EXISTS `critiques`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `critiques` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `critiqueable_id` int(11) unsigned NOT NULL,
  `critiqueable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) unsigned NOT NULL,
  `comment` mediumtext COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `original_sequence` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rearrangement_sequence` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `critiques`
--

LOCK TABLES `critiques` WRITE;
/*!40000 ALTER TABLE `critiques` DISABLE KEYS */;
/*!40000 ALTER TABLE `critiques` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enquiries`
--

DROP TABLE IF EXISTS `enquiries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `enquiries` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enquiries`
--

LOCK TABLES `enquiries` WRITE;
/*!40000 ALTER TABLE `enquiries` DISABLE KEYS */;
/*!40000 ALTER TABLE `enquiries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enrolments`
--

DROP TABLE IF EXISTS `enrolments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `enrolments` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `scheduled_course_id` int(11) unsigned NOT NULL,
  `student_user_id` int(11) unsigned NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `purchase_id` int(11) unsigned DEFAULT NULL,
  `package_purchase_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_scheduled_course_id` (`scheduled_course_id`),
  KEY `idx_scheduled_course_id_student_user_id` (`scheduled_course_id`,`student_user_id`),
  KEY `idx_purchase_id` (`purchase_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrolments`
--

LOCK TABLES `enrolments` WRITE;
/*!40000 ALTER TABLE `enrolments` DISABLE KEYS */;
/*!40000 ALTER TABLE `enrolments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exchange_rates`
--

DROP TABLE IF EXISTS `exchange_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exchange_rates` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `base_currency` varchar(3) COLLATE utf8_unicode_ci NOT NULL,
  `counter_currency` varchar(3) COLLATE utf8_unicode_ci NOT NULL,
  `rate` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_base_currency_counter_currency` (`base_currency`,`counter_currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exchange_rates`
--

LOCK TABLES `exchange_rates` WRITE;
/*!40000 ALTER TABLE `exchange_rates` DISABLE KEYS */;
/*!40000 ALTER TABLE `exchange_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forum_posts`
--

DROP TABLE IF EXISTS `forum_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forum_posts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `forum_topic_id` int(11) unsigned NOT NULL,
  `content` mediumtext COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_forum_topic_id` (`forum_topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_posts`
--

LOCK TABLES `forum_posts` WRITE;
/*!40000 ALTER TABLE `forum_posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `forum_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forum_topic_users`
--

DROP TABLE IF EXISTS `forum_topic_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forum_topic_users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `forum_topic_id` int(11) unsigned NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_forum_topic_id` (`forum_topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_topic_users`
--

LOCK TABLES `forum_topic_users` WRITE;
/*!40000 ALTER TABLE `forum_topic_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `forum_topic_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forum_topics`
--

DROP TABLE IF EXISTS `forum_topics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forum_topics` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `discussable_id` int(11) unsigned DEFAULT NULL,
  `discussable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `content` mediumtext COLLATE utf8_unicode_ci,
  `posts_count` int(11) unsigned NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `publish_on` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_discussable_type_discussable_id` (`discussable_type`,`discussable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_topics`
--

LOCK TABLES `forum_topics` WRITE;
/*!40000 ALTER TABLE `forum_topics` DISABLE KEYS */;
/*!40000 ALTER TABLE `forum_topics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `instructorships`
--

DROP TABLE IF EXISTS `instructorships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instructorships` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `course_id` int(11) unsigned NOT NULL,
  `instructor_user_id` int(11) unsigned NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_course_id_instructor_user_id` (`course_id`,`instructor_user_id`),
  KEY `idx_course_id` (`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instructorships`
--

LOCK TABLES `instructorships` WRITE;
/*!40000 ALTER TABLE `instructorships` DISABLE KEYS */;
INSERT INTO `instructorships` VALUES (1,1,4,'2014-05-29 11:51:37','2014-05-29 11:51:37'),(2,2,7,'2014-05-29 11:51:38','2014-05-29 11:51:38'),(3,3,11,'2014-05-29 11:51:39','2014-05-29 11:51:39'),(4,4,6,'2014-05-29 11:51:40','2014-05-29 11:51:40'),(5,5,8,'2014-05-29 11:51:41','2014-05-29 11:51:41'),(6,6,6,'2014-05-29 11:51:42','2014-05-29 11:51:42'),(7,7,2,'2014-05-29 11:51:43','2014-05-29 11:51:43'),(8,8,3,'2014-05-29 11:51:44','2014-05-29 11:51:44'),(9,9,10,'2014-05-29 11:51:45','2014-05-29 11:51:45'),(10,10,12,'2014-05-29 11:51:46','2014-05-29 11:51:46'),(11,11,2,'2014-05-29 11:51:47','2014-05-29 11:51:47'),(12,12,4,'2014-05-29 11:51:48','2014-05-29 11:51:48'),(13,13,3,'2014-05-29 11:51:49','2014-05-29 11:51:49'),(14,14,5,'2014-05-29 11:51:50','2014-05-29 11:51:50'),(15,15,9,'2014-05-29 11:51:51','2014-05-29 11:51:51'),(16,16,2,'2014-05-29 11:51:52','2014-05-29 11:51:52'),(17,17,6,'2014-05-29 11:51:53','2014-05-29 11:51:53'),(18,18,2,'2014-05-29 11:51:54','2014-05-29 11:51:54');
/*!40000 ALTER TABLE `instructorships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lessons`
--

DROP TABLE IF EXISTS `lessons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lessons` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `course_id` int(11) unsigned NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `summary` text COLLATE utf8_unicode_ci,
  `description` mediumtext COLLATE utf8_unicode_ci,
  `duration` smallint(5) unsigned NOT NULL,
  `position` int(11) unsigned NOT NULL DEFAULT '0',
  `photo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_file_size` int(11) unsigned DEFAULT NULL,
  `photo_updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_course_id` (`course_id`),
  KEY `idx_position` (`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lessons`
--

LOCK TABLES `lessons` WRITE;
/*!40000 ALTER TABLE `lessons` DISABLE KEYS */;
/*!40000 ALTER TABLE `lessons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `package_courses`
--

DROP TABLE IF EXISTS `package_courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `package_courses` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `package_id` int(11) unsigned DEFAULT NULL,
  `course_id` int(11) unsigned DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `package_courses`
--

LOCK TABLES `package_courses` WRITE;
/*!40000 ALTER TABLE `package_courses` DISABLE KEYS */;
/*!40000 ALTER TABLE `package_courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `package_purchases`
--

DROP TABLE IF EXISTS `package_purchases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `package_purchases` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `package_id` int(11) unsigned NOT NULL DEFAULT '0',
  `student_user_id` int(11) unsigned NOT NULL DEFAULT '0',
  `price_in_cents` int(11) unsigned NOT NULL DEFAULT '0',
  `price_currency` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'USD',
  `gateway` varchar(50) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reference` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'pending',
  `raw_params` text COLLATE utf8_unicode_ci,
  `notification_received_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `package_purchases`
--

LOCK TABLES `package_purchases` WRITE;
/*!40000 ALTER TABLE `package_purchases` DISABLE KEYS */;
/*!40000 ALTER TABLE `package_purchases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `packages`
--

DROP TABLE IF EXISTS `packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `packages` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `page_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `summary` text COLLATE utf8_unicode_ci,
  `description` mediumtext COLLATE utf8_unicode_ci,
  `price_in_cents` int(11) unsigned NOT NULL DEFAULT '0',
  `price_currency` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'USD',
  `photo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_file_size` int(11) unsigned DEFAULT NULL,
  `photo_updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `packages`
--

LOCK TABLES `packages` WRITE;
/*!40000 ALTER TABLE `packages` DISABLE KEYS */;
/*!40000 ALTER TABLE `packages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partners`
--

DROP TABLE IF EXISTS `partners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partners` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `logo` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partners`
--

LOCK TABLES `partners` WRITE;
/*!40000 ALTER TABLE `partners` DISABLE KEYS */;
/*!40000 ALTER TABLE `partners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchases`
--

DROP TABLE IF EXISTS `purchases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purchases` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `scheduled_course_id` int(11) unsigned NOT NULL,
  `student_user_id` int(11) unsigned NOT NULL,
  `price_in_cents` int(11) unsigned NOT NULL,
  `price_currency` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'USD',
  `gateway` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `reference` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'pending',
  `raw_params` text COLLATE utf8_unicode_ci,
  `notification_received_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_scheduled_course_id` (`scheduled_course_id`),
  KEY `idx_scheduled_course_id_student_user_id` (`scheduled_course_id`,`student_user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchases`
--

LOCK TABLES `purchases` WRITE;
/*!40000 ALTER TABLE `purchases` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rearrangements`
--

DROP TABLE IF EXISTS `rearrangements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rearrangements` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `assignment_id` int(11) unsigned NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `summary` text COLLATE utf8_unicode_ci,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rearrangements`
--

LOCK TABLES `rearrangements` WRITE;
/*!40000 ALTER TABLE `rearrangements` DISABLE KEYS */;
/*!40000 ALTER TABLE `rearrangements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scheduled_assignments`
--

DROP TABLE IF EXISTS `scheduled_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduled_assignments` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `scheduled_lesson_id` int(11) unsigned NOT NULL,
  `assignment_id` int(11) unsigned NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_assignment_id_scheduled_lesson_id` (`assignment_id`,`scheduled_lesson_id`),
  KEY `idx_scheduled_lesson_id` (`scheduled_lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scheduled_assignments`
--

LOCK TABLES `scheduled_assignments` WRITE;
/*!40000 ALTER TABLE `scheduled_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `scheduled_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scheduled_courses`
--

DROP TABLE IF EXISTS `scheduled_courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduled_courses` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `course_id` int(11) unsigned NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `system` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scheduled_courses`
--

LOCK TABLES `scheduled_courses` WRITE;
/*!40000 ALTER TABLE `scheduled_courses` DISABLE KEYS */;
/*!40000 ALTER TABLE `scheduled_courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scheduled_lessons`
--

DROP TABLE IF EXISTS `scheduled_lessons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduled_lessons` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `scheduled_course_id` int(11) unsigned NOT NULL,
  `lesson_id` int(11) unsigned NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_lesson_id_scheduled_course_id` (`lesson_id`,`scheduled_course_id`),
  KEY `idx_scheduled_course_id` (`scheduled_course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scheduled_lessons`
--

LOCK TABLES `scheduled_lessons` WRITE;
/*!40000 ALTER TABLE `scheduled_lessons` DISABLE KEYS */;
/*!40000 ALTER TABLE `scheduled_lessons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20090122142713'),('20090122215934'),('20090128113227'),('20090128121716'),('20090128121741'),('20090128121814'),('20090128170019'),('20090129163459'),('20090129211056'),('20090129211338'),('20090129211459'),('20090129213726'),('20090129213848'),('20090202130215'),('20090202130958'),('20090202131220'),('20090202175000'),('20090202215839'),('20090202220828'),('20090203185032'),('20090205174751'),('20090205174834'),('20090205222303'),('20090206164315'),('20090216131542'),('20090218192346'),('20090219104818'),('20090219144617'),('20090219161628'),('20090326155648'),('20090326155649'),('20090611222317'),('20090623150825'),('20090706215310'),('20100919230642'),('20101001110013'),('20101005004821'),('20101006225827'),('20101007231343'),('20101102133306'),('20101102135916'),('20101102192112'),('20101212230846'),('20101213003325'),('20101216003627'),('20110118191219'),('20110118213931'),('20110118214724'),('20110118214853'),('20110217215204'),('20110218002326'),('20110509210301'),('20110618221625'),('20110705083646'),('20120510071847'),('20120518114824'),('20120705113536'),('20130214221346'),('20130527225000');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taggings`
--

DROP TABLE IF EXISTS `taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taggings` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) unsigned DEFAULT NULL,
  `taggable_id` int(11) unsigned DEFAULT NULL,
  `taggable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tag_id_taggable_type` (`tag_id`,`taggable_type`),
  KEY `idx_user_id_tag_id_taggable_type` (`user_id`,`tag_id`,`taggable_type`),
  KEY `idx_taggable_id_taggable_type` (`taggable_id`,`taggable_type`),
  KEY `idx_user_id_taggable_id_taggable_type` (`user_id`,`taggable_id`,`taggable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=450 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taggings`
--

LOCK TABLES `taggings` WRITE;
/*!40000 ALTER TABLE `taggings` DISABLE KEYS */;
INSERT INTO `taggings` VALUES (1,1,1,'Course',NULL),(2,2,1,'Course',NULL),(3,3,1,'Course',NULL),(4,4,1,'Course',NULL),(5,5,1,'Course',NULL),(6,6,1,'Course',NULL),(7,7,1,'Course',NULL),(8,8,1,'Course',NULL),(9,9,1,'Course',NULL),(10,10,1,'Course',NULL),(11,11,1,'Course',NULL),(12,12,1,'Course',NULL),(13,13,1,'Course',NULL),(14,7,2,'Course',NULL),(15,14,2,'Course',NULL),(16,15,2,'Course',NULL),(17,16,2,'Course',NULL),(18,17,2,'Course',NULL),(19,8,2,'Course',NULL),(20,18,2,'Course',NULL),(21,19,2,'Course',NULL),(22,20,2,'Course',NULL),(23,21,2,'Course',NULL),(24,22,2,'Course',NULL),(25,23,2,'Course',NULL),(26,24,2,'Course',NULL),(27,25,2,'Course',NULL),(28,26,2,'Course',NULL),(29,27,2,'Course',NULL),(30,28,2,'Course',NULL),(31,5,2,'Course',NULL),(32,29,2,'Course',NULL),(33,30,2,'Course',NULL),(34,31,2,'Course',NULL),(35,32,2,'Course',NULL),(36,13,2,'Course',NULL),(37,7,3,'Course',NULL),(38,6,3,'Course',NULL),(39,33,3,'Course',NULL),(40,34,3,'Course',NULL),(41,35,3,'Course',NULL),(42,2,3,'Course',NULL),(43,1,3,'Course',NULL),(44,36,3,'Course',NULL),(45,37,3,'Course',NULL),(46,38,3,'Course',NULL),(47,39,3,'Course',NULL),(48,40,3,'Course',NULL),(49,41,3,'Course',NULL),(50,14,3,'Course',NULL),(51,15,3,'Course',NULL),(52,28,3,'Course',NULL),(53,20,4,'Course',NULL),(54,21,4,'Course',NULL),(55,12,4,'Course',NULL),(56,42,4,'Course',NULL),(57,43,4,'Course',NULL),(58,44,4,'Course',NULL),(59,45,4,'Course',NULL),(60,46,4,'Course',NULL),(61,47,4,'Course',NULL),(62,48,4,'Course',NULL),(63,49,4,'Course',NULL),(64,50,4,'Course',NULL),(65,51,4,'Course',NULL),(66,52,4,'Course',NULL),(67,53,4,'Course',NULL),(68,54,4,'Course',NULL),(69,55,4,'Course',NULL),(70,56,4,'Course',NULL),(71,57,4,'Course',NULL),(72,58,4,'Course',NULL),(73,59,4,'Course',NULL),(74,60,4,'Course',NULL),(75,13,4,'Course',NULL),(76,61,5,'Course',NULL),(77,62,5,'Course',NULL),(78,48,5,'Course',NULL),(79,63,5,'Course',NULL),(80,64,5,'Course',NULL),(81,60,5,'Course',NULL),(82,65,5,'Course',NULL),(83,57,5,'Course',NULL),(84,50,5,'Course',NULL),(85,49,5,'Course',NULL),(86,42,5,'Course',NULL),(87,20,5,'Course',NULL),(88,21,5,'Course',NULL),(89,66,5,'Course',NULL),(90,67,5,'Course',NULL),(91,13,5,'Course',NULL),(92,12,6,'Course',NULL),(93,43,6,'Course',NULL),(94,42,6,'Course',NULL),(95,52,6,'Course',NULL),(96,68,6,'Course',NULL),(97,2,6,'Course',NULL),(98,1,6,'Course',NULL),(99,49,6,'Course',NULL),(100,56,6,'Course',NULL),(101,69,6,'Course',NULL),(102,70,6,'Course',NULL),(103,65,6,'Course',NULL),(104,13,6,'Course',NULL),(105,71,6,'Course',NULL),(106,72,6,'Course',NULL),(107,58,6,'Course',NULL),(108,73,6,'Course',NULL),(109,74,6,'Course',NULL),(110,75,6,'Course',NULL),(111,76,6,'Course',NULL),(112,77,6,'Course',NULL),(113,36,6,'Course',NULL),(114,78,6,'Course',NULL),(115,79,6,'Course',NULL),(116,80,6,'Course',NULL),(117,81,6,'Course',NULL),(118,82,6,'Course',NULL),(119,83,6,'Course',NULL),(120,84,6,'Course',NULL),(121,85,6,'Course',NULL),(122,37,6,'Course',NULL),(123,38,6,'Course',NULL),(124,42,7,'Course',NULL),(125,12,7,'Course',NULL),(126,20,7,'Course',NULL),(127,21,7,'Course',NULL),(128,86,7,'Course',NULL),(129,51,7,'Course',NULL),(130,49,7,'Course',NULL),(131,56,7,'Course',NULL),(132,58,7,'Course',NULL),(133,73,7,'Course',NULL),(134,87,7,'Course',NULL),(135,88,7,'Course',NULL),(136,89,7,'Course',NULL),(137,90,7,'Course',NULL),(138,91,7,'Course',NULL),(139,92,7,'Course',NULL),(140,93,7,'Course',NULL),(141,94,7,'Course',NULL),(142,95,7,'Course',NULL),(143,13,7,'Course',NULL),(144,2,8,'Course',NULL),(145,20,8,'Course',NULL),(146,21,8,'Course',NULL),(147,96,8,'Course',NULL),(148,97,8,'Course',NULL),(149,98,8,'Course',NULL),(150,52,8,'Course',NULL),(151,77,8,'Course',NULL),(152,99,8,'Course',NULL),(153,42,8,'Course',NULL),(154,54,8,'Course',NULL),(155,13,8,'Course',NULL),(156,58,8,'Course',NULL),(157,100,8,'Course',NULL),(158,56,8,'Course',NULL),(159,101,8,'Course',NULL),(160,9,8,'Course',NULL),(161,91,8,'Course',NULL),(162,72,8,'Course',NULL),(163,102,8,'Course',NULL),(164,71,8,'Course',NULL),(165,69,8,'Course',NULL),(166,70,8,'Course',NULL),(167,43,8,'Course',NULL),(168,12,8,'Course',NULL),(169,65,8,'Course',NULL),(170,53,8,'Course',NULL),(171,76,8,'Course',NULL),(172,74,8,'Course',NULL),(173,85,8,'Course',NULL),(174,93,9,'Course',NULL),(175,56,9,'Course',NULL),(176,103,9,'Course',NULL),(177,104,9,'Course',NULL),(178,105,9,'Course',NULL),(179,106,9,'Course',NULL),(180,107,9,'Course',NULL),(181,108,9,'Course',NULL),(182,109,9,'Course',NULL),(183,110,9,'Course',NULL),(184,111,9,'Course',NULL),(185,58,9,'Course',NULL),(186,73,9,'Course',NULL),(187,112,9,'Course',NULL),(188,113,9,'Course',NULL),(189,91,9,'Course',NULL),(190,114,9,'Course',NULL),(191,26,9,'Course',NULL),(192,115,9,'Course',NULL),(193,94,9,'Course',NULL),(194,116,9,'Course',NULL),(195,117,9,'Course',NULL),(196,118,9,'Course',NULL),(197,20,9,'Course',NULL),(198,21,9,'Course',NULL),(199,22,9,'Course',NULL),(200,42,9,'Course',NULL),(201,43,9,'Course',NULL),(202,12,9,'Course',NULL),(203,119,9,'Course',NULL),(204,53,9,'Course',NULL),(205,52,9,'Course',NULL),(206,93,10,'Course',NULL),(207,58,10,'Course',NULL),(208,71,10,'Course',NULL),(209,72,10,'Course',NULL),(210,102,10,'Course',NULL),(211,120,10,'Course',NULL),(212,56,10,'Course',NULL),(213,114,10,'Course',NULL),(214,26,10,'Course',NULL),(215,115,10,'Course',NULL),(216,94,10,'Course',NULL),(217,107,10,'Course',NULL),(218,69,10,'Course',NULL),(219,121,10,'Course',NULL),(220,122,10,'Course',NULL),(221,123,10,'Course',NULL),(222,124,10,'Course',NULL),(223,125,10,'Course',NULL),(224,20,10,'Course',NULL),(225,21,10,'Course',NULL),(226,126,10,'Course',NULL),(227,42,10,'Course',NULL),(228,43,10,'Course',NULL),(229,12,10,'Course',NULL),(230,52,10,'Course',NULL),(231,68,10,'Course',NULL),(232,49,10,'Course',NULL),(233,76,10,'Course',NULL),(234,53,10,'Course',NULL),(235,77,10,'Course',NULL),(236,106,10,'Course',NULL),(237,127,11,'Course',NULL),(238,128,11,'Course',NULL),(239,12,11,'Course',NULL),(240,49,11,'Course',NULL),(241,51,11,'Course',NULL),(242,129,11,'Course',NULL),(243,94,11,'Course',NULL),(244,130,11,'Course',NULL),(245,131,11,'Course',NULL),(246,132,11,'Course',NULL),(247,133,11,'Course',NULL),(248,134,11,'Course',NULL),(249,135,11,'Course',NULL),(250,53,11,'Course',NULL),(251,77,11,'Course',NULL),(252,54,11,'Course',NULL),(253,136,11,'Course',NULL),(254,42,11,'Course',NULL),(255,43,11,'Course',NULL),(256,20,11,'Course',NULL),(257,21,11,'Course',NULL),(258,106,12,'Course',NULL),(259,137,12,'Course',NULL),(260,138,12,'Course',NULL),(261,139,12,'Course',NULL),(262,134,12,'Course',NULL),(263,52,12,'Course',NULL),(264,35,12,'Course',NULL),(265,12,12,'Course',NULL),(266,49,12,'Course',NULL),(267,74,12,'Course',NULL),(268,140,12,'Course',NULL),(269,141,12,'Course',NULL),(270,142,12,'Course',NULL),(271,143,12,'Course',NULL),(272,144,12,'Course',NULL),(273,145,12,'Course',NULL),(274,115,12,'Course',NULL),(275,20,12,'Course',NULL),(276,21,12,'Course',NULL),(277,22,12,'Course',NULL),(278,13,12,'Course',NULL),(279,58,12,'Course',NULL),(280,73,12,'Course',NULL),(281,20,13,'Course',NULL),(282,21,13,'Course',NULL),(283,22,13,'Course',NULL),(284,51,13,'Course',NULL),(285,50,13,'Course',NULL),(286,49,13,'Course',NULL),(287,12,13,'Course',NULL),(288,18,13,'Course',NULL),(289,146,13,'Course',NULL),(290,62,13,'Course',NULL),(291,147,13,'Course',NULL),(292,148,13,'Course',NULL),(293,42,13,'Course',NULL),(294,74,13,'Course',NULL),(295,85,13,'Course',NULL),(296,149,13,'Course',NULL),(297,150,13,'Course',NULL),(298,151,13,'Course',NULL),(299,52,13,'Course',NULL),(300,53,13,'Course',NULL),(301,68,13,'Course',NULL),(302,54,13,'Course',NULL),(303,152,13,'Course',NULL),(304,153,13,'Course',NULL),(305,136,13,'Course',NULL),(306,154,13,'Course',NULL),(307,155,13,'Course',NULL),(308,48,13,'Course',NULL),(309,13,13,'Course',NULL),(310,127,14,'Course',NULL),(311,51,14,'Course',NULL),(312,20,14,'Course',NULL),(313,21,14,'Course',NULL),(314,12,14,'Course',NULL),(315,42,14,'Course',NULL),(316,56,14,'Course',NULL),(317,58,14,'Course',NULL),(318,57,14,'Course',NULL),(319,74,14,'Course',NULL),(320,85,14,'Course',NULL),(321,156,14,'Course',NULL),(322,94,14,'Course',NULL),(323,153,14,'Course',NULL),(324,152,14,'Course',NULL),(325,4,14,'Course',NULL),(326,143,14,'Course',NULL),(327,157,14,'Course',NULL),(328,75,14,'Course',NULL),(329,158,14,'Course',NULL),(330,13,14,'Course',NULL),(331,12,15,'Course',NULL),(332,43,15,'Course',NULL),(333,42,15,'Course',NULL),(334,52,15,'Course',NULL),(335,68,15,'Course',NULL),(336,2,15,'Course',NULL),(337,1,15,'Course',NULL),(338,49,15,'Course',NULL),(339,56,15,'Course',NULL),(340,69,15,'Course',NULL),(341,70,15,'Course',NULL),(342,65,15,'Course',NULL),(343,13,15,'Course',NULL),(344,71,15,'Course',NULL),(345,72,15,'Course',NULL),(346,58,15,'Course',NULL),(347,73,15,'Course',NULL),(348,74,15,'Course',NULL),(349,75,15,'Course',NULL),(350,76,15,'Course',NULL),(351,77,15,'Course',NULL),(352,36,15,'Course',NULL),(353,78,15,'Course',NULL),(354,79,15,'Course',NULL),(355,80,15,'Course',NULL),(356,81,15,'Course',NULL),(357,82,15,'Course',NULL),(358,83,15,'Course',NULL),(359,84,15,'Course',NULL),(360,85,15,'Course',NULL),(361,37,15,'Course',NULL),(362,38,15,'Course',NULL),(363,49,16,'Course',NULL),(364,159,16,'Course',NULL),(365,160,16,'Course',NULL),(366,94,16,'Course',NULL),(367,148,16,'Course',NULL),(368,161,16,'Course',NULL),(369,57,16,'Course',NULL),(370,65,16,'Course',NULL),(371,60,16,'Course',NULL),(372,156,16,'Course',NULL),(373,162,16,'Course',NULL),(374,42,16,'Course',NULL),(375,43,16,'Course',NULL),(376,163,16,'Course',NULL),(377,164,16,'Course',NULL),(378,85,16,'Course',NULL),(379,165,16,'Course',NULL),(380,166,16,'Course',NULL),(381,167,16,'Course',NULL),(382,136,16,'Course',NULL),(383,152,16,'Course',NULL),(384,53,16,'Course',NULL),(385,77,16,'Course',NULL),(386,54,16,'Course',NULL),(387,20,16,'Course',NULL),(388,21,16,'Course',NULL),(389,22,16,'Course',NULL),(390,68,16,'Course',NULL),(391,95,16,'Course',NULL),(392,13,16,'Course',NULL),(393,168,17,'Course',NULL),(394,45,17,'Course',NULL),(395,64,17,'Course',NULL),(396,169,17,'Course',NULL),(397,170,17,'Course',NULL),(398,171,17,'Course',NULL),(399,49,17,'Course',NULL),(400,12,17,'Course',NULL),(401,74,17,'Course',NULL),(402,172,17,'Course',NULL),(403,13,17,'Course',NULL),(404,58,17,'Course',NULL),(405,57,17,'Course',NULL),(406,173,17,'Course',NULL),(407,174,17,'Course',NULL),(408,2,17,'Course',NULL),(409,1,17,'Course',NULL),(410,20,17,'Course',NULL),(411,56,17,'Course',NULL),(412,175,17,'Course',NULL),(413,176,17,'Course',NULL),(414,177,17,'Course',NULL),(415,178,17,'Course',NULL),(416,179,18,'Course',NULL),(417,35,18,'Course',NULL),(418,143,18,'Course',NULL),(419,137,18,'Course',NULL),(420,144,18,'Course',NULL),(421,42,18,'Course',NULL),(422,43,18,'Course',NULL),(423,54,18,'Course',NULL),(424,77,18,'Course',NULL),(425,52,18,'Course',NULL),(426,180,18,'Course',NULL),(427,153,18,'Course',NULL),(428,181,18,'Course',NULL),(429,4,18,'Course',NULL),(430,182,18,'Course',NULL),(431,183,18,'Course',NULL),(432,184,18,'Course',NULL),(433,120,18,'Course',NULL),(434,185,18,'Course',NULL),(435,18,18,'Course',NULL),(436,154,18,'Course',NULL),(437,49,18,'Course',NULL),(438,74,18,'Course',NULL),(439,12,18,'Course',NULL),(440,51,18,'Course',NULL),(441,50,18,'Course',NULL),(442,20,18,'Course',NULL),(443,21,18,'Course',NULL),(444,22,18,'Course',NULL),(445,62,18,'Course',NULL),(446,13,18,'Course',NULL),(447,58,18,'Course',NULL),(448,73,18,'Course',NULL),(449,26,18,'Course',NULL);
/*!40000 ALTER TABLE `taggings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `taggings_count` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`),
  KEY `idx_taggings_count` (`taggings_count`)
) ENGINE=InnoDB AUTO_INCREMENT=186 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
INSERT INTO `tags` VALUES (1,'introductory',5),(2,'beginner',6),(3,'basic',1),(4,'story',3),(5,'scripting',2),(6,'editing',2),(7,'video',3),(8,'audio',2),(9,'tripod',2),(10,'entertaining',1),(11,'engaging',1),(12,'camera',14),(13,'light',14),(14,'videography',2),(15,'visual storytelling',2),(16,'solo journalist',1),(17,'journalism',1),(18,'news',3),(19,'features',1),(20,'intermediate',14),(21,'advanced',13),(22,'aspiring professional',6),(23,'on the go',1),(24,'mobile',1),(25,'flexibility',1),(26,'edit',4),(27,'capture',1),(28,'sound',2),(29,'interviews',1),(30,'cameraman',1),(31,'production',1),(32,'video camera',1),(33,'final cut pro',1),(34,'final cut express',1),(35,'storytelling',3),(36,'introduction',3),(37,'basics',3),(38,'fundamentals',3),(39,'software',1),(40,'first-time user',1),(41,'computer',1),(42,'digital',13),(43,'film',9),(44,'sports',1),(45,'adventure',2),(46,'outdoors',1),(47,'nature',1),(48,'action',3),(49,'lens',12),(50,'telephoto',4),(51,'wide angle',6),(52,'photography',9),(53,'photo',7),(54,'image',6),(55,'challenge',1),(56,'composition',9),(57,'depth of field',5),(58,'color',11),(59,'motion',1),(60,'shutter speed',3),(61,'game',1),(62,'coverage',3),(63,'flash',1),(64,'document',2),(65,'aperture',5),(66,'equipment',1),(67,'photojournalist',1),(68,'photographer',5),(69,'depth-of-field',4),(70,'shutter',3),(71,'form',4),(72,'line',4),(73,'black and white',6),(74,'subject',8),(75,'focus',3),(76,'picture',4),(77,'photograph',7),(78,'getting started',2),(79,'first steps',2),(80,'newcomer',2),(81,'confidence',2),(82,'enjoyment',2),(83,'fun',2),(84,'focal length',2),(85,'background',6),(86,'ghosting',1),(87,'sense of moment',1),(88,'frame',1),(89,'balance',1),(90,'visual logic',1),(91,'creativity',3),(92,'expression',1),(93,'design',3),(94,'expressive',6),(95,'interpret',2),(96,'flower',1),(97,'macro',1),(98,'close-up',1),(99,'technique',1),(100,'macro-lens',1),(101,'exposure',1),(102,'shape',2),(103,'lay-out',1),(104,'arrangement',1),(105,'sequencing',1),(106,'portfolio',3),(107,'presentation',2),(108,'aesthetic',1),(109,'book',1),(110,'beamer',1),(111,'detail',1),(112,'packaging',1),(113,'self-promotion',1),(114,'eye',2),(115,'editorial',3),(116,'collections',1),(117,'innovative',1),(118,'impressive',1),(119,'photographs',1),(120,'style',2),(121,'techniques',1),(122,'express',1),(123,'fresh',1),(124,'way of seeing',1),(125,'interpretation',1),(126,'new',1),(127,'candid',2),(128,'personal space',1),(129,'emotion',1),(130,'environmental portrait',1),(131,'portrait',1),(132,'group portrait',1),(133,'interaction',1),(134,'self-confidence',2),(135,'street photography',1),(136,'dynamic',3),(137,'layout',2),(138,'self-discipline',1),(139,'hands on experience',1),(140,'planning',1),(141,'location',1),(142,'self-commissioned',1),(143,'photo essay',3),(144,'photo story',2),(145,'self promotion',1),(146,'event',1),(147,'actual',1),(148,'close up',2),(149,'newspaper',1),(150,'magazine',1),(151,'internet',1),(152,'powerful',3),(153,'impact',3),(154,'reporting',2),(155,'fast-paced',1),(156,'layers',2),(157,'personal interaction',1),(158,'reportage',1),(159,'perspective',1),(160,'dramatic',1),(161,'personal',1),(162,'expansive',1),(163,'wide angle lens',1),(164,'foreground',1),(165,'sharpness',1),(166,'out of focus',1),(167,'soft focus',1),(168,'travel',1),(169,'trip',1),(170,'holiday',1),(171,'foreign',1),(172,'time of day',1),(173,'people',1),(174,'landscape',1),(175,'seeing pictures',1),(176,'close ups',1),(177,'other countries',1),(178,'culture',1),(179,'documentary',1),(180,'sequence',1),(181,'power',1),(182,'facts',1),(183,'information',1),(184,'informative',1),(185,'content',1);
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(320) COLLATE utf8_unicode_ci NOT NULL,
  `password_hash` char(64) CHARACTER SET latin1 NOT NULL,
  `password_salt` char(64) CHARACTER SET latin1 NOT NULL,
  `role` varchar(1) COLLATE utf8_unicode_ci NOT NULL DEFAULT 's',
  `given_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `family_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `address_street` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_locality` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_region` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_postal_code` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_country` varchar(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_voice` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_mobile` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `profile` mediumtext COLLATE utf8_unicode_ci,
  `time_zone` varchar(30) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'London',
  `activation_code` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
  `temporary_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `temporary_password_expires_at` datetime DEFAULT NULL,
  `status` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  `photo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_file_size` int(11) unsigned DEFAULT NULL,
  `photo_updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `instructor_photo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `instructor_photo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `instructor_photo_file_size` int(11) unsigned DEFAULT NULL,
  `instructor_photo_updated_at` datetime DEFAULT NULL,
  `hidden` tinyint(1) DEFAULT '0',
  `meta_description` text COLLATE utf8_unicode_ci,
  `meta_keywords` text COLLATE utf8_unicode_ci,
  `mentor` tinyint(1) DEFAULT NULL,
  `youtube_video_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `vimeo_video_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`(100))
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin@thecompellingimage.com','669b4a1ff6385b1d0cf15f7c2f8b9cf5c211c0f25ec706a95f5a218456093581','221e5093b07a42291c085bed1ba67cc268577e92088a9a1165443d41175587e3','a','Admin','User',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:07','2014-05-29 11:51:07',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(2,'david@davidbathgate.com','ba84589afba9f2701f46349f440a0eb9d84c77e5141d8185b11d08dc64c3d7fa','b61db673436fad990809618d73becc4500ebf6aba086ec77ff9efdea600e5fbe','i','David','Bathgate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>David Bathgate studied anthropology and journalism at the Pennsylvania State University in the U.S., earning a doctorate and master\'s degree, respectively, in those two disciplines.</p><p>Thereafter, university teaching and visual journalism followed as parallel career pursuits. First photographing and writing for local magazines and newspapers, David eventually took his co-careers to Australia and worked on photographic projects in Indonesia and Southeast Asia.</p><p>In 1993 he closed the door on academia to become a full-time visual story-teller, covering social and environmental topics he knows best.</p><p>Today, David works regularly in Asia and the Middle East, as well as Europe, for publications such as Time, Newsweek, Geo, Stern, Focus and The London Sunday Times Magazine.</p><p>In addition, he regularly conducts workshops and seminars on photography, photojournalism and visual communication in places like Dharamshala, India and Ladakh and at institutions like, Pathshala - South Asian Insitute of Photograpy, in Dhaka, Bangladesh and AINA in Kabul, Afghanistan.</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:36','2014-05-29 11:51:36',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(3,'ashwini@ashwinibhatia.com','5b7f1d2ae7677e3c4cc25ba929e7f32a5d3cae388175887df47787e19b80e474','ff9f152c83993ee5e206c33a97144ce511784d282175088ac9527a27f098eda7','i','Ashwini','Bhatia',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>Ashwini Bhatia writes and photographs for the Associated Press from Dharamshala, his adopted home in the Indian Himalayas.</p><p>From His Holiness the 14th Dalai Lama to the Tibetan government-in-exile and the thriving exile Tibetan community, Ashwini covers it all.</p><p>His work has appeared in Time, The New York Times, International Herald Tribune, Washington Post, The Telegraph and many other leading publications.</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:36','2014-05-29 11:51:36',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(4,'oneshotmore@kloie.com','2c895e8ac368addfa5b295a529c2acd43a8a54a9728fd3e7eef75512bf1ff097','8efe8d9971277569d07f8e44fd2f31d74f1548f6a611b59a0d892cac7503e6bc','i','Kloie','Picot',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>Kloie Picot is a self-taught photojournalist/video filmmaker, focusing on conflict, critical social issues, and cultural events from around the world. She began her career as a video journalist in the West Bank, making short video documentaries and has just completed her first full length documentary entitled &quot;Shots that Bind&quot; Palestinian Photojournalists in Nablus.</p><p>Her numerous short films have won awards in Canada and S.E Asia including Best Cinematography at the New York Film and Video Festival, Best Documentary at the Urban Nomad Festival in Taipei.&quot;Shots that Bind&quot; has been selected by FRONTLINE CLUB RUSSIA as part of their Russian showcase to start at the end of 2008.</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:36','2014-05-29 11:51:36',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(5,'gmbakash@yahoo.com','a8f4574ace9acb79d5b0429c6727f3158d9cfcbee4bcfa9189e7302f9a6aa4b0','4c9f420a5a55be465d0267d5cab2a284a53f76ececac1ed2900798f1b484e9e2','i','GMB','Akash',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>Akash\'s passion for photography began in 1996. He attended the World Press Photo seminar in Dhaka for 3 years and graduated with a BA in Photojournalism from Pathshala, Dhaka. His work has been featured in over 35 major international publications including: Time, Newsweek, , Geo, Stern, Der Spiegel, The Economist, The New Internationalist, Amnesty Journal, Courier International,, Modern Times , A Magazine, PDN, View, Earth Geo , Days Japan, Zenith, Free Lance, Art Asia Pacific, El Mundo, NRC Handelsblad , Cicero, Insight, Szene Hamburg, Himal -the south Asian, Frankfurter Allgemeine Zeitung, Westdeutsche Allgemeneine, Berliner Journalisten, Frankfurter Rundschau,Das Parlament, Hinz & Kunzt, China daily, Asia News, Hamburger Abenbblatt, Hamburger Morgen Post, and Sunday Telegraph of London.</p><p>In 2002 he became the first Bangladeshi to be selected for the World Press Photo Joop Swart Masterclass in the Netherlands. In 2004 he received the Young Reporters Award from the Scope Photo Festival in Paris, again being the first Bangladeshi to receive the honour. In 2005 he was awarded Best of Show at the Center for Fine Art Photography’s international competition in Colorado, USA. In 2006 he was awarded World Press Photo award and released his first book &quot;First Light&quot;.</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:36','2014-05-29 11:51:36',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(6,'dan@danbaileyphoto.com','1f496f38f3f80278f5efa3278cd94157f5b6a9657a3252cc8334f5fff3d3b53c','a68cb8a5d7ad2c745265268ce1b972cb4e7c25ee9ec85cb0631c2e8fd8b9a33b','i','Daniel','Bailey',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>Dan Bailey is a professional photographer who specializes in creating images that convey the essence of adventure. His images communicate the fear, exhilaration, struggles and personalities of his subjects as they interact with the natural world and test the limits of their skills and endurance or as they simply live their lives off of the beaten path.</p><p>His work has been published by clients worldwide, including Nikon, Fidelity Investments, British Petroleum, National Geographic Adventure Magazine, Outside Magazine, The New York Times, and Patagonia. Daniel\'s own passion for adventure usually places himself right alongside his subjects, which allows him to share in their experiences firsthand as he shoots. In that way his photography has become his vehicle for a life of exploration and documenting expeditions, cultures and landscapes around the world.</p><p>His experience as a former photo editor, combined with over a decade of teaching photography workshops, has given Dan a solid understanding of how to recognize and critique eye catching imagery, and how to effectively communicate the methods for making stronger photographs to his students</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:36','2014-05-29 11:51:36',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(7,'chris@cgbooker.com','795b56d199059e2fd18f3c12fd86f01c27c8cc6a34ab0045309c0af5a67f6625','816cfcef6bd9f8accc1c9006a5dc54bb56ec1be296356ca018dfefdf2dae2d2a','i','Christopher','Booker',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>Christopher Booker is a video and multimedia journalist with the Chicago Tribune. Working as a one-man production crew, he writes, produces, shoots and edits video and multimedia content for the paper\'s website and broadcast partners. He also regularly shoots photographs for the newspaper.  He has also written for the Tribune\'s Sunday Magazine, Books, National and Perspective sections.</p><p>His work has appeared on CNN, NPR, the Chicago International Documentary Festival, Farm Aid and a collection of Tribune broadcast stations.</p><p>Outside of the Tribune, he is freelance producer for NPR\'s Hearing Voices and an adjunct professor at Northwestern\'s Medill School of Journalism where he teaches video and multimedia storytelling.</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:36','2014-05-29 11:51:36',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(8,'sknox@smk-images.com','dde66eb6bb0d7c578e85fea4a04509669fcf13e45730178e58221c88d2470ab4','05d6a6d5a7bc422ce066b3de86bdadb0e1873e1124e108a4a4e3d77e12e596d3','i','Shawn','Knox',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>Shawn M. Knox is an awarding winning South Carolina photographer with a photography career spanning over fifteen years.  He is a graduate of Indiana University-Purdue University Indianapolis (IUPUI) in the U.S.</p><p>He currently serves as the team photographer for the Anderson Joes Professional Baseball team of the South Coast Independent League in America.  His images have appeared in various local and regional newspapers, magazines and websites throughout the Southeastern United States.</p><p>Shawn is a regular sports photo contributor to the Abbeville (SC) Press and Banner newspaper and also contributes frequently to the Greenwood (SC) Index-Journal newspaper.  His photography experience runs the gamut from nature, fine art and travel to weddings, portraits, sports action and news events.  Over the past few years, however, Shawn has successfully transitioned his photography business focus to mainly sports-related photojournalism and special events.</p><p>Shawn currently resides in the Upstate of South Carolina in the town of Honea Path with his wife Michelle and their daughter Gabrielle.</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:36','2014-05-29 11:51:36',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(9,'heidilaughton@googlemail.com','7feb510603d5174b37d5e5434367848de041ec07faeda59f50dd785d30ae8074','536370dc83db548cfbed3f587b669c24f90643555c515ec8ffd3c8cd6f5219fa','i','Heidi','Laughton',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>Heidi Laughton is a British photographer now based in Los Angeles. Her passion lies in photographing people, whether it\'s for reportage documentary projects, formal portraits, travel & lifestyle editorial features or bands in the music industry. Heidi has attended courses & workshops with City & Guilds; David Bathgate; Steve McCurry and Julia Dean. However, most of her critical eye has been fostered through 12 years in the music industry commissioning videos, virals, podcasts, documentaries & photography for a variety of artists, the last five years of which, having been at SonyBMG, London.</p><p>Heidi has recently been working on humanitarian projects including: breast cancer for Ausmed publications; Youth community centre for Save The Children in Kunming, China; an interview on Aids prevention and treatment in Dali (Barry & Martin\'s Trust); A study of the smallest minority groups of China (personal project). Last year she also taught a photography workshop to 20 girls from the slum areas of Kisumu, Kenya for NGO, K-MET (the Kisumu Medical & Educational Trust).</p><p>Currently Heidi is building on her portrait portfolio and advertising/editorial career.</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:36','2014-05-29 11:51:36',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(10,'yunho@mac.com','e11458ce8c692fec2eec14216787eaeba1bb0d15e7cef6eb27b76608054ee1af','b843af6f88f874335757275e9419b4ce85c0374a98d4e9ce52b66838d85e8d14','i','Deb','Pang Davis',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>Deb Pang Davis is a graphic designer based in Portland, Oregon.</p><p>She began her career in publication design in 1998 after pursuing graduate studies in visual communication from Ohio University and moving to Seattle as a features design intern for The Seattle Times. Deb has worked for several newspapers in North America and eventually made her way to Washington, DC as Associate Art Director for National Geographic Traveler. From there, she relocated to Portland, Oregon where she telecommuted as Art Director and Photo Editor for Virtuoso Life, a bimonthly luxury travel magazine.</p><p>Her most recent projects include working with her husband and picture editor, Mike Davis, as Directors of Photography for The Blue Planet Run book. They also launched a blog called Raw Take: Talking Pictures through conversation and thought.</p><p>Currently Deb is pursuing studies in web design and development at Portland State University and plans to offer web design services through her studio, Cococello :: Design to photographers and other small businesses beginning this Fall 2008.</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:36','2014-05-29 11:51:36',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(11,'andrewsatter@gmail.com','0dfa4526f0eed6e3838e35a89e0bed547e58045cad853ade0fa957f1320df777','60a8e73bae8b03181eae3ee58cac43e2adec342b7e35bd1a74cf7e8cafc38312','i','Andrew','Satter',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>Andrew Satter is an award-winning news videojournalist in Washington, DC., covering issues of both international and domestic importance.</p><p>He has covered illegal immigration issues from both sides of the U.S.-Mexico border; growth and development in the American Southwest; and is currently covering the 2008 Election, both in Washington and on the campaign trail.</p><p>Satter\'s mission is to engage viewers emotionally and intellectually, provide a concise narrative, thoughtful character development, stimulating visuals and tight editing. He is experienced working as a one-man band, where he writes, shoots, edits and produces a complete package, as well as with a team of reporters, editors and other shooters.</p><p>His work has garnered recognition and awards from Editor and Publisher, the Arizona Press Club and the National Press Photographer’s Association. He was the online producer and videographer for the heralded series ‘Sealing our Border: Why It Won’t Work’ (http://www.azstarnet.com/secureborder).</p><p>Satter is currently the online video producer for Congressional Quarterly\'s free politics site, CQPolitics.com.</p><p>Previously he worked as an Online News Producer/Sr. Video Producer at the Arizona Daily Star in Tucson. Satter has also spent time as a reporter for the English-language Prague Post; a national correspondent for the Bend, Ore. Bulletin; a media consultant for the Milwaukee Journal-Sentinel; a production intern for Kurtis Productions in Chicago for the A&E show &quot;Cold Case Files&quot;; and a preps reporter for the New Orleans Times-Picayune.</p><p>Satter holds a master’s degree in New Media Journalism from Northwestern University’s Medill School of Journalism. Upon graduation in March 2004 he was awarded the Harrington Award for journalistic promise and high scholastic achievement in new media, Medill’s highest accolade.</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:36','2014-05-29 11:51:36',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(12,'michelle@mwoodward.com','e27afdf58241d47b8149bc497f826bc95dd565c8435e792b047c586203e97f64','d091a03bae58a3e4f5ca9cb1a213177a176c7222bf79559f902727504ce26b2e','i','Michelle','Woodward',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'<p>Michelle Woodward is the photo editor of Middle East Report, a magazine respected for its independent analysis of events and developments in the Middle East. She is also a freelance photo researcher and has worked as a stringer photographer for AFP in Amman, Jordan, and as a freelance photographer providing images to travel guidebooks, magazines and books on the Middle East. However, she finds that her best photographs are often those taken of the odd things that interest her such as industrial ruins, urban details and things in decay, which she exhibits occasionally. She also writes and conducts research into historical and contemporary photography of the Middle East. Last year she was based in Beirut, but now she is back home in Baltimore. She is also teaching a photography class in Baltimore through Odyssey: Liberal Arts Programs for Adults at Johns Hopkins University.</p>','London',NULL,NULL,NULL,'activated',NULL,NULL,NULL,NULL,NULL,'2014-05-29 11:51:37','2014-05-29 11:51:37',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'',''),(13,'waqar.shahid@pixelcrayons.com','cc5c9034bab98c6fdedf53cdea1b0806ffaedc30a4081ef94117bf6ff2d309b1','7836603cfc740465bf2959e299a3af7c23b064e524955254cc7c3a6546a1c8c6','s','waqar','test',NULL,NULL,NULL,'','',NULL,NULL,NULL,'London','e0a666fc',NULL,NULL,'pending',NULL,NULL,NULL,NULL,NULL,'2014-05-29 12:44:01','2014-05-29 12:44:01',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'','');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workshops`
--

DROP TABLE IF EXISTS `workshops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workshops` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `page_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `summary` text COLLATE utf8_unicode_ci,
  `description` mediumtext COLLATE utf8_unicode_ci,
  `enrolment` text COLLATE utf8_unicode_ci,
  `upcoming` text COLLATE utf8_unicode_ci,
  `terms` text COLLATE utf8_unicode_ci,
  `full_price_in_cents` int(11) unsigned NOT NULL DEFAULT '0',
  `full_price_currency` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'USD',
  `deposit_price_in_cents` int(11) unsigned NOT NULL DEFAULT '0',
  `deposit_price_currency` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'USD',
  `photo_1_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_1_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_1_file_size` int(11) unsigned DEFAULT NULL,
  `photo_1_updated_at` datetime DEFAULT NULL,
  `photo_2_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_2_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_2_file_size` int(11) unsigned DEFAULT NULL,
  `photo_2_updated_at` datetime DEFAULT NULL,
  `photo_3_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_3_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_3_file_size` int(11) unsigned DEFAULT NULL,
  `photo_3_updated_at` datetime DEFAULT NULL,
  `photo_4_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_4_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_4_file_size` int(11) unsigned DEFAULT NULL,
  `photo_4_updated_at` datetime DEFAULT NULL,
  `photo_5_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_5_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_5_file_size` int(11) unsigned DEFAULT NULL,
  `photo_5_updated_at` datetime DEFAULT NULL,
  `photo_6_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_6_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_6_file_size` int(11) unsigned DEFAULT NULL,
  `photo_6_updated_at` datetime DEFAULT NULL,
  `vimeo_video_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `instructor_1_id` int(11) DEFAULT NULL,
  `instructor_2_id` int(11) DEFAULT NULL,
  `instructor_3_id` int(11) DEFAULT NULL,
  `instructor_4_id` int(11) DEFAULT NULL,
  `visible` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `youtube_video_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workshops`
--

LOCK TABLES `workshops` WRITE;
/*!40000 ALTER TABLE `workshops` DISABLE KEYS */;
/*!40000 ALTER TABLE `workshops` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-05-26  4:22:51
