import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/chat_message.dart';
import '../models/community_record.dart';
import '../models/listing.dart';
import '../models/order_record.dart';
import '../models/user_profile.dart';
import '../store/seed_data.dart';

class ListingRepository {
  static const _databaseName = 'retro_tech_marketplace.db';
  static const _databaseVersion = 3;
  static const _listingsTable = 'listings';
  static const _profileTable = 'profile';
  static const _savedItemsTable = 'saved_items';
  static const _ordersTable = 'orders';
  static const _sellerFollowsTable = 'seller_follows';
  static const _chatMessagesTable = 'chat_messages';
  static const _chatConversationStatesTable = 'chat_conversation_states';
  static const _communityPostLikesTable = 'community_post_likes';
  static const _communityRepliesTable = 'community_replies';
  static const _communityReplyLikesTable = 'community_reply_likes';

  Database? _database;

  Future<Database> get _db async {
    final existing = _database;
    if (existing != null) return existing;

    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      p.join(databasePath, _databaseName),
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
    _database = database;
    return database;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await _createListingsTable(db);
    await _createFeatureTables(db);
    await _seedListings(db);
    await _ensureDefaultProfile(db);
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createFeatureTables(db);
      await _ensureDefaultProfile(db);
    }
    if (oldVersion < 3) {
      await _createFeatureTables(db);
    }
  }

  Future<void> _createListingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_listingsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        condition TEXT NOT NULL,
        description TEXT NOT NULL,
        storage TEXT NOT NULL,
        battery TEXT NOT NULL,
        connector TEXT NOT NULL,
        imageAsset TEXT NOT NULL,
        status TEXT NOT NULL,
        views INTEGER NOT NULL,
        seller TEXT NOT NULL,
        rating REAL NOT NULL,
        reviews INTEGER NOT NULL,
        sortOrder INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _seedListings(Database db) async {
    final batch = db.batch();
    for (var index = 0; index < seedListings.length; index += 1) {
      batch.insert(_listingsTable, seedListings[index].toMap(sortOrder: index));
    }
    await batch.commit(noResult: true);
  }

  Future<void> _createFeatureTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_profileTable (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        displayName TEXT NOT NULL,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        bio TEXT NOT NULL,
        location TEXT NOT NULL,
        sellerName TEXT NOT NULL,
        preferredContact TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_savedItemsTable (
        listingId TEXT PRIMARY KEY,
        savedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_ordersTable (
        id TEXT PRIMARY KEY,
        listingId TEXT NOT NULL,
        listingTitle TEXT NOT NULL,
        seller TEXT NOT NULL,
        imageAsset TEXT NOT NULL,
        itemPrice REAL NOT NULL,
        shipping REAL NOT NULL,
        protectionFee REAL NOT NULL,
        paymentMethodId TEXT NOT NULL,
        paymentMethodTitle TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_sellerFollowsTable (
        seller TEXT PRIMARY KEY,
        followedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_chatMessagesTable (
        id TEXT PRIMARY KEY,
        conversationId TEXT NOT NULL,
        sellerName TEXT NOT NULL,
        listingId TEXT,
        text TEXT NOT NULL,
        mine INTEGER NOT NULL,
        imagePath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_chatConversationStatesTable (
        conversationId TEXT PRIMARY KEY,
        sellerName TEXT NOT NULL,
        listingId TEXT,
        blocked INTEGER NOT NULL,
        reported INTEGER NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_communityPostLikesTable (
        postId TEXT PRIMARY KEY,
        likedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_communityRepliesTable (
        id TEXT PRIMARY KEY,
        postId TEXT NOT NULL,
        user TEXT NOT NULL,
        handle TEXT NOT NULL,
        timeLabel TEXT NOT NULL,
        text TEXT NOT NULL,
        asset TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_communityReplyLikesTable (
        replyId TEXT PRIMARY KEY,
        likedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _ensureDefaultProfile(Database db) async {
    await db.insert(
      _profileTable,
      UserProfile.defaults.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Listing>> load() async {
    final db = await _db;
    final rows = await db.query(_listingsTable, orderBy: 'sortOrder ASC');
    return rows.map(Listing.fromMap).toList();
  }

  Future<void> add(Listing listing) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE $_listingsTable SET sortOrder = sortOrder + 1',
      );
      await txn.insert(_listingsTable, listing.toMap(sortOrder: 0));
    });
  }

  Future<void> update(Listing listing) async {
    final db = await _db;
    await db.update(
      _listingsTable,
      listing.toMap(),
      where: 'id = ?',
      whereArgs: [listing.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_listingsTable, where: 'id = ?', whereArgs: [id]);
    await db.delete(_savedItemsTable, where: 'listingId = ?', whereArgs: [id]);
  }

  Future<UserProfile> loadProfile() async {
    final db = await _db;
    await _ensureDefaultProfile(db);
    final rows = await db.query(_profileTable, limit: 1);
    return rows.isEmpty
        ? UserProfile.defaults
        : UserProfile.fromMap(rows.first);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final db = await _db;
    await db.insert(
      _profileTable,
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Set<String>> loadSavedItemIds() async {
    final db = await _db;
    final rows = await db.query(_savedItemsTable, orderBy: 'savedAt DESC');
    return rows.map((row) => row['listingId'] as String).toSet();
  }

  Future<void> setSaved(String listingId, bool saved) async {
    final db = await _db;
    if (saved) {
      await db.insert(_savedItemsTable, {
        'listingId': listingId,
        'savedAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return;
    }
    await db.delete(
      _savedItemsTable,
      where: 'listingId = ?',
      whereArgs: [listingId],
    );
  }

  Future<List<OrderRecord>> loadOrders() async {
    final db = await _db;
    final rows = await db.query(_ordersTable, orderBy: 'createdAt DESC');
    return rows.map(OrderRecord.fromMap).toList();
  }

  Future<void> addOrder(OrderRecord order) async {
    final db = await _db;
    await db.insert(
      _ordersTable,
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Set<String>> loadFollowedSellers() async {
    final db = await _db;
    final rows = await db.query(_sellerFollowsTable);
    return rows.map((row) => row['seller'] as String).toSet();
  }

  Future<void> setFollowing(String seller, bool following) async {
    final db = await _db;
    if (following) {
      await db.insert(_sellerFollowsTable, {
        'seller': seller,
        'followedAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return;
    }
    await db.delete(
      _sellerFollowsTable,
      where: 'seller = ?',
      whereArgs: [seller],
    );
  }

  Future<List<ChatMessage>> loadChatMessages() async {
    final db = await _db;
    final rows = await db.query(_chatMessagesTable, orderBy: 'createdAt ASC');
    return rows.map(ChatMessage.fromMap).toList();
  }

  Future<void> addChatMessage(ChatMessage message) async {
    final db = await _db;
    await db.insert(
      _chatMessagesTable,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatConversationState>> loadChatConversationStates() async {
    final db = await _db;
    final rows = await db.query(_chatConversationStatesTable);
    return rows.map(ChatConversationState.fromMap).toList();
  }

  Future<void> saveChatConversationState(ChatConversationState state) async {
    final db = await _db;
    await db.insert(
      _chatConversationStatesTable,
      state.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Set<String>> loadCommunityPostLikeIds() async {
    final db = await _db;
    final rows = await db.query(_communityPostLikesTable);
    return rows.map((row) => row['postId'] as String).toSet();
  }

  Future<void> setCommunityPostLiked(String postId, bool liked) async {
    final db = await _db;
    if (liked) {
      await db.insert(_communityPostLikesTable, {
        'postId': postId,
        'likedAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return;
    }
    await db.delete(
      _communityPostLikesTable,
      where: 'postId = ?',
      whereArgs: [postId],
    );
  }

  Future<List<CommunityReplyRecord>> loadCommunityReplies() async {
    final db = await _db;
    final rows = await db.query(
      _communityRepliesTable,
      orderBy: 'createdAt DESC',
    );
    return rows.map(CommunityReplyRecord.fromMap).toList();
  }

  Future<void> addCommunityReply(CommunityReplyRecord reply) async {
    final db = await _db;
    await db.insert(
      _communityRepliesTable,
      reply.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Set<String>> loadCommunityReplyLikeIds() async {
    final db = await _db;
    final rows = await db.query(_communityReplyLikesTable);
    return rows.map((row) => row['replyId'] as String).toSet();
  }

  Future<void> setCommunityReplyLiked(String replyId, bool liked) async {
    final db = await _db;
    if (liked) {
      await db.insert(_communityReplyLikesTable, {
        'replyId': replyId,
        'likedAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return;
    }
    await db.delete(
      _communityReplyLikesTable,
      where: 'replyId = ?',
      whereArgs: [replyId],
    );
  }
}
