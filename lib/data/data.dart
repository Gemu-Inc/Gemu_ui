import 'package:Gemu/models/clan_model.dart';
import 'package:Gemu/models/models.dart';
import 'package:Gemu/screens/screens.dart';

final User currentUser = User(
  name: '0ruj',
  imageProfil: 'img/Lelouch.png',
  imageBanniere: 'img/Lelouch_appbar.png',
);

final List<CategoriePost> categoriePosts = [
  CategoriePost(idCategorie: 01, name: 'Général', selected: true),
  CategoriePost(idCategorie: 02, name: 'Blague', selected: true),
  CategoriePost(idCategorie: 03, name: 'Aide', selected: true),
  CategoriePost(idCategorie: 04, name: 'Leak', selected: true),
  CategoriePost(idCategorie: 05, name: 'Débat', selected: true),
  CategoriePost(idCategorie: 06, name: 'Evénement', selected: true),
  CategoriePost(idCategorie: 07, name: 'Compétition', selected: true)
];

final List<Post> posts = [
  Post(
    user: currentUser,
    caption: 'Check out these cool puppers',
    timeAgo: '58m',
    imageUrl: 'https://images.unsplash.com/photo-1525253086316-d0c936c814f8',
    videoUrl: null,
    likes: 1202,
    comments: 184,
    shares: 96,
  ),
  Post(
    user: currentUser,
    caption:
        'Please enjoy this placeholder text: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    timeAgo: '3hr',
    imageUrl: null,
    videoUrl: null,
    likes: 683,
    comments: 79,
    shares: 18,
  ),
  Post(
    user: currentUser,
    caption: 'Butterfly',
    timeAgo: '1d',
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    imageUrl: null,
    likes: 1689,
    shares: 129,
    comments: 1001,
  ),
  Post(
    user: currentUser,
    caption: 'This is a very good boy.',
    timeAgo: '8hr',
    imageUrl:
        'https://images.unsplash.com/photo-1575535468632-345892291673?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80',
    videoUrl: null,
    likes: 894,
    comments: 201,
    shares: 27,
  ),
  Post(
    user: currentUser,
    caption: 'Little bee',
    timeAgo: '3d',
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    imageUrl: null,
    likes: 1689,
    shares: 129,
    comments: 1001,
  ),
  Post(
    user: currentUser,
    caption: 'Adventure 🏔',
    timeAgo: '15hr',
    imageUrl:
        'https://images.unsplash.com/photo-1573331519317-30b24326bb9a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80',
    videoUrl: null,
    likes: 722,
    comments: 183,
    shares: 42,
  ),
  Post(
    user: currentUser,
    caption:
        'More placeholder text for the soul: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    timeAgo: '1d',
    videoUrl: null,
    imageUrl: null,
    likes: 482,
    comments: 37,
    shares: 9,
  ),
  Post(
    user: currentUser,
    caption: 'A classic.',
    timeAgo: '1d',
    videoUrl: null,
    imageUrl:
        'https://images.unsplash.com/reserve/OlxPGKgRUaX0E1hg3b3X_Dumbo.JPG?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80',
    likes: 1523,
    shares: 129,
    comments: 301,
  ),
  Post(
    user: currentUser,
    caption: 'Check out these cool puppers',
    timeAgo: '58m',
    imageUrl: 'https://images.unsplash.com/photo-1525253086316-d0c936c814f8',
    videoUrl: null,
    likes: 1202,
    comments: 184,
    shares: 96,
  ),
  Post(
    user: currentUser,
    caption:
        'Please enjoy this placeholder text: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    timeAgo: '3hr',
    imageUrl: null,
    videoUrl: null,
    likes: 683,
    comments: 79,
    shares: 18,
  ),
  Post(
    user: currentUser,
    caption: 'Butterfly',
    timeAgo: '1d',
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    imageUrl: null,
    likes: 1689,
    shares: 129,
    comments: 1001,
  ),
  Post(
    user: currentUser,
    caption: 'This is a very good boy.',
    timeAgo: '8hr',
    imageUrl:
        'https://images.unsplash.com/photo-1575535468632-345892291673?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80',
    videoUrl: null,
    likes: 894,
    comments: 201,
    shares: 27,
  ),
  Post(
    user: currentUser,
    caption: 'Little bee',
    timeAgo: '3d',
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    imageUrl: null,
    likes: 1689,
    shares: 129,
    comments: 1001,
  ),
  Post(
    user: currentUser,
    caption: 'Adventure 🏔',
    timeAgo: '15hr',
    imageUrl:
        'https://images.unsplash.com/photo-1573331519317-30b24326bb9a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80',
    videoUrl: null,
    likes: 722,
    comments: 183,
    shares: 42,
  ),
  Post(
    user: currentUser,
    caption:
        'More placeholder text for the soul: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    timeAgo: '1d',
    videoUrl: null,
    imageUrl: null,
    likes: 482,
    comments: 37,
    shares: 9,
  ),
  Post(
    user: currentUser,
    caption: 'A classic.',
    timeAgo: '1d',
    videoUrl: null,
    imageUrl:
        'https://images.unsplash.com/reserve/OlxPGKgRUaX0E1hg3b3X_Dumbo.JPG?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80',
    likes: 1523,
    shares: 129,
    comments: 301,
  )
];

final List<Clan> panelClans = [
  Clan(nameClan: 'Lay\'s', pointsClan: 4587, imageUrl: 'img/Lays.png'),
  Clan(nameClan: 'Orion', pointsClan: 2561, imageUrl: 'img/Orion.png'),
  Clan(nameClan: 'Tenryu', pointsClan: 6698, imageUrl: 'img/Tenryu.png'),
  Clan(nameClan: 'Lay\'s', pointsClan: 4587, imageUrl: 'img/Lays.png'),
  Clan(nameClan: 'Orion', pointsClan: 2561, imageUrl: 'img/Orion.png'),
  Clan(nameClan: 'Tenryu', pointsClan: 6698, imageUrl: 'img/Tenryu.png'),
  Clan(nameClan: 'Lay\'s', pointsClan: 4587, imageUrl: 'img/Lays.png'),
  Clan(nameClan: 'Orion', pointsClan: 2561, imageUrl: 'img/Orion.png'),
  Clan(nameClan: 'Tenryu', pointsClan: 6698, imageUrl: 'img/Tenryu.png'),
  Clan(nameClan: 'Lay\'s', pointsClan: 4587, imageUrl: 'img/Lays.png'),
  Clan(nameClan: 'Orion', pointsClan: 2561, imageUrl: 'img/Orion.png'),
  Clan(nameClan: 'Tenryu', pointsClan: 6698, imageUrl: 'img/Tenryu.png'),
  Clan(nameClan: 'Lay\'s', pointsClan: 4587, imageUrl: 'img/Lays.png'),
  Clan(nameClan: 'Orion', pointsClan: 2561, imageUrl: 'img/Orion.png'),
  Clan(nameClan: 'Tenryu', pointsClan: 6698, imageUrl: 'img/Tenryu.png'),
];

final List<Game> panelGames = [
  //Game(nameGame: 'Abo\'s', widget: MixScreen()),
  //Game(nameGame: 'Mix', widget: MixScreen()),
  Game(
      nameGame: 'Fortnite',
      widget: MixScreen(),
      imageUrl: 'img/logo_fortnite.jpg'),
  Game(
      nameGame: 'Fall Guys',
      widget: MixScreen(),
      imageUrl: 'img/logo_fall_guys.png'),
  Game(
      nameGame: 'Valorant',
      widget: MixScreen(),
      imageUrl: 'img/logo_valorant.png'),
  Game(
      nameGame: 'Formula One',
      widget: MixScreen(),
      imageUrl: 'img/FormulaOne.png'),
];

final List<Categorie> panelCategorie = [
  Categorie(idCategorie: 01, name: 'Action'),
  Categorie(idCategorie: 02, name: 'Anime'),
  Categorie(idCategorie: 03, name: 'Aventure'),
  Categorie(idCategorie: 04, name: 'Casual'),
  Categorie(idCategorie: 05, name: 'Fantasy'),
  Categorie(idCategorie: 06, name: 'Humour'),
  Categorie(idCategorie: 07, name: 'Indépendant'),
  Categorie(idCategorie: 08, name: 'Multijoueur'),
  Categorie(idCategorie: 09, name: 'RPG'),
  Categorie(idCategorie: 10, name: 'Simulation'),
  Categorie(idCategorie: 11, name: 'Solo'),
  Categorie(idCategorie: 12, name: 'Sport'),
  Categorie(idCategorie: 13, name: 'Stratégie'),
  Categorie(idCategorie: 14, name: 'Violence'),
  Categorie(idCategorie: 15, name: 'VR'),
  Categorie(idCategorie: 16, name: '2D'),
  Categorie(idCategorie: 17, name: 'Adulte'),
];
