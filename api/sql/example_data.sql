-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 31, 2025 at 09:55 PM
-- Server version: 10.6.20-MariaDB-cll-lve-log
-- PHP Version: 8.1.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `proudout_qsapp`
--

-- --------------------------------------------------------

--
-- Table structure for table `content_notes`
--

CREATE TABLE `content_notes` (
  `id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `content_notes`
--

INSERT INTO `content_notes` (`id`, `title`) VALUES
('1a', 'Krieg – guerre'),
('1b', 'Folter – torture'),
('1c', 'Brutale Handlungen, physisch und psychisch - actes brutaux, physiques ou psychiques'),
('1d', 'Verstümmelung – mutilations'),
('1e', 'Mord – meurtre'),
('1f', 'Sexualisierte Gewalt – violence sexualisée'),
('2a', 'Erkrankungen, physisch und psychisch maladies, physiques ou psychiques'),
('2b', 'Sucht / Substanzmissbrauch – dépendance / abus de substances'),
('2c', 'Manipulation – manipulation'),
('2d', 'Selbstverletzung / Suizid – automutilation / suicide'),
('2e', 'Sexualisierte Gewalt – violence sexualisée'),
('2f', 'Sexuell explizite Szenen – scènes sexuellement explicites'),
('2g', 'Pädokriminalität – pédocriminalité'),
('2h', 'Verstümmelung (z. B. bei intergeschlechtlichen Menschen) - mutilation (par ex. chez les personnes intersexuées)'),
('2i', 'Drogenkonsum – consommation de drogues'),
('3a', 'Sexismus – sexisme'),
('3b', 'Rassismus – racisme'),
('3c', 'Ableismus (physisch / psychisch) – validisme'),
('3d', 'Trans- und Queerfeindlichkeit – transphobie et queerphobie'),
('3e', 'Homo- und Bi-Feindlichkeit – homophobie et biphobie'),
('3f', 'Fettfeindlichkeit – grossophobie'),
('3g', 'Ageismus – âgisme'),
('3h', 'Klassismus – classicisme'),
('3i', 'Interfeindlichkeit – interphobie'),
('4', 'Strobo'),
('5', 'Kindertauglich (U12) - convient aux enfants (moins de 12 ans)');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `imageURL` varchar(255) DEFAULT NULL,
  `locationID` varchar(36) DEFAULT NULL,
  `weblink` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`id`, `title`, `description`, `date`, `imageURL`, `locationID`, `weblink`) VALUES
('evt1', 'Queersicht Party', 'Dieses Jahr tanzen wir im Stellwerk! Dich erwartet eine Nacht voller Tanz, Rhythmus und Queer Joy. Lass dir das nicht entgehen, schnapp dir deine Liebsten und feiere mit uns! Das feurige Line-up hat für alle etwas dabei.\nMöchtest du für den Weg vom Bahnhof zum Stellwerk Begleitung haben? Melde dich bei uns: events@queersicht.ch (vorgesehene Zeitpunkte: 23.00 Uhr und 24.00 Uhr).\n\nLineup:\nthe.last.zebra\nKobra\ndibbasey\ntigerdisco', '2025-11-07 17:00:00', 'https://example.com/uploads/events/thumb/688b6102c6d47_smaller_friends-celebrating-at-a-birthday-party-2025-02-09-23-20-21-utc.jpeg', 'loc3', 'https://example.com/events/opening'),
('evt2', 'Quiz', 'Messe dich mit den schärfsten Geistern und den hellsten Kerzen aus der Community. Im fabulösen Queersicht-Quiz dreht sich alles um queere Filme, Popkultur und viel unnützes und unnötiges Wissen. Gespielt wird allein oder in Teams von bis zu drei Personen. Durch den Abend führt die stets erheiternde Nella Pecorella mit ihrer Quiz-Crew.\n\nDie Moderation findet in Mundart statt, die Fragen und Texte sind alle Deutsch.', '2025-11-08 13:00:00', 'https://example.com/uploads/events/thumb/6883e26091e87_nella.jpg', 'loc2', 'https://example.com/events/talk'),
('evt3', 'Brunch', 'Trommle deine Lieblingsmenschen zusammen, komm am 10.11.2024 ins Du Nord und iss dich durch die vegane bis fleischige Karte – der perfekte Start in den Festival-Sonntag.\n\nZeiten: 9:30 – 12:30 oder 13:00 – 15:30\nPreis: CHF 34 exkl. Getränke\nGut zu wissen: Reservier dir deinen Platz direkt über www.du-nord.ch – Reservation empfohlen!', '2025-11-10 18:00:00', 'https://example.com/uploads/events/thumb/688b60c3ab550_smaller_group-of-hands-sharing-food-and-drink-caucasian-p-2024-11-02-23-36-34-utc.jpeg', 'loc3', 'https://example.com/events/closing');

-- --------------------------------------------------------

--
-- Table structure for table `locations`
--

CREATE TABLE `locations` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` text DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `accessibilityInfo` text DEFAULT NULL,
  `imageURL` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `locations`
--

INSERT INTO `locations` (`id`, `name`, `address`, `latitude`, `longitude`, `accessibilityInfo`, `imageURL`, `description`) VALUES
('loc1', 'Kino ABC', 'Moserstrasse 24, 3014 Bern', 46.957008, 7.45302, 'Wheelchair accessible, elevator available', 'https://example.com/uploads/locations/thumb/688b5dee4fb7a_Screenshot 2025-07-31 at 14.12.52.jpg', 'Historic cinema in the heart of Bern'),
('loc2', 'Kino REX', 'Schwanengasse 9, 3011 Bern', 46.946678, 7.43932, 'Wheelchair accessible', 'https://example.com/uploads/locations/thumb/6877cd36a292f_6877cced90575_581d9b0c-709a-4cae-a8fe-ffb9f67a81d5.jpeg', 'Modern cinema with state-of-the-art projection'),
('loc3', 'Progr', 'Waisenhausplatz 30, 3011 Bern', 46.95015, 7.44387, 'Limited accessibility', 'https://example.com/uploads/locations/progr.jpg', 'Cultural center hosting various events');

-- --------------------------------------------------------

--
-- Table structure for table `movies`
--

CREATE TABLE `movies` (
  `id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description_de` text DEFAULT NULL,
  `description_fr` text DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `imageURL` varchar(255) DEFAULT NULL,
  `director` varchar(255) DEFAULT NULL,
  `originlang` varchar(50) DEFAULT NULL,
  `trailerURL` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `movies`
--

INSERT INTO `movies` (`id`, `title`, `description_de`, `description_fr`, `duration`, `imageURL`, `director`, `originlang`, `trailerURL`) VALUES
('1b4e28ba-2fa1-11e9-b210-d663bd873d93', 'Chrissy Judy', 'Eine herzerwärmende Geschichte über zwei Drag Queens in New York, die ihre Freundschaft und Karriere in Balance halten müssen. Als Judy eine große Chance bekommt, muss Chrissy lernen, alleine zurechtzukommen.', 'Une histoire touchante de deux drag queens à New York qui doivent équilibrer leur amitié et leur carrière. Quand Judy obtient une grande opportunité, Chrissy doit apprendre à se débrouiller seule.', 96, 'https://example.com/uploads/movies/thumb/687d47fe5dc64_IMG_2803.jpeg', 'Todd Flaherty', 'Englisch', 'https://youtu.be/qN0WwsCbMjY?si=K0RB8vw-eMc7iXBs'),
('1b4e2932-2fa1-11e9-b210-d663bd873d93', 'Kokomo City', 'Ein bahnbrechender Dokumentarfilm, der das Leben von vier schwarzen trans Sexarbeiterinnen in den USA beleuchtet. Der Film bietet einen intimen Einblick in ihre Realität, Kämpfe und Triumphe.', 'Un documentaire révolutionnaire qui met en lumière la vie de quatre travailleuses du sexe trans noires aux États-Unis. Le film offre un aperçu intime de leur réalité, leurs luttes et leurs triomphes.', 73, 'https://example.com/uploads/movies/thumb/68795d3a55b9b_Kokomo City.jpg', 'D. Smith', 'Englisch', NULL),
('1b4e2a3c-2fa1-11e9-b210-d663bd873d93', 'Norwegian Dream', 'Ein junger polnischer Einwanderer findet Arbeit in einer norwegischen Fischfabrik und entdeckt nicht nur eine neue Heimat, sondern auch eine unerwartete Liebe, die sein Leben verändert.', 'Un jeune immigrant polonais trouve du travail dans une usine de poisson norvégienne et découvre non seulement un nouveau foyer, mais aussi un amour inattendu qui change sa vie.', 97, 'https://example.com/uploads/movies/thumb/68795d7f155fb_Norwegian Dream.jpg', 'Leiv Igor Devold', 'Englisch, Norwegisch, Polnisch', NULL),
('1b4e2b36-2fa1-11e9-b210-d663bd873d93', 'Le paradis', 'In einem belgischen Jugendgefängnis entwickelt sich zwischen zwei jungen Männern eine verbotene Romanze. Eine bewegende Geschichte über Liebe, Freiheit und die Suche nach Identität.', 'Dans une prison pour mineurs belge, une romance interdite se développe entre deux jeunes hommes. Une histoire émouvante sur l&#039;amour, la liberté et la quête d&#039;identité.', 83, 'https://example.com/uploads/movies/thumb/68795d85d00df_Le paradis.jpg', 'Zeno Graton', 'Französisch', NULL),
('1b4e2c1c-2fa1-11e9-b210-d663bd873d93', 'Transfariana', 'Eine fesselnde Dokumentation über die LGBTQ+-Bewegung in Kolumbien und deren Kampf für Gleichberechtigung. Der Film zeigt die Verbindung zwischen politischem Aktivismus und persönlichen Geschichten.', 'Un documentaire captivant sur le mouvement LGBTQ+ en Colombie et sa lutte pour l&#039;égalité. Le film montre le lien entre l&#039;activisme politique et les histoires personnelles.', 153, 'https://example.com/uploads/movies/thumb/6878139ebf924_Transfariana.jpg', 'Joris Lachaise', 'Spanisch', NULL),
('1b4e2cf8-2fa1-11e9-b210-d663bd873d93', 'Venuseffekten', 'Eine charmante dänische Komödie über eine junge Frau, die ihre Sexualität entdeckt und lernt, zu sich selbst zu stehen. Eine Geschichte über Selbstakzeptanz, Familie und die Kraft der Liebe.', 'Une charmante comédie danoise sur une jeune femme qui découvre sa sexualité et apprend à s&#039;assumer. Une histoire sur l&#039;acceptation de soi, la famille et le pouvoir de l&#039;amour.', 105, 'https://example.com/uploads/movies/thumb/68795d937a776_Venuseffekten.jpg', 'Anna Emma Haudal', 'Dänisch', NULL),
('1b4e2dde-2fa1-11e9-b210-d663bd873d93', 'Soft', 'Ein einfühlsames Drama über einen jungen Drag-Performer in Toronto, der zwischen seiner queeren Identität und den Erwartungen seiner philippinischen Familie navigiert.', 'Un drame sensible sur un jeune performeur drag à Toronto qui navigue entre son identité queer et les attentes de sa famille philippine.', 87, 'https://example.com/uploads/movies/thumb/687d484c339fb_IMG_2804.jpeg', 'Joseph Amenta', 'Englisch, Tagalog', NULL),
('1b4e2eb0-2fa1-11e9-b210-d663bd873d93', 'O Acidente', 'Nach einem mysteriösen Unfall muss sich eine Frau ihrer Vergangenheit und ihren unterdrückten Gefühlen stellen. Ein brasilianisches Drama über Trauma, Heilung und verborgene Wahrheiten.', 'Après un accident mystérieux, une femme doit faire face à son passé et à ses sentiments refoulés. Un drame brésilien sur le trauma, la guérison et les vérités cachées.', 95, 'https://example.com/uploads/movies/thumb/687e6708884dc_queerlisboa-o-acidente-critica.jpg', 'Bruno Carboni', 'Portugiesisch', NULL),
('1b4e2f82-2fa1-11e9-b210-d663bd873d93', 'Out of Uganda', 'Eine kraftvolle Dokumentation über LGBTQ+-Flüchtlinge aus Uganda, die in der Schweiz Asyl suchen. Der Film zeigt ihre Geschichten von Verfolgung, Hoffnung und dem Kampf um ein neues Leben.', 'Un documentaire puissant sur les réfugiés LGBTQ+ d\'Ouganda cherchant l\'asile en Suisse. Le film montre leurs histoires de persécution, d\'espoir et de lutte pour une nouvelle vie.', 65, 'https://example.com/uploads/movies/thumb/687e674ff0f60_OUT_OF_UGANDA_STILLS_OUTPLAY-1-scaled.jpg', 'Rolando Colla and Josef Burri', 'Französisch Englisch', NULL),
('1b4e3054-2fa1-11e9-b210-d663bd873d93', 'CorPolitica', 'Ein faszinierender Einblick in die brasilianische LGBTQ+-Politik und den Kampf für Repräsentation. Der Film dokumentiert den Weg queerer Kandidat:innen im politischen System.', 'Un aperçu fascinant de la politique LGBTQ+ brésilienne et de la lutte pour la représentation. Le film documente le parcours des candidat·e·s queer dans le système politique.', 102, 'https://example.com/uploads/movies/thumb/687e676fafa34_corpolitica-imagem-2022jpg.jpeg', 'Pedro Henrique França', 'Portugiesisch', NULL),
('1b4e313a-2fa1-11e9-b210-d663bd873d93', 'Silver Haze', 'In den Straßen Londons sucht eine junge Krankenschwester nach Antworten und findet dabei unerwartete Verbindungen. Eine Geschichte über Heilung, Identität und die Kraft der Gemeinschaft.', 'Dans les rues de Londres, une jeune infirmière cherche des réponses et trouve des connexions inattendues. Une histoire sur la guérison, l\'identité et le pouvoir de la communauté.', 102, 'https://example.com/uploads/movies/thumb/687e678c97d11_446066.jpg', 'Sacha Polak', 'Englisch', NULL),
('1b4e321c-2fa1-11e9-b210-d663bd873d93', 'Passages', 'Ein intensives Drama über eine komplexe Dreiecksbeziehung in Paris. Der Film erforscht die Grenzen von Liebe, Begehren und die Folgen unserer Entscheidungen.', 'Un drame intense sur une relation triangulaire complexe à Paris. Le film explore les limites de l\'amour, du désir et les conséquences de nos choix.', 91, 'https://example.com/uploads/movies/thumb/687e680635f41_passages.jpg', 'Ira Sachs', 'Englisch Französisch', NULL),
('1b4e32f8-2fa1-11e9-b210-d663bd873d93', 'Lotus Sports Club', 'Eine inspirierende Dokumentation über einen LGBTQ+-freundlichen Sportverein in Kambodscha. Der Film zeigt, wie Sport Vorurteile überwinden und Gemeinschaften stärken kann.', 'Un documentaire inspirant sur un club de sport LGBTQ+ au Cambodge. Le film montre comment le sport peut surmonter les préjugés et renforcer les communautés.', 72, 'https://example.com/uploads/movies/thumb/687e69dfeaf7e_LOTUS_SPORTS_CLUB_05-3000x1837.jpg', 'Vanna Hem & Tommaso Colognese', 'Khmer', NULL),
('1b4e33de-2fa1-11e9-b210-d663bd873d93', 'Bis ans Ende der Nacht', 'Ein atmosphärischer Thriller über eine Polizistin, die undercover in der Berliner Clubszene ermittelt. Der Film vermischt gekonnt Spannung mit einer komplexen Liebesgeschichte.', 'Un thriller atmosphérique sur une policière qui enquête sous couverture dans la scène des clubs berlinois. Le film mélange habilement suspense et histoire d\'amour complexe.', 120, 'https://example.com/uploads/movies/thumb/687e68ada8cd7_Bis ans Ende der Nacht.jpeg', 'Christoph Hochhäusler', 'Deutsch', NULL),
('1b4e34b0-2fa1-11e9-b210-d663bd873d93', 'Knochen und Namen', 'Ein intimes Porträt einer sich entwickelnden Beziehung in Berlin. Der Film erkundet die Komplexität moderner Beziehungen und die Suche nach authentischer Verbindung.', 'Un portrait intime d\'une relation en développement à Berlin. Le film explore la complexité des relations modernes et la recherche de connexions authentiques.', 104, 'https://example.com/uploads/movies/thumb/687e699e275b9_Knochen und Namen.jpeg', 'Fabian Stumm', 'Deutsch, Französisch', NULL),
('1b4e3582-2fa1-11e9-b210-d663bd873d93', 'Captain Faggotron Saves The Universe', 'Eine wilde, queere Science-Fiction-Komödie über einen unwahrscheinlichen Superhelden. Mit viel Humor und Herz kämpft Captain Faggotron gegen Vorurteile und rettet nebenbei das Universum.', 'Une comédie de science-fiction queer et délirante sur un super-héros improbable. Avec beaucoup d\'humour et de cœur, Captain Faggotron combat les préjugés tout en sauvant l\'univers.', 75, 'https://example.com/uploads/movies/thumb/687e6953d527e_Captain Faggotron Saves The Universe.jpeg', 'Harvey Rabbit', 'Englisch', NULL),
('1b4e3654-2fa1-11e9-b210-d663bd873d93', 'Blue Jean', 'Im England der 1980er Jahre kämpft eine Lehrerin mit ihrer Identität während der Einführung diskriminierender Gesetze. Ein bewegendes Drama über persönlichen und politischen Mut.', 'Dans l\'Angleterre des années 1980, une enseignante lutte avec son identité pendant l\'introduction de lois discriminatoires. Un drame émouvant sur le courage personnel et politique.', 97, 'https://example.com/uploads/movies/thumb/687e68efef950_BlueJean.jpeg', 'Georgia Oakley', 'Englisch', NULL),
('1b4e3726-2fa1-11e9-b210-d663bd873d93', 'Elephant', 'In den polnischen Bergen entdeckt ein junger Mann seine wahren Gefühle. Eine sensible Geschichte über erste Liebe, familiäre Erwartungen und den Mut, zu sich selbst zu stehen.', 'Dans les montagnes polonaises, un jeune homme découvre ses vrais sentiments. Une histoire sensible sur le premier amour, les attentes familiales et le courage d\'être soi-même.', 94, NULL, 'Kamil Krawczycki', 'Polnisch', NULL),
('1b4e37f8-2fa1-11e9-b210-d663bd873d93', 'Arrête avec tes mensonges', 'Ein berührendes französisches Drama über einen Schriftsteller, der sich seiner ersten Liebe und den Lügen seiner Vergangenheit stellen muss. Eine Geschichte über Wahrheit und Versöhnung.', 'Un drame français touchant sur un écrivain qui doit faire face à son premier amour et aux mensonges de son passé. Une histoire sur la vérité et la réconciliation.', 98, NULL, 'Olivier Peyon', 'Französisch Englisch', NULL),
('1b4e38ca-2fa1-11e9-b210-d663bd873d93', 'Orlando, ma biographie politique', 'Eine faszinierende Dokumentation über Gender-Identität, inspiriert von Virginia Woolfs \'Orlando\'. Der Film verbindet persönliche Erfahrungen mit philosophischen Betrachtungen.', 'Un documentaire fascinant sur l\'identité de genre, inspiré par \'Orlando\' de Virginia Woolf. Le film mêle expériences personnelles et réflexions philosophiques.', 98, NULL, 'Paul B. Preciado', 'Französisch', NULL),
('1b4e399c-2fa1-11e9-b210-d663bd873d93', 'Breaking the Ice', 'Ein österreichisches Drama über eine professionelle Eishockeyspielerin, die zwischen sportlichem Erfolg und ihrer erwachenden Liebe zu einer Teamkollegin navigieren muss.', 'Un drame autrichien sur une joueuse de hockey professionnelle qui doit naviguer entre le succès sportif et son amour naissant pour une coéquipière.', 101, NULL, 'Clara Stern', NULL, NULL),
('1b4e3a6e-2fa1-11e9-b210-d663bd873d93', 'Queer Glauben', 'Eine aufschlussreiche Dokumentation über queere Gläubige in der Schweiz. Der Film zeigt ihre persönlichen Geschichten und den Weg zur Versöhnung von Glauben und Identität.', 'Un documentaire révélateur sur les croyants queer en Suisse. Le film montre leurs histoires personnelles et le chemin vers la réconciliation entre foi et identité.', 59, NULL, 'Madeleine Corbat', 'Schweizerdeutsch', NULL),
('1b4e3b40-2fa1-11e9-b210-d663bd873d93', 'All The Silence', 'Ein eindringliches mexikanisches Drama über das Schweigen und seine Folgen. Der Film erkundet die unausgesprochenen Wahrheiten in einer Familie und den Weg zur Heilung.', 'Un drame mexicain poignant sur le silence et ses conséquences. Le film explore les vérités non dites dans une famille et le chemin vers la guérison.', 78, NULL, 'Diego del Río', 'Spanisch', NULL),
('1b4e3c12-2fa1-11e9-b210-d663bd873d93', 'I Am They', 'Eine bahnbrechende Dokumentation über nicht-binäre Identitäten. Der Film folgt verschiedenen Menschen auf ihrer Reise zur Selbstfindung und zeigt die Vielfalt geschlechtlicher Identität.', 'Un documentaire novateur sur les identités non binaires. Le film suit différentes personnes dans leur voyage de découverte de soi et montre la diversité de l\'identité de genre.', 61, NULL, 'Fox & Owl', 'Englisch', NULL),
('1b4e3ce4-2fa1-11e9-b210-d663bd873d93', 'Triple Oh!', 'Eine kraftvolle australische Kurzdokumentation über queere Rettungskräfte. Der Film zeigt ihren Alltag, ihre Herausforderungen und wie sie Leben retten, während sie ihre Identität leben.', 'Un court documentaire australien puissant sur les secouristes queer. Le film montre leur quotidien, leurs défis et comment ils sauvent des vies tout en vivant leur identité.', 41, NULL, 'Poppy Stockell', 'Englisch', NULL),
('1b4e3db6-2fa1-11e9-b210-d663bd873d93', 'La amiga de mi amiga', 'Eine charmante spanische Komödie über Freundschaft, Liebe und die Komplexität moderner Beziehungen. Der Film spielt mit Rom-Com-Konventionen und bietet eine frische queere Perspektive.', 'Une charmante comédie espagnole sur l\'amitié, l\'amour et la complexité des relations modernes. Le film joue avec les conventions des rom-coms et offre une perspective queer fraîche.', 85, NULL, 'Zaida Carmona', 'Spanisch', NULL),
('1b4e3e88-2fa1-11e9-b210-d663bd873d93', 'Trois nuits par semaine', 'Eine mitreißende französische Geschichte über einen jungen Mann, der in die Welt des Drag eintaucht. Der Film zeigt seine Transformation und die Entdeckung einer neuen Familie.', 'Une histoire française captivante sur un jeune homme qui plonge dans le monde du drag. Le film montre sa transformation et la découverte d\'une nouvelle famille.', 103, NULL, 'Florent Gouëlou', 'Französisch', NULL),
('1b4e3f5a-2fa1-11e9-b210-d663bd873d93', 'Sweetheart', 'Eine herzerwärmende britische Coming-of-Age-Geschichte über ein Mädchen, das während eines Familienurlaubs erste Gefühle entwickelt. Ein sensibler Film über Selbstentdeckung und erste Liebe.', 'Une histoire britannique touchante sur une jeune fille qui développe ses premiers sentiments pendant des vacances en famille. Un film sensible sur la découverte de soi et le premier amour.', 103, NULL, 'Marley Morrison', 'Englisch', NULL),
('562afd75-be5c-4a3a-822e-6b4096066ac2', 'KURZFILMBLOCK 2 | COURT MÉTRAGES BLOC 2', 'MANTING | China 2023 | Chinesisch (Deutsch, Englisch) | 15 Min. | Shuyao Chen\n\nSEAHORSE PARENTS | Niederlande 2023 | Englisch, Niederländisch (Deutsch, Englisch) | 10 Min. | Miriam Guttmann\n\nCARROTICA | Deutschland 2024 | Englisch (Deutsch) | 13 Min. | Daniel Sterlin-Altman\n\nROSES | UK 2023 | Englisch (Deutsch) | 16 Min. | Coral Knights\n\nTHE FIRST KISS | Spanien 2023 | Spanisch (Deutsch, Englisch) | 15 Min.  | Miguel Lafuente\n\nTHE SCRIPT | Vereinigte Staaten 2023 | Englisch (Deutsch) | 15 Min.  | Brit Fryer, Noah Schamus\n\nRIPE! | Spanien 2023 | Englisch, Spanisch (Deutsch) | 18 Min. | Tusk', 'MANTING | Chine 2023 | chinois (allemand, anglais) | 15 min. | Shuyao Chen\n\nSEAHORSE PARENTS | Pays-Bas 2023 | anglais, néerlandais (allemand, anglais) | 10 min. | Miriam Guttmann\n\nCARROTICA | Allemagne 2024 | anglais (allemand) | 13 min. | Daniel Sterlin-Altman\n\nROSES | UK 2023 | anglais (allemand) | 16 min. | Coral Knights\n\nTHE FIRST KISS | panie 2023 | espagnol (allemand, anglais) | 15 min. | Miguel Lafuente\n\nTHE SCRIPT | USA 2023 | anglais (allemand) | 15 min. | Brit Fryer, Noah Schamus\n\nRIPE ! | Espagne 2023 | anglais, espagnol (allemand) | 18 min. | Tusk', 100, 'https://example.com/uploads/movies/thumb/687d447c475aa_short2.jpg', NULL, NULL, NULL),
('9891f321-8f0f-47fb-839e-f9b6d6daafd9', 'KURZFILMBLOCK 1 | COURT MÉTRAGES BLOC 1', 'THE TALENT | UK 2023 | Englisch (Deutsch) | 15 Min. | Thomas May Bailey\n\nLA CASQUETTE | Frankreich 2022 | Französisch (Deutsch, Englisch) | 4 Min. | Hadi Moussally\n\nSEAGULLS CUT THROUGH THE SKY | Portugal 2023 | Portugiesisch (Deutsch, Englisch) | 18 Min. | Mariana Bártolo, Guillermo García López\n\nACCOMPAGNÉ | Frankreich 2023 | Französisch (Deutsch, Englisch) | 3 Min. | Liam Laurenti\n\nGOOD BOY | UK 2023 | Englisch (Deutsch) | 16 Min. | Tom Stuart\n\nMNM | Vereinigte Staaten 2023 | Englisch (Deutsch) | 15 Min. | Twiggy Pucci Garçon\n\nF**KED | UK 2023 | Englisch (Deutsch) | 6 Min. | Sara Harrak\n\nBUST | Vereinigte Staaten 2024 | Englisch (Deutsch) | 10 Min. | Angalis Field\n\nYOUR SCISSORS NEAR MY EARS | Spanien 2023 | Spanisch (Deutsch, Englisch) | 12 Min. | Carlos Ruano', 'THE TALENT | UK 2023 | anglais (allemand) | 15 min. | Thomas May Bailey\n\nLA CASQUETTE | France 2022 | français (allemand, anglais) | 4 min. | Hadi Moussally\n\nSEAGULLS CUT THROUGH THE SKY | Portugal 2023 | portugais (allemand, anglais) | 18 min. | Mariana Bártolo, Guillermo García López\n\nACCOMPAGNÉ | France 2023 | français (allemand, anglais) | 3 min. | Liam Laurenti\n\nGOOD BOY | UK 2023 | anglais (allemand) | 16 min. | Tom Stuart\n\nMNM | USA 2023 | anglais (allemand) | 15 min. | Twiggy Pucci Garçon\n\nF**KED | UK 2023 | anglais (allemand) | 6 min. | Sara Harrak\n\nBUST | USA 2024 | anglais (allemand) | 10 min. | Angalis Field\n\nYOUR SCISSORS NEAR MY EARS | Espagne 2023 | espagnol (allemand, anglais) | 12 min. | Carlos Ruano\n', 100, 'https://example.com/uploads/movies/thumb/687972f8b6349_short1.jpg', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `movie_content_notes`
--

CREATE TABLE `movie_content_notes` (
  `movie_id` varchar(36) NOT NULL,
  `content_note_id` varchar(36) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `movie_content_notes`
--

INSERT INTO `movie_content_notes` (`movie_id`, `content_note_id`) VALUES
('1b4e28ba-2fa1-11e9-b210-d663bd873d93', '1f'),
('1b4e28ba-2fa1-11e9-b210-d663bd873d93', '3g'),
('1b4e2932-2fa1-11e9-b210-d663bd873d93', '1f'),
('1b4e2932-2fa1-11e9-b210-d663bd873d93', '2h'),
('1b4e2932-2fa1-11e9-b210-d663bd873d93', '3i'),
('1b4e2932-2fa1-11e9-b210-d663bd873d93', '5'),
('562afd75-be5c-4a3a-822e-6b4096066ac2', '1b'),
('562afd75-be5c-4a3a-822e-6b4096066ac2', '2c'),
('562afd75-be5c-4a3a-822e-6b4096066ac2', '3d'),
('9891f321-8f0f-47fb-839e-f9b6d6daafd9', '1b'),
('9891f321-8f0f-47fb-839e-f9b6d6daafd9', '1e'),
('9891f321-8f0f-47fb-839e-f9b6d6daafd9', '2b'),
('9891f321-8f0f-47fb-839e-f9b6d6daafd9', '2i'),
('9891f321-8f0f-47fb-839e-f9b6d6daafd9', '3c');

-- --------------------------------------------------------

--
-- Table structure for table `showings`
--

CREATE TABLE `showings` (
  `id` varchar(36) NOT NULL,
  `date` datetime DEFAULT NULL,
  `locationID` varchar(36) DEFAULT NULL,
  `weblink` varchar(255) DEFAULT NULL,
  `movieID` varchar(36) DEFAULT NULL,
  `eventID` varchar(36) DEFAULT NULL,
  `special_info` text DEFAULT NULL COMMENT 'Special information about the showing (e.g. "Mit Regisseur*in", "Podiumsdiskussion")'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `showings`
--

INSERT INTO `showings` (`id`, `date`, `locationID`, `weblink`, `movieID`, `eventID`, `special_info`) VALUES
('2196e505-1db5-4bf9-b11f-5e9c3f4b028e', '2025-11-06 22:28:00', 'loc1', NULL, '1b4e2a3c-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('3de3dc36-e8de-46f0-9c10-be3782a5e2d5', '2025-11-06 21:34:00', 'loc1', NULL, '562afd75-be5c-4a3a-822e-6b4096066ac2', NULL, NULL),
('6500dc08-f885-4c55-be1b-77cdd6b21403', '2025-11-07 23:27:00', 'loc3', NULL, '562afd75-be5c-4a3a-822e-6b4096066ac2', NULL, NULL),
('81660cc3-cf04-45ba-907d-9e93e04907c3', '2025-11-07 00:02:00', 'loc1', NULL, '9891f321-8f0f-47fb-839e-f9b6d6daafd9', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d479', '2025-11-08 18:30:00', 'loc2', NULL, '1b4e28ba-2fa1-11e9-b210-d663bd873d93', NULL, 'Mit Regisseur*in'),
('f47ac10b-58cc-4372-a567-0e02b2c3d480', '2025-11-08 20:45:00', 'loc1', NULL, '1b4e2932-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d481', '2025-11-09 16:15:00', 'loc2', NULL, '1b4e2a3c-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d482', '2025-11-09 18:30:00', 'loc1', NULL, '1b4e2b36-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d483', '2025-11-09 20:45:00', 'loc3', NULL, '1b4e2c1c-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d484', '2025-11-09 14:00:00', 'loc2', NULL, '1b4e2cf8-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d485', '2025-11-11 16:15:00', 'loc1', NULL, '1b4e2dde-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d486', '2025-11-11 18:30:00', 'loc3', NULL, '1b4e2eb0-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d487', '2025-11-11 20:45:00', 'loc2', NULL, '1b4e2f82-2fa1-11e9-b210-d663bd873d93', NULL, 'Podiumsdiskussion zum Thema LGBTQ+ Rechte in Uganda'),
('f47ac10b-58cc-4372-a567-0e02b2c3d488', '2025-11-12 14:00:00', 'loc1', NULL, '1b4e3054-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d489', '2025-11-07 16:15:00', 'loc3', NULL, '1b4e313a-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d490', '2025-11-08 18:30:00', 'loc2', NULL, '1b4e321c-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d491', '2025-11-06 20:45:00', 'loc1', NULL, '1b4e32f8-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d492', '2025-11-06 18:30:00', 'loc2', NULL, '1b4e33de-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d493', '2025-11-10 20:45:00', 'loc3', NULL, '1b4e34b0-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d494', '2025-11-10 18:30:00', 'loc1', NULL, '1b4e3582-2fa1-11e9-b210-d663bd873d93', NULL, NULL),
('f47ac10b-58cc-4372-a567-0e02b2c3d495', '2025-11-10 20:45:00', 'loc2', NULL, '1b4e3654-2fa1-11e9-b210-d663bd873d93', NULL, 'Filmgespräch mit Hauptdarsteller*in und Filmteam');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `content_notes`
--
ALTER TABLE `content_notes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `locations`
--
ALTER TABLE `locations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `movies`
--
ALTER TABLE `movies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `movie_content_notes`
--
ALTER TABLE `movie_content_notes`
  ADD PRIMARY KEY (`movie_id`,`content_note_id`),
  ADD KEY `content_note_id` (`content_note_id`);

--
-- Indexes for table `showings`
--
ALTER TABLE `showings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `locationID` (`locationID`),
  ADD KEY `movieID` (`movieID`),
  ADD KEY `eventID` (`eventID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `movie_content_notes`
--
ALTER TABLE `movie_content_notes`
  ADD CONSTRAINT `movie_content_notes_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`id`),
  ADD CONSTRAINT `movie_content_notes_ibfk_2` FOREIGN KEY (`content_note_id`) REFERENCES `content_notes` (`id`);

--
-- Constraints for table `showings`
--
ALTER TABLE `showings`
  ADD CONSTRAINT `showings_ibfk_1` FOREIGN KEY (`locationID`) REFERENCES `locations` (`id`),
  ADD CONSTRAINT `showings_ibfk_2` FOREIGN KEY (`movieID`) REFERENCES `movies` (`id`),
  ADD CONSTRAINT `showings_ibfk_3` FOREIGN KEY (`eventID`) REFERENCES `events` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
