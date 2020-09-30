import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/lemmy_api_client.dart';

import '../widgets/user_profile.dart';

/// Page showing posts, comments, and general info about a user.
class UserPage extends HookWidget {
  final int userId;
  final String instanceUrl;
  final Future<UserDetails> _userDetails;

  UserPage({@required this.userId, @required this.instanceUrl})
      : assert(userId != null),
        assert(instanceUrl != null),
        _userDetails = LemmyApi(instanceUrl).v1.getUserDetails(
            userId: userId, savedOnly: true, sort: SortType.active);

  UserPage.fromName({@required this.instanceUrl, @required String username})
      : assert(instanceUrl != null),
        assert(username != null),
        userId = null,
        _userDetails = LemmyApi(instanceUrl).v1.getUserDetails(
            username: username, savedOnly: true, sort: SortType.active);

  @override
  Widget build(BuildContext context) {
    final userDetailsSnap = useFuture(_userDetails);

    final body = () {
      if (userDetailsSnap.hasData) {
        return UserProfile.fromUserDetails(userDetailsSnap.data);
      } else if (userDetailsSnap.hasError) {
        return Center(child: Text('Could not find that user.'));
      } else {
        return Center(child: CircularProgressIndicator());
      }
    }();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        actions: [
          if (userDetailsSnap.hasData) ...[
            IconButton(
              icon: Icon(Icons.email),
              onPressed: () {}, // TODO: go to messaging page
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => Share.text('Share user',
                  userDetailsSnap.data.user.actorId, 'text/plain'),
            )
          ]
        ],
      ),
      body: body,
    );
  }
}
