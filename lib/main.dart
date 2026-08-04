body: postsLoading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : RefreshIndicator(
        onRefresh: loadPosts,
        child: ListView(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 25,
          ),
          children: [
            _stories(),
            const SizedBox(height: 15),
            _createBox(),
            const SizedBox(height: 10),

            if (posts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'এখনও কোনো post নেই',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ...posts.map(_postCard),
          ],
        ),
      ),
